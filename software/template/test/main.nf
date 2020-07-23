#!/usr/bin/env nextflow

nextflow.preview.dsl = 2
params.out_dir = "test_output"
params.publish_dir_mode = "copy"
params.single_end = false

include { FASTQC } from '../main.nf' params(params)


workflow {
  input = file("${baseDir}/data/test_samples.tsv")
  inputSample = Channel.empty()
  inputSample = readInputFile(input, params.single_end)

  FASTQC(inputSample)

  // ## IMPORTANT this is a test workflow
  // so a test should always been implemented to check
  // the output corresponds to what expected

  FASTQC.out.html.map { map, reports ->
    html_read1 = reports[0]
    html_read2 = reports[1]

    assert html_read1.exists()
    assert html_read2.exists()
    assert html_read1.getExtension() == "html"
    assert html_read2.getExtension() == "html"

  }

}





// ############## WARNING !!! #########################
// the part below is going to be transferred to a module soon
// ############## UTILITIES AND SAMPLE LOADING ######################

// ### preliminary check functions

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
            array = [ meta, reads]
            return array
        }
}
