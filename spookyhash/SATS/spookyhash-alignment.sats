(*

Copyright © 2021 Barry Schwartz

This program is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License, as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received copies of the GNU General Public License
along with this program. If not, see
<https://www.gnu.org/licenses/>.

*)

#define ATS_PACKNAME "ats2-spookyhash"
#define ATS_EXTERN_PREFIX "ats2_spookyhash_"

%{#
#include "spookyhash/CATS/spookyhash-implementation.cats"
%}

fun
is_uint64_aligned_g0 (p : ptr) :<> bool = "mac#%"

fun
is_uint64_aligned_g1 {p : addr} (p : ptr p) :<> bool = "mac#%"

overload is_uint64_aligned with is_uint64_aligned_g0 of 0
overload is_uint64_aligned with is_uint64_aligned_g1 of 10
