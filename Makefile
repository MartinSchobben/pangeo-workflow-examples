.ONESHELL:
SHELL = /bin/bash
.PHONY: help clean install environment test version dist
CONDA_ENV_DIR = $(shell conda info --base)/envs/<pkg-name>
CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate
EODAG_PATH = $$(poetry env info --path)

help:
	@echo "make clean"
	@echo " clean all jupyter checkpoints"
	@echo "make manifest"
	@echo " lock dependencies of conda environment"
	@echo "make develop"
	@echo " create a development conda environment"
	@echo "make kernel"
	@echo " make ipykernel based on conda lock file"
	@echo "make jupyter"
	@echo " launch JupyterLab server"

clean:
	rm --force --recursive .ipynb_checkpoints/

develop:
	@echo "creating new base pangeo-workflow-examples conda environment..."
	conda create -y -c conda-forge -n pangeo-workflow-examples python=3.10 pip mamba
	$(CONDA_ACTIVATE) pangeo-workflow-examples
	mamba install -y -c conda-forge nbgitpuller jupyterlab eodag ipykernel 

publish:
	conda env export | grep -v "^prefix: " > pangeo-workflow-examples.yml

kernel:
	conda env create -n eonenv --file pangeo-workflow-examples.yml
	$(CONDA_ACTIVATE) pangeo-workflow-examples
	cp -f /tmp/eodag.yml ${HOME}/.config/eodag/eodag.yml
	cp -f /tmp/providers.yml $(EODAG_PATH)/lib/python3.10/site-packages/eodag/resources/providers.yml
	python -m ipykernel install --user --name pangeo-workflow-examples
	@echo -e "conda jupyter kernel is ready."

jupyter: kernel develop
	jupyter lab .
