/*

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

*/

#include <tests/try-spookyhash-common-c.h>

int
main (int argc, char *argv[])
{
  uint64_t seed1 = get_seed1 (argc, argv);
  uint64_t seed2 = get_seed2 (argc, argv);
  size_t length = get_length (argc, argv);
  int pattern = get_pattern (argc, argv);
  uint64_t reference_hash1 = get_reference_hash1 (argc, argv);
  uint64_t reference_hash2 = get_reference_hash2 (argc, argv);

  if (seed1 != seed2)
    {
      printf ("The seeds are unequal.\n");
      exit (3);
    }

  uint64_t seed = seed1;
  uint64_t reference_hash = reference_hash1;

  uint8_t *message = malloc (length);
  fill_message (message, length, pattern);
  uint64_t hash = spookyhash_hash64 (message, length, seed);
  free (message);

  if (hash != reference_hash)
    {
      printf ("Expected:\n");
      print_hash64_results (seed, length, pattern,
                            reference_hash);
      printf ("Got:\n");
      print_hash64_results (seed, length, pattern, hash);
      exit (1);
    }

  return 0;
}
