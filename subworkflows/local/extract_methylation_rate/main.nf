//
// METHYLDACKEL EXTRACT
//

// Extract methylation information from BAM files using Methyldackel.

include { GUNZIP } from '../../../modules/nf-core/gunzip/main.nf'
include { SAMTOOLS_FAIDX } from '../../../modules/nf-core/samtools/faidx/main.nf'
include { SAMTOOLS_INDEX } from '../../../modules/nf-core/samtools/index/main.nf'
include { METHYLDACKEL_EXTRACT } from '../../../modules/nf-core/methyldackel/extract/main.nf'

workflow EXTRACT_METHYLATION_RATE {
    take:
    bam
    fasta

    main:
    ch_fasta        = Channel.empty()
    ch_fasta_index  = Channel.empty()
    ch_bam          = Channel.empty()
    ch_bam_index    = Channel.empty()
    ch_versions     = Channel.empty()

    if (fasta.toString().endsWith('.gz')) {
        GUNZIP (
            [ [:], file(fasta, checkIfExists: true) ]
        )
        ch_fasta    = GUNZIP.out.gunzip
        ch_versions = ch_versions.mix(GUNZIP.out.versions)
    } else {
        ch_fasta    = Channel.value([[:], file(fasta, checkIfExists: true)])
    }

    SAMTOOLS_FAIDX(ch_fasta, [[:], []])
    ch_fasta_index = SAMTOOLS_FAIDX.out.fai
    ch_versions = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

    ch_bam = Channel.value([[:], file(bam, checkIfExists: true)])
    SAMTOOLS_INDEX(ch_bam)
    ch_bam_index = SAMTOOLS_INDEX.out.bai
    ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions)

    METHYLDACKEL_EXTRACT(
        ch_bam.join(ch_bam_index),
        ch_fasta,
        ch_fasta_index
    )

    bedgraph = METHYLDACKEL_EXTRACT.out.bedgraph
    ch_versions = ch_versions.mix(METHYLDACKEL_EXTRACT.out.versions)

    emit:
    bedgraph                   // [ ${bam.baseName}_CpG.bedGraph ]
    ch_versions                // [ versions.yml ]
}