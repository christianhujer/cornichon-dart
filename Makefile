.PHONY: all
## all:	Runs the tests (same as test).
all: test

.PHONY: test
## test:	Runs the tests.
test:
	dart test

.PHONY: help
## help:	Print this help text.
help:
	@sed -En 's/^## ?//p' $(MAKEFILE_LIST)
