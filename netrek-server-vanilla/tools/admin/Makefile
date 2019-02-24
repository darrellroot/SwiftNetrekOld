# Change CONFIG to the .mk file that matches your system

CONFIG = ../system.mk

srcdir = .
DESTDIR = /Users/Shared/MacTrek/Server

# Do Not Change anything below this line. It should be setup in config

include ../$(CONFIG)

INSTALL = /usr/bin/install -c
INSTALLPROG = ${INSTALL}
INSTALLDATA = ${INSTALL} -m 644

ADMINDIR= $(LIBDIR)/tools/admin

EXECS =	ban free kill quit reset

all: $(EXECS)

install: $(EXECS) 
	mkdir -p $(DESTDIR)$(ADMINDIR)
	$(INSTALLPROG) $(INSTALLOPTS) $(EXECS) $(DESTDIR)$(ADMINDIR)

clean::
