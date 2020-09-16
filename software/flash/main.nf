def MODULE = "flash"
params.publish_dir = MODULE
params.publish_results = "default"

// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

// TODO nf-core: All of these TODO statements can be deleted after the relevant changes have been made.
// TODO nf-core: If in doubt look at other nf-core/modules to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/software
//               You can also ask for help via your pull request or on the #modules channel on the nf-core Slack workspace:
//               https://nf-co.re/join

// TODO nf-core: The key words "MUST", "MUST NOT", "SHOULD", etc. are to be interpreted as described in RFC 2119 (https://tools.ietf.org/html/rfc2119).
// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided as a string i.e. "options.args"
//               where "options" is a Groovy Map that MUST be provided in the "input:" section of the process.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core: Software that can be piped together SHOULD be added to separate module files
//               unless there is a run-time, storage advantage in implementing in this way
//               e.g. bwa mem | samtools view -B -T ref.fasta to output BAM instead of SAM.
// TODO nf-core: Optional inputs are not currently supported by Nextflow. However, "fake files" MAY be used to work around this issue.

// TODO nf-core: Process name MUST be all uppercase,
//               "SOFTWARE" and (ideally) "TOOL" MUST be all one word separated by an "_".



process FLASH {
    // each module must define a process label to declare a category of
    // resource requirements
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        // TODO nf-core: If a meta map of sample information is NOT provided in "input:" section
        //               change "publish_id:meta.id" to initialise an empty string e.g. "publish_id:''".
        saveAs: { filename ->
          saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.sampleID)
        }

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

  // TODO nf-core: List additional required input channels/values here
  val options

  output:
  tuple val(meta), path("${meta.sampleID}.extendedFrags.fastq.gz"), emit: reads
  path "*.version.txt", emit: version

  script:
  // flash is meant to merge reads, so this should only be used
  // when paired-end sequencing has bene done
  """
  flash \
  -t ${task.cpus} \
  --quiet \
  -o ${meta.sampleID} \
  -z --max-overlap 300 \
  ${reads[0]} ${reads[1]}

  flash -v | head -n 1 | cut -d" " -f 2 >flash.version.txt
  """


}
