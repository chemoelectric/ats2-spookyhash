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

#include "try-spookyhash-common.hats"

implement
main0 (argc, argv) =
  {
    val seed1 = get_seed1 (argc, argv)
    val seed2 = get_seed2 (argc, argv)
    val length = get_length (argc, argv)
    val pattern = get_pattern (argc, argv)
    val reference_hash1 = get_reference_hash1 (argc, argv)
    val reference_hash2 = get_reference_hash2 (argc, argv)

    val [length : int] length = g1ofg0 length

    fn
    misalign {misalignment : int | 0 <= misalignment}
             (misalignment : size_t misalignment) :
        @(uint64, uint64) =
      let
        val (pf_msg, pf_msg_mem | p_msg) =
          malloc_gc (misalignment + length)
        prval (pf_padding, pf_data) =
          array_v_split
            {byte?} {..} {misalignment + length} {misalignment}
            pf_msg
        val p_data = ptr_add<byte> (p_msg, misalignment)
        val _ = fill_message (pf_data | p_data, length, pattern)
        val (hash1, hash2) =
          spookyhash_hash128 (!p_data, length, seed1, seed2)
        prval _ = pf_msg := array_v_unsplit (pf_padding, pf_data)
        val _ = mfree_gc (pf_msg, pf_msg_mem | p_msg)
      in
        (hash1, hash2)
      end

    val _ =
      let
        val misalignment_max = 16 * sizeof<uint64>
        prval _ = lemma_sizeof {uint64} ()
        var i : [i : int | 0 <= i] size_t i
      in
        (* Try various misalignments. *)
        for (i := i2sz 0; i <= misalignment_max; i := succ i)
          let
            val (hash1, hash2) = misalign (i)
          in
            if (hash1 <> reference_hash1 ||
                  hash2 <> reference_hash2) then
              {
                val _ = $extfcall (int, "printf", "Expected:\n")
                val _ = $extfcall (void, "print_hash128_results",
                                   seed1, seed2, length, pattern,
                                   reference_hash1, reference_hash2)
                val _ = $extfcall (int, "printf", "Got:\n")
                val _ = $extfcall (void, "print_hash128_results",
                                   seed1, seed2, length, pattern,
                                   hash1, hash2)
                val _ = $extfcall (void, "exit", 1)
              }
          end
      end
  }
