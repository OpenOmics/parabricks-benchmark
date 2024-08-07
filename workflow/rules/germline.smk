# Rules for benchmarking Parabricks GATK Germline pipeline
# with different hardware configurations and job allocations
from scripts.common import (
    allocated
)


# Rules utilizing a single A100 GPU
rule parabricks_gatk_germline_1gpu_normal_memory:
    """Benchmarking Parabricks GATK Germline pipeline with 1 GPU and an normal allotment
    of main memory. NOTE: The limit memory option needs to be toned down to allow for 
    sufficent system memory to be available for the GPU. Internal testing has shown that
    parabricks germline pipeline tends to use more than the allocated memory (even with
    the --memory-limit option).
    @Inputs:
        GIAB Sample fastq file (scatter-per-sample).
    @Outputs:
        BAM file,
        VCF file,
        Recal table
    """
    input:
        idxs = expand(join(workpath, "refs", genome + "{ext}"), ext=bwa_index_extensions),
        lnk  = join(workpath, "refs", genome),
        r1   = join(workpath,"{name}.R1.fastq.gz"),
        r2   = join(workpath,"{name}.R2.fastq.gz"),
    output:
        bam   = join(workpath, "gatk_germline", "1gpu_normal_memory", "{sample}", "{name}.bam"),
        vcf   = join(workpath, "gatk_germline", "1gpu_normal_memory", "{sample}", "{name}.vcf"),
        recal = join(workpath, "gatk_germline", "1gpu_normal_memory", "{sample}", "{name}.recal"),
    params:
        # Rule specific parameters
        sample = "{name}",
        # Job submission parameters
        rname = "pb_germline_1gpu_normal_memory",
        mem   = allocated("mem", "1-gpu_normal-memory", cluster),
        gres  = allocated("gres", "1-gpu_normal-memory", cluster),
        time  = allocated("time", "1-gpu_normal-memory", cluster),
        partition = allocated("partition", "1-gpu_normal-memory", cluster),
        # Singularity options
        bindpaths = ','.join(bindpaths),
        tmpdir    = tmpdir,
        sif       = config['images']['parabricks'],
        # Parabricks options
        RUNNING_MEMORY_GB = int(
            int(allocated("mem", "1-gpu_normal-memory", cluster).lower().rstrip("g")) / 2
        ),
        KNOWN_INDELS_1 = config['references']['GATK_KNOWN_INDELS'],
        KNOWN_INDELS_2 = config['references']['OTHER_KNOWN_INDELS'],
    threads: int(allocated("threads", "1-gpu_normal-memory", cluster))
    shell: """
    # Run Parabricks germline pipeline with
    # default acceleration options
    singularity exec \\
        -c \\
        --nv  \\
        -B {params.bindpaths},{params.tmpdir}:/tmp \\
        {params.sif} \\
             pbrun germline \\
                --ref {input.lnk} \\
                --in-fq {input.r1} {input.r1} "@RG\\tID:{params.sample}\\tSM:{params.sample}\\tPL:illumina\\tLB:{params.sample}\\tPU:{params.sample}\\tCN:ncbr\\tDS:wgs" \\
                --knownSites {params.KNOWN_INDELS_1} \\
                --knownSites {params.KNOWN_INDELS_2} \\
                --out-bam {output.bam} \\
                --out-variants {output.vcf} \\
                --out-recal-file {output.recal} \\
                --bwa-options="-M" \\
                --monitor-usage \\
                --memory-limit {params.RUNNING_MEMORY_GB} \\
                --tmp-dir /tmp
    """


rule parabricks_gatk_germline_1gpu_normal_memory_optimized:
    """Benchmarking Parabricks GATK Germline pipeline with 1 GPU and an normal allotment
    of main memory using the recommended set of option to gain the best performance. 
    NOTE: The limit memory option needs to be toned down to allow for sufficent system
    memory to be available for the GPU. Internal testing has shown that parabricks
    germline pipeline tends to use more than the allocated memory (even with the 
    --memory-limit option).
    @Inputs:
        GIAB Sample fastq file (scatter-per-sample).
    @Outputs:
        BAM file,
        VCF file,
        Recal table
    """
    input:
        idxs = expand(join(workpath, "refs", genome + "{ext}"), ext=bwa_index_extensions),
        lnk  = join(workpath, "refs", genome),
        r1   = join(workpath,"{name}.R1.fastq.gz"),
        r2   = join(workpath,"{name}.R2.fastq.gz"),
    output:
        bam   = join(workpath, "gatk_germline", "1gpu_normal_memory_optimized", "{sample}", "{name}.bam"),
        # Gzipped VCF cannot be created with --run-partition option
        vcf   = join(workpath, "gatk_germline", "1gpu_normal_memory_optimized", "{sample}", "{name}.vcf"),
        recal = join(workpath, "gatk_germline", "1gpu_normal_memory_optimized", "{sample}", "{name}.recal"),
    params:
        # Rule specific parameters
        sample = "{name}",
        # Job submission parameters
        rname = "pb_germline_1gpu_normal_memory_optimized",
        mem   = allocated("mem",  "1-gpu_normal-memory_optimized", cluster),
        gres  = allocated("gres", "1-gpu_normal-memory_optimized", cluster),
        time  = allocated("time", "1-gpu_normal-memory_optimized", cluster),
        partition = allocated("partition", "1-gpu_normal-memory_optimized", cluster),
        # Singularity options
        bindpaths = ','.join(bindpaths),
        tmpdir    = tmpdir,
        sif       = config['images']['parabricks'],
        # Parabricks options
        RUNNING_MEMORY_GB = int(
            int(allocated("mem", "1-gpu_normal-memory_optimized", cluster).lower().rstrip("g")) / 2
        ),
        KNOWN_INDELS_1 = config['references']['GATK_KNOWN_INDELS'],
        KNOWN_INDELS_2 = config['references']['OTHER_KNOWN_INDELS'],
    threads: int(allocated("threads", "1-gpu_normal-memory_optimized", cluster))
    shell: """
    # Run Parabricks germline pipeline with
    # default acceleration options and the 
    # recommended set of options for best
    # performance
    singularity exec \\
        -c \\
        --nv  \\
        --env TCMALLOC_MAX_TOTAL_THREAD_CACHE_BYTES=268435456 \\
        -B {params.bindpaths},{params.tmpdir}:/tmp \\
        {params.sif} \\
             pbrun germline \\
                --ref {input.lnk} \\
                --in-fq {input.r1} {input.r1} "@RG\\tID:{params.sample}\\tSM:{params.sample}\\tPL:illumina\\tLB:{params.sample}\\tPU:{params.sample}\\tCN:ncbr\\tDS:wgs" \\
                --knownSites {params.KNOWN_INDELS_1} \\
                --knownSites {params.KNOWN_INDELS_2} \\
                --out-bam {output.bam} \\
                --out-variants {output.vcf} \\
                --out-recal-file {output.recal} \\
                --bwa-options="-M" \\
                --monitor-usage \\
                --memory-limit {params.RUNNING_MEMORY_GB} \\
                --tmp-dir /tmp \\
                --num-cpu-threads-per-stage {threads} \\
                --bwa-cpu-thread-pool {threads} \\
                --gpusort \\
                --gpuwrite \\
                --fq2bamfast \\
                --keep-tmp
    """


rule parabricks_gatk_germline_1gpu_low_memory:
    """Benchmarking Parabricks GATK Germline pipeline with 1 GPU and an normal allotment
    of main memory with the --low-memory option. NOTE: The limit memory option needs to 
    be toned down to allow for sufficent system memory to be available for the GPU. 
    Internal testing has shown that parabricks germline pipeline tends to use more 
    than the allocated memory (even with the --memory-limit option).
    @Inputs:
        GIAB Sample fastq file (scatter-per-sample).
    @Outputs:
        BAM file,
        VCF file,
        Recal table
    """
    input:
        idxs = expand(join(workpath, "refs", genome + "{ext}"), ext=bwa_index_extensions),
        lnk  = join(workpath, "refs", genome),
        r1   = join(workpath,"{name}.R1.fastq.gz"),
        r2   = join(workpath,"{name}.R2.fastq.gz"),
    output:
        bam   = join(workpath, "gatk_germline", "1gpu_low_memory", "{sample}", "{name}.bam"),
        vcf   = join(workpath, "gatk_germline", "1gpu_low_memory", "{sample}", "{name}.vcf"),
        recal = join(workpath, "gatk_germline", "1gpu_low_memory", "{sample}", "{name}.recal"),
    params:
        # Rule specific parameters
        sample = "{name}",
        # Job submission parameters
        rname = "pb_germline_1gpu_low_memory",
        mem   = allocated("mem",  "1-gpu_low-memory", cluster),
        gres  = allocated("gres", "1-gpu_low-memory", cluster),
        time  = allocated("time", "1-gpu_low-memory", cluster),
        partition = allocated("partition", "1-gpu_low-memory", cluster),
        # Singularity options
        bindpaths = ','.join(bindpaths),
        tmpdir    = tmpdir,
        sif       = config['images']['parabricks'],
        # Parabricks options
        RUNNING_MEMORY_GB = int(
            int(allocated("mem", "1-gpu_low-memory", cluster).lower().rstrip("g")) / 2
        ),
        KNOWN_INDELS_1 = config['references']['GATK_KNOWN_INDELS'],
        KNOWN_INDELS_2 = config['references']['OTHER_KNOWN_INDELS'],
    threads: int(allocated("threads", "1-gpu_low-memory", cluster))
    shell: """
    # Run Parabricks germline pipeline with
    # default acceleration options
    singularity exec \\
        -c \\
        --nv  \\
        -B {params.bindpaths},{params.tmpdir}:/tmp \\
        {params.sif} \\
             pbrun germline \\
                --ref {input.lnk} \\
                --in-fq {input.r1} {input.r1} "@RG\\tID:{params.sample}\\tSM:{params.sample}\\tPL:illumina\\tLB:{params.sample}\\tPU:{params.sample}\\tCN:ncbr\\tDS:wgs" \\
                --knownSites {params.KNOWN_INDELS_1} \\
                --knownSites {params.KNOWN_INDELS_2} \\
                --out-bam {output.bam} \\
                --out-variants {output.vcf} \\
                --out-recal-file {output.recal} \\
                --bwa-options="-M" \\
                --monitor-usage \\
                --memory-limit {params.RUNNING_MEMORY_GB} \\
                --tmp-dir /tmp \\
                --low-memory \\
                --htvc-low-memory
    """


rule parabricks_gatk_germline_1gpu_high_memory:
    """Benchmarking Parabricks GATK Germline pipeline with 1 GPU and an high allotment
    of main memory. NOTE: The limit memory option needs to be toned down to allow for 
    sufficent system memory to be available for the GPU. Internal testing has shown that
    parabricks germline pipeline tends to use more than the allocated memory (even with
    the --memory-limit option). Memory usage for this rule peaks around 110 GB. The A100
    GPU nodes we are using have 247 GB of memory spread across 4 GPUs. Two get more than
    60 GB of memory we are asking for more than 247/4 = 61.75 GB of memory for a given 
    node. As so, we might as well ask for two GPUs in a real production setting.
    @Inputs:
        GIAB Sample fastq file (scatter-per-sample).
    @Outputs:
        BAM file,
        VCF file,
        Recal table
    """
    input:
        idxs = expand(join(workpath, "refs", genome + "{ext}"), ext=bwa_index_extensions),
        lnk  = join(workpath, "refs", genome),
        r1   = join(workpath,"{name}.R1.fastq.gz"),
        r2   = join(workpath,"{name}.R2.fastq.gz"),
    output:
        bam   = join(workpath, "gatk_germline", "1gpu_high_memory", "{sample}", "{name}.bam"),
        vcf   = join(workpath, "gatk_germline", "1gpu_high_memory", "{sample}", "{name}.vcf"),
        recal = join(workpath, "gatk_germline", "1gpu_high_memory", "{sample}", "{name}.recal"),
    params:
        # Rule specific parameters
        sample = "{name}",
        # Job submission parameters
        rname = "pb_germline_1gpu_high_memory",
        mem   = allocated("mem",  "1-gpu_high-memory", cluster),
        gres  = allocated("gres", "1-gpu_high-memory", cluster),
        time  = allocated("time", "1-gpu_high-memory", cluster),
        partition = allocated("partition", "1-gpu_high-memory", cluster),
        # Singularity options
        bindpaths = ','.join(bindpaths),
        tmpdir    = tmpdir,
        sif       = config['images']['parabricks'],
        # Parabricks options
        RUNNING_MEMORY_GB = int(
            allocated("mem", "1-gpu_high-memory", cluster).lower().rstrip("g") 
        ) - 12 ,
        KNOWN_INDELS_1 = config['references']['GATK_KNOWN_INDELS'],
        KNOWN_INDELS_2 = config['references']['OTHER_KNOWN_INDELS'],
    threads: int(allocated("threads", "1-gpu_high-memory", cluster))
    shell: """
    # Run Parabricks germline pipeline with
    # default acceleration options
    singularity exec \\
        -c \\
        --nv  \\
        -B {params.bindpaths},{params.tmpdir}:/tmp \\
        {params.sif} \\
             pbrun germline \\
                --ref {input.lnk} \\
                --in-fq {input.r1} {input.r1} "@RG\\tID:{params.sample}\\tSM:{params.sample}\\tPL:illumina\\tLB:{params.sample}\\tPU:{params.sample}\\tCN:ncbr\\tDS:wgs" \\
                --knownSites {params.KNOWN_INDELS_1} \\
                --knownSites {params.KNOWN_INDELS_2} \\
                --out-bam {output.bam} \\
                --out-variants {output.vcf} \\
                --out-recal-file {output.recal} \\
                --bwa-options="-M" \\
                --monitor-usage \\
                --memory-limit {params.RUNNING_MEMORY_GB} \\
                --tmp-dir /tmp
    """


rule parabricks_deepvariant_germline_1gpu_normal_memory_optimized:
    """Benchmarking Parabricks DeepVariant Germline pipeline with 1 GPU and an normal allotment
    of main/system memory using the recommended set of options for the best performance. 
    NOTE: The limit memory option needs to be toned down to allow for sufficent system memory to 
    be available for the GPU. Internal testing has shown that parabricks germline pipeline tends 
    to use more than the allocated memory (even with
    the --memory-limit option).
    @Inputs:
        GIAB Sample fastq file (scatter-per-sample).
    @Outputs:
        BAM file,
        VCF file
    """
    input:
        idxs = expand(join(workpath, "refs", genome + "{ext}"), ext=bwa_index_extensions),
        lnk  = join(workpath, "refs", genome),
        r1   = join(workpath,"{name}.R1.fastq.gz"),
        r2   = join(workpath,"{name}.R2.fastq.gz"),
    output:
        bam   = join(workpath, "deepvariant_germline", "1gpu_normal_memory_optimized", "{sample}", "{name}.bam"),
        vcf   = join(workpath, "deepvariant_germline", "1gpu_normal_memory_optimized", "{sample}", "{name}.vcf"),
        recal = join(workpath, "deepvariant_germline", "1gpu_normal_memory_optimized", "{sample}", "{name}.recal"),
    params:
        # Rule specific parameters
        sample = "{name}",
        # Job submission parameters
        rname = "pb_dv_germline_1gpu_normal_memory_optimized",
        mem   = allocated("mem",  "1-gpu_normal-memory_optimized", cluster),
        gres  = allocated("gres", "1-gpu_normal-memory_optimized", cluster),
        time  = allocated("time", "1-gpu_normal-memory_optimized", cluster),
        partition = allocated("partition", "1-gpu_normal-memory_optimized", cluster),
        # Singularity options
        bindpaths = ','.join(bindpaths),
        tmpdir    = tmpdir,
        sif       = config['images']['parabricks'],
        # Parabricks options
        RUNNING_MEMORY_GB = int(
            int(allocated("mem", "1-gpu_normal-memory_optimized", cluster).lower().rstrip("g")) / 2
        ),
        KNOWN_INDELS_1 = config['references']['GATK_KNOWN_INDELS'],
        KNOWN_INDELS_2 = config['references']['OTHER_KNOWN_INDELS'],
    threads: int(allocated("threads", "1-gpu_normal-memory_optimized", cluster))
    shell: """
    # Run Parabricks germline pipeline with
    # default acceleration options and the 
    # recommended set of options for best
    # performance
    singularity exec \\
        -c \\
        --nv  \\
        --env TCMALLOC_MAX_TOTAL_THREAD_CACHE_BYTES=268435456 \\
        -B {params.bindpaths},{params.tmpdir}:/tmp \\
        {params.sif} \\
             pbrun deepvariant_germline \\
                --mode shortread \\
                --ref {input.lnk} \\
                --in-fq {input.r1} {input.r1} "@RG\\tID:{params.sample}\\tSM:{params.sample}\\tPL:illumina\\tLB:{params.sample}\\tPU:{params.sample}\\tCN:ncbr\\tDS:wgs" \\
                --knownSites {params.KNOWN_INDELS_1} \\
                --knownSites {params.KNOWN_INDELS_2} \\
                --out-bam {output.bam} \\
                --out-variants {output.vcf} \\
                --out-recal-file {output.recal} \\
                --bwa-options="-M" \\
                --monitor-usage \\
                --memory-limit {params.RUNNING_MEMORY_GB} \\
                --tmp-dir /tmp \\
                --num-cpu-threads-per-stage {threads} \\
                --bwa-cpu-thread-pool {threads} \\
                --num-streams-per-gpu 4 \\
                --gpusort \\
                --gpuwrite \\
                --fq2bamfast \\
                --keep-tmp
    """


# Rules utilizing more than one A100 GPU,
# This set of rules use 2 GPUs with different
# memory allocations and performance options
rule parabricks_gatk_germline_2gpu_normal_memory:
    """Benchmarking Parabricks GATK Germline pipeline with 2 GPU and an normal allotment
    of main memory. NOTE: The limit memory option needs to be toned down to allow for 
    sufficent system memory to be available for the GPU. Internal testing has shown that
    parabricks germline pipeline tends to use more than the allocated memory (even with
    the --memory-limit option).
    @Inputs:
        GIAB Sample fastq file (scatter-per-sample).
    @Outputs:
        BAM file,
        VCF file,
        Recal table
    """
    input:
        idxs = expand(join(workpath, "refs", genome + "{ext}"), ext=bwa_index_extensions),
        lnk  = join(workpath, "refs", genome),
        r1   = join(workpath,"{name}.R1.fastq.gz"),
        r2   = join(workpath,"{name}.R2.fastq.gz"),
    output:
        bam   = join(workpath, "gatk_germline", "2gpu_normal_memory", "{sample}", "{name}.bam"),
        vcf   = join(workpath, "gatk_germline", "2gpu_normal_memory", "{sample}", "{name}.vcf"),
        recal = join(workpath, "gatk_germline", "2gpu_normal_memory", "{sample}", "{name}.recal"),
    params:
        # Rule specific parameters
        sample = "{name}",
        # Job submission parameters
        rname = "pb_germline_2gpu_normal_memory",
        mem   = allocated("mem",  "2-gpu_normal-memory", cluster),
        gres  = allocated("gres", "2-gpu_normal-memory", cluster),
        time  = allocated("time", "2-gpu_normal-memory", cluster),
        partition = allocated("partition", "2-gpu_normal-memory", cluster),
        # Singularity options
        bindpaths = ','.join(bindpaths),
        tmpdir    = tmpdir,
        sif       = config['images']['parabricks'],
        # Parabricks options
        RUNNING_MEMORY_GB = int(
            allocated("mem", "2-gpu_normal-memory", cluster).lower().rstrip("g") 
        ) - 12 ,
        KNOWN_INDELS_1 = config['references']['GATK_KNOWN_INDELS'],
        KNOWN_INDELS_2 = config['references']['OTHER_KNOWN_INDELS'],
    threads: int(allocated("threads", "2-gpu_normal-memory", cluster))
    shell: """
    # Run Parabricks germline pipeline with
    # default acceleration options
    singularity exec \\
        -c \\
        --nv  \\
        -B {params.bindpaths},{params.tmpdir}:/tmp \\
        {params.sif} \\
             pbrun germline \\
                --ref {input.lnk} \\
                --in-fq {input.r1} {input.r1} "@RG\\tID:{params.sample}\\tSM:{params.sample}\\tPL:illumina\\tLB:{params.sample}\\tPU:{params.sample}\\tCN:ncbr\\tDS:wgs" \\
                --knownSites {params.KNOWN_INDELS_1} \\
                --knownSites {params.KNOWN_INDELS_2} \\
                --out-bam {output.bam} \\
                --out-variants {output.vcf} \\
                --out-recal-file {output.recal} \\
                --bwa-options="-M" \\
                --monitor-usage \\
                --memory-limit {params.RUNNING_MEMORY_GB} \\
                --tmp-dir /tmp
    """


rule parabricks_gatk_germline_2gpu_normal_memory_optimized:
    """Benchmarking Parabricks GATK Germline pipeline with 2 GPU and an normal allotment
    of main memory using the recommended set of option to gain the best performance. 
    NOTE: The limit memory option needs to be toned down to allow for sufficent system
    memory to be available for the GPU. Internal testing has shown that parabricks
    germline pipeline tends to use more than the allocated memory (even with the 
    --memory-limit option).
    @Inputs:
        GIAB Sample fastq file (scatter-per-sample).
    @Outputs:
        BAM file,
        VCF file,
        Recal table
    """
    input:
        idxs = expand(join(workpath, "refs", genome + "{ext}"), ext=bwa_index_extensions),
        lnk  = join(workpath, "refs", genome),
        r1   = join(workpath,"{name}.R1.fastq.gz"),
        r2   = join(workpath,"{name}.R2.fastq.gz"),
    output:
        bam   = join(workpath, "gatk_germline", "2gpu_normal_memory_optimized", "{sample}", "{name}.bam"),
        # Gzipped VCF cannot be created with --run-partition option
        vcf   = join(workpath, "gatk_germline", "2gpu_normal_memory_optimized", "{sample}", "{name}.vcf"),
        recal = join(workpath, "gatk_germline", "2gpu_normal_memory_optimized", "{sample}", "{name}.recal"),
    params:
        # Rule specific parameters
        sample = "{name}",
        # Job submission parameters
        rname = "pb_germline_2gpu_normal_memory_optimized",
        mem   = allocated("mem",  "2-gpu_normal-memory_optimized", cluster),
        gres  = allocated("gres", "2-gpu_normal-memory_optimized", cluster),
        time  = allocated("time", "2-gpu_normal-memory_optimized", cluster),
        partition = allocated("partition", "2-gpu_normal-memory_optimized", cluster),
        # Singularity options
        bindpaths = ','.join(bindpaths),
        tmpdir    = tmpdir,
        sif       = config['images']['parabricks'],
        # Parabricks options
        RUNNING_MEMORY_GB = int(
            allocated("mem", "2-gpu_normal-memory_optimized", cluster).lower().rstrip("g") 
        ) - 12 ,
        KNOWN_INDELS_1 = config['references']['GATK_KNOWN_INDELS'],
        KNOWN_INDELS_2 = config['references']['OTHER_KNOWN_INDELS'],
    threads: int(allocated("threads", "2-gpu_normal-memory_optimized", cluster))
    shell: """
    # Run Parabricks germline pipeline with
    # default acceleration options and the 
    # recommended set of options for best
    # performance
    singularity exec \\
        -c \\
        --nv  \\
        --env TCMALLOC_MAX_TOTAL_THREAD_CACHE_BYTES=268435456 \\
        -B {params.bindpaths},{params.tmpdir}:/tmp \\
        {params.sif} \\
             pbrun germline \\
                --ref {input.lnk} \\
                --in-fq {input.r1} {input.r1} "@RG\\tID:{params.sample}\\tSM:{params.sample}\\tPL:illumina\\tLB:{params.sample}\\tPU:{params.sample}\\tCN:ncbr\\tDS:wgs" \\
                --knownSites {params.KNOWN_INDELS_1} \\
                --knownSites {params.KNOWN_INDELS_2} \\
                --out-bam {output.bam} \\
                --out-variants {output.vcf} \\
                --out-recal-file {output.recal} \\
                --bwa-options="-M" \\
                --monitor-usage \\
                --memory-limit {params.RUNNING_MEMORY_GB} \\
                --tmp-dir /tmp \\
                --num-cpu-threads-per-stage {threads} \\
                --bwa-cpu-thread-pool {threads} \\
                --run-partition \\
                --gpusort \\
                --gpuwrite \\
                --fq2bamfast \\
                --keep-tmp
    """


rule parabricks_gatk_germline_2gpu_low_memory:
    """Benchmarking Parabricks GATK Germline pipeline with 2 GPU and an normal allotment
    of main memory with the --low-memory option. NOTE: The limit memory option needs to 
    be toned down to allow for sufficent system memory to be available for the GPU. 
    Internal testing has shown that parabricks germline pipeline tends to use more 
    than the allocated memory (even with the --memory-limit option).
    @Inputs:
        GIAB Sample fastq file (scatter-per-sample).
    @Outputs:
        BAM file,
        VCF file,
        Recal table
    """
    input:
        idxs = expand(join(workpath, "refs", genome + "{ext}"), ext=bwa_index_extensions),
        lnk  = join(workpath, "refs", genome),
        r1   = join(workpath,"{name}.R1.fastq.gz"),
        r2   = join(workpath,"{name}.R2.fastq.gz"),
    output:
        bam   = join(workpath, "gatk_germline", "2gpu_low_memory", "{sample}", "{name}.bam"),
        vcf   = join(workpath, "gatk_germline", "2gpu_low_memory", "{sample}", "{name}.vcf"),
        recal = join(workpath, "gatk_germline", "2gpu_low_memory", "{sample}", "{name}.recal"),
    params:
        # Rule specific parameters
        sample = "{name}",
        # Job submission parameters
        rname = "pb_germline_2gpu_low_memory",
        mem   = allocated("mem",  "2-gpu_low-memory", cluster),
        gres  = allocated("gres", "2-gpu_low-memory", cluster),
        time  = allocated("time", "2-gpu_low-memory", cluster),
        partition = allocated("partition", "2-gpu_low-memory", cluster),
        # Singularity options
        bindpaths = ','.join(bindpaths),
        tmpdir    = tmpdir,
        sif       = config['images']['parabricks'],
        # Parabricks options
        RUNNING_MEMORY_GB = int(
            allocated("mem", "2-gpu_low-memory", cluster).lower().rstrip("g") 
        ) - 12 ,
        KNOWN_INDELS_1 = config['references']['GATK_KNOWN_INDELS'],
        KNOWN_INDELS_2 = config['references']['OTHER_KNOWN_INDELS'],
    threads: int(allocated("threads", "2-gpu_low-memory", cluster))
    shell: """
    # Run Parabricks germline pipeline with
    # default acceleration options
    singularity exec \\
        -c \\
        --nv  \\
        -B {params.bindpaths},{params.tmpdir}:/tmp \\
        {params.sif} \\
             pbrun germline \\
                --ref {input.lnk} \\
                --in-fq {input.r1} {input.r1} "@RG\\tID:{params.sample}\\tSM:{params.sample}\\tPL:illumina\\tLB:{params.sample}\\tPU:{params.sample}\\tCN:ncbr\\tDS:wgs" \\
                --knownSites {params.KNOWN_INDELS_1} \\
                --knownSites {params.KNOWN_INDELS_2} \\
                --out-bam {output.bam} \\
                --out-variants {output.vcf} \\
                --out-recal-file {output.recal} \\
                --bwa-options="-M" \\
                --monitor-usage \\
                --memory-limit {params.RUNNING_MEMORY_GB} \\
                --tmp-dir /tmp \\
                --low-memory \\
                --htvc-low-memory
    """


# Rule utilizing 4 A100 GPUs,
# NOTE: each A100 node has 4 GPUs
# so we are allocating an entire 
# node for this rule
rule parabricks_gatk_germline_4gpu_normal_memory:
    """Benchmarking Parabricks GATK Germline pipeline with 4 GPU and an normal allotment
    of main memory. NOTE: The limit memory option needs to be toned down to allow for 
    sufficent system memory to be available for the GPU. Internal testing has shown that
    parabricks germline pipeline tends to use more than the allocated memory (even with
    the --memory-limit option).
    @Inputs:
        GIAB Sample fastq file (scatter-per-sample).
    @Outputs:
        BAM file,
        VCF file,
        Recal table
    """
    input:
        idxs = expand(join(workpath, "refs", genome + "{ext}"), ext=bwa_index_extensions),
        lnk  = join(workpath, "refs", genome),
        r1   = join(workpath,"{name}.R1.fastq.gz"),
        r2   = join(workpath,"{name}.R2.fastq.gz"),
    output:
        bam   = join(workpath, "gatk_germline", "4gpu_normal_memory", "{sample}", "{name}.bam"),
        vcf   = join(workpath, "gatk_germline", "4gpu_normal_memory", "{sample}", "{name}.vcf"),
        recal = join(workpath, "gatk_germline", "4gpu_normal_memory", "{sample}", "{name}.recal"),
    params:
        # Rule specific parameters
        sample = "{name}",
        # Job submission parameters
        rname = "pb_germline_4gpu_normal_memory",
        mem   = allocated("mem",  "4-gpu_normal-memory", cluster),
        gres  = allocated("gres", "4-gpu_normal-memory", cluster),
        time  = allocated("time", "4-gpu_normal-memory", cluster),
        partition = allocated("partition", "4-gpu_normal-memory", cluster),
        # Singularity options
        bindpaths = ','.join(bindpaths),
        tmpdir    = tmpdir,
        sif       = config['images']['parabricks'],
        # Parabricks options
        RUNNING_MEMORY_GB = int(
            allocated("mem", "4-gpu_normal-memory", cluster).lower().rstrip("g") 
        ) - 12 ,
        KNOWN_INDELS_1 = config['references']['GATK_KNOWN_INDELS'],
        KNOWN_INDELS_2 = config['references']['OTHER_KNOWN_INDELS'],
    threads: int(allocated("threads", "4-gpu_normal-memory", cluster))
    shell: """
    # Run Parabricks germline pipeline with
    # default acceleration options
    singularity exec \\
        -c \\
        --nv  \\
        -B {params.bindpaths},{params.tmpdir}:/tmp \\
        {params.sif} \\
             pbrun germline \\
                --ref {input.lnk} \\
                --in-fq {input.r1} {input.r1} "@RG\\tID:{params.sample}\\tSM:{params.sample}\\tPL:illumina\\tLB:{params.sample}\\tPU:{params.sample}\\tCN:ncbr\\tDS:wgs" \\
                --knownSites {params.KNOWN_INDELS_1} \\
                --knownSites {params.KNOWN_INDELS_2} \\
                --out-bam {output.bam} \\
                --out-variants {output.vcf} \\
                --out-recal-file {output.recal} \\
                --bwa-options="-M" \\
                --monitor-usage \\
                --memory-limit {params.RUNNING_MEMORY_GB} \\
                --tmp-dir /tmp
    """


rule parabricks_gatk_germline_4gpu_normal_memory_optimized:
    """Benchmarking Parabricks GATK Germline pipeline with 4 GPU and an normal allotment
    of main memory using the recommended set of option to gain the best performance. 
    NOTE: The limit memory option needs to be toned down to allow for sufficent system
    memory to be available for the GPU. Internal testing has shown that parabricks
    germline pipeline tends to use more than the allocated memory (even with the 
    --memory-limit option).
    @Inputs:
        GIAB Sample fastq file (scatter-per-sample).
    @Outputs:
        BAM file,
        VCF file,
        Recal table
    """
    input:
        idxs = expand(join(workpath, "refs", genome + "{ext}"), ext=bwa_index_extensions),
        lnk  = join(workpath, "refs", genome),
        r1   = join(workpath,"{name}.R1.fastq.gz"),
        r2   = join(workpath,"{name}.R2.fastq.gz"),
    output:
        bam   = join(workpath, "gatk_germline", "4gpu_normal_memory_optimized", "{sample}", "{name}.bam"),
        # Gzipped VCF cannot be created with --run-partition option
        vcf   = join(workpath, "gatk_germline", "4gpu_normal_memory_optimized", "{sample}", "{name}.vcf"),
        recal = join(workpath, "gatk_germline", "4gpu_normal_memory_optimized", "{sample}", "{name}.recal"),
    params:
        # Rule specific parameters
        sample = "{name}",
        # Job submission parameters
        rname = "pb_germline_4gpu_normal_memory_optimized",
        mem   = allocated("mem",  "4-gpu_normal-memory_optimized", cluster),
        gres  = allocated("gres", "4-gpu_normal-memory_optimized", cluster),
        time  = allocated("time", "4-gpu_normal-memory_optimized", cluster),
        partition = allocated("partition", "4-gpu_normal-memory_optimized", cluster),
        # Singularity options
        bindpaths = ','.join(bindpaths),
        tmpdir    = tmpdir,
        sif       = config['images']['parabricks'],
        # Parabricks options
        RUNNING_MEMORY_GB = int(
            allocated("mem", "4-gpu_normal-memory_optimized", cluster).lower().rstrip("g") 
        ) - 12 ,
        KNOWN_INDELS_1 = config['references']['GATK_KNOWN_INDELS'],
        KNOWN_INDELS_2 = config['references']['OTHER_KNOWN_INDELS'],
    threads: int(allocated("threads", "4-gpu_normal-memory_optimized", cluster))
    shell: """
    # Run Parabricks germline pipeline with
    # default acceleration options and the 
    # recommended set of options for best
    # performance
    singularity exec \\
        -c \\
        --nv  \\
        --env TCMALLOC_MAX_TOTAL_THREAD_CACHE_BYTES=268435456 \\
        -B {params.bindpaths},{params.tmpdir}:/tmp \\
        {params.sif} \\
             pbrun germline \\
                --ref {input.lnk} \\
                --in-fq {input.r1} {input.r1} "@RG\\tID:{params.sample}\\tSM:{params.sample}\\tPL:illumina\\tLB:{params.sample}\\tPU:{params.sample}\\tCN:ncbr\\tDS:wgs" \\
                --knownSites {params.KNOWN_INDELS_1} \\
                --knownSites {params.KNOWN_INDELS_2} \\
                --out-bam {output.bam} \\
                --out-variants {output.vcf} \\
                --out-recal-file {output.recal} \\
                --bwa-options="-M" \\
                --monitor-usage \\
                --memory-limit {params.RUNNING_MEMORY_GB} \\
                --tmp-dir /tmp \\
                --num-cpu-threads-per-stage {threads} \\
                --bwa-cpu-thread-pool {threads} \\
                --run-partition \\
                --gpusort \\
                --gpuwrite \\
                --fq2bamfast \\
                --keep-tmp
    """


rule bgzip_index_vcf:
    """Data processing step to compress the VCF file with bgzip and index it with tabix.
    @Inputs:
        VCF file
    @Outputs:
        bgzip compressed VCF file,
        tabix index file
    """
    input:
        vcf = join(workpath, "{tested_tool}", "{benchmark_configuration}", "{sample}", "{name}.vcf"),
    output:
        vcf = join(workpath, "{tested_tool}", "{benchmark_configuration}", "{sample}", "{name}.vcf.gz"),
        idx = join(workpath, "{tested_tool}", "{benchmark_configuration}", "{sample}", "{name}.vcf.gz.tbi"),
    params:
        # Job submission parameters
        rname = "bgzip_index_vcf",
        mem   = allocated("mem",  "bgzip_index_vcf", cluster),
        gres  = allocated("gres", "bgzip_index_vcf", cluster),
        time  = allocated("time", "bgzip_index_vcf", cluster),
        partition = allocated("partition", "bgzip_index_vcf", cluster),
    threads: int(allocated("threads", "bgzip_index_vcf", cluster)),
    container: config['images']['gatk'],
    shell: """
    # Bgzip compress the VCF file
    bgzip \\
        -c {input.vcf} \\
    > {output.vcf}
    # Create a tabix index
    tabix \\
        -p vcf \\
        {output.vcf}
    """