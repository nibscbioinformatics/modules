FROM conda/miniconda3
LABEL authors="Francesco Lescai and Thomas Bleazard" \
      description="Docker image containing all software requirements for the READSAMPLE module"

# Install procps so that Nextflow can poll CPU usage
RUN apt-get update && apt-get install -y procps && apt-get clean -y

# Install the conda environment
# COPY environment.yml /
# RUN conda env create -f /environment.yml && conda clean -a

# currently no specific software is needed so we will just use the base container
# ENV PATH /usr/local/envs/nibscbioinformatics-modules-fastqc/bin:$PATH
