#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { CNVKIT } from '../main.nf' addParams( options: [ publish_dir:'test_with_normal' ] )
include { CNVKIT } from '../main.nf' addParams( options: [ publish_dir:'test_without_normal' ] )

/*
 * Test with normal sample
 */
workflow test_with_normal {

    def input = []
    input = [ [ id:'test', with_normal:true ], // meta map
              [ file("${baseDir}/input/278_sub_chr21.bam", checkIfExists: true),
	        file("${baseDir}/input/280_sub_chr21.bam", checkIfExists: true) ] ]

    CNVKIT (
        input,
        file("${baseDir}/input/subseq_chr21.fasta", checkIfExists: true),
        file("${baseDir}/input/refflat.txt", checkIfExists: true)
    )
}

/*
 * Test without normal sample
 */
workflow test_without_normal {

    def input = []
    input = [ [ id:'test', with_normal:false ], // meta map
              [ file("${baseDir}/input/278_sub_chr21.bam", checkIfExists: true) ] ]

    CNVKIT (
        input,
        file("${baseDir}/input/subseq_chr21.fasta", checkIfExists: true),
        file("${baseDir}/input/refflat.txt", checkIfExists: true)
    )
}

workflow {
    test_with_normal()
    test_without_normal()
} 
