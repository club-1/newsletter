# Configuration / variables section
PREFIX ?= /usr/local

# Default installation paths
SBIN_DIR    := $(DESTDIR)$(PREFIX)/sbin
DIRS        := $(SBIN_DIR)

# Files to install
BINS        := nl newsletter

# Installed files
BINS_INST   := $(patsubst %,$(SBIN_DIR)/%,$(BINS))

all: ;

install: | $(DIRS)
	install -D $(BINS) $(SBIN_DIR) -m 750 -g mail
	sed -i -e 's#{{PREFIX}}#$(PREFIX)#' $(SBIN_DIR)/newsletter

uninstall:
	-rm $(BINS_INST)

$(DIRS):
	install -d $@

.PHONY: all install uninstall
