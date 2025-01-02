//
// METHYLDACKEL EXTRACT
//

// Extract methylation information from BAM files using Methyldackel.

include { METHYLDACKEL_EXTRACT } from '../../modules/nf-core/methyldackel/extract/main.nf'

workflow EXTRACT_METHYLATION_RATE {
    take:
    bam
    reference

    main:
    versions = Channel.empty()

    METHYLDACKEL_EXTRACT(
        bam: bam,
        bai: bam + '.bai',
        fasta: reference,
        fai: reference + '.fai'
    )

    bedgraph = METHYLDACKEL_EXTRACT.out.bedgraph

    versions = versions.mix(METHYLDACKEL_EXTRACT.out.versions)

    emit:
    bedgraph                // [ bedgraph ]

    versions                // [ versions.yml ]
}