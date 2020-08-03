// Import generic module functions
include { initOptions; saveFiles } from './functions'

process FRIP_SCORE {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}/${options.publish_dir}${options.publish_by_id ? "/${meta.id}" : ''}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename, options, task.process.tokenize('_')[0].toLowerCase()) }

    conda (params.conda ? "${baseDir}/environment.yml" : null)

    input:
    tuple val(meta), path(bam), path(peak)
    val options

    output:
    tuple val(meta), path("*.txt"), emit: txt

    script:
    def ioptions = initOptions(options, task.process.tokenize('_')[0].toLowerCase())
    prefix = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    """
    READS_IN_PEAKS=\$(intersectBed -a $bam -b $peak $ioptions.args | awk -F '\t' '{sum += \$NF} END {print sum}')
    samtools flagstat $bam > ${bam}.flagstat
    grep 'mapped (' ${bam}.flagstat | awk -v a="\$READS_IN_PEAKS" -v OFS='\t' '{print "${prefix}", a/\$1}' > ${prefix}.FRiP.txt
    """
}
