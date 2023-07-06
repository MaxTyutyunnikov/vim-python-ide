.DEFAULT_GOAL:=help
.PHONY: all help clean release major minor patch
.PRECIOUS:
SHELL:=/bin/bash

#include mkfiles/*.mk

VERSION:=$(shell git describe --abbrev=0 --tags)
CURRENT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
NAME:=$(shell [ -e .registry ] && cat .registry)

help:
	@echo -e "\033[33mUsage:\033[0m\n  make TARGET\n\n\033[33mTargets:\033[0m"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-7s\033[0m %s\n", $$1, $$2}'

git_commit:
	@git add .
	@git commit -a -m "Auto" || true

git_push: git_commit
	@git push --all
	@git push --tags

V?=minor
release: git_push
	@echo === advbumpversion $(V) ========================================
	@advbumpversion $(V)
	
	@echo === checkout to master with submodules =========================
#	@git submodule foreach git checkout master
	@git checkout master
	
	@echo === commit before merge ========================================
	@git add .
	@git commit -a -m "Auto before_merge commit submodules" || :
	
	@echo === merge ======================================================
	@git merge --no-edit --commit -X theirs develop || ( git add . ; git commit -a -m Auto )
	
	@echo === commit after merger ========================================
	@git add .
	@git commit -a -m "Auto after_merge commit submodules" || :
	
	@echo === advbumpversion build and push ==============================
	@advbumpversion build
	
	@git push --all
	@git push --tags
	
#	@git submodule foreach git checkout develop
	@git checkout develop

checkout_develop:
	@git submodule foreach git checkout develop || :
	@git checkout develop

checkout_master:
	@git submodule foreach git checkout master || :
	@git checkout master

dev:
	@advbumpversion build

major:
	make release V=major

minor:
	make release V=minor

patch:
	make release V=patch

bootstrap:
#	git remote add
	git remote add parent https://github.com/jarolrod/vim-python-ide.git || :
	git remote add cydanil https://github.com/cydanil/python-vimrc.git || :
	git remote add ajkdrag https://github.com/ajkdrag/python-vimrc.git || :
	git remote add brunorpinho https://github.com/brunorpinho/python-vimrc.git || :
	git remote add qooba https://github.com/qooba/vim-python-ide.git || :
	git remote add DJNing https://github.com/DJNing/python-vimrc.git || :
	git remote add nartiz https://github.com/nartiz/vim-python-ide.git || :
	git remote add maiconq https://github.com/maiconq/python-vimrc.git || :
