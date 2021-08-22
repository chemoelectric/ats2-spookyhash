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

#define ATS_PACKNAME "ats2-spookyhash"
#define ATS_EXTERN_PREFIX "ats2_spookyhash_"

(********************************************************************)

fun
spookyhash_hash128 {length  : int}
                   (message : &(@[byte][length]),
                    length  : size_t length,
                    seed1   : uint64,
                    seed2   : uint64) :<!refwrt>
    @(uint64,         (* The first 64 bits (in native byte order). *)
      uint64)         (* The second 64 bits (in native byte order). *)

fun
spookyhash_hash64 {length  : int}
                  (message : &(@[byte][length]),
                   length  : size_t length,
                   seed    : uint64) :<!refwrt>
    uint64                     (* The first 64 bits of the hash value,
                                  in native byte order. *)

fun
spookyhash_hash32 {length  : int}
                  (message : &(@[byte][length]),
                   length  : size_t length,
                   seed    : uint32) :<!refwrt>
    uint32                     (* The first 32 bits of the hash value,
                                  in native byte order. *)

(********************************************************************)
(* Calculation of a hash by incrementally updating.                 *)

typedef spookyhash_context_t = $extype"ats2_spookyhash_context_t"

(* spookyhash_init:

   Initialize the context of a SpookyHash.

   Any 64-bit value, including zero, will work as a seed.
   Different seeds produce independent hashes. *)
fun
spookyhash_init (context : &spookyhash_context_t?
                              >> spookyhash_context_t,
                 seed1   : uint64,
                 seed2   : uint64) :<!refwrt> void

(* spookyhash_update:

   Add a message fragment to the context. *)
fun
spookyhash_update {length  : int}
                  (context : &spookyhash_context_t,
                   message : &(@[byte][length]),
                   length  : size_t length) :<!refwrt> void

(* spookyhash_final:

   Compute the hash for the current context.

   You can continue updating the context, even after
   you have used spookyhash_final. *)
fun
spookyhash_final (context : &spookyhash_context_t) :<!refwrt>
    @(uint64,         (* The first 64 bits (in native byte order). *)
      uint64)         (* The second 64 bits (in native byte order). *)

(********************************************************************)
