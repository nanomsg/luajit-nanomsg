PREFIX=/usr/local
LMODNAME=nanomsg-ffi

LUA=luajit
LMODFILE=$(LMODNAME).lua

ABIVER=5.1
INSTALL_SHARE=$(PREFIX)/share
INSTALL_LMOD=$(INSTALL_SHARE)/lua/$(ABIVER)

all:
	@echo "This is a pure module. Nothing to make :)"

test:
	$(LUA) $(LMODNAME).test.lua

install:
	install -m0644 $(LMODFILE) $(INSTALL_LMOD)/$(LMODFILE)

uninstall:
	rm -f $(INSTALL_LMOD)/$(LMODFILE)
