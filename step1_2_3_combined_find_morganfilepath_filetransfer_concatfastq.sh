#!/usr/bin/bash

FLOWCELL_IDS="CBTWLANXX"
LANE_IDS="s8"
SEARCH_PAT="*SL*.fastq.gz"

OUTPUT_DIR=$(pwd)/"sarcoma_tp53_analysis"
OUTPUT_FILE="${OUTPUT_DIR}/sarcoma_tp53_file.txt"

if [[ ! -d ${OUTPUT_DIR} ]];then mkdir -p ${OUTPUT_DIR}; fi
if [[ -f ${OUTPUT_FILE} ]];then rm ${OUTPUT_FILE}; fi

# Search all fastqs for requested flowcell id and lanes:
for flow_id in ${FLOWCELL_IDS};do
    for lane_id in ${LANE_IDS};do
        printf "Searching files for flowcell ${flow_id} and ${lane_id}... \n\n"; 
        find /gpfs/gpfs1/myerslab/data/Flowcells/${flow_id}/${lane_id} -type f -name ${SEARCH_PAT} >> ${OUTPUT_FILE} 
    done
done

# Make new SL dir for each unique SL# and generate sym link for all assoc-files
SL_ARRAY=()
for each in $(cat ${OUTPUT_FILE}); do 
    dir=$(basename $each | cut -f6 -d "_" | cut -f1 -d "."); 
    if [[ ! -d ${OUTPUT_DIR}/$dir ]]; then 
        mkdir ${OUTPUT_DIR}/$dir; 
    fi; 

    if [[ ! -f ${OUTPUT_DIR}/$dir/each ]]; then 
        ln -fs $each ${OUTPUT_DIR}/$dir; 
    fi; 
    printf "Sym links generated for : $dir\n"; 
    
    # Generate SL array for file concat or job run later:
    if [[ ! ${SL_ARRAY[@]} =~ ${dir} ]];then 
        SL_ARRAY=(${SL_ARRAY[@]} ${dir})
    fi
done
SORTED_SL_ARRAY=($(echo ${SL_ARRAY[@]}| tr " " "\n" | sort -n))
echo -e "\nUpdated SL_array: ${SL_ARRAY[@]}"
echo -e "\nSorted SL_array: ${SORTED_SL_ARRAY[@]}"
echo -e "\nTotal SL_array num: ${#SL_ARRAY[@]} \n"

# Copying config file (for pe: config.txt; else for se : se_config.txt) to same dir
# as needed for later part of scripts and rnaseq analysis:

if [[ ! -f ${OUTPUT_DIR}/config.txt ]];then
    cp $(pwd)/config_hg19.txt ${OUTPUT_DIR}/config.txt;
fi 

# Concatenate the fastq files and place to same dir:

export LIB_LIST="${SL_ARRAY[@]}" # unsorted SL array
export LIB_LIST="${SORTED_SL_ARRAY[@]}" # sorted SL array
export INPUT_DIR=${OUTPUT_DIR}

for LIB in ${LIB_LIST}; do
	echo -e "\nProcessing $LIB" 
    echo -e "\nPlacing concat file to : ${OUTPUT_DIR}/${LIB}"

	if [[ -f $OUTPUT_DIR/$LIB/${LIB}_R1_fastq.gz ]]; then
		rm $OUTPUT_DIR/$LIB/${LIB}_R1_fastq.gz
	fi
	
	if [[ -f $OUTPUT_DIR/$LIB/${LIB}_R2_fastq.gz ]]; then
		rm $OUTPUT_DIR/$LIB/${LIB}_R2_fastq.gz
	fi

    mkdir -p $OUTPUT_DIR/log_files
    LOG_DIR=$OUTPUT_DIR/log_files

	bsub -We 10:00 -J "RNA seq fastq concat for $LIB" -o $LOG_DIR/${LIB}_rnaseq_submission_1.log "cat $INPUT_DIR/$LIB/*_1_GSL* >> $OUTPUT_DIR/$LIB/${LIB}_R1.fastq.gz"
	bsub -We 10:00 -J "RNA seq fastq concat for $LIB" -o $LOG_DIR/${LIB}_rnaseq_submission_2.log "cat $INPUT_DIR/$LIB/*_2_GSL* >> $OUTPUT_DIR/$LIB/${LIB}_R2.fastq.gz"

done

# Generate file containing fastqfile_paths for RNAseq script run - which looks for config file and filepaths in given dir:
export FILE_NAME="samples.list"
export LIB_LIST="${SORTED_SL_ARRAY[@]}" # sorted SL array

if [[ -f $OUTPUT_DIR/${FILE_NAME} ]];then
    rm $OUTPUT_DIR/${FILE_NAME}
fi

echo -e "SampleID\tFASTQ_1\tFASTQ_2" >> $OUTPUT_DIR/${FILE_NAME}
for LIB in ${LIB_LIST};do
    # READ_1=$(readlink -f $OUTPUT_DIR/$LIB/*R1.fastq*)
    # READ_2=$(readlink -f $OUTPUT_DIR/$LIB/*R2.fastq*)
    READ_1="$OUTPUT_DIR/$LIB/${LIB}_R1.fastq.gz"
    READ_2="$OUTPUT_DIR/$LIB/${LIB}_R2.fastq.gz"
    SAMPLE_ID=${LIB}
    echo $READ_1
    echo $READ_2
    echo -e "${SAMPLE_ID}\t${READ_1}\t${READ_2}" >> $OUTPUT_DIR/${FILE_NAME}
done

# Checking filesze for sanity check after concatenation; but being in same outputdir containing SLs:
# for each in $(ls -d SL*| xargs); do du --max-depth 1 -lah $(readlink -f ${each}/*.gz); done



