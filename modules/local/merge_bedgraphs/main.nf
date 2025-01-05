process MERGE_BEDGRAPHS {
    tag "$meta.id"
    label 'process_high'

    input:
    tuple val(meta), path(target_files), path(background_files)

    output:
    path "${meta.id}.tsv", emit: matrix

    script:
    """
    python merge_bedgraphs.py \\
        --target_files ${target_files.join(' ')} \\
        --background_files ${background_files.join(' ')} \\
        --output ${meta.id}.tsv
    """
}