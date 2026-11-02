# QC y preprocesamiento de lecturas Illumina: SRR11441020

Este proyecto reproduce el control de calidad y preprocesamiento de las lecturas de *E. coli* UMB9246 (Belmonte et al., 2020), mediante FastQC, MultiQC y fastp. Se analizan 300.000 pares de lecturas Illumina paired-end (R1/R2), seleccionados con semilla 11.

## 1. Preparar el entorno

Clonar el repositorio:
```bash
git clone https://github.com/aleliconstanza/proyecto-qc-bioinf-aplicada.git
cd proyecto-qc-bioinf-aplicada
```

Crear y activar el entorno:
```bash
conda env create -f environment.yml
conda activate qc-pareja1
```

## 2. Obtener los datos

Los FASTQ no están incluidos en el repositorio. Descargarlos desde [Google Drive](https://drive.google.com/drive/folders/1K9x9yVIT7NqfTcqn6dgbKpv5JTbv26AG) y copiarlos a `data/raw/`:
- `SRR11441020_sub_1.fastq.gz` (R1).
- `SRR11441020_sub_2.fastq.gz` (R2).

Alternativamente, ejecutar `bash download.sh` para descargarlos desde NCBI SRA y generar el submuestreo (10–30 min).

## 3. Ejecutar el análisis

Desde la raíz del repositorio, con el entorno activado:
```bash
bash run_qc.sh
```
El procesamiento tarda aproximadamente 5 minutos, según el equipo.

## 4. Resultados

Se generan:
- `results/multiqc/raw.html` y `trimmed.html`: informes de calidad antes y después del recorte.
- `results/fastp.html`: informe del recorte.
- `logs/tabla_antes_despues.tsv`: comparación de lecturas, retención, longitud promedio y porcentaje Q30.
Los FASTQ procesados se guardan en `data/trimmed/`. Resultado esperado: 298.800 pares retenidos (99,60 %).
