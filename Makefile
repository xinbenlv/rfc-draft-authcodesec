# Makefile for AuthCodeSEC Internet-Draft

# Paths
SRC_DIR = src
DIST_DIR = dist
ARCHIVE_DIR = archive
BIN_DIR = /Users/zzn/Library/Python/3.9/bin
GEM_BIN = /Users/zzn/.gem/ruby/2.6.0/bin

# Tools
KRAMDOWN = $(GEM_BIN)/kramdown-rfc2629
XML2RFC = $(BIN_DIR)/xml2rfc
IDNITS = npx @ietf-tools/idnits

# Files
DRAFT_NAME = draft-zzn-authcodesec
SOURCE = $(SRC_DIR)/$(DRAFT_NAME).md
XML_OUT = $(DIST_DIR)/$(DRAFT_NAME).xml
TXT_OUT = $(DIST_DIR)/$(DRAFT_NAME).txt

all: txt

xml: $(XML_OUT)

txt: $(TXT_OUT)

# Publish target: determines next version, generates file, runs idnits
publish: $(XML_OUT)
	@echo "Determining next version..."
	@mkdir -p $(ARCHIVE_DIR)
	@LAST_FILE=$$(ls $(ARCHIVE_DIR)/$(DRAFT_NAME)-*.txt 2>/dev/null | sort | tail -n 1); \
	if [ -z "$$LAST_FILE" ]; then \
		NEXT_VER="00"; \
	else \
		LAST_VER=$$(echo "$$LAST_FILE" | sed -E 's/.*-([0-9]+)\.txt/\1/'); \
		LAST_NUM=$$(echo "$$LAST_VER" | sed 's/^0*//'); \
		if [ -z "$$LAST_NUM" ]; then LAST_NUM=0; fi; \
		NEXT_NUM=$$((LAST_NUM + 1)); \
		NEXT_VER=$$(printf "%02d" $$NEXT_NUM); \
	fi; \
	NEW_NAME="$(DRAFT_NAME)-$$NEXT_VER"; \
	NEW_XML="$(DIST_DIR)/$$NEW_NAME.xml"; \
	NEW_TXT="$(ARCHIVE_DIR)/$$NEW_NAME.txt"; \
	echo "Next version is $$NEXT_VER"; \
	cp $(XML_OUT) "$$NEW_XML"; \
	sed -i '' "s/docName=\"$(DRAFT_NAME)-[0-9]*\"/docName=\"$$NEW_NAME\"/" "$$NEW_XML"; \
	echo "Generating $$NEW_TXT..."; \
	$(XML2RFC) --text "$$NEW_XML" -o "$$NEW_TXT"; \
	echo "Running idnits on $$NEW_TXT..."; \
	$(IDNITS) --mode submission "$$NEW_TXT"

$(XML_OUT): $(SOURCE)
	mkdir -p $(DIST_DIR)
	$(KRAMDOWN) $(SOURCE) > $(XML_OUT)

$(TXT_OUT): $(XML_OUT)
	$(XML2RFC) --text $(XML_OUT) -o $(TXT_OUT)

clean:
	rm -f $(DIST_DIR)/*

.PHONY: all xml txt clean publish
