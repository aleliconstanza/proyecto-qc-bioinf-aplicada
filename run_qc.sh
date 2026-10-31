#!/usr/bin/env bash
# run_qc.sh — QC y preprocesamiento de lecturas Illumina (versión 1: QC crudo)
# Uso: bash run_qc.sh [SRR]   (por defecto SRR11441020)
# Requiere: entorno qc-pareja1 activo y lecturas en data/raw/ (bash download.sh)
set -euo pipefail

SRR=${1:-SRR11441020}
RAW=data/raw
THREADS=4

mkdir -p results/fastqc_raw results/fastqc_trimmed results/multiqc data/trimmed logs

# 0. Comprobar que existen las lecturas submuestreadas
for R in 1 2; do
  if [[ ! -s "$RAW/${SRR}_sub_${R}.fastq.gz" ]]; then
    echo "Falta $RAW/${SRR}_sub_${R}.fastq.gz. Corre primero: bash download.sh" >&2
    exit 1
  fi
done

# 1. FastQC sobre las lecturas crudas (R1 y R2)
for R in 1 2; do
  echo "FastQC crudo R${R}..."
  fastqc -t "$THREADS" --outdir results/fastqc_raw "$RAW/${SRR}_sub_${R}.fastq.gz" \
    > logs/fastqc_raw_R${R}.log 2>&1
done

# 2. MultiQC: junta los dos reportes en uno
echo "MultiQC crudo..."
multiqc results/fastqc_raw -o results/multiqc -n raw -f > logs/multiqc_raw.log 2>&1

echo "Listo: results/multiqc/raw.html"
