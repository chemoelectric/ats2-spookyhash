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

(* An interface to memcpy or __builtin_memcpy. *)
fun
memcpy {n   : int}
       (dst : &(@[byte?][n]) >> @[byte][n],
        src : &RD(@[byte][n]),
        n   : size_t n) :<!refwrt> void = "mac#%"

(* An interface to memset or __builtin_memset. *)
fun
memset {n     : int}
       (dst   : &(@[byte?][n]) >> @[byte][n],
        value : byte,
        n     : size_t n) :<!refwrt> void = "mac#%"
