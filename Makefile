## reveal.js presentation makefile
#
# This Makefile will generate a reveal.js presentation from a Markdown file
# using Pandoc. The resulting presentation can be easily exported with Github
# Pages.

##---------- Preliminaries ----------------------------------------------------

.POSIX:     # Get relible POSIX behaviour
.SUFFIXES:  # Clear built-in inference rules

##---------- Variables --------------------------------------------------------

# Markdown file containing presentation source
SOURCE_FILES := $(wildcard [0-9][0-9]-*.md)

# Target directory for the reveal.js presentation
OUTPUT := gh-pages

# Web pages for the presentations
PRESENTATION_FILES := $(patsubst %.md,$(OUTPUT)/%.html,$(SOURCE_FILES))

# Directory for reveal.js
REVEAL_JS_DIR := $(OUTPUT)/reveal.js

# Directory for other assets (images, etc.)
ASSETS_DIR := assets

# File name of the reveal.js tarball
# Remark: Pandoc 2.9.2.1 and earlier must use reveal.js 3.x:
# See Pandoc Wiki <https://github.com/jgm/pandoc/wiki/Using-pandoc-to-produce-reveal.js-slides>
REVEAL_JS_TAR := 3.9.2.tar.gz

# Download URL
REVEAL_JS_URL := https://github.com/hakimel/reveal.js/archive/$(REVEAL_JS_TAR)

# reveal.js style file
STYLE := hogent
STYLE_FILE := $(REVEAL_JS_DIR)/css/theme/$(STYLE).css

##---------- User build targets -----------------------------------------------

help: ## Show this help message (default)
	@printf 'The following build targets are available:\n'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\033[34mIndividual presentations:\033[0m\n"
	@printf "\033[36m%-20s\033[0m\n" $(PRESENTATION_FILES)

all: $(STYLE_FILE) $(PRESENTATION_FILES) ## Build the presentation (but not the handouts)

clean: ## Deletes the presentation and handouts (not reveal.js)
	rm -f $(OUTPUT)/*.html
#	rm -f $(OUTPUT)/*.pdf

mrproper: clean ## Thorough cleanup (also removes reveal.js)
	rm -rf $(REVEAL_JS_DIR)

.PHONY: clean mrproper help

##---------- Actual build targets ---------------------------------------------

## Generate the reveal.js presentation
$(OUTPUT)/%.html: %.md $(REVEAL_JS_DIR) $(STYLE_FILE) $(OUTPUT)/$(ASSETS_DIR)
	pandoc \
		--standalone \
		--to=revealjs \
		--template=default.revealjs \
		--variable=theme:hogent \
		--output $@ $<

##---------- Dependent files and directories ----------------------------------

## Ensure the style file is put into the right place
$(STYLE_FILE): $(STYLE).css $(REVEAL_JS_DIR)
	cp $(STYLE).css $(STYLE_FILE)

## Download and install reveal.js locally
$(REVEAL_JS_DIR):
	test -d $(OUTPUT) || mkdir -p $(OUTPUT)
	wget $(REVEAL_JS_URL)
	tar xzf $(REVEAL_JS_TAR)
	rm -v $(REVEAL_JS_TAR)
	mv -T reveal.js* $(REVEAL_JS_DIR)

## Assets directory
$(OUTPUT)/$(ASSETS_DIR):
	rsync -av $(ASSETS_DIR) $(OUTPUT)
