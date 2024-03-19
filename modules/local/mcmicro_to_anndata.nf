process SAMPLEAGGREGATION {
    tag "$meta.id"
    label 'process_low'

    container 'ghcr.io/schapirolabor/molkart-local:v0.0.4'

    input:
    tuple val(meta), path(csv_dir)

    output:
    tuple val(meta), path("*.h5ad")  , emit: anndata
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    """
    mcmicro_to_anndata.py \\
        --input_dir $csv_dir \\
        --output_dir "adata.h5ad"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mcmicro_to_anndata: \$(mcmicro_to_anndata.py --version)
    END_VERSIONS
    """

    stub:

    """
    touch adata.h5ad

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mcmicro_to_anndata: \$(mcmicro_to_anndata.py --version)
    END_VERSIONS
    """
}
