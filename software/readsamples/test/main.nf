#!/usr/bin/env nextflow

nextflow.preview.dsl = 2
params.out_dir = "test_output"
params.publish_dir_mode = "copy"
params.single_end = false
params.conda = false

include { FASTQC } from '../../template/main.nf' params(params)
include { READSAMPLE } from '../main.nf' params(params)


workflow {
  input = file("${baseDir}/data/test_samples.tsv")

  READSAMPLE(input)

  FASTQC(READSAMPLE.out.sampledata)

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
