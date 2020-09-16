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

    //container "ghcr.io/nibscbioinformatics/flash:1.2.11"
    container "quay.io/biocontainers/flash:1.2.11--hed695b0_5"

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
  tuple val(meta), path("*.extendedFrags.fastq.gz"), emit: reads
  path "*.version.txt", emit: version

  script:
  // flash is meant to merge reads, so this should only be used
  // when paired-end sequencing has bene done
  """
  flash \
  -t {task.cpus} \
  --quiet \
  -o ${meta.sampleID} \
  -z --max-overlap 300 \
  ${reads[0]} ${reads[1]}

  flash -v | head -n 1 | cut -d" " -f 2 >flash.version.txt
  """


}
