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

    val _ =
      if ($UNSAFE.cast 0x100000000 <= seed1 ||
            $UNSAFE.cast 0 < seed2) then
        {
          val _ = $extfcall (int, "printf",
                             "The seed is too large.\n")
          val _ = $extfcall (void, "exit", 2)
        }
    val seed : uint32 = $UNSAFE.cast (seed1)

    val (pf_msg, pf_msg_mem | p_msg) = malloc_gc (length)
    val _ = fill_message (pf_msg | p_msg, length, pattern)
    val hash = spookyhash_hash32 (!p_msg, length, seed)
    val _ = mfree_gc (pf_msg, pf_msg_mem | p_msg)

    val reference_hash : uint32 =
      $UNSAFE.cast{uint32}
        (reference_hash1 mod ($UNSAFE.cast{uint64} 0x100000000))
    val _ = 
      if hash <> reference_hash then
        {
          val _ = $extfcall (int, "printf", "Expected:\n")
          val _ = $extfcall (void, "print_hash32_results",
                             seed, length, pattern, reference_hash)
          val _ = $extfcall (int, "printf", "Got:\n")
          val _ = $extfcall (void, "print_hash32_results",
                             seed, length, pattern, hash)
          val _ = $extfcall (void, "exit", 1)
        }
  }
