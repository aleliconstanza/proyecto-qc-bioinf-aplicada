#!/usr/bin/env bash
# run_qc.sh — QC y preprocesamiento de lecturas Illumina
# Reproduce el recorte de Belmonte et al. (2020) (Sickle v1.33) traducido a fastp.
# Uso: bash run_qc.sh [SRR]   (por defecto SRR11441020)
# Requiere: entorno qc-pareja1 activo y lecturas en data/raw/ (bash download.sh)
set -euo pipefail

SRR=${1:-SRR11441020}
RAW=data/raw
TRIM=data/trimmed
THREADS=4

mkdir -p results/fastqc_raw results/fastqc_trimmed results/multiqc "$TRIM" logs

# 0. Comprobar que existen las lecturas submuestreadas
for R in 1 2; do
  if [[ ! -s "$RAW/${SRR}_sub_${R}.fastq.gz" ]]; then
    echo "Falta $RAW/${SRR}_sub_${R}.fastq.gz. Corre primero: bash download.sh" >&2
    exit 1
  fi
done

# 1. FastQC sobre las lecturas crudas (R1 y R2)
for R in 1 2; do
  echo "[1/6] FastQC crudo R${R}..."
  fastqc -t "$THREADS" --outdir results/fastqc_raw "$RAW/${SRR}_sub_${R}.fastq.gz" \
    > logs/fastqc_raw_R${R}.log 2>&1
done

# 2. MultiQC sobre las lecturas crudas
echo "[2/6] MultiQC crudo..."
multiqc results/fastqc_raw -o results/multiqc -n raw -f > logs/multiqc_raw.log 2>&1

# 3. Recorte con fastp (equivalente a Sickle con parámetros por defecto)
#    --cut_front / --cut_right : ventana deslizante en 5' y 3' (como Sickle)
#    --cut_window_size 15      : 0,1 x 150 pb (ventana de Sickle)
#    --cut_mean_quality 20     : umbral de calidad (decisión propia, Q20)
#    --length_required 20      : largo mínimo (decisión propia)
#    -A / -G / -Q              : sin adaptadores, sin poly-G, sin filtro global (Sickle no los hace)
echo "[3/6] fastp..."
fastp \
  -i "$RAW/${SRR}_sub_1.fastq.gz" -I "$RAW/${SRR}_sub_2.fastq.gz" \
  -o "$TRIM/${SRR}_trim_1.fastq.gz" -O "$TRIM/${SRR}_trim_2.fastq.gz" \
  --cut_front --cut_right --cut_window_size 15 --cut_mean_quality 20 \
  --length_required 20 -A -G -Q -w "$THREADS" \
  --html results/fastp.html --json results/fastp.json \
  > logs/fastp.log 2>&1

# 4. FastQC sobre las lecturas recortadas
for R in 1 2; do
  echo "[4/6] FastQC recortado R${R}..."
  fastqc -t "$THREADS" --outdir results/fastqc_trimmed "$TRIM/${SRR}_trim_${R}.fastq.gz" \
    > logs/fastqc_trimmed_R${R}.log 2>&1
done

# 5. MultiQC sobre las lecturas recortadas (incluye el reporte de fastp)
echo "[5/6] MultiQC recortado..."
multiqc results/fastqc_trimmed results/fastp.json -o results/multiqc -n trimmed -f \
  > logs/multiqc_trimmed.log 2>&1

# 6. Tabla antes/después
echo "[6/6] Tabla antes/después:"
seqkit stats -a -T \
  "$RAW/${SRR}_sub_1.fastq.gz" "$RAW/${SRR}_sub_2.fastq.gz" \
  "$TRIM/${SRR}_trim_1.fastq.gz" "$TRIM/${SRR}_trim_2.fastq.gz" \
  > logs/seqkit_antes_despues.tsv

awk -F'\t' '
  NR==1 { for (i=1; i<=NF; i++) col[$i]=i
          print "archivo\tlecturas\t%_retenido\tlargo_promedio\t%_Q30"; next }
  { n=$col["num_seqs"]
    if (NR==2) base1=n
    if (NR==3) base2=n
    base = (NR==2 || NR==4) ? base1 : base2
    printf "%s\t%s\t%.2f\t%s\t%s\n", $1, n, 100*n/base, $col["avg_len"], $col["Q30(%)"] }
' logs/seqkit_antes_despues.tsv | tee logs/tabla_antes_despues.tsv

echo "Listo. Reportes: results/multiqc/raw.html, results/multiqc/trimmed.html, results/fastp.html"
