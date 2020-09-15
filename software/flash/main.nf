def MODULE = "flash"
params.publish_dir = FLASH
params.publish_results = "default"

process FLASH {
    // each module must define a process label to declare a category of
    // resource requirements
    label 'process_low'

    publishDir "${params.out_dir}/${params.publish_dir}",
        mode: params.publish_dir_mode,
        saveAs: { filename ->
                    if (params.publish_results == "none") null
                    else filename }

    //container "docker.pkg.github.com/nibscbioinformatics/$MODULE"
    // need to use biocontainers because of problem with github registry
    // requesting o-auth
    container "quay.io/biocontainers/flash:1.2.11--hed695b0_5" // TODO -> change with appropriate biocontainer
    // alternatively, now we can choose "nibscbioinformatics/modules:software-version" which is built
    // automatically from the containers definitions

    conda (params.conda ? "${moduleDir}/environment.yml" : null)


  input:
  // --> meta is a Groovy MAP containing any number of information (metadata) per sample
  // or analysis unit, corresponding to each of "reads"
  // it is accessible via meta.name where ".name" is the name of the metadata
  // these MUST be described in the meta.yml when the metatada are expected by the process
  tuple val(meta), path(reads)

  // configuration parameters are accessible via
  // params.modules['modulename'].name
  // where "name" is the name of parameter, and defined in nextflow.config

  output:
  tuple val(meta), path("*.html"), emit: html
  tuple val(meta), path("*.zip"), emit: zip
  path "*.version.txt", emit: version

  script:
  // flash is meant to merge reads, so this should only be used
  // when paired-end sequencing has bene done

  
}
