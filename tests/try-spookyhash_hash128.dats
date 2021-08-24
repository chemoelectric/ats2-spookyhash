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

    val length = g1ofg0 length

    val (pf_msg, pf_msg_mem | p_msg) = malloc_gc (length)
    val _ = fill_message (pf_msg | p_msg, length, pattern)
    val (hash1, hash2) =
      spookyhash_hash128 (!p_msg, length, seed1, seed2)
    val _ = mfree_gc (pf_msg, pf_msg_mem | p_msg)

    val _ = 
      if hash1 <> reference_hash1 || hash2 <> reference_hash2 then
        {
          val _ = $extfcall (int, "printf", "Expected:\n")
          val _ = $extfcall (void, "print_results", seed1, seed2,
                             length, pattern, reference_hash1,
                             reference_hash2)
          val _ = $extfcall (int, "printf", "Got:\n")
          val _ = $extfcall (void, "print_results", seed1, seed2,
                             length, pattern, hash1, hash2)
          val _ = $extfcall (void, "exit", 1)
        }
  }
