## Usage

### DRA HPC Cluster

From terminal:

```bash
module load apptainer
make create_kernel
```

Load apptainer in Softwares tab

Launch notebook with kernel

### Local

Install Apptainer and Jupyter

```bash
make jupyter
```

Creates a sandbox container with the provided definition file, but you can override to use a SIF container, by defining the ENV variable via:

```bash
make create_kernel ENV=container.sif
```

## Install New Packages

If using the default sandbox environment, you can install new packages, using the following command.

```bash
apptainer run --writable env/ micromamba install <package_name>
```

## Export Conda Environment

```bash
apptainer run env/ micromamba env export --no-build > environment.yml
```

## Building a SIF container

```bash
apptainer build env/ <container_name>.sif