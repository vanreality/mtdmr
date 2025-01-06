//
// GENERATE METILENE INPUT
//

// Merge methylation rate of samples to metilene input format matrix

include { MERGE_BEDGRAPHS } from '../../../modules/local/merge_bedgraphs/main.nf'

workflow GENERATE_METILENE_INPUT {
    take:
    ch_bedgraph    // ch_bedgraph: [ val(meta), path(bedgraph) ]
    
    main:
    // Group bedGraph files by tissue
    ch_grouped = ch_bedgraph
        .map { meta, bedgraph -> 
            [ meta.tissue, bedgraph ]
        }
        .groupTuple(by: 0)

    // ch_grouped.view { "ch_grouped: $it" }

    // Generate channel where each tissue is compared to all others combined
    ch_target_vs_background = ch_grouped
        .combine(ch_grouped)
        .filter { target, target_files, background, background_files -> 
            target != background 
        }
        .map { target, target_files, background, background_files ->
            def meta = [id: target]
            [meta, target_files, background_files]
        }
        .groupTuple(by: 0)
        .map { meta, target_files, background_files ->
            [meta, target_files[0], background_files.flatten()]
        }

    // ch_target_vs_background.view { "ch_target_vs_background: $it" }
    
    // Process each tissue to create metilene input matrix
    MERGE_BEDGRAPHS(ch_target_vs_background)
    
    emit:
    metilene_input_matrix = MERGE_BEDGRAPHS.out.matrix // channel: [ val(meta), path(matrix) ]
}