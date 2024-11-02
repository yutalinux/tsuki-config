.PHONY: all build repo clean
pkgs = $(wildcard packages/*/PKGBUILD)

all: build repo

build: pkgs
