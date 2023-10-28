# Configuration / variables section
PREFIX ?= /usr/local

# Default installation paths
SBIN_DIR    := $(DESTDIR)$(PREFIX)/sbin
DIRS        := $(SBIN_DIR)

# Files to install
BINS        := $(wildcard *.sh)

# Installed files
BINS_INST   := $(patsubst %,$(SBIN_DIR)/%,$(BINS))

install: | $(DIRS)
	install -D $(BINS) $(SBIN_DIR) -m 750

uninstall:
	-rm $(BINS_INST)

$(DIRS):
	install -d $@

.PHONY: install uninstall
