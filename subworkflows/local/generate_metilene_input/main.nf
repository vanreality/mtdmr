//
// GENERATE METILENE INPUT
//

// Merge methylation rate of samples to metilene input format matrix

include { MERGE_BEDGRAPHS } from '../../modules/local/merge_bedgraphs/main.nf'

workflow GENERATE_METILENE_INPUT {
    take:
    ch_bedgraph    // ch_bedgraph: [ val(meta), path(bedgraph) ]
    
    main:
    // Group bedGraph files by tissue
    ch_grouped = ch_bedgraph
        .map { meta, bedgraph -> 
            [ tissue: meta.tissue, sample: meta.id, bedgraph: bedgraph ]
        }
        .groupTuple(by: 0)

    // Generate channel where each tissue is compared to all others combined
    ch_target_vs_background = ch_grouped
        .flatMap { target_tissue, target_bedgraphs ->
            def background_bedgraphs = ch_grouped
                .filter { tissue, samples -> tissue != target_tissue }
                .map { tissue, samples -> samples }  // Get the samples for other tissues
                .flatten()  // Merge all remaining samples into one list
            def meta = [ id: target_tissue]
            return [ [meta, target_bedgraphs, background_bedgraphs] ]  // Return formatted tuple
        }
    
    // Process each tissue to create metilene input matrix
    MERGE_BEDGRAPHS(ch_target_vs_background)
    
    emit:
    metilene_input_matrix = MERGE_BEDGRAPHS.out.matrix // channel: [ val(meta), path(matrix) ]
}