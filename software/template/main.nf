def MODULE = "template"
params.publish_dir = MODULE
params.publish_results = "default"

process FASTQC {
    // each module must define a process label to declare a category of
    // resource requirements
    label 'process_low'

    publishDir "${params.out_dir}/${params.publish_dir}",
        mode: params.publish_dir_mode,
        saveAs: { filename ->
                    if (params.publish_results == "none") null
                    else filename }

    container "docker.pkg.github.com/nibscbioinformatics/$MODULE"

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
  // elegant solution as implemented by nf-core
  // all credits to original authors :)
  if (params.single_end) {
      """
      [ ! -f  ${meta.sampleID}.fastq.gz ] && ln -s $reads ${meta.sampleID}.fastq.gz
      fastqc ${params.modules['fastqc'].args} --threads $task.cpus ${meta.sampleID}.fastq.gz
      fastqc --version | sed -n "s/.*\\(v.*\$\\)/\\1/p" > fastqc.version.txt
      """
  } else {
      """
      [ ! -f  ${meta.sampleID}_1.fastq.gz ] && ln -s ${reads[0]} ${meta.sampleID}_1.fastq.gz
      [ ! -f  ${meta.sampleID}_2.fastq.gz ] && ln -s ${reads[1]} ${meta.sampleID}_2.fastq.gz
      fastqc ${params.modules['fastqc'].args} --threads $task.cpus ${meta.sampleID}_1.fastq.gz ${meta.sampleID}_2.fastq.gz
      fastqc --version | sed -n "s/.*\\(v.*\$\\)/\\1/p" > fastqc.version.txt
      """
  }
}
