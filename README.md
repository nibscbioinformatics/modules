# NIBSC Bioinformatics Nextflow Modules

This repository has a couple of main goals:

- collect shared modules that might be specific to NIBSC needs and activities
- provide the team a playground to develop and test modules, before contributing to the community

The NF-Core community is engaged in a huge effort, to convert most pipelines to DSL2 and build all necessary modules: for this reason, beyond the above scopes, it is important to contribute rather than duplicate the efforts.


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


### Identify test data

Before even beginning to develop your modules, it is important that you have identified test data (created, or using existing ones).
The files should be very small (Github maximum upload file size is 100MB): this will ensure portability but also a quick execution of your test run.
It goes without saying the data should make sense for the workflow to be tested.


Once you have prepared the test data, place them under *software/modulename/test/data*.

### Modify the container


### Modify the module code

**module settings** in a central config

**sample metadata** in a map

### Write a test script


### Modify container build github action


### Modify module test github action


## Submit your module with a Pull Request

![initiate pull](images/pr_create.png)


![open pull](images/pr_open.png)
