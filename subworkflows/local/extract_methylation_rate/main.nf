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
    ch_samplesheet

    main:
    ch_fasta        = Channel.empty()
    ch_fasta_index  = Channel.empty()
    ch_bam          = Channel.empty()
    ch_bam_index    = Channel.empty()
    ch_versions     = Channel.empty()

    // ch_samplesheet.view { it -> "Current samples: ${it}" }

    fasta = file(params.reference)

    if (fasta.toString().endsWith('.gz')) {
        GUNZIP ([[:], fasta])
        ch_fasta    = GUNZIP.out.gunzip
        ch_versions = ch_versions.mix(GUNZIP.out.versions)
    } else {
        ch_fasta    = Channel.value([[:], fasta])
    }

    SAMTOOLS_FAIDX(ch_fasta, [[:], []])
    ch_fasta_index = SAMTOOLS_FAIDX.out.fai
    ch_versions = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

    SAMTOOLS_INDEX(ch_samplesheet)
    ch_bam_index = SAMTOOLS_INDEX.out.bai
    ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions)

    ch_combined = ch_samplesheet
        .join(ch_bam_index)
        .map { meta, bam, bai ->
            tuple(meta, bam, bai)
        }
    ch_fasta = ch_fasta
        .map {meta, fasta -> fasta}
    ch_fasta_index = ch_fasta_index
        .map {meta, fasta_index -> fasta_index}

    METHYLDACKEL_EXTRACT(
        ch_combined,
        ch_fasta,
        ch_fasta_index
    )

    bedgraph = METHYLDACKEL_EXTRACT.out.bedgraph
    ch_versions = ch_versions.mix(METHYLDACKEL_EXTRACT.out.versions)

    emit:
    bedgraph                   // [ ${bam.baseName}_CpG.bedGraph ]
    ch_versions                // [ versions.yml ]
}