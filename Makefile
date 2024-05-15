.ONESHELL:
SHELL = /bin/bash
.PHONY: help clean install environment test version dist
POETRY_ACTIVATE = source $$(poetry env info --path)/bin/activate

help:
	@echo "make clean"
	@echo " clean all jupyter checkpoints"
	@echo "make install"
	@echo " install dependencies in local venv environment and creates a new one if it doesn't exist yet"
	@echo "make jupyter"
	@echo " launch JupyterLab server"

clean:
	rm --force --recursive .ipynb_checkpoints/

manifest:
	@echo "creating new base pangeo-workflow-examples poetry environment..."
	poetry init -n
	poetry add jupyterlab nbgrader nbgitpuller --group dev 
	poetry add ipykernel eodag
	@echo "... finished."

develop:
	poetry install
	$(POETRY_ACTIVATE) pangeo-workflow-examples
	@echo -e "poetry development environment is ready."

kernel:
	poetry install --only main
	$(POETRY_ACTIVATE) pangeo-workflow-examples
	poetry run cp -f /tmp/eodag.yml ${HOME}/.config/eodag/eodag.yml
	poetry run cp -f /tmp/providers.yml $(shell poetry env info --path)/lib/python3.10/site-packages/eodag/resources/providers.yml
	python -m ipykernel install --user --name pangeo-workflow-examples --display-name "pangeo-workflow-examples"
	@echo -e "poetry jupyter kernel is ready."

jupyter:
	jupyter lab .
