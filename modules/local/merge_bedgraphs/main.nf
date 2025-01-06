process MERGE_BEDGRAPHS {
    tag "$meta.id"
    label 'process_high'

    input:
    tuple val(meta), path(target_files), path(background_files)

    output:
    tuple val(meta), path("*.tsv") , emit: matrix
    path  "versions.yml"           , emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python ${projectDir}/modules/local/merge_bedgraphs/merge_bedgraphs.py \\
        --target_files ${target_files.join(' ')} \\
        --background_files ${background_files.join(' ')} \\
        --output ${prefix}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | cut -f2 -d' ')
    END_VERSIONS
    """
}