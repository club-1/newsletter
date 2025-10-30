# Configuration / variables section
PREFIX ?= /usr/local

# Default installation paths
BIN_DIR     := $(DESTDIR)$(PREFIX)/bin
SBIN_DIR    := $(DESTDIR)$(PREFIX)/sbin
DIRS        := $(BIN_DIR) $(SBIN_DIR)

# Files to install
BINS        := newsletter
SBINS       := newsletterctl

# Installed files
BINS_INST   := $(patsubst %,$(BIN_DIR)/%,$(BINS))
SBINS_INST  := $(patsubst %,$(SBIN_DIR)/%,$(SBINS))

all: ;

install: | $(DIRS)
	install -D $(BINS) $(BIN_DIR)
	install -D $(SBINS) $(SBIN_DIR)
	sed -i -e 's#{{PREFIX}}#$(PREFIX)#' "$(BIN_DIR)/newsletter"
	sed -i -e 's#{{PREFIX}}#$(PREFIX)#' "$(SBIN_DIR)/newsletterctl"

uninstall:
	rm -f $(BINS_INST) $(SBINS_INST)
	-rm -d $(BIN_DIR) $(SBIN_DIR)

$(DIRS):
	install -d $@

.PHONY: all install uninstall
