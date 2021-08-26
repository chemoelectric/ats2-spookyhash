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

staload "spookyhash/SATS/spookyhash-byte-order.sats"

(********************************************************************)

#ifdef WORDS_BIGENDIAN #then
  implement {}
  fix_byte_order_uint32 (x) = bswap x
#else
  implement {}
  fix_byte_order_uint32 (x) = x
#endif

#ifdef WORDS_BIGENDIAN #then
  implement {}
  fix_byte_order_uint64 (x) = bswap x
#else
  implement {}
  fix_byte_order_uint64 (x) = x
#endif

(********************************************************************)
(* local variables: *)
(* mode: ATS *)
(* end: *)
