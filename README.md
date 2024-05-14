# Overview

This repository bootstraps a reproducible, conda-based Jupyter kernel via an Apptainer container. This enables JupyterHub instances, which support Apptainer but do not already have a conda-based package manager installed, like those provided by the [Digital Research Alliance](https://docs.alliancecan.ca/wiki/JupyterHub), to support managing environments and installing packages via a conda-based package manager thus enabling packages to be installed from conda-forge and environments to be quickly reproduced via an `environment.yml` file.

Note: The Digital Research Alliance already includes an expansive list of [software](https://docs.alliancecan.ca/wiki/Available_software) and [Python packages](https://docs.alliancecan.ca/wiki/Available_Python_wheels), which have all been compiled specifically to function efficiently in a High Performance Computing environment. It's strongly recommended that you rely on the Alliance's software first as that will ensure the best performance for your code.

## Installation

### Digital Research Alliance JupyterHub

Start a new terminal session in your JupyterHub environment and clone this repository.

```bash
git clone https://github.com/ubc-geography/jupyter-apptainer-conda
```

Run the following commands to load the Apptainer module, build the Apptainer container, install any packages listed in an `environment.yml` file, and install the environment in the container as a new Jupyter kernel.

```bash
module load apptainer
make -C ~/jupyter-apptainer-conda create_kernel
```

Your terminal session is in a separate environment from where the Jupyter kernel is launched from, so you will need to locate and load the Apptainer module through the Jupyter Lab software tab. After waiting a few seconds, you should see the new kernel listed in the Jupyter Lab launcher.

### Local

Apptainer can be installed locally on Linux, Windows (via WSL2), or Mac (via Lima). You can find instructions in Apptainer's documentation [here](https://apptainer.org/docs/admin/main/installation.html).

From a terminal, run the following to start up a Jupyter server with the kernel pre-installed.

```bash
make jupyter
```

## Installing Packages

If using the default sandbox environment, you can install new packages, using the following command.

```bash
apptainer run --writable env/ micromamba install <package_name>
```

## Exporting the Conda Environment

```bash
apptainer run env/ micromamba env export --no-build > environment.yml
```

## Building a SIF container

If you are looking to share your environment with others. You can either use the exported environment.yml file or build your sandbox environment as a distributable Apptainer SIF container. The latter provides an even greater guarantee that others will be able to create an exact replication of your computing environment.

```bash
apptainer build env/ <container_name>.sif
```

To use that or any other containers build from the included container.def file, you can use the following command to set them up as your kernel.

```bash
make create_kernel ENV=<container_name>.sif
```