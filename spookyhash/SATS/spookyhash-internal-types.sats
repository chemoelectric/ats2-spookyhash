(*

Copyright © 2018, 2021 Barry Schwartz

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

staload "spookyhash/SATS/spookyhash.sats"

#include "spookyhash/HATS/spookyhash-ats-parameters.hats"

typedef remainder_t (i : int) = [i < BUFSIZE] g1uint (uint8knd, i)
typedef remainder_t = [i : int] remainder_t i

fun
m_data (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (@[uint64][TWICE_NUMVARS] @ p,
     @[uint64][TWICE_NUMVARS] @ p -<lin,prf> void |
     ptr p) = "mac#%"

fun
m_state (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (@[uint64][NUMVARS] @ p,
     @[uint64][NUMVARS] @ p -<lin,prf> void |
     ptr p) = "mac#%"

fun
m_length (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (Size_t @ p,
     Size_t @ p -<lin,prf> void |
     ptr p) = "mac#%"

fun
m_remainder (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (remainder_t @ p,
     remainder_t @ p -<lin,prf> void |
     ptr p) = "mac#%"
