# NIBSC Bioinformatics Nextflow Modules

This repository has a couple of main goals:

- collect shared modules that might be specific to NIBSC needs and activities
- provide the team with a playground to develop and test modules, before contributing to the community

The NF-Core community is engaged in a huge effort, to convert most pipelines to DSL2 and build all necessary modules: for this reason, beyond the scope described above, it is important to contribute rather than duplicate the efforts.

## Table of contents

- [NF-Core](#nf-core)
  - [nf-core principles](#nf-core-principles)
  - [contributions and overlaps](#contributions-and-overlaps)
- [How to add a new Module to this repository](#how-to-add-a-new-module-to-this-repository)
  - [Create new branch](#create-new-branch)
  - [Subcommands](#subcommands)
- [How to use the base template](#how-to-use-the-base-template)
  - [Identify test data](#identify-test-data)
  - [Modify the container](#modify-the-container)
  - [Modify the module code](#modify-the-module-code)
  - [Write a test script](#write-a-test-script)
  - [Modify Github Actions](#modify-github-actions)
- [Submit your module with a Pull Request](#submit-your-module-with-a-pull-request)



## NF-Core

Before developing a new module, and unless it serves purely as learning experience, please check the list of [nf-core modules](https://github.com/nf-core/modules/tree/master/software) to verify if the module already exists or if there is a need to add it.

### nf-core principles

In order to enable collaborations, and develop as much as possible community-standards, there is an active discussion about the principles we should all try and adhere when coding new Nextflow modules.

Please review the latest guidelines here:

[nf-core modules guidelines](https://github.com/nf-core/modules/blob/master/README.md)


### contributions and overlaps

Once you have developed a new module, which might be useful to the community, please follow these guidelines to submit it to the common repository:

[upload to *nf-core/modules*](https://github.com/nf-core/modules#uploading-to-nf-coremodules)


## How to add a new Module to this repository

In the following section, a few steps to make sure we can all collaborate and develop our modules independently.

### Create new branch

To start develop a new module, create a new branch as shown in the picture:

![create branch](images/branch.png)

with the following simple steps:

1. select the arrow next to the name of the current branch, and check you are on *master*
2. type the name of the new branch, using the name of the new module you want to create, lowercase
3. click on the line composed below, which gives the option to create a new branch with the chosen name


### Subcommands

Some software like *bwa* or *samtools* have multiple commands available under the same hood. A basic principle agreed for nf-core modules is **atomicity**.
This means, in most cases, modules should **only** execute one task: this choice simplifies the code and maximises the usability of modules in different pipelines.

In these cases, one should build a subfolder under the module folder named after the sub-command to be executed.

For example, in the case of bwa, one would create

```{bash}
./software/bwa/
```

And inside this folder we would create

```{bash}
./software/bwa/
-- index/
-- mem/
```

When subcommands are needed, and one has to create multiple modules for each of them, the container will be the same for all of them.
For this reason, container files will be located only at the upper level, i.e. in the folder with the software name

```{bash}
./software/bwa
-- index/
-- mem/
-- Dockerfile
-- environment.yml
```


## How to use the base template

The template (available under *software/template*) is inspired to a couple of important principles:

- reproducibility: test data should be available, and version-controlled sofware should be used
- documentation: all modules should be documented, and a structured YAML file should be written to clearly describe the expected inputs and outputs
- automation: github actions are used to check the validity of the code, using test data and a mini-workflow

The template contains the following structure:

```{bash}
+--- Dockerfile
+--- environment.yml
+--- main.nf
+--- meta.yml
+--- README.md
+--- test
|   +--- data
|   |   +--- test2_reads_1.fastq.gz
|   |   +--- test2_reads_2.fastq.gz
|   |   +--- test_reads_1.fastq.gz
|   |   +--- test_reads_2.fastq.gz
|   |   +--- test_samples.tsv
|   +--- main.nf
|   +--- nextflow.config
```

### Identify test data

Before even beginning to develop your modules, it is important that you have identified test data (created, or using existing ones).
The files should be very small (Github maximum upload file size is 100MB): this will ensure portability but also a quick execution of your test run.
It goes without saying the data should make sense for the workflow to be tested.


Once you have prepared the test data, place them under *software/modulename/test/data*.

### Modify the container

Currently, it has been agreed

1. to use [Biocontainers](https://biocontainers.pro/#/registry) for single-software modules
2. to use the latest version of the software

You should change the module template, where it indicates the Biocontainer

```{bash}
container "quay.io/biocontainers/fastqc:0.11.9--0"
```

to the appropriate software and version you need to use.

However, we still want to modify our custom Docker container, which is particularly useful when multiple software applications need to be used.
In order to do that, we need to slighly modify the following files

```{bash}
+--- Dockerfile
+--- environment.yml
```

First, the **environment.yml**: here you should change the name of the environment, and the software to be installed.
Then, the **Dockerfile** should be modified to change the *PATH* with the name of the conda environment as you changed it in the *environment.yml*.

All files contain comments, which should help identifying the changes to be introduced.

The container will be built and uploaded to [Docker Hub](https://hub.docker.com/repository/docker/nibscbioinformatics/nf-modules) under the repository **nf-modules**: in order to distinguish the different containers, the **tag** will identify the *software* (module name) and the *version* separated by "*-*".
This is not exactly compliant to nf-core practices, which are currently evolving. The most compliant way, is to use a biocontainer, as explained above.


### Modify the module code

In order to ensure consistency, it's been agreed for the moment that:

1. **module settings** should be located in the main **nextflow.config** file, using the JSON structure that has been adopted for genome references, i.e.

```{bash}
params {
  modules {
    'modulename' {
      args = "--newarg xyz"
      more = "this and that"
    }
  }
}
```

In this way, the appropriate parameters can always be called inside the module code by using the expression:

```
${params.modules['modulename'].args}
```


2. **sample metadata** should be passed to the module as a [Groovy Map](http://groovy-lang.org/groovy-dev-kit.html#Collections-Maps) in a **tuple** with an array containing the reads.

This means the metadata can be created with something like

```
def meta = [:]
meta.id = yourdatafield
meta.type = yourotherdatafield
```

The reads will be defined by something like:

```
reads = [ file(read1), file(read2) ]
```

And the tuple can be emitted as:

```
sampleInfo = [ meta, reads ]
```

Currently, we have written a basic function in the template test workflow to read a sample TSV file, and create this structure. Soon we will prepare a module with this functionality.


### Write a test script

The test folder contains the following structure:

```
+--- test
|   +--- data
|   |   +--- test_reads_1.fastq.gz
|   |   +--- test_reads_2.fastq.gz
|   |   +--- test_samples.tsv
|   +--- main.nf
|   +--- nextflow.config
```

You will have already modified the contents of the *test/data* folder, to add the identified small datasets.
You should replace the *test_samples.tsv* with an appropriate one, pointing to the new data.

It is important to modify the **main.nf** located in *test/data* to create an appropriate workflow which can load and execute the module you have created.
Additionally, the workflow should test in the most appropriate way that the results match what is expected.

### Modify Github Actions

The folder **.github** prepared for the template contains the following:

```
+--- workflows
|   +--- template_build.yml
|   +--- template_test.yml
```

You should **create a copy** of both files, and rename it as *modulename_build.yml* and *modulename_test.yml*, where *modulename* is the name you chose for the module and corresponding to the folder you added under **software/**.

Both files include comments which should highlight the parts of the code you need to modify, in order to enable github actions that will:

- build the custom container for your module
- run the test workflow using both conda and docker profile


## Submit your module with a Pull Request

Once you have completed development, you are ready to submit a pull request with the code you worked on.
Make sure you are located in the correct branch, with your module name (i.e. the folder with your module will be visible, as indicated by the blue arrow) and click on *pull request* as indicated by the red arrow below.

![initiate pull](images/pr_create.png)

Now, following the steps highlighted in the picture below:

![open pull](images/pr_open.png)

1. make sure you are merging from **your branch** into **master**
2. give a meaningful title (i.e. your module name) and describe the key functionality you are adding (*a PR template will be provided soon*)
3. select some other members of the team (2) to act as reviewers, and assign the appropriate labels.

And you're ready to go!
