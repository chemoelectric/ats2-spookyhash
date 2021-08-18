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

#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload "spookyhash/SATS/spookyhash.sats"

#include "spookyhash/HATS/spookyhash-parameters.hats"
#define NUMVARS ATS2_SPOOKYHASH_NUMVARS

(********************************************************************)

extern castfn
u2u8 {i : int} (i : uint i) :<> uint8 i

(********************************************************************)

extern fun
m_data (context : &spookyhash_context_t) :<!ref>
    [p : addr] (@[uint64][2 * NUMVARS] @ p,
                @[uint64][2 * NUMVARS] @ p -<lin,prf> void |
                ptr p) = "mac#%"

extern fun
m_state (context : &spookyhash_context_t) :<!ref>
    [p : addr] (@[uint64][NUMVARS] @ p,
                @[uint64][NUMVARS] @ p -<lin,prf> void |
                ptr p) = "mac#%"

extern fun
m_length (context : &spookyhash_context_t) :<!ref>
    [p : addr] (size_t @ p,
                size_t @ p -<lin,prf> void |
                ptr p) = "mac#%"

extern fun
m_remainder (context : &spookyhash_context_t) :<!ref>
    [p : addr] (uint8 @ p,
                uint8 @ p -<lin,prf> void |
                ptr p) = "mac#%"

(********************************************************************)

implement
spookyhash_init (context, seed1, seed2) =
  {
    val (pf, fpf | p) = m_length (context)
    val _ = !p := i2sz 0
    prval _ = fpf pf

    val (pf, fpf | p) = m_remainder (context)
    val _ = !p := u2u8 0U
    prval _ = fpf pf

    val (pf, fpf | p) = m_state (context)
    macdef state = !p
    val _ = state[0] := seed1
    val _ = state[1] := seed2
    prval _ = fpf pf
  }

(********************************************************************)
