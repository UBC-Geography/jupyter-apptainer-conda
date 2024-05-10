.PHONY: create_env remove_env create_kernel remove_kernel jupyter

#################################################################################
# GLOBALS                                                                       #
#################################################################################

## Change this variable
PROJECT_NAME=My Project Name

## Update these variables if needed
LANG=python
CONDA_FILE=./enviornment.yml
PIP_FILE=./requirements.txt
CRAN_FILE=./install.R

## Avoid changing these variables
PROJECT_SLUG=$(notdir $(shell pwd))
PROJECT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
ENV?=$(PROJECT_DIR)/env

apptainer_cmd = "apptainer","run","-B","/localscratch:/localscratch"

jupyter: apptainer_cmd = "apptainer","run"

ifeq ($(LANG),r)
define KERNEL =
{
    "argv": [
		$(apptainer_cmd),
        "$(ENV)",
       	"R",
    	"--slave",
    	"-e",
    	"IRkernel::main()",
    	"--args",
    	"{connection_file}"
    ],
    "display_name": "R ($(PROJECT_NAME))",
    "language": "R"
}
endef
else
define KERNEL =
{
    "argv": [
		$(apptainer_cmd),
        "$(ENV)",
        "python",
        "-m",
        "ipykernel_launcher",
        "-f",
        "{connection_file}"
    ],
    "display_name": "Python ($(PROJECT_NAME))",
    "language": "python"
}
endef
endif

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Create the project's container and install packages from files
create_env:
ifneq (,$(wildcard $(ENV)))
	@echo Container already exists
else
	apptainer build --sandbox --build-arg LANG=$(LANG) \
		--build-arg CONDA_FILE=$(CONDA_FILE) \
		--build-arg PIP_FILE=$(PIP_FILE) \
		--build-arg CRAN_FILE=$(CRAN_FILE) \
		$(ENV) container.def
endif

## Remove the project's container
remove_env:
ifneq (,$(wildcard $(ENV)))
	rm -rf $(ENV)
else
	@echo Container does not exist
endif

setup_kernel: create_env
ifeq ($(LANG),r)
	apptainer run $(ENV) Rscript \
		-e "IRkernel::installspec(name='$(PROJECT_SLUG)',prefix='tmp')"
else
	apptainer run $(ENV) python -m ipykernel install --prefix tmp \
		--name $(PROJECT_SLUG)
endif
	
## Create a new Jupyter kernel using the project environment
create_kernel: setup_kernel
	$(file > tmp/share/jupyter/kernels/$(PROJECT_SLUG)/kernel.json,$(KERNEL))
	jupyter kernelspec install tmp/share/jupyter/kernels/$(PROJECT_SLUG) --user
	rm -rf tmp

## Remove the kernel from Jupyter
remove_kernel: remove_env
	jupyter kernelspec remove $(PROJECT_SLUG) -f

## Run the kernel in a local Juyter environment
jupyter: create_kernel
	jupyter lab
