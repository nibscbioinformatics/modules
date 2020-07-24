# Nextflow Module READSAMPLE


## Software information

No particular software is used by this module, other than groovy language within Nextflow.

## Add information about the process

The module simply processes a tab-separated sample information file, and provides other modules in a Nextflow workflow with a tuple composed by sample metadata and read path information.

The module only expects the path to the TSV file, and standard params incuding single_end, a boolean indicating if the experiment is single-ended or paired-ended squencing.
