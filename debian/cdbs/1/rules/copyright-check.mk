# -*- mode: makefile; coding: utf-8 -*-
# Copyright © 2005-2006 Jonas Smedegaard <dr@jones.dk>
# Description: Check for changes to copyright notices in source
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

ifndef _cdbs_bootstrap
_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class
endif

ifndef _cdbs_rules_copyright-check
_cdbs_rules_copyright-check := 1

include $(_cdbs_rules_path)/buildcore.mk$(_cdbs_makefile_suffix)

cdbs_copyright-check_find_opts := -not -regex '\./debian/.*'

clean::
	@echo 'Scanning upstream source for new/changed copyright notices...'
	@echo '(the debian/ subdir is _not_ examined - do that manually!)'
	find . -type f $(cdbs_copyright-check_find_opts) -exec cat '{}' ';' \
		| egrep --text -rih '(copyright|\(c\) ).*[0-9]{4}' \
		| sed -e 's/^[[:space:]*#]*//' -e 's/[[:space:]]*$$//' \
		| LC_ALL=C sort -u \
		> debian/copyright_newhints
	if [ ! -f debian/copyright_hints ]; then touch debian/copyright_hints; fi
	@echo "diff --normal debian/copyright_hints debian/copyright_newhints | egrep '^>'"
	@diff --normal debian/copyright_hints debian/copyright_newhints | egrep '^>'; \
		if [ "$$?" -eq "0" ]; then \
			echo "New or changed copyright notices discovered! Do this:"; \
			echo "  1) Search source for each of the above lines ('grep -r' is your friend)"; \
			echo "  2) Update debian/copyright as needed"; \
			echo "  3) Replace debian/copyright_hints with debian/copyright_newhints"; \
			exit 1; \
		fi
	
	@echo 'No new copyright notices found - assuming no news is good news...'
	rm -f debian/copyright_newhints

endif
