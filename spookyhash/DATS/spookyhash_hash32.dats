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

staload "spookyhash/SATS/spookyhash.sats"
staload "spookyhash/SATS/spookyhash-casts.sats"

implement
spookyhash_hash32 (message, length, seed) =
  let
    val seed = u32u64 seed
    val hash = (spookyhash_hash128 (message, length, seed, seed)).0
  in
    u64u32 hash
  end
