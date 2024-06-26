.ONESHELL:
SHELL = /bin/bash
.PHONY: help clean install environment test version dist
CONDA_ENV_DIR = $(shell conda info --base)/envs/pangeo-workflow-examples
CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate
EODAG_PATH = $$(python -m pip show eodag | grep Location: | sed 's/^Location: //')

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

$(CONDA_ENV_DIR):
	if ! { conda env list | grep 'pangeo-workflow-examples'; } >/dev/null 2>&1; then
		@echo "creating new base pangeo-workflow-examples conda environment..."
		conda env create --file environment.yml -y
	fi;
	$(CONDA_ACTIVATE) pangeo-workflow-examples

environment: $(CONDA_ENV_DIR)
	@echo -e "conda environment is ready. To activate use:\n\tconda activate pangeo-workflow-examples"

publish:
	$(CONDA_ACTIVATE) pangeo-workflow-examples
	conda env export  --from-history | grep -ve "^prefix:" -ve "jupyter" -ve "nbgitpuller" > environment.yml

kernel: environment
	$(CONDA_ACTIVATE) pangeo-workflow-examples
	if { jupyter server list | grep "/home/jovyan" ; } >/dev/null 2>&1; then
		cp -f /tmp/eodag.yml ${HOME}/.config/eodag/eodag.yml
		python -m pip install eodag && cp -f /tmp/providers.yml $(EODAG_PATH)/eodag/resources/providers.yml
	fi;
	python -m ipykernel install --user --name pangeo-workflow-examples
	@echo -e "conda jupyter kernel is ready."

jupyter: kernel
	jupyter lab .
