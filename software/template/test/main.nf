#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { CNVKIT } from '../main.nf' addParams( options: [:] )


workflow test {
  CNVKIT ( 
	file("${baseDir}/input/278_sub_chr21.bam", checkIfExists: true),
	file("${baseDir}/input/280_sub_chr21.bam", checkIfExists: true),
	file("${baseDir}/input/subseq_chr21.fasta", checkIfExists: true),
	file("${baseDir}/input/refflat.txt", checkIfExists: true)
  )	
}

workflow {
    test()
} 
