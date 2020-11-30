// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

def VERSION = '0.9.6'

process CNVKIT {
    tag "$meta.id"
    // each module must define a process label to declare a category of
    // resource requirements
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    //container "docker.pkg.github.com/nibscbioinformatics/$MODULE"
    // need to use biocontainers because of problem with github registry
    // requesting o-auth
    container "quay.io/biocontainers/cnvkit:0.9.6--0" // TODO -> change with appropriate biocontainer
    // alternatively, now we can choose "nibscbioinformatics/modules:software-version" which is built
    // automatically from the containers definitions

    conda (params.enable_conda ? "bioconda::cnvkit=0.9.6" : null)


  input:
  // --> meta is a Groovy MAP containing any number of information (metadata) per sample
  // or analysis unit, corresponding to each of "reads"
  // it is accessible via meta.name where ".name" is the name of the metadata
  // these MUST be described in the meta.yml when the metatada are expected by the process
  tuple val(meta), path(tumourbam), path(normalbam)
  path fasta
  path annotationfile

  // configuration parameters are accessible via
  // params.modules['modulename'].name
  // where "name" is the name of parameter, and defined in nextflow.config

  output:
  tuple val(meta), path("*.cnn"), emit: cnn
  tuple val(meta), path("*.bed"), emit: bed
  tuple val(meta), path("*.cnr"), emit: cnr
  tuple val(meta), path("*.cns"), emit: cns
  path "*.version.txt", emit: version

  script:
  def software = getSoftwareName(task.process)
  def prefix   = options.suffix ? "${meta.id}.${options.suffix}" : "${meta.id}"
  """
  cnvkit.py batch $tumourbam 
    --normal $normalbam \\
    --method wgs \\
    --fasta $reffasta \\
    --annotate $annotationfile \\
    --output-reference my_reference.cnn --output-dir results

  echo $VERSION > ${software}.version.txt
  """
}

