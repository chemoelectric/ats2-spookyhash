#
# Copyright © 2021 Barry Schwartz
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License, as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received copies of the GNU General Public License
# along with this program. If not, see
# <https://www.gnu.org/licenses/>.
#

.DELETE_ON_ERROR:

ACLOCAL_AMFLAGS = -I m4 --install
AUTOMAKE_OPTIONS =
AUTOMAKE_OPTIONS += foreign
AUTOMAKE_OPTIONS += subdir-objects
AUTOMAKE_OPTIONS += -Wno-portability

include $(top_srcdir)/aminclude_static.am
@GNU@ include $(srcdir)/silent-rules.mk

#SUBDIRS = lib

EXTRA_DIST =
MOSTLYCLEANFILES =
CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
AM_CPPFLAGS =
AM_CFLAGS =
AM_LDFLAGS =
LDADD =
bin_PROGRAMS =
lib_LTLIBRARIES =
EXTRA_PROGRAMS =
nobase_nodist_pkginclude_HEADERS =

pkgconfigdir = ${libdir}/pkgconfig
nodist_pkgconfig_DATA =

EXTRA_DIST += $(srcdir)/silent-rules.mk
EXTRA_DIST += COPYING
EXTRA_DIST += INSTALL
EXTRA_DIST += README
EXTRA_DIST += AUTHORS

DISTCLEANFILES += Makefile
DISTCLEANFILES += GNUmakefile
#DISTCLEANFILES += lib/Makefile
#DISTCLEANFILES += lib/GNUmakefile

# We will not be using exceptions.
AM_CPPFLAGS += -D_ATS_CCOMP_EXCEPTION_NONE

AM_CPPFLAGS += -I$(builddir)
AM_CPPFLAGS += -I$(srcdir)
AM_CPPFLAGS += -I$(PATSHOME)
AM_CPPFLAGS += -I$(PATSHOME)/ccomp/runtime/
AM_CPPFLAGS += -I$(builddir)/lib
AM_CPPFLAGS += -I$(srcdir)/lib

LDADD += $(CODE_COVERAGE_LIBS)

CODE_COVERAGE_IGNORE_PATTERN =
CODE_COVERAGE_IGNORE_PATTERN += /usr/include/*
CODE_COVERAGE_IGNORE_PATTERN += /usr/include/*/*
CODE_COVERAGE_IGNORE_PATTERN += $(PATSHOME)/ccomp/runtime/*
CODE_COVERAGE_IGNORE_PATTERN += $(PATSHOME)/prelude/CATS/*

clean-local: code-coverage-clean tests-clean
distclean-local: code-coverage-dist-clean

#EXTRA_DIST += m4/gnulib-cache.m4

#---------------------------------------------------------------------
#
# Some GNU Make aids you might want to use.
#

comma := ,
empty :=
space := $(empty) $(empty)

# Escape things for sed expressions, etc.
escape = $(subst $$,\$$,$(subst ^,\^,$(subst ],\],$(subst [,\[,$(subst .,\.,$(subst \,\\,$(1)))))))

#--------------------------------------------------------------------------

#M4_DEPS =
#
#AM_M4FLAGS =
#
#TOTAL_M4FLAGS =
#TOTAL_M4FLAGS += $(AM_M4FLAGS)
#TOTAL_M4FLAGS += $(M4FLAGS)
#TOTAL_M4FLAGS += $(XM4FLAGS)
#
#%: %.m4 common-macros.m4
#	@$(MKDIR_P) $(@D)
#	$(call v,M4)$(M4) $(TOTAL_M4FLAGS) $(<) > $(@)
#
#%.c: %.c.m4 common-macros.m4
#	@$(MKDIR_P) $(@D)
#	$(call v,M4)$(M4) $(TOTAL_M4FLAGS) $(<) > $(@)

PATSOPT_DEPS =

AM_PATSOPTFLAGS =
AM_PATSOPTFLAGS += -IATS $(builddir)
AM_PATSOPTFLAGS += -IATS $(srcdir)

TOTAL_PATSOPTFLAGS =
TOTAL_PATSOPTFLAGS += $(AM_PATSOPTFLAGS)
TOTAL_PATSOPTFLAGS += $(PATSOPTFLAGS)
TOTAL_PATSOPTFLAGS += $(XPATSOPTFLAGS)

TESTS_PATSOPTFLAGS =
TESTS_PATSOPTFLAGS += -IATS $(builddir)/tests
TESTS_PATSOPTFLAGS += -IATS $(srcdir)/tests

%_sats.c: %.sats $(PATSOPT_DEPS)
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) -s $(<)

%_dats.c: %.dats $(PATSOPT_DEPS)
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) -d $(<)

%_tests.c: %.dats $(PATSOPT_DEPS)
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) \
			$(TESTS_PATSOPTFLAGS) -d $(<)

#--------------------------------------------------------------------------
#
# The ATS2 library.
#

lib_LTLIBRARIES += libats2-spookyhash.la

SPOOKYHASH_PARAMETERS_HATS = spookyhash/HATS/spookyhash-parameters.hats
EXTRA_DIST += $(SPOOKYHASH_PARAMETERS_HATS)

SPOOKYHASH_IMPL_CATS = spookyhash/CATS/spookyhash-implementation.cats
EXTRA_DIST += $(SPOOKYHASH_IMPL_CATS)

SPOOKYHASH_CATS = spookyhash/CATS/spookyhash.cats
EXTRA_DIST += $(SPOOKYHASH_CATS)

ARRAY_PRF_SATS = spookyhash/SATS/array_prf.sats
ARRAY_PRF_SATS_C = spookyhash/SATS/array_prf_sats.c
EXTRA_DIST += $(ARRAY_PRF_SATS)
CLEANFILES += $(ARRAY_PRF_SATS_C)

ARRAY_PRF_DATS = spookyhash/DATS/array_prf.dats
ARRAY_PRF_DATS_C = spookyhash/DATS/array_prf_dats.c
EXTRA_DIST += $(ARRAY_PRF_DATS)
CLEANFILES += $(ARRAY_PRF_DATS_C)

SPOOKYHASH_SATS = spookyhash/SATS/spookyhash.sats
SPOOKYHASH_SATS_C = spookyhash/SATS/spookyhash_sats.c
EXTRA_DIST += $(SPOOKYHASH_SATS)
CLEANFILES += $(SPOOKYHASH_SATS_C)

SPOOKYHASH_DATS = spookyhash/DATS/spookyhash.dats
SPOOKYHASH_DATS_C = spookyhash/DATS/spookyhash_dats.c
EXTRA_DIST += $(SPOOKYHASH_DATS)
CLEANFILES += $(SPOOKYHASH_DATS_C)

nodist_libats2_spookyhash_la_SOURCES =
nodist_libats2_spookyhash_la_SOURCES += $(ARRAY_PRF_SATS_C)
nodist_libats2_spookyhash_la_SOURCES += $(ARRAY_PRF_DATS_C)
nodist_libats2_spookyhash_la_SOURCES += $(SPOOKYHASH_SATS_C)
nodist_libats2_spookyhash_la_SOURCES += $(SPOOKYHASH_DATS_C)

$(ARRAY_PRF_SATS_C): $(ARRAY_PRF_SATS)
$(ARRAY_PRF_DATS_C): $(ARRAY_PRF_SATS) $(ARRAY_PRF_DATS)
$(SPOOKYHASH_SATS_C): $(SPOOKYHASH_SATS) $(SPOOKYHASH_CATS) \
						$(SPOOKYHASH_IMPL_CATS) \
						$(SPOOKYHASH_PARAMETERS_HATS)
$(SPOOKYHASH_DATS_C): $(SPOOKYHASH_SATS) $(SPOOKYHASH_CATS) \
						$(SPOOKYHASH_DATS) \
						$(SPOOKYHASH_IMPL_CATS) \
						$(SPOOKYHASH_PARAMETERS_HATS) \
						$(ARRAY_PRF_SATS)

nobase_nodist_pkginclude_HEADERS += $(SPOOKYHASH_SATS)
nobase_nodist_pkginclude_HEADERS += $(SPOOKYHASH_CATS)

#--------------------------------------------------------------------------

EXTRA_PROGRAMS += tests/compute-reference-result
CLEANFILES += tests/compute-reference-result

tests_compute_reference_result_SOURCES =
tests_compute_reference_result_SOURCES += tests/compute-reference-result.cpp
tests_compute_reference_result_SOURCES += tests/SpookyV2.cpp
tests_compute_reference_result_SOURCES += tests/SpookyV2.h
tests_compute_reference_result_CPPFLAGS =
tests_compute_reference_result_CPPFLAGS += $(AM_CPPFLAGS)
tests_compute_reference_result_CPPFLAGS += -I$(builddir)/tests
tests_compute_reference_result_CPPFLAGS += -I$(srcdir)/tests

EXTRA_PROGRAMS += tests/try-spookyhash_hash128
CLEANFILES += tests/try-spookyhash_hash128
CLEANFILES += tests/try-spookyhash_hash128_tests.c

tests_try_spookyhash_hash128_SOURCES =
tests_try_spookyhash_hash128_SOURCES += tests/try-spookyhash_hash128_tests.c
tests_try_spookyhash_hash128_DEPENDENCIES =
tests_try_spookyhash_hash128_DEPENDENCIES += tests/try-spookyhash_hash128.dats
tests_try_spookyhash_hash128_DEPENDENCIES += tests/try-spookyhash-common.hats
tests_try_spookyhash_hash128_DEPENDENCIES += libats2-spookyhash.la
tests_try_spookyhash_hash128_LDADD =
tests_try_spookyhash_hash128_LDADD += libats2-spookyhash.la

EXTRA_PROGRAMS += tests/try-spookyhash_hash64
CLEANFILES += tests/try-spookyhash_hash64
CLEANFILES += tests/try-spookyhash_hash64_tests.c

tests_try_spookyhash_hash64_SOURCES =
tests_try_spookyhash_hash64_SOURCES += tests/try-spookyhash_hash64_tests.c
tests_try_spookyhash_hash64_DEPENDENCIES =
tests_try_spookyhash_hash64_DEPENDENCIES += tests/try-spookyhash_hash64.dats
tests_try_spookyhash_hash64_DEPENDENCIES += tests/try-spookyhash-common.hats
tests_try_spookyhash_hash64_DEPENDENCIES += libats2-spookyhash.la
tests_try_spookyhash_hash64_LDADD =
tests_try_spookyhash_hash64_LDADD += libats2-spookyhash.la

EXTRA_PROGRAMS += tests/try-spookyhash_hash32
CLEANFILES += tests/try-spookyhash_hash32
CLEANFILES += tests/try-spookyhash_hash32_tests.c

tests_try_spookyhash_hash32_SOURCES =
tests_try_spookyhash_hash32_SOURCES += tests/try-spookyhash_hash32_tests.c
tests_try_spookyhash_hash32_DEPENDENCIES =
tests_try_spookyhash_hash32_DEPENDENCIES += tests/try-spookyhash_hash32.dats
tests_try_spookyhash_hash32_DEPENDENCIES += tests/try-spookyhash-common.hats
tests_try_spookyhash_hash32_DEPENDENCIES += libats2-spookyhash.la
tests_try_spookyhash_hash32_LDADD =
tests_try_spookyhash_hash32_LDADD += libats2-spookyhash.la

EXTRA_PROGRAMS += tests/try-spookyhash-incremental
CLEANFILES += tests/try-spookyhash-incremental
CLEANFILES += tests/try-spookyhash-incremental_tests.c

tests_try_spookyhash_incremental_SOURCES =
tests_try_spookyhash_incremental_SOURCES += tests/try-spookyhash-incremental_tests.c
tests_try_spookyhash_incremental_DEPENDENCIES =
tests_try_spookyhash_incremental_DEPENDENCIES += tests/try-spookyhash-incremental.dats
tests_try_spookyhash_incremental_DEPENDENCIES += tests/try-spookyhash-common.hats
tests_try_spookyhash_incremental_DEPENDENCIES += libats2-spookyhash.la
tests_try_spookyhash_incremental_LDADD =
tests_try_spookyhash_incremental_LDADD += libats2-spookyhash.la

EXTRA_PROGRAMS += tests/try-spookyhash_hash128-misaligned
CLEANFILES += tests/try-spookyhash_hash128-misaligned
CLEANFILES += tests/try-spookyhash_hash128-misaligned_tests.c

tests_try_spookyhash_hash128_misaligned_SOURCES =
tests_try_spookyhash_hash128_misaligned_SOURCES += tests/try-spookyhash_hash128-misaligned_tests.c
tests_try_spookyhash_hash128_misaligned_DEPENDENCIES =
tests_try_spookyhash_hash128_misaligned_DEPENDENCIES += tests/try-spookyhash_hash128-misaligned.dats
tests_try_spookyhash_hash128_misaligned_DEPENDENCIES += tests/try-spookyhash-common.hats
tests_try_spookyhash_hash128_misaligned_DEPENDENCIES += libats2-spookyhash.la
tests_try_spookyhash_hash128_misaligned_LDADD =
tests_try_spookyhash_hash128_misaligned_LDADD += libats2-spookyhash.la

EXTRA_DIST += tests/try-spookyhash_hash128.dats
EXTRA_DIST += tests/try-spookyhash_hash64.dats
EXTRA_DIST += tests/try-spookyhash_hash32.dats
EXTRA_DIST += tests/try-spookyhash-incremental.dats
EXTRA_DIST += tests/try-spookyhash-common.hats
EXTRA_DIST += tests/try-spookyhash_hash128-misaligned.dats

tests/try-spookyhash_hash128_tests.c: tests/try-spookyhash_hash128.dats
tests/try-spookyhash_hash128_tests.c: tests/try-spookyhash-common.hats
tests/try-spookyhash_hash64_tests.c: tests/try-spookyhash_hash64.dats
tests/try-spookyhash_hash64_tests.c: tests/try-spookyhash-common.hats
tests/try-spookyhash_hash32_tests.c: tests/try-spookyhash_hash32.dats
tests/try-spookyhash_hash32_tests.c: tests/try-spookyhash-common.hats
tests/try-spookyhash-incremental_tests.c: tests/try-spookyhash-incremental.dats
tests/try-spookyhash-incremental_tests.c: tests/try-spookyhash-common.hats
tests/try-spookyhash_hash128-misaligned_tests.c: tests/try-spookyhash_hash128-misaligned.dats
tests/try-spookyhash_hash128-misaligned_tests.c: tests/try-spookyhash-common.hats

EXTRA_DIST += tests/compute-reference-for-seeds-eq-zero.sh
EXTRA_DIST += $(srcdir)/tests/reference-for-seeds-eq-zero.dat

$(srcdir)/tests/reference-for-seeds-eq-zero.dat: \
				tests/compute-reference-for-seeds-eq-zero.sh \
				tests/compute-reference-result
# If the srcdir is unwritable, do not try to write over the test
# data. This will be the case during a ‘make distcheck’.
	if test -w $(@D) ; then $(<) > $(@) ; else : ; fi

TESTS =
TESTS += tests/test-spookyhash_hash128-for-seeds-eq-zero.sh
TESTS += tests/test-spookyhash_hash64-for-seeds-eq-zero.sh
TESTS += tests/test-spookyhash_hash32-for-seeds-eq-zero.sh
TESTS += tests/test-spookyhash-incremental-for-seeds-eq-zero.sh
TESTS += tests/test-spookyhash_hash128-misaligned-for-seeds-eq-zero.sh

$(TESTS): $(srcdir)/tests/reference-for-seeds-eq-zero.dat
$(TESTS): tests/try-spookyhash_hash128
$(TESTS): tests/test-spookyhash_hash128.sh
$(TESTS): tests/try-spookyhash_hash64
$(TESTS): tests/test-spookyhash_hash64.sh
$(TESTS): tests/try-spookyhash_hash32
$(TESTS): tests/test-spookyhash_hash32.sh
$(TESTS): tests/try-spookyhash-incremental
$(TESTS): tests/test-spookyhash-incremental.sh
$(TESTS): tests/try-spookyhash_hash128-misaligned
$(TESTS): tests/test-spookyhash_hash128-misaligned.sh

tests-clean:
	-rm -f tests/*.o

# #--------------------------------------------------------------------------
# #
# # The C library.
# #
# 
# lib_LTLIBRARIES += libspookyhash.la
# 
# SPOOKYHASH_C_DATS = spookyhash/DATS/spookyhash_c.dats
# SPOOKYHASH_C_DATS_C = spookyhash/DATS/spookyhash_c_dats.c
# EXTRA_DIST += $(SPOOKYHASH_C_DATS)
# CLEANFILES += $(SPOOKYHASH_C_DATS_C)
# 
# HALFSPOOKYHASH_C_DATS = spookyhash/DATS/halfspookyhash_c.dats
# HALFSPOOKYHASH_C_DATS_C = spookyhash/DATS/halfspookyhash_c_dats.c
# EXTRA_DIST += $(HALFSPOOKYHASH_C_DATS)
# CLEANFILES += $(HALFSPOOKYHASH_C_DATS_C)
# 
# KEY_C_DATS = spookyhash/DATS/key_c.dats
# KEY_C_DATS_C = spookyhash/DATS/key_c_dats.c
# EXTRA_DIST += $(KEY_C_DATS)
# CLEANFILES += $(KEY_C_DATS_C)
# 
# libspookyhash_la_SOURCES =
# libspookyhash_la_SOURCES += $(SPOOKYHASH_C_DATS_C)
# libspookyhash_la_SOURCES += $(HALFSPOOKYHASH_C_DATS_C)
# libspookyhash_la_SOURCES += $(KEY_C_DATS_C)
# libspookyhash_la_SOURCES += spookyhash/spookyhash.h
# libspookyhash_la_SOURCES += spookyhash/halfspookyhash.h
# libspookyhash_la_SOURCES += spookyhash/key.h
# 
# libspookyhash_la_LIBADD =
# libspookyhash_la_LIBADD += libats2-spookyhash.la
# 
# nobase_nodist_pkginclude_HEADERS += $(SPOOKYHASH_C_DATS)
# nobase_nodist_pkginclude_HEADERS += $(HALFSPOOKYHASH_C_DATS)
# nobase_nodist_pkginclude_HEADERS += spookyhash/spookyhash.h
# nobase_nodist_pkginclude_HEADERS += spookyhash/halfspookyhash.h
# nobase_nodist_pkginclude_HEADERS += spookyhash/key.h
# 
# #--------------------------------------------------------------------------
# 
# nodist_pkgconfig_DATA += ats2-spookyhash.pc
# nodist_pkgconfig_DATA += spookyhash.pc
# 
# #--------------------------------------------------------------------------

EXTRA_DIST += reference-implementation/SpookyV2.cpp
EXTRA_DIST += reference-implementation/SpookyV2.h
EXTRA_DIST += reference-implementation/TestSpookyV2.cpp

#--------------------------------------------------------------------------
# local variables:
# coding: utf-8
# end:
