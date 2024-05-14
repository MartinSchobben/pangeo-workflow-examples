.ONESHELL:
SHELL = /bin/bash
.PHONY: help clean install environment test version dist

POETRY_ENV_DIR = $(shell poetry env info)

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
	poetry add ipykernel jupyterlab nbgrader nbgitpuller --group dev 
	poetry add eodag
	@echo "... finished."

environment:
	poetry install --no-root
	source $(shell poetry env info --path)/bin/activate
	python -m ipykernel install --user --name pangeo-workflow-examples --display-name "pangeo-workflow-examples"
	jupyter kernelspec list
	@echo -e "poetry environment is ready."

jupyter:
	jupyter lab .
