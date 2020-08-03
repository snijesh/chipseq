// Import generic module functions
include { initOptions; saveFiles } from './functions'

// Has the run name been specified by the user?
// this has the bonus effect of catching both -name and --name
custom_runName = params.name
if (!(workflow.runName ==~ /[a-z]+_[a-z]+/)) {
    custom_runName = workflow.runName
}

process MULTIQC {
    label 'process_medium'
    publishDir "${params.outdir}/${options.publish_dir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename, options, task.process.toLowerCase()) }

    container "quay.io/biocontainers/multiqc:1.9--pyh9f0ad1d_0"
    //container "https://depot.galaxyproject.org/singularity/multiqc:1.9--pyh9f0ad1d_0"

    conda (params.conda ? "bioconda::multiqc=1.9" : null)

    input:
    path multiqc_config
    path mqc_custom_config
    path software_versions
    path workflow_summary

    path ('fastqc/*')
    path ('trimgalore/*')
    path ('trimgalore/fastqc/*')

    path ('alignment/library/*')
    path ('alignment/library/*')
    path ('alignment/library/*')

    path ('alignment/mergedLibrary/unfiltered/*')
    path ('alignment/mergedLibrary/unfiltered/*')
    path ('alignment/mergedLibrary/unfiltered/*')
    path ('alignment/mergedLibrary/unfiltered/picard_metrics/*')

    path ('alignment/mergedLibrary/filtered/*')
    path ('alignment/mergedLibrary/filtered/*')
    path ('alignment/mergedLibrary/filtered/*')
    path ('alignment/mergedLibrary/filtered/picard_metrics/*')

    path ('preseq/*')
    path ('deeptools/*')
    path ('deeptools/*')
    path ('phantompeakqualtools/*')
    path ('phantompeakqualtools/*')
    path ('phantompeakqualtools/*')
    path ('phantompeakqualtools/*')

    path ('macs2/peaks/*')
    path ('macs2/peaks/*')
    path ('macs2/annotation/*')

    path ('featurecounts/*')
    // path ('macs/consensus/*') from ch_macs_consensus_deseq_mqc.collect().ifEmpty([])

    val options

    output:
    path "*multiqc_report.html", emit: report
    path "*_data", emit: data

    script:
    def software = task.process.toLowerCase()
    def ioptions = initOptions(options, software)
    rtitle = custom_runName ? "--title \"$custom_runName\"" : ''
    rfilename = custom_runName ? "--filename " + custom_runName.replaceAll('\\W','_').replaceAll('_+','_') + "_multiqc_report" : ''
    custom_config_file = params.multiqc_config ? "--config $mqc_custom_config" : ''
    """
    multiqc -f $ioptions.args $rtitle $rfilename $custom_config_file .
    """
}
