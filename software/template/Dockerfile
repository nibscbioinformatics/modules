FROM conda/miniconda3
LABEL authors="Francesco Lescai and Ravneet Bhuller" \
      description="Docker image containing all software requirements for the cnvkit module"

# Install procps so that Nextflow can poll CPU usage
# deep clean the apt cache to reduce image/layer size
RUN apt-get update && apt-get install -y procps && apt-get clean -y

# Install the conda environment
COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
# TODO ->>> change the path here indicated by "xxx" [/envs/]xxxx[/bin:$PATH] with the very same name
# given into the environment.yml file
ENV PATH /usr/local/envs/nibscbioinformatics-modules-cnvkit/bin:$PATH
