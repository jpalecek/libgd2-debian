# -*- mode: makefile; coding: utf-8 -*-
# Copyright © 2007 Jonas Smedegaard <dr@jones.dk>
# Description: Convenience rules for maintanining packaging in some VCS
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307 USA.

_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class

ifndef _cdbs_rules_vcs
_cdbs_rules_vcs := 1

# Write the md5sum of the downloaded tarball, to ensure all VCS users use same tarball
#DEB_VCS_MD5 = 

# Base URL for downloading upstream tarballs
#DEB_VCS_UPSTREAM_URL = 

# Suffix to add to repackaged tarball
#DEB_VCS_DIRT_TAG = dfsg

# Space-delimited list of directories and files to strip from repackaged tarball
#DEB_VCS_DIRT_EXCLUDES = CVS .cvsignore doc/rfc*.txt doc/draft*.txt

DEB_VCS_UPSTREAM_VERSION = $(shell basename '$(DEB_UPSTREAM_VERSION)' '.$(DEB_VCS_DIRT_TAG)')

# Upstream may package their software using different naming scehems
DEB_VCS_UPSTREAM_PACKAGE = $(DEB_SOURCE_PACKAGE)
DEB_VCS_TARBALL_SRCDIR = $(DEB_VCS_UPSTREAM_PACKAGE)-$(DEB_VCS_UPSTREAM_VERSION)

DEB_VCS_UPSTREAM_FILENAME = $(DEB_VCS_UPSTREAM_PACKAGE)-$(DEB_VCS_UPSTREAM_VERSION).tar.gz
DEB_VCS_VIRGIN_FILENAME = $(DEB_SOURCE_PACKAGE)_$(DEB_VCS_UPSTREAM_VERSION).orig.tar.gz
DEB_VCS_DIRTY_FILENAME = $(DEB_SOURCE_PACKAGE)_$(DEB_VCS_UPSTREAM_VERSION).$(DEB_VCS_DIRT_TAG).orig.tar.gz

DEB_VCS_TARBALL_BASEDIR = ../tarballs

print-version:
	@@echo "Debian version:          $(DEB_VERSION)"
	@@echo "Upstream version:        $(DEB_VCS_UPSTREAM_VERSION)"

get-orig-source:
	@@dh_testdir
	@@mkdir -p "$(DEB_VCS_TARBALL_BASEDIR)"

	@if [ ! -f "$(DEB_VCS_TARBALL_BASEDIR)/$(DEB_VCS_VIRGIN_FILENAME)" ] ; then \
		echo "Downloading $(DEB_VCS_VIRGIN_FILENAME) from $(DEB_VCS_UPSTREAM_URL)/$(DEB_VCS_UPSTREAM_FILENAME) ..." ; \
		wget -N -nv -T10 -t3 -O "$(DEB_VCS_TARBALL_BASEDIR)/$(DEB_VCS_VIRGIN_FILENAME)" "$(DEB_VCS_UPSTREAM_URL)/$(DEB_VCS_UPSTREAM_FILENAME)" ; \
	else \
		echo "Upstream source tarball have been already downloaded: $(DEB_VCS_TARBALL_BASEDIR)/$(DEB_VCS_VIRGIN_FILENAME)" ; \
	fi

	@md5current=`md5sum "$(DEB_VCS_TARBALL_BASEDIR)/$(DEB_VCS_VIRGIN_FILENAME)" | sed -e 's/ .*//'`; \
	if [ -n "$(DEB_VCS_MD5)" ] ; then \
		if [ "$$md5current" != "$(DEB_VCS_MD5)" ] ; then \
			echo "Expecting upstream filename md5sum $(DEB_VCS_MD5), but $$md5current found" ; \
			echo "Upstream filename md5sum is NOT trusted! Possible upstream filename forge!" ; \
			echo "Purging downloaded file. Try new download." ; \
			rm -f "$(DEB_VCS_TARBALL_BASEDIR)/$(DEB_VCS_VIRGIN_FILENAME)" ; \
			false ; \
		else \
			echo "Upstream tarball is trusted!" ; \
		fi; \
	else \
		echo "Upstream tarball NOT trusted (current md5sum is $$md5current)!" ; \
	fi

	@if [ -n "$(DEB_VCS_DIRT_TAG)" ]; then \
		echo "Repackaging tarball ..." && \
		mkdir -p "$(DEB_VCS_TARBALL_BASEDIR)/$(DEB_VCS_DIRT_TAG)" && \
		tar -xzf "$(DEB_VCS_TARBALL_BASEDIR)/$(DEB_VCS_VIRGIN_FILENAME)" -C "$(DEB_VCS_TARBALL_BASEDIR)/$(DEB_VCS_DIRT_TAG)" $(patsubst %,--exclude='%',$(DEB_VCS_DIRT_EXCLUDES)) && \
		GZIP=-9 tar -b1 -czf "$(DEB_VCS_TARBALL_BASEDIR)/$(DEB_VCS_DIRTY_FILENAME)" -C "$(DEB_VCS_TARBALL_BASEDIR)/$(DEB_VCS_DIRT_TAG)" $(DEB_VCS_TARBALL_SRCDIR) && \
		echo "Cleaning up" && \
		rm -rf "$(DEB_VCS_TARBALL_BASEDIR)/$(DEB_VCS_DIRT_TAG)"; \
	fi

DEB_PHONY_RULES += print-version get-orig-source

endif
