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

(********************************************************************)
(* bswap: Reverse the byte order. *)

fun
bswap32 (x : uint32) :<> uint32 = "mac#%"

fun
bswap64 (x : uint64) :<> uint64 = "mac#%"

overload bswap with bswap32
overload bswap with bswap64

(********************************************************************)
(* fix_byte_order:
   On big-endian platforms, reverse the byte order.
   On little-endian platforms, make no changes.  *)

fun {}
fix_byte_order_uint32 (x : uint32) :<> uint32

fun {}
fix_byte_order_uint64 (x : uint64) :<> uint64

overload fix_byte_order with fix_byte_order_uint32
overload fix_byte_order with fix_byte_order_uint64

(********************************************************************)
