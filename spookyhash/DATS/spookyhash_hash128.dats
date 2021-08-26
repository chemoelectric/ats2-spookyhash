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

#include "spookyhash/DATS/include/spookyhash-templates.inc"

implement
spookyhash_hash128 {length} (message, length, seed1, seed2) =
  if length < i2sz BUFSIZE then
    spookyhash_short<> (message, length, seed1, seed2)
  else
    let
      var h0 : uint64 = seed1
      var h1 : uint64 = seed2
      var h2 : uint64 = ull2u64 CONST
      var h3 : uint64 = seed1
      var h4 : uint64 = seed2
      var h5 : uint64 = ull2u64 CONST
      var h6 : uint64 = seed1
      var h7 : uint64 = seed2
      var h8 : uint64 = ull2u64 CONST
      var h9 : uint64 = seed1
      var h10 : uint64 = seed2
      var h11 : uint64 = ull2u64 CONST

      (* Divide the message into blocks and a small remainder. *)
      stadef block_count = ndiv (length, BLOCKSIZE)
      stadef remainder = nmod (length, BLOCKSIZE)
      val block_count : size_t block_count =
        g1uint_div (length, i2sz BLOCKSIZE)
      val remainder : size_t remainder =
        natmod (length, i2sz BLOCKSIZE)

      prval _ = prop_verify {block_count * BLOCKSIZE + remainder
                                  == length} ()
      prval _ = prop_verify {remainder < BLOCKSIZE} ()

      prval (pf_blocks, pf_remainder) =
        array_v_subdivide2
          {byte} {..} {block_count * BLOCKSIZE, remainder}
          (view@ message)

      (* Handle all the full-size blocks. *)
      val _ = mix_in_blocks<> (pf_blocks |
                               addr@ message, block_count,
                               h0, h1, h2, h3, h4, h5,
                               h6, h7, h8, h9, h10, h11)

      (* Handle the remainder. *)

      var buf : @[uint64][NUMVARS]

      prval pf_bytes = array2bytesqmark<uint64?> {NUMVARS} (view@ buf)
      prval (pf_memcpy, pf_memset) =
        array_v_subdivide2
          {byte?} {..} {remainder, BLOCKSIZE - remainder}
          pf_bytes

      val p_remainder =
        ptr_add<byte> {..} {block_count * BLOCKSIZE}
                      (addr@ message, block_count * i2sz BLOCKSIZE)
      val p_memcpy = addr@ buf
      val p_memset = ptr_add<byte> {..} {remainder}
                                   (p_memcpy, remainder)
      val _ = memcpy (!p_memcpy, !p_remainder, remainder)
      val _ = memset (!p_memset, u2byte 0U,
                      i2sz BLOCKSIZE - remainder)

      prval _ = pf_bytes :=
        array_v_join2
          {byte} {..} {remainder, BLOCKSIZE - remainder}
          (pf_memcpy, pf_memset)

      val _ = buf[BLOCKSIZE - 1] := sz2byte remainder

      prval _ = view@ buf := bytes2array<uint64> {NUMVARS} pf_bytes
      prval _ = view@ message :=
        array_v_join2
          {byte} {..} {block_count * BLOCKSIZE, remainder}
          (pf_blocks, pf_remainder)

      val _ = spookyhash_end<> (buf, h0, h1, h2, h3, h4, h5,
                                h6, h7, h8, h9, h10, h11)
    in
      (h0, h1)
    end

implement
spookyhash_hash128_vars {length}
                        (message, length, seed1, seed2,
                         hash1, hash2) =
  let
    val (h1, h2) = 
      spookyhash_hash128 {length} (message, length, seed1, seed2)
  in
    hash1 := h1;
    hash2 := h2
  end
