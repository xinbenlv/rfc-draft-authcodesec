# Makefile for AuthCodeSEC Internet-Draft

# Paths
SRC_DIR = src
DIST_DIR = dist
BIN_DIR = /Users/zzn/Library/Python/3.9/bin
GEM_BIN = /Users/zzn/.gem/ruby/2.6.0/bin

# Tools
KRAMDOWN = $(GEM_BIN)/kramdown-rfc2629
XML2RFC = $(BIN_DIR)/xml2rfc

# Files
DRAFT_NAME = draft-zzn-authcodesec
SOURCE = $(SRC_DIR)/$(DRAFT_NAME).md
XML_OUT = $(DIST_DIR)/$(DRAFT_NAME).xml
TXT_OUT = $(DIST_DIR)/$(DRAFT_NAME).txt

all: txt

xml: $(XML_OUT)

txt: $(TXT_OUT)

$(XML_OUT): $(SOURCE)
	mkdir -p $(DIST_DIR)
	$(KRAMDOWN) $(SOURCE) > $(XML_OUT)

$(TXT_OUT): $(XML_OUT)
	$(XML2RFC) --text $(XML_OUT) -o $(TXT_OUT)

clean:
	rm -f $(DIST_DIR)/*

.PHONY: all xml txt clean

