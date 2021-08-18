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

(* Spookyhash version 2 *)


%{#
#include "spookyhash/CATS/spookyhash.cats"
%}

#include "spookyhash/HATS/spookyhash-parameters.hats"

#define ATS_PACKNAME "ats2-spookyhash"
#define ATS_EXTERN_PREFIX "ats2_spookyhash_"

typedef spookyhash_context_t = $extype"ats2_spookyhash_context_t"

(*
  spookyhash_init:
  Any 64-bit value will work, including zero.
  Different seeds produce independent hashes.
*)
fun
spookyhash_init (context : &spookyhash_context_t,
                 seed1   : uint64,
                 seed2   : uint64) :<!refwrt> void

(*
  spookyhash_update:
  Add a message fragment to the state.
*)
fun
spookyhash_update {length  : int}
                  (context : &spookyhash_context_t,
                   message : &(@[byte][length]),
                   length  : size_t length) :<!refwrt> void
