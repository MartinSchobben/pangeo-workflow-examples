.ONESHELL:
SHELL = /bin/bash
.PHONY: help clean install environment test version dist
POETRY_ACTIVATE = source $$(poetry env info --path)/bin/activate
EODAG_PATH = $$(poetry env info --path)

help:
	@echo "make clean"
	@echo " clean all jupyter checkpoints"
	@echo "make manifest"
	@echo " lock dependencies of poetry environment"
	@echo "make develop"
	@echo " create a development poetry environment"
	@echo "make kernel"
	@echo " make ipykernel based on poetry lock file"
	@echo "make jupyter"
	@echo " launch JupyterLab server"

clean:
	rm --force --recursive .ipynb_checkpoints/

develop:
	poetry install
	$(POETRY_ACTIVATE) pangeo-workflow-examples
	@echo -e "poetry development environment is ready."

kernel:
	poetry install --only main
	$(POETRY_ACTIVATE) pangeo-workflow-examples
	poetry run cp -f /tmp/eodag.yml ${HOME}/.config/eodag/eodag.yml
	poetry run cp -f /tmp/providers.yml $(EODAG_PATH)/lib/python3.10/site-packages/eodag/resources/providers.yml
	python -m ipykernel install --user --name pangeo-workflow-examples --display-name "pangeo-workflow-examples"
	@echo -e "poetry jupyter kernel is ready."

jupyter: kernel develop
	jupyter lab .
