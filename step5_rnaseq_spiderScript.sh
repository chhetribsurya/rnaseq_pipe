#!/bin/bash

# OUTPUT_DIR=$(pwd)/"podocyte_rnaseq_analysis"
NEW_OUTPUT_DIR=$(pwd)/"sarcoma_tp53_analysis/rnaseq_outputs"
SPIDER_SCRIPT="/gpfs/gpfs1/myerslab/reference/genomes/rnaseq_pipeline/aRNAPipe1.1/spider.py"

### For the output and html files with spider script:
python $SPIDER_SCRIPT -p ${NEW_OUTPUT_DIR} 
