#!/bin/bash

# OUTPUT_DIR="/gpfs/gpfs1/home/schhetri/for_jeremy/rat_time_point_rnaseq_analysis" #set newoutput_dir instead of dirname:rat_time_point_rnaseq_analysis
OUTPUT_DIR=$(pwd)/"sarcoma_tp53_analysis"
NEW_OUTPUT_DIR=$(pwd)/"sarcoma_tp53_analysis/rnaseq_outputs"
PYTHON_SCRIPT="/gpfs/gpfs1/myerslab/reference/genomes/rnaseq_pipeline/aRNAPipe1.1/aRNApipe.py"

CONFIG_FILE="${OUTPUT_DIR}/config.txt" #set the config file
FASTQ_FILE_PATH="${OUTPUT_DIR}/samples.list" #set the fastq file path for all the samples

### Sets the skeleton and the base folder for all the output files from aRNA_pipe:
python $PYTHON_SCRIPT -m 'skeleton' -p ${NEW_OUTPUT_DIR}

### Provides the list of genome builds that are availabe:
echo -e "\nHere are the genome builds available........."
cd $OUTPUT_DIR
python $PYTHON_SCRIPT -m genomes

### Copy the config file, necessary for the aRNA_pipe, to the newly created directory:
echo -e "\nCopied config and samples_file_path list to new output dir....\n"
cp ${CONFIG_FILE} ${NEW_OUTPUT_DIR}/config.txt
cp ${FASTQ_FILE_PATH} ${NEW_OUTPUT_DIR}/samples.list

### Now, running the aRNA_pipe for the RNA_seq analysis:
echo -e "\nRunning the aRNA-pipe for RNA_seq analysis......"
python $PYTHON_SCRIPT -m 'new' -p ${NEW_OUTPUT_DIR}

### For the output and html files with spider script:
#python /gpfs/gpfs1/myerslab/reference/genomes/rnaseq_pipeline/aRNAPipe1.1/spider.py -p $OUTPUT_DIR 
