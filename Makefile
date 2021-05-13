# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Include my.env and export it so variables set in there are available
# in the Makefile.
include my.env
export

DC := $(shell which docker-compose)

.DEFAULT_GOAL := help
.PHONY: help
help:
	@echo "Usage: make RULE"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' Makefile \
		| grep -v grep \
	    | sed -n 's/^\(.*\): \(.*\)##\(.*\)/\1\3/p' \
	    | column -t  -s '|'
	@echo ""
	@echo "See https://github.com/willkg/socorro-jupyter/ for more documentation."

my.env:
	@if [ ! -f my.env ]; \
	then \
	echo "Copying my.env.dist to my.env..."; \
	cp my.env.dist my.env; \
	fi

.docker-build:
	make build

.PHONY: build
build: my.env  ## | Build docker images.
	${DC} build jupyter
	touch .docker-build

.PHONY: run
run: my.env  ## | Run processor and webapp and all required services.
	${DC} up jupyter

.PHONY: stop
stop: my.env  ## | Stop all service containers.
	${DC} stop

.PHONY: shell
shell: my.env .docker-build  ## | Open a shell in the app container.
	${DC} run --rm jupyter shell

.PHONY: clean
clean:  ## | Remove all build, test, coverage, and Python artifacts.
	-rm .docker-build*
	${DC} rm -f
