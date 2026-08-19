VERSION := $(strip $(shell sed -n '1p' VERSION))
TARGET ?= neutral
INPUT_DIR ?= input
MAIN_TEX ?=
TARGETS := arxiv biorxiv zenodo neutral
BUILD_INPUT_ARGS := --input-dir "$(INPUT_DIR)"

ifneq ($(strip $(MAIN_TEX)),)
BUILD_INPUT_ARGS += --main "$(MAIN_TEX)"
endif

.PHONY: all pdf all-targets dependencies version clean help

all: pdf

pdf:
	./build.sh --target "$(TARGET)" $(BUILD_INPUT_ARGS)

all-targets:
	@set -e; for target in $(TARGETS); do \
	  ./build.sh --target "$$target" $(BUILD_INPUT_ARGS); \
	done

dependencies:
	./build.sh --check-dependencies --target "$(TARGET)" $(BUILD_INPUT_ARGS)

version:
	@./build.sh --version

clean:
	@if [ -d build ]; then find build -depth -mindepth 1 -delete; fi
	@if [ -d output/pdf ]; then find output/pdf -type f -name '*.pdf' -delete; fi

help:
	@printf '%s\n' \
	  'make TARGET=neutral   # no repository label (default)' \
	  'make TARGET=arxiv     # arXiv footer label' \
	  'make TARGET=biorxiv   # bioRxiv footer label' \
	  'make TARGET=zenodo    # Zenodo footer label' \
	  'make all-targets      # build all four PDFs' \
	  'make TARGET=arxiv INPUT_DIR=test-manuscript' \
	  'make all-targets INPUT_DIR=test-manuscript' \
	  'make TARGET=neutral INPUT_DIR=drafts MAIN_TEX=article.tex' \
	  'make dependencies      # write build/DEPENDENCY_REPORT.md' \
	  'make version           # show template version $(VERSION)' \
	  'make clean            # remove generated build products'
