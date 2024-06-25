# Rules for build required reference files
from scripts.common import (
    allocated
)


rule build_bwa_index:
    """Reference building step to create an BWA index for the reference genome.
    Parabricks requires a BWA-MEM/1.X index to be built 
    @Inputs:
        GRCh38 reference genome in fasta format.
    @Outputs:
        BWA-MEM index files.
    """
    input:
        ref  = config['references']['GENOME_FASTA'],
    output:
        lnk  = join(workpath, "refs", genome),
        idxs = expand(join(workpath, "refs", genome + "{ext}"), ext=bwa_index_extensions),
    params:
        prefix = join(workpath, "refs", genome),
        # Job submission parameters
        rname = "bwa_index",
        mem   = allocated("mem", "build_bwa_index", cluster),
        gres  = allocated("gres", "build_bwa_index", cluster),
        time  = allocated("time", "build_bwa_index", cluster),
        partition = allocated("partition", "build_bwa_index", cluster),
    message: "Bulding BWA-MEM Index for '{input.ref}'"
    threads: int(allocated("threads", "build_bwa_index", cluster))
    container: config['images']['bwa']
    shell: """
    # Symlink reference genome and 
    # its index to the workpath
    ln -sf \\
        {input.ref} \\
        {output.lnk}
    ln -sf \\
        {input.ref}.fai \\
        {output.lnk}.fai

    # Build BWA Index of reference genome
    bwa index \\
        -p {params.prefix} \\
        {input.ref}
    """