release_version := $(shell grep "^RUBY_BUILD_VERSION" bin/ruby-build | cut -d\" -f2)

.PHONY: install
install:
	bash install.sh

share/man/man1/%.1: share/man/man1/%.1.adoc bin/ruby-build
	asciidoctor -b manpage -a version=$(release_version:v%=%) -o $@ $<
