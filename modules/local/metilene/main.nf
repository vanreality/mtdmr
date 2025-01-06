process METILENE {
    tag "$meta.id"
    label 'process_high'
    
    input:
    tuple val(meta), path(input_matrix)

    output:
    tuple val(meta), path("*.tsv") , emit: dmr
    path  "versions.yml"           , emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    mkdir -p ${group_dir}
    metilene -a target -b background -t ${task.cpus} -m 3 ${input_matrix} | \\
    sort -V -k1,1 -k2,2n > ${prefix}_DMRs.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metilene: 0.2-8
    END_VERSIONS
    """
}