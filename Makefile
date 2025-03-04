#
# Copyright 2015 Andrew Ayer <agwa@andrewayer.name>
# Copyright 2016, 2017 Chris Lamb <lamby@debian.org>
# 
# This file is part of disorderfs.
# 
# disorderfs is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# disorderfs is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with disorderfs.  If not, see <http://www.gnu.org/licenses/>.
#

# Note: uses GNU Make features

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man
ENABLE_MAN ?= $(HAS_A2X)

# a2x
HAS_A2X ?= $(shell command -v a2x >/dev/null && echo yes || echo no)

# FUSE
PKG_CONFIG ?= pkg-config
FUSE_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags fuse) -DFUSE_USE_VERSION=26
FUSE_LIBS ?= $(shell $(PKG_CONFIG) --libs fuse) -lulockmgr

# CXXFLAGS
CXXFLAGS += -Wall -Wextra -pedantic -O2 -g
CXXFLAGS += -std=c++11 -Wno-unused-parameter
CXXFLAGS += $(FUSE_CFLAGS)

# Files
OBJFILES = disorderfs.o

all: build

#
# Build
#
BUILD_MAN_TARGETS-yes = build-man
BUILD_MAN_TARGETS-no =
BUILD_TARGETS := build-bin $(BUILD_MAN_TARGETS-$(ENABLE_MAN))

build: $(BUILD_TARGETS)

build-bin: disorderfs

disorderfs: $(OBJFILES)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJFILES) $(LDFLAGS) $(FUSE_LIBS)

build-man: disorderfs.1

disorderfs.1: disorderfs.1.txt
	a2x --doctype manpage --format manpage disorderfs.1.txt

#
# Clean
#
CLEAN_MAN_TARGETS-yes = clean-man
CLEAN_MAN_TARGETS-no =
CLEAN_TARGETS := clean-bin $(CLEAN_MAN_TARGETS-$(ENABLE_MAN))

clean: $(CLEAN_TARGETS)

clean-bin:
	rm -f $(OBJFILES) disorderfs

clean-man:
	rm -f disorderfs.1


#
# Install
#
INSTALL_MAN_TARGETS-yes = install-man
INSTALL_MAN_TARGETS-no =
INSTALL_TARGETS := install-bin $(INSTALL_MAN_TARGETS-$(ENABLE_MAN))

install: $(INSTALL_TARGETS)

install-bin: build-bin
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 disorderfs $(DESTDIR)$(BINDIR)/

install-man: build-man
	install -d $(DESTDIR)$(MANDIR)/man1
	install -m 644 disorderfs.1 $(DESTDIR)$(MANDIR)/man1/

test: build
	$(MAKE) -C tests

.PHONY: all \
	build build-bin build-man \
	clean clean-bin clean-man \
	install install-bin install-man \
	test
