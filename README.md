<div align="center">
   
  <h1>parabricks-benchmark 🔬</h1>
  
  **_Benchmarking Parabrick's GPU-accelerated tools_**

  [![tests](https://github.com/OpenOmics/parabricks-benchmark/workflows/tests/badge.svg)](https://github.com/OpenOmics/parabricks-benchmark/actions/workflows/main.yaml) [![docs](https://github.com/OpenOmics/parabricks-benchmark/workflows/docs/badge.svg)](https://github.com/OpenOmics/parabricks-benchmark/actions/workflows/docs.yml) [![GitHub issues](https://img.shields.io/github/issues/OpenOmics/parabricks-benchmark?color=brightgreen)](https://github.com/OpenOmics/parabricks-benchmark/issues)  [![GitHub license](https://img.shields.io/github/license/OpenOmics/parabricks-benchmark)](https://github.com/OpenOmics/parabricks-benchmark/blob/main/LICENSE) 
  
  <i>
    This is the home of the pipeline, parabricks-benchmark. Its long-term goals: to benchmarking Parabricks GPU-accelerated tools for GATK and beyond!
  </i>
</div>

## Overview
Welcome to parabricks-benchmark! Before getting started, we highly recommend reading through [parabricks-benchmark's documentation](https://openomics.github.io/parabricks-benchmark/).

The **`./parabricks-benchmark`** pipeline is composed several inter-related sub commands to setup and run the pipeline across different systems. Each of the available sub commands perform different functions: 

 * [<code>parabricks-benchmark <b>run</b></code>](https://openomics.github.io/parabricks-benchmark/usage/run/): Run the parabricks-benchmark pipeline with your input files.
 * [<code>parabricks-benchmark <b>unlock</b></code>](https://openomics.github.io/parabricks-benchmark/usage/unlock/): Unlocks a previous runs output directory.
 * [<code>parabricks-benchmark <b>install</b></code>](https://openomics.github.io/parabricks-benchmark/usage/install/): Download reference files locally.
 * [<code>parabricks-benchmark <b>cache</b></code>](https://openomics.github.io/parabricks-benchmark/usage/cache/): Cache remote resources locally, coming soon!

**parabricks-benchmark** is pipeline to test and compare different GPU-accelerated parabricks tools against the tools they were _inspired from_. It relies on technologies like [Singularity<sup>1</sup>](https://singularity.lbl.gov/) to maintain the highest-level of reproducibility. The pipeline consists of a series of data processing steps orchestrated by [Snakemake<sup>2</sup>](https://snakemake.readthedocs.io/en/stable/), a flexible and scalable workflow management system, to submit jobs to a cluster.

The pipeline is compatible with data generated from Illumina short-read sequencing technologies. The GATK germline pipeline was tested using NIST's GIAB HG002, HG003, HG004 samples.

Before getting started, we highly recommend reading through the [usage](https://openomics.github.io/parabricks-benchmark/usage/run/) section of each available sub command.

For more information about issues or trouble-shooting a problem, please checkout our [FAQ](https://openomics.github.io/parabricks-benchmark/faq/questions/) prior to [opening an issue on Github](https://github.com/OpenOmics/parabricks-benchmark/issues).

## Dependencies
**Requires:** `singularity>=3.5`  `snakemake<8.0`

The pipeline uses the offical parabricks docker image. With that being said, [snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) and [singularity](https://singularity.lbl.gov/all-releases) must be installed on the target system. Snakemake orchestrates the execution of each step in the pipeline. To guarantee the highest level of reproducibility, each step of the pipeline will rely on versioned images from [DockerHub](https://hub.docker.com/orgs/nciccbr/repositories). Snakemake uses singularity to pull these images onto the local filesystem prior to job execution, and as so, snakemake and singularity will be the only two dependencies in the future.

## Installation
Please clone this repository to your local filesystem using the following command:
```bash
# Clone Repository from Github
git clone https://github.com/OpenOmics/parabricks-benchmark.git
# Change your working directory
cd parabricks-benchmark/
# Add dependencies to $PATH
# Biowulf users should run
module load snakemake singularity
# Get usage information
./parabricks-benchmark -h
```

## Contribute 
This site is a living document, created for and by members like you. parabricks-benchmark is maintained by the members of OpenOmics and is improved by continous feedback! We encourage you to contribute new content and make improvements to existing content via pull request to our [GitHub repository](https://github.com/OpenOmics/parabricks-benchmark).


## Cite

If you use this software, please cite it as below:  

<details>
  <summary><b><i>@BibText</i></b></summary>
 
```text
Citation coming soon!
```

</details>

<details>
  <summary><b><i>@APA</i></b></summary>

```text
Citation coming soon!
```

</details>

## References
<sup>**1.**  Kurtzer GM, Sochat V, Bauer MW (2017). Singularity: Scientific containers for mobility of compute. PLoS ONE 12(5): e0177459.</sup>  
<sup>**2.**  Koster, J. and S. Rahmann (2018). "Snakemake-a scalable bioinformatics workflow engine." Bioinformatics 34(20): 3600.</sup>  
