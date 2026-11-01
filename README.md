# QC y preprocesamiento de lecturas Illumina: SRR11441020

Reproduce el preprocesamiento de Belmonte et al. (2020), E. coli UMB9246
(MRA 9:e00437-20): QC con FastQC/MultiQC, recorte con fastp (traducción de
Sickle v1.33) y QC posterior al recorte. Análisis sobre 300.000 pares
submuestreados (seqkit sample -s 11).

## 1. Clonar y crear el entorno

    git clone https://github.com/aleliconstanza/proyecto-qc-bioinf-aplicada.git
    cd proyecto-qc-bioinf-aplicada
    mamba env create -f environment.yml
    conda activate qc-pareja1

## 2. Obtener los datos (no están en el repositorio)

Descargar los dos archivos de https://drive.google.com/drive/folders/1K9x9yVIT7NqfTcqn6dgbKpv5JTbv26AG
y copiarlos a data/raw/. Verificar con: md5sum data/raw/SRR11441020_sub_*.fastq.gz
(comparar con logs/md5_sub.txt). Alternativa: bash download.sh (desde SRA, 10-30 min).

## 3. Ejecutar (desde la raíz del repositorio)

    bash run_qc.sh

Tarda unos 5 minutos.

## 4. Resultados

- results/multiqc/raw.html y trimmed.html: QC antes y después del recorte
- results/fastp.html: reporte de fastp
- logs/tabla_antes_despues.tsv: lecturas, % retenido, largo promedio y % Q30
- Resultado esperado: 298.800 pares retenidos (99,60 %)
