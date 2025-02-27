
process TRIMMOMATIC {

    container 'staphb/trimmomatic'
    tag "trimming ${sample_id}"
    publishDir "${params.outdir}", mode: "copy"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}*fastq")

    script:
    """
    
    # Determine the number of input reads
    if [ -f "${reads[0]}" ] && [ -f "${reads[1]}" ]; then
        # Paired-End mode
        trimmomatic PE -threads 4 \
            ${reads[0]} ${reads[1]} \
            ${sample_id}_R1_paired.fastq ${sample_id}_R1_unpaired.fastq \
            ${sample_id}_R2_paired.fastq ${sample_id}_R2_unpaired.fastq \
            ILLUMINACLIP:/usr/share/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 \
            SLIDINGWINDOW:4:20 MINLEN:50
    elif [ -f "${reads[0]}" ]; then
        # Single-End mode
        trimmomatic SE -threads 4 \
            ${reads[0]} ${sample_id}_trimmed.fastq \
            ILLUMINACLIP:/usr/share/trimmomatic/adapters/TruSeq3-SE.fa:2:30:10 \
            SLIDINGWINDOW:4:20 MINLEN:50
    else
        echo "Error: No valid read files found for sample ${sample_id}"
        exit 1
    fi

    echo "Trimmomatic processing complete for ${sample_id}"
    """
}