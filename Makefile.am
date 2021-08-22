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

clean-local: code-coverage-clean
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

M4_DEPS =

AM_M4FLAGS =

TOTAL_M4FLAGS =
TOTAL_M4FLAGS += $(AM_M4FLAGS)
TOTAL_M4FLAGS += $(M4FLAGS)
TOTAL_M4FLAGS += $(XM4FLAGS)

%: %.m4 common-macros.m4
	@$(MKDIR_P) $(@D)
	$(call v,M4)$(M4) $(TOTAL_M4FLAGS) $(<) > $(@)

%.c: %.c.m4 common-macros.m4
	@$(MKDIR_P) $(@D)
	$(call v,M4)$(M4) $(TOTAL_M4FLAGS) $(<) > $(@)

PATSOPT_DEPS =

AM_PATSOPTFLAGS =
AM_PATSOPTFLAGS += -IATS $(builddir)
AM_PATSOPTFLAGS += -IATS $(srcdir)

TOTAL_PATSOPTFLAGS =
TOTAL_PATSOPTFLAGS += $(AM_PATSOPTFLAGS)
TOTAL_PATSOPTFLAGS += $(PATSOPTFLAGS)
TOTAL_PATSOPTFLAGS += $(XPATSOPTFLAGS)

%_sats.c: %.sats $(PATSOPT_DEPS)
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) -s $(<)

%_dats.c: %.dats $(PATSOPT_DEPS)
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) -d $(<)

#--------------------------------------------------------------------------
#
# The ATS2 library.
#

lib_LTLIBRARIES += libats2-spookyhash.la

SPOOKYHASH_PARAMETERS_HATS = spookyhash/HATS/spookyhash-parameters.hats
EXTRA_DIST += $(SPOOKYHASH_PARAMETERS_HATS)

SPOOKYHASH_IMPL_CATS = spookyhash/CATS/spookyhash-implementation.cats
EXTRA_DIST += $(SPOOKYHASH_IMPL_CATS)

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
$(SPOOKYHASH_SATS_C): $(SPOOKYHASH_SATS) $(SPOOKYHASH_IMPL_CATS) \
						$(SPOOKYHASH_PARAMETERS_HATS)
$(SPOOKYHASH_DATS_C): $(SPOOKYHASH_SATS) $(SPOOKYHASH_DATS) \
						$(SPOOKYHASH_IMPL_CATS) \
						$(SPOOKYHASH_PARAMETERS_HATS) \
						$(ARRAY_PRF_SATS)

nobase_nodist_pkginclude_HEADERS += $(SPOOKYHASH_SATS)

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
# 
# AM_DEFAULT_SOURCE_EXT = _dats.c
# 
# TESTS =
# TESTS += $(check_PROGRAMS)
# 
# DISTRIBUTED_ATS2_TESTS =
# 
# M4_GENERATED_ATS2_TESTS =
# M4_GENERATED_ATS2_TESTS += tests/test-spookyhash-2-4-64
# M4_GENERATED_ATS2_TESTS += tests/test-spookyhash-2-4-128
# M4_GENERATED_ATS2_TESTS += tests/test-spookyhash-4-8-64
# M4_GENERATED_ATS2_TESTS += tests/test-spookyhash-4-8-128
# M4_GENERATED_ATS2_TESTS += tests/test-spookyhash-2-4-64-hats
# M4_GENERATED_ATS2_TESTS += tests/test-spookyhash-4-8-64-hats
# M4_GENERATED_ATS2_TESTS += tests/test-halfspookyhash-2-4-32
# M4_GENERATED_ATS2_TESTS += tests/test-halfspookyhash-2-4-64
# M4_GENERATED_ATS2_TESTS += tests/test-halfspookyhash-4-8-32
# M4_GENERATED_ATS2_TESTS += tests/test-halfspookyhash-4-8-64
# M4_GENERATED_ATS2_TESTS += tests/test-halfspookyhash-2-4-32-hats
# M4_GENERATED_ATS2_TESTS += tests/test-halfspookyhash-4-8-32-hats
# M4_GENERATED_ATS2_TESTS += tests/test-key
# 
# tests_test_spookyhash_2_4_64_SOURCES =
# tests_test_spookyhash_2_4_64_SOURCES += tests/test-spookyhash-2-4-64_dats.c
# tests_test_spookyhash_2_4_64_SOURCES += tests/vectors_sats.c
# tests_test_spookyhash_2_4_64_SOURCES += tests/vectors-2-4_dats.c
# tests_test_spookyhash_2_4_64_LDADD =
# tests_test_spookyhash_2_4_64_LDADD += libats2-spookyhash.la
# tests_test_spookyhash_2_4_64_DEPENDENCIES =
# tests_test_spookyhash_2_4_64_DEPENDENCIES += tests/vectors-2-4.h
# tests_test_spookyhash_2_4_64_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_spookyhash_2_4_128_SOURCES =
# tests_test_spookyhash_2_4_128_SOURCES += tests/test-spookyhash-2-4-128_dats.c
# tests_test_spookyhash_2_4_128_SOURCES += tests/vectors_sats.c
# tests_test_spookyhash_2_4_128_SOURCES += tests/vectors-2-4_dats.c
# tests_test_spookyhash_2_4_128_LDADD =
# tests_test_spookyhash_2_4_128_LDADD += libats2-spookyhash.la
# tests_test_spookyhash_2_4_128_DEPENDENCIES =
# tests_test_spookyhash_2_4_128_DEPENDENCIES += tests/vectors-2-4.h
# tests_test_spookyhash_2_4_128_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_spookyhash_4_8_64_SOURCES =
# tests_test_spookyhash_4_8_64_SOURCES += tests/test-spookyhash-4-8-64_dats.c
# tests_test_spookyhash_4_8_64_SOURCES += tests/vectors_sats.c
# tests_test_spookyhash_4_8_64_SOURCES += tests/vectors-4-8_dats.c
# tests_test_spookyhash_4_8_64_LDADD =
# tests_test_spookyhash_4_8_64_LDADD += libats2-spookyhash.la
# tests_test_spookyhash_4_8_64_DEPENDENCIES =
# tests_test_spookyhash_4_8_64_DEPENDENCIES += tests/vectors-4-8.h
# tests_test_spookyhash_4_8_64_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_spookyhash_4_8_128_SOURCES =
# tests_test_spookyhash_4_8_128_SOURCES += tests/test-spookyhash-4-8-128_dats.c
# tests_test_spookyhash_4_8_128_SOURCES += tests/vectors_sats.c
# tests_test_spookyhash_4_8_128_SOURCES += tests/vectors-4-8_dats.c
# tests_test_spookyhash_4_8_128_LDADD =
# tests_test_spookyhash_4_8_128_LDADD += libats2-spookyhash.la
# tests_test_spookyhash_4_8_128_DEPENDENCIES =
# tests_test_spookyhash_4_8_128_DEPENDENCIES += tests/vectors-4-8.h
# tests_test_spookyhash_4_8_128_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_spookyhash_2_4_64_hats_SOURCES =
# tests_test_spookyhash_2_4_64_hats_SOURCES += tests/test-spookyhash-2-4-64-hats_dats.c
# tests_test_spookyhash_2_4_64_hats_SOURCES += tests/vectors_sats.c
# tests_test_spookyhash_2_4_64_hats_SOURCES += tests/vectors-2-4_dats.c
# tests_test_spookyhash_2_4_64_hats_LDADD =
# tests_test_spookyhash_2_4_64_hats_LDADD += libats2-spookyhash.la
# tests_test_spookyhash_2_4_64_hats_DEPENDENCIES =
# tests_test_spookyhash_2_4_64_hats_DEPENDENCIES += tests/vectors-2-4.h
# tests_test_spookyhash_2_4_64_hats_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_spookyhash_4_8_64_hats_SOURCES =
# tests_test_spookyhash_4_8_64_hats_SOURCES += tests/test-spookyhash-4-8-64-hats_dats.c
# tests_test_spookyhash_4_8_64_hats_SOURCES += tests/vectors_sats.c
# tests_test_spookyhash_4_8_64_hats_SOURCES += tests/vectors-4-8_dats.c
# tests_test_spookyhash_4_8_64_hats_LDADD =
# tests_test_spookyhash_4_8_64_hats_LDADD += libats2-spookyhash.la
# tests_test_spookyhash_4_8_64_hats_DEPENDENCIES =
# tests_test_spookyhash_4_8_64_hats_DEPENDENCIES += tests/vectors-4-8.h
# tests_test_spookyhash_4_8_64_hats_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_halfspookyhash_2_4_32_SOURCES =
# tests_test_halfspookyhash_2_4_32_SOURCES += tests/test-halfspookyhash-2-4-32_dats.c
# tests_test_halfspookyhash_2_4_32_SOURCES += tests/vectors_sats.c
# tests_test_halfspookyhash_2_4_32_SOURCES += tests/vectors-2-4_dats.c
# tests_test_halfspookyhash_2_4_32_LDADD =
# tests_test_halfspookyhash_2_4_32_LDADD += libats2-spookyhash.la
# tests_test_halfspookyhash_2_4_32_DEPENDENCIES =
# tests_test_halfspookyhash_2_4_32_DEPENDENCIES += tests/vectors-2-4.h
# tests_test_halfspookyhash_2_4_32_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_halfspookyhash_2_4_64_SOURCES =
# tests_test_halfspookyhash_2_4_64_SOURCES += tests/test-halfspookyhash-2-4-64_dats.c
# tests_test_halfspookyhash_2_4_64_SOURCES += tests/vectors_sats.c
# tests_test_halfspookyhash_2_4_64_SOURCES += tests/vectors-2-4_dats.c
# tests_test_halfspookyhash_2_4_64_LDADD =
# tests_test_halfspookyhash_2_4_64_LDADD += libats2-spookyhash.la
# tests_test_halfspookyhash_2_4_64_DEPENDENCIES =
# tests_test_halfspookyhash_2_4_64_DEPENDENCIES += tests/vectors-2-4.h
# tests_test_halfspookyhash_2_4_64_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_halfspookyhash_4_8_32_SOURCES =
# tests_test_halfspookyhash_4_8_32_SOURCES += tests/test-halfspookyhash-4-8-32_dats.c
# tests_test_halfspookyhash_4_8_32_SOURCES += tests/vectors_sats.c
# tests_test_halfspookyhash_4_8_32_SOURCES += tests/vectors-4-8_dats.c
# tests_test_halfspookyhash_4_8_32_LDADD =
# tests_test_halfspookyhash_4_8_32_LDADD += libats2-spookyhash.la
# tests_test_halfspookyhash_4_8_32_DEPENDENCIES =
# tests_test_halfspookyhash_4_8_32_DEPENDENCIES += tests/vectors-4-8.h
# tests_test_halfspookyhash_4_8_32_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_halfspookyhash_4_8_64_SOURCES =
# tests_test_halfspookyhash_4_8_64_SOURCES += tests/test-halfspookyhash-4-8-64_dats.c
# tests_test_halfspookyhash_4_8_64_SOURCES += tests/vectors_sats.c
# tests_test_halfspookyhash_4_8_64_SOURCES += tests/vectors-4-8_dats.c
# tests_test_halfspookyhash_4_8_64_LDADD =
# tests_test_halfspookyhash_4_8_64_LDADD += libats2-spookyhash.la
# tests_test_halfspookyhash_4_8_64_DEPENDENCIES =
# tests_test_halfspookyhash_4_8_64_DEPENDENCIES += tests/vectors-4-8.h
# tests_test_halfspookyhash_4_8_64_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_halfspookyhash_2_4_32_hats_SOURCES =
# tests_test_halfspookyhash_2_4_32_hats_SOURCES += tests/test-halfspookyhash-2-4-32-hats_dats.c
# tests_test_halfspookyhash_2_4_32_hats_SOURCES += tests/vectors_sats.c
# tests_test_halfspookyhash_2_4_32_hats_SOURCES += tests/vectors-2-4_dats.c
# tests_test_halfspookyhash_2_4_32_hats_LDADD =
# tests_test_halfspookyhash_2_4_32_hats_LDADD += libats2-spookyhash.la
# tests_test_halfspookyhash_2_4_32_hats_DEPENDENCIES =
# tests_test_halfspookyhash_2_4_32_hats_DEPENDENCIES += tests/vectors-2-4.h
# tests_test_halfspookyhash_2_4_32_hats_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_halfspookyhash_4_8_32_hats_SOURCES =
# tests_test_halfspookyhash_4_8_32_hats_SOURCES += tests/test-halfspookyhash-4-8-32-hats_dats.c
# tests_test_halfspookyhash_4_8_32_hats_SOURCES += tests/vectors_sats.c
# tests_test_halfspookyhash_4_8_32_hats_SOURCES += tests/vectors-4-8_dats.c
# tests_test_halfspookyhash_4_8_32_hats_LDADD =
# tests_test_halfspookyhash_4_8_32_hats_LDADD += libats2-spookyhash.la
# tests_test_halfspookyhash_4_8_32_hats_DEPENDENCIES =
# tests_test_halfspookyhash_4_8_32_hats_DEPENDENCIES += tests/vectors-4-8.h
# tests_test_halfspookyhash_4_8_32_hats_DEPENDENCIES += spookyhash/SATS/array_prf.sats
# 
# tests_test_key_SOURCES =
# tests_test_key_SOURCES += tests/test-key_dats.c
# tests_test_key_LDADD =
# tests_test_key_LDADD += libats2-spookyhash.la
# tests_test_key_DEPENDENCIES =
# 
# tests/vectors_sats.c: tests/vectors.sats
# tests/vectors_dats.c: tests/vectors.dats tests/vectors.sats
# EXTRA_DIST += tests/vectors.sats
# EXTRA_DIST += tests/vectors-2-4.dats
# EXTRA_DIST += tests/vectors-4-8.dats
# CLEANFILES += tests/vectors_sats.c
# CLEANFILES += tests/vectors-2-4_dats.c
# CLEANFILES += tests/vectors-4-8_dats.c
# 
# DISTRIBUTED_C_TESTS =
# 
# M4_GENERATED_C_TESTS =
# M4_GENERATED_C_TESTS += tests/test-spookyhash-2-4-64-C
# M4_GENERATED_C_TESTS += tests/test-spookyhash-2-4-128-C
# M4_GENERATED_C_TESTS += tests/test-spookyhash-4-8-64-C
# M4_GENERATED_C_TESTS += tests/test-spookyhash-4-8-128-C
# M4_GENERATED_C_TESTS += tests/test-halfspookyhash-2-4-32-C
# M4_GENERATED_C_TESTS += tests/test-halfspookyhash-2-4-64-C
# M4_GENERATED_C_TESTS += tests/test-halfspookyhash-4-8-32-C
# M4_GENERATED_C_TESTS += tests/test-halfspookyhash-4-8-64-C
# M4_GENERATED_C_TESTS += tests/test-key-C
# 
# tests_test_spookyhash_2_4_64_C_SOURCES =
# tests_test_spookyhash_2_4_64_C_SOURCES += tests/test-spookyhash-2-4-64-C.c
# tests_test_spookyhash_2_4_64_C_SOURCES += tests/vectors-2-4.h
# tests_test_spookyhash_2_4_64_C_LDADD =
# tests_test_spookyhash_2_4_64_C_LDADD += libspookyhash.la
# 
# tests_test_spookyhash_2_4_128_C_SOURCES =
# tests_test_spookyhash_2_4_128_C_SOURCES += tests/test-spookyhash-2-4-128-C.c
# tests_test_spookyhash_2_4_128_C_SOURCES += tests/vectors-2-4.h
# tests_test_spookyhash_2_4_128_C_LDADD =
# tests_test_spookyhash_2_4_128_C_LDADD += libspookyhash.la
# 
# tests_test_spookyhash_4_8_64_C_SOURCES =
# tests_test_spookyhash_4_8_64_C_SOURCES += tests/test-spookyhash-4-8-64-C.c
# tests_test_spookyhash_4_8_64_C_SOURCES += tests/vectors-4-8.h
# tests_test_spookyhash_4_8_64_C_LDADD =
# tests_test_spookyhash_4_8_64_C_LDADD += libspookyhash.la
# 
# tests_test_spookyhash_4_8_128_C_SOURCES =
# tests_test_spookyhash_4_8_128_C_SOURCES += tests/test-spookyhash-4-8-128-C.c
# tests_test_spookyhash_4_8_128_C_SOURCES += tests/vectors-4-8.h
# tests_test_spookyhash_4_8_128_C_LDADD =
# tests_test_spookyhash_4_8_128_C_LDADD += libspookyhash.la
# 
# tests_test_halfspookyhash_2_4_32_C_SOURCES =
# tests_test_halfspookyhash_2_4_32_C_SOURCES += tests/test-halfspookyhash-2-4-32-C.c
# tests_test_halfspookyhash_2_4_32_C_SOURCES += tests/vectors-2-4.h
# tests_test_halfspookyhash_2_4_32_C_LDADD =
# tests_test_halfspookyhash_2_4_32_C_LDADD += libspookyhash.la
# 
# tests_test_halfspookyhash_2_4_64_C_SOURCES =
# tests_test_halfspookyhash_2_4_64_C_SOURCES += tests/test-halfspookyhash-2-4-64-C.c
# tests_test_halfspookyhash_2_4_64_C_SOURCES += tests/vectors-2-4.h
# tests_test_halfspookyhash_2_4_64_C_LDADD =
# tests_test_halfspookyhash_2_4_64_C_LDADD += libspookyhash.la
# 
# tests_test_halfspookyhash_4_8_32_C_SOURCES =
# tests_test_halfspookyhash_4_8_32_C_SOURCES += tests/test-halfspookyhash-4-8-32-C.c
# tests_test_halfspookyhash_4_8_32_C_SOURCES += tests/vectors-4-8.h
# tests_test_halfspookyhash_4_8_32_C_LDADD =
# tests_test_halfspookyhash_4_8_32_C_LDADD += libspookyhash.la
# 
# tests_test_halfspookyhash_4_8_64_C_SOURCES =
# tests_test_halfspookyhash_4_8_64_C_SOURCES += tests/test-halfspookyhash-4-8-64-C.c
# tests_test_halfspookyhash_4_8_64_C_SOURCES += tests/vectors-4-8.h
# tests_test_halfspookyhash_4_8_64_C_LDADD =
# tests_test_halfspookyhash_4_8_64_C_LDADD += libspookyhash.la
# 
# tests_test_key_C_SOURCES =
# tests_test_key_C_SOURCES += tests/test-key-C.c
# tests_test_key_C_LDADD =
# tests_test_key_C_LDADD += libspookyhash.la
# 
# DISTRIBUTED_TESTS =
# DISTRIBUTED_TESTS += $(DISTRIBUTED_ATS2_TESTS)
# DISTRIBUTED_TESTS += $(DISTRIBUTED_C_TESTS)
# 
# GENERATED_TESTS =
# GENERATED_TESTS += $(M4_GENERATED_ATS2_TESTS)
# GENERATED_TESTS += $(M4_GENERATED_C_TESTS)
# 
# check_PROGRAMS =
# check_PROGRAMS += $(DISTRIBUTED_TESTS)
# check_PROGRAMS += $(GENERATED_TESTS)
# 
# EXTRA_DIST += $(DISTRIBUTED_ATS2_TESTS:%=%.dats)
# EXTRA_DIST += $(M4_GENERATED_ATS2_TESTS:%=%.dats.m4)
# EXTRA_DIST += $(DISTRIBUTED_C_TESTS:%=%.c)
# EXTRA_DIST += $(M4_GENERATED_C_TESTS:%=%.c.m4)
# 
# CLEANFILES += $(DISTRIBUTED_ATS2_TESTS:%=%_dats.c)
# CLEANFILES += $(M4_GENERATED_ATS2_TESTS:%=%.dats)
# CLEANFILES += $(M4_GENERATED_ATS2_TESTS:%=%_dats.c)
# CLEANFILES += $(M4_GENERATED_C_TESTS:%=%.c)
# 
# $(foreach f,$(M4_GENERATED_ATS2_TESTS), \
# 	$(eval $(f:%=%.dats) $(f:%=%_dats.c): $(f:%=%.dats.m4)))
# 
# $(foreach f,$(M4_GENERATED_C_TESTS), \
# 	$(eval $(f:%=%.c): $(f:%=%.c.m4)))
#
#--------------------------------------------------------------------------

EXTRA_DIST += reference-implementation/SpookyV2.cpp
EXTRA_DIST += reference-implementation/SpookyV2.h
EXTRA_DIST += reference-implementation/TestSpookyV2.cpp

#--------------------------------------------------------------------------
# local variables:
# coding: utf-8
# end:
