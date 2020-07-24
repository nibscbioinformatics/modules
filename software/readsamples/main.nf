def MODULE = "READSAMPLE"
params.publish_dir = MODULE
params.publish_results = "none"

process READSAMPLE {

  label 'process_low'

  publishDir "${params.out_dir}/${params.publish_dir}",
      mode: params.publish_dir_mode,
      saveAs: { filename ->
                  if (params.publish_results == "none") null
                  else filename }

  container "quay.io/biocontainers/nextflow:20.04.1--hecda079_1"
  conda (params.conda ? "${moduleDir}/environment.yml" : null)


  input:
  file(samplesheet)

  output:
  val inputSample, emit: sampledata

  script:
  inputSample = Channel.empty()
  inputSample = readInputFile(samplesheet, params.single_end)
}



def checkExtension(file, extension) {
    file.toString().toLowerCase().endsWith(extension.toLowerCase())
}

def checkFile(filePath, extension) {
  // first let's check if has the correct extension
  if (!checkExtension(filePath, extension)) exit 1, "File: ${filePath} has the wrong extension. See --help for more information"
  // then we check if the file exists
  if (!file(filePath).exists()) exit 1, "Missing file in TSV file: ${filePath}, see --help for more information"
  // if none of the above has thrown an error, return the file
  return(file(filePath))
}

// the function expects a tab delimited sample sheet, with a header in the first line
// the header will name the variables and therefore there are a few mandatory names
// sampleID to indicate the sample name or unique identifier
// read1 to indicate read_1.fastq.gz, i.e. R1 read or forward read
// read2 to indicate read_2.fastq.gz, i.e. R2 read or reverse read
// any other column should fulfill the requirements of modules imported in main
// the function also expects a boolean for single or paired end reads from params

def readInputFile(tsvFile, single_end) {
    Channel.from(tsvFile)
        .splitCsv(header:true, sep: '\t')
        .map { row ->
            def meta = [:]
            def reads = []
            def sampleinfo = []
            meta.sampleID = row.sampleID
            if (single_end) {
              reads = checkFile(row.read1, "fastq.gz")
            } else {
              reads = [ checkFile(row.read1, "fastq.gz"), checkFile(row.read2, "fastq.gz") ]
            }
            sampleinfo = [ meta, reads ]
            return sampleinfo
        }
}
