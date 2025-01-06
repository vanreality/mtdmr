//
// METILENE CALL DMR
//

// Call differentially methylated regions (DMRs) using metilene

include { METILENE } from '../../../modules/local/metilene/main.nf'

workflow METILENE_CALL_DMR {
    take:
    ch_matrix // channel: [ val(meta), path(matrix) ]

    main:
    // Run the METILENE module
    METILENE(
        ch_matrix
    )

    emit:
    dmr      = METILENE.out.dmr
}