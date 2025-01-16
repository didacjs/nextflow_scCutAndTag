#!/usr/bin/env nextflow


/*
 * Pipeline parameters
 */

// Primary input
params.sample    = "S1"
params.reads_bam = "/home/didac/Work/Misc/CutAndTag/Data/S2/CellRanger/outs/possorted_bam.bam"
params.outdir    = "results"
params.threads   = 4

// Parameters
// conda.enabled = true


/*
 * Generate BAM index file
 */
process SAMTOOLS_INDEX {

	conda "CT.yaml"

    publishDir params.outdir, mode: 'symlink'

    input:
        path input_bam

    output:
        tuple path(input_bam), path("${input_bam}.bai")

    script:
    """
    samtools index '$input_bam'
    """
}

/*
 * deepTools bamCoverage
 */
process DEEPTOOLS_BAMCOVERAGE {

	conda "CT.yaml"

    publishDir params.outdir , mode: 'symlink'

    input:
		val  sample
		tuple path(input_bam), path(input_bam_index)

    output:
        path "${sample}_allReads.bw" , emit: bigwig

    script:
    """
	bamCoverage -b "${input_bam}" -o "${sample}_allReads.bw" -p "${params.threads}" --minMappingQuality 5  --binSize 100 --centerReads --smoothLength 500 --normalizeUsing RPKM --ignoreDuplicates

    """
}

/*
 * MACS
 */
process MACS2_CALLPEAK {

	conda "CT.yaml"

    publishDir params.outdir, mode: 'symlink'

    input:
		val  sample
        tuple path(input_bam), path(input_bam_index)

    output:
        path "${sample}_peaks.narrowPeak" , emit: macsNarrow
		path "${sample}_peaks.broadPeak" , emit: macsBroad

    script:
    """
    macs2 callpeak -t "${input_bam}" -g mm -f BAMPE -n "${sample}" --outdir "${sample}_peaks.narrowPeak" -q 0.05 -B --SPMR --keep-dup=1
	macs2 callpeak -t "${input_bam}" -g mm -f BAMPE -n "${sample}" --outdir "${sample}_peaks.broadPeak" -q 0.05 -B --SPMR --keep-dup=1 --broad-cutoff=0.1 --broad
    """
}

workflow {

    // Create input channel (single file via CLI parameter)
    sample_ch = Channel.of(params.sample)
	bam_ch = Channel.fromPath(params.reads_bam)

    // Create index file for input BAM file
	SAMTOOLS_INDEX(bam_ch)

    DEEPTOOLS_BAMCOVERAGE(sample_ch, SAMTOOLS_INDEX.out)
	MACS2_CALLPEAK(sample_ch, SAMTOOLS_INDEX.out)
}