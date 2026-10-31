#!/usr/bin/env bash
# download.sh — descarga y submuestrea las lecturas del run SRA
# Uso: bash download.sh [SRR]   (por defecto SRR11441020)
set -euo pipefail

SRR=${1:-SRR11441020}
N=300000     # pares a conservar en el submuestreo
SEED=11      # semilla: la misma en R1 y R2

mkdir -p data/raw logs

# 1. Descargar el archivo .sra (se puede reanudar si se corta)
prefetch "$SRR" > logs/prefetch.log 2>&1

# 2. Convertir a FASTQ, separando R1 y R2
fasterq-dump --split-files --threads 4 "$SRR" -O data/raw/ > logs/fasterq-dump.log 2>&1

# 3. Comprimir
gzip -f data/raw/"${SRR}"_1.fastq data/raw/"${SRR}"_2.fastq

# 4. Submuestrear R1 y R2 con la misma semilla (mantiene los pares)
for R in 1 2; do
  seqkit sample -s "$SEED" -n "$N" data/raw/"${SRR}"_"${R}".fastq.gz \
    -o data/raw/"${SRR}"_sub_"${R}".fastq.gz 2>> logs/seqkit_sample.log
done

# 5. Estadísticas de los archivos completos y submuestreados
seqkit stats -a -T data/raw/"${SRR}"_*.fastq.gz > logs/seqkit_raw.tsv
cat logs/seqkit_raw.tsv

# 6. Comprobar que R1 y R2 submuestreados siguen pareados (debe imprimir 0)
paste <(zcat data/raw/"${SRR}"_sub_1.fastq.gz | awk 'NR%4==1{print $1}') \
      <(zcat data/raw/"${SRR}"_sub_2.fastq.gz | awk 'NR%4==1{print $1}') \
  | awk '$1!=$2' | wc -l | tee logs/pares_desincronizados.txt

