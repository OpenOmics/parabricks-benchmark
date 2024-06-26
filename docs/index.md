<div align="center">

  <h1 style="font-size: 250%">parabricks-benchmark 🔬</h1>

  <b><i>Benchmarking Parabrick's GPU-accelerated tools</i></b><br> 
  <a href="https://github.com/OpenOmics/parabricks-benchmark/actions/workflows/main.yaml">
    <img alt="tests" src="https://github.com/OpenOmics/parabricks-benchmark/workflows/tests/badge.svg">
  </a>
  <a href="https://github.com/OpenOmics/parabricks-benchmark/actions/workflows/docs.yml">
    <img alt="docs" src="https://github.com/OpenOmics/parabricks-benchmark/workflows/docs/badge.svg">
  </a>
  <a href="https://github.com/OpenOmics/parabricks-benchmark/issues">
    <img alt="GitHub issues" src="https://img.shields.io/github/issues/OpenOmics/parabricks-benchmark?color=brightgreen">
  </a>
  <a href="https://github.com/OpenOmics/parabricks-benchmark/blob/main/LICENSE">
    <img alt="GitHub license" src="https://img.shields.io/github/license/OpenOmics/parabricks-benchmark">
  </a>

  <p>
    This is the home of the pipeline, parabricks-benchmark. Its long-term goals: to benchmarking Parabricks GPU-accelerated tools for GATK and beyond!
  </p>

</div>  


## Overview

Welcome to parabricks-benchmark's documentation! This guide is the main source of documentation for users that are getting started with the [long pipeline name](https://github.com/OpenOmics/parabricks-benchmark/). 

The **`./parabricks-benchmark`** pipeline is composed several inter-related sub commands to setup and run the pipeline across different systems. Each of the available sub commands perform different functions: 

<section align="center" markdown="1" style="display: flex; flex-wrap: row wrap; justify-content: space-around;">

!!! inline custom-grid-button ""

    [<code style="font-size: 1em;">parabricks-benchmark <b>run</b></code>](usage/run.md)   
    Run the parabricks-benchmark pipeline with your input files.

!!! inline custom-grid-button ""

    [<code style="font-size: 1em;">parabricks-benchmark <b>unlock</b></code>](usage/unlock.md)  
    Unlocks a previous runs output directory.

</section>

<section align="center" markdown="1" style="display: flex; flex-wrap: row wrap; justify-content: space-around;">


!!! inline custom-grid-button ""

    [<code style="font-size: 1em;">parabricks-benchmark <b>install</b></code>](usage/install.md)  
    Download remote reference files locally.


!!! inline custom-grid-button ""

    [<code style="font-size: 1em;">parabricks-benchmark <b>cache</b></code>](usage/cache.md)  
    Cache remote software containers locally.  

</section>

**parabricks-benchmark** is pipeline to test and compare different GPU-accelerated parabricks tools against the tools they were _inspired from_. It relies on technologies like [Singularity<sup>1</sup>](https://singularity.lbl.gov/) to maintain the highest-level of reproducibility. The pipeline consists of a series of data processing steps orchestrated by [Snakemake<sup>2</sup>](https://snakemake.readthedocs.io/en/stable/), a flexible and scalable workflow management system, to submit jobs to a cluster.

The pipeline is compatible with data generated from Illumina short-read sequencing technologies. The GATK germline pipeline was tested using NIST's GIAB HG002, HG003, HG004 samples.

Before getting started, we highly recommend reading through the [usage](usage/run.md) section of each available sub command.

For more information about issues or trouble-shooting a problem, please checkout our [FAQ](faq/questions.md) prior to [opening an issue on Github](https://github.com/OpenOmics/parabricks-benchmark/issues).

## Contribute 

This site is a living document, created for and by members like you. parabricks-benchmark is maintained by the members of NCBR and is improved by continous feedback! We encourage you to contribute new content and make improvements to existing content via pull request to our [GitHub repository :octicons-heart-fill-24:{ .heart }](https://github.com/OpenOmics/parabricks-benchmark).

## Citation

If you use this software, please cite it as below:  

=== "BibTex"

    ```
    Citation coming soon!
    ```

=== "APA"

    ```
    Citation coming soon!
    ```

## References
<sup>**1.**  Kurtzer GM, Sochat V, Bauer MW (2017). Singularity: Scientific containers for mobility of compute. PLoS ONE 12(5): e0177459.</sup>  
<sup>**2.**  Koster, J. and S. Rahmann (2018). "Snakemake-a scalable bioinformatics workflow engine." Bioinformatics 34(20): 3600.</sup>  
