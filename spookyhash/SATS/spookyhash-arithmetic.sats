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

(* A natural numbers MOD function. *)
fun
natmod_size {x, y : nat | y != 0}
            (x    : size_t x,
             y    : size_t y) :<>
    [z : nat | z <= x; z < y; z == x mod y]
    size_t z = "mac#%"
overload natmod with natmod_size

(* Bitwise AND. *)
fun
bitwise_and_ullint (x : ullint, y : ullint) :<> ullint = "mac#%"
fun
bitwise_and_uint64 (x : uint64, y : uint64) :<> uint64 = "mac#%"
overload bitwise_and with bitwise_and_ullint
overload bitwise_and with bitwise_and_uint64

(* Bitwise XOR. *)
fun
bitwise_xor_uint64 (x : uint64, y : uint64) :<> uint64 = "mac#%"
overload bitwise_xor with bitwise_xor_uint64

(* Bitwise LEFT SHIFT. *)
fun
bitwise_lshift_uint64_uint {i : int | i < 64}
                           (x : uint64,
                            i : uint i) :<> uint64 = "mac#%"
overload bitwise_lshift with bitwise_lshift_uint64_uint

(* Bitwise LEFT ROTATE. *)
fun
bitwise_lrotate_uint64_uint {i : int | i < 64}
                            (x : uint64,
                             i : uint i) :<> uint64 = "mac#%"
overload bitwise_lrotate with bitwise_lrotate_uint64_uint
