/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_mtdmr_pipeline'

include { EXTRACT_METHYLATION_RATE } from '../subworkflows/local/extract_methylation_rate/main.nf'
include { GENERATE_METILENE_INPUT }  from '../subworkflows/local/generate_metilene_input/main.nf'
include { METILENE_CALL_DMR }        from '../subworkflows/local/metilene_call_dmr/main.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow MTDMR {

    take:
    ch_samplesheet // channel: samplesheet read in from --input, with columns ['sample', 'tissue', 'bam']
    main:

    ch_versions = Channel.empty()

    // Extract methylation rate from bam files
    EXTRACT_METHYLATION_RATE(ch_samplesheet)
    ch_versions = ch_versions.mix(EXTRACT_METHYLATION_RATE.out.versions)

    // Merge methylation rate of samples to metilene input format matrix
    GENERATE_METILENE_INPUT(
        EXTRACT_METHYLATION_RATE.out.bedgraph
    )
    ch_versions = ch_versions.mix(GENERATE_METILENE_INPUT.out.versions)

    // Run metilene to call DMRs
    METILENE_CALL_DMR(
        GENERATE_METILENE_INPUT.out.metilene_input_matrix
    )
    ch_versions = ch_versions.mix(METILENE_CALL_DMR.out.versions)

    // TODO: Annotate DMRs


    // Collate and save software versions
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'mtdmr_software_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    emit:
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
