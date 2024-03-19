process SAMPLEAGGREGATION {
    tag "$meta.id"
    label 'process_low'

    container 'ghcr.io/schapirolabor/molkart-local:v0.0.4'

    input:
    tuple val(meta), path(csv_dir)

    output:
    tuple val(meta), path("*.csv")          , emit: all_csv
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    sampleaggregation.py \\
        --input $csv_dir \\
        --output "all_samples.csv"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sampleaggregation: \$(sampleaggregation.py --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch all_samples.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sampleaggregation: \$(sampleaggregation.py --version)
    END_VERSIONS
    """
}
