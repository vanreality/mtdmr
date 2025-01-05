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
        .map { target -> 
            def (target_tissue, target_bedgraphs) = target
            def background_bedgraphs = ch_grouped
                .filter { it[0] != target_tissue }
                .collect { it[1] }
                .flatten()
            def meta = [id: target_tissue]
            
            return [meta, target_bedgraphs, background_bedgraphs]
        }

    ch_target_vs_background.view { "ch_target_vs_background: $it" }
    
    // Process each tissue to create metilene input matrix
    MERGE_BEDGRAPHS(ch_target_vs_background)
    
    emit:
    metilene_input_matrix = MERGE_BEDGRAPHS.out.matrix // channel: [ val(meta), path(matrix) ]
}