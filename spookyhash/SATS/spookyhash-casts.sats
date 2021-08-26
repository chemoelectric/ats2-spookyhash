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

(*
  The C standard specifies: "[I]f the new type is unsigned,
  the value is converted by repeatedly adding or subtracting
  one more than the maximum value that can be represented in
  the new type until the value is in the range of the new
  type." In other words, casts from larger unsigned to smaller
  unsigned will truncate for us nicely.

  Also notable is that atstype_byte is equivalent to unsigned
  char.
*)

castfn
g1ofg1_g1uint {tk : tkind}
              {i  : int}
              (i  : g1uint (tk, i)) :<>
    [j : int | j == i] g1uint (tk, j)

castfn
g1ofg1_ptr {p : addr}
           (p : ptr p) :<>
    [q : addr | q == p] ptr q

overload g1ofg1 with g1ofg1_g1uint
overload g1ofg1 with g1ofg1_ptr

castfn
u2u8 {i : int} (i : uint i) :<> uint8 i

castfn
u2u64 {i : int} (i : uint i) :<> uint64 i

castfn
u32u64 (i : uint32) :<> uint64

castfn
u64u32 (i : uint64) :<> uint32

castfn
byte2u64 (b : byte) :<> uint64

castfn
u8sz {i : int} (i : uint8 i) :<> size_t i

castfn
sz2u8 {i : int} (i : size_t i) :<> uint8 i

castfn
sz2u64 {i : int} (i : size_t i) :<> uint64 i

castfn
sz2byte {i : int | i < 256}
        (i : size_t i) :<> byte

castfn
u2byte (i : uint) :<> byte

castfn
ull2u64 (i : ullint) :<> uint64
