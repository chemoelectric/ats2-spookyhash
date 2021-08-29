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

  uint64_t hash1;
  uint64_t hash2;
  spookyhash_context_t context;
  uint8_t *message = malloc (length);

  /* In one piece. */
  fill_message (message, length, pattern);
  spookyhash_init (&context, seed1, seed2);
  spookyhash_update (&context, message, length);
  spookyhash_final (&context, &hash1, &hash2);
  if (hash1 != reference_hash1 || hash2 != reference_hash2)
    {
      printf ("In one piece --\n");
      printf ("Expected:\n");
      print_hash128_results (seed1, seed2, length, pattern,
                             reference_hash1, reference_hash2);
      printf ("Got:\n");
      print_hash128_results (seed1, seed2, length, pattern,
                             hash1, hash2);
      exit (1);
    }

  /* In two consecutive pieces, cut all the different ways. */
  for (size_t i = 0; i != length; i += 1)
    {
      spookyhash_init (&context, seed1, seed2);
      spookyhash_update (&context, message, i);
      spookyhash_update (&context, message + i, length - i);
      spookyhash_final (&context, &hash1, &hash2);
      if (hash1 != reference_hash1 || hash2 != reference_hash2)
        {
          printf ("In two pieces (%zu, %zu) --\n", i, length - i);
          printf ("Expected:\n");
          print_hash128_results (seed1, seed2, length, pattern,
                                 reference_hash1, reference_hash2);
          printf ("Got:\n");
          print_hash128_results (seed1, seed2, length, pattern,
                                 hash1, hash2);
          exit (1);
        }
    }

  /* In two consecutive pieces, cut all the different ways, and
     running spookyhash_final along the way. */
  for (size_t i = 0; i != length; i += 1)
    {
      spookyhash_init (&context, seed1, seed2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_update (&context, message, i);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_update (&context, message + i, length - i);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      if (hash1 != reference_hash1 || hash2 != reference_hash2)
        {
          printf ("Running spookyhash_final along the way --\n");
          printf ("In two pieces (%zu, %zu) --\n", i, length - i);
          printf ("Expected:\n");
          print_hash128_results (seed1, seed2, length, pattern,
                                 reference_hash1, reference_hash2);
          printf ("Got:\n");
          print_hash128_results (seed1, seed2, length, pattern,
                                 hash1, hash2);
          exit (1);
        }
    }

  /* In chunks of a certain size. */
  for (size_t size = 1; size < length; size += 1)
    {
      size_t chunk_count = length / size;
      size_t remainder = length % size;
      spookyhash_init (&context, seed1, seed2);
      for (size_t i = 0; i != chunk_count; i += 1)
        spookyhash_update (&context, message + (i * size), size);
      spookyhash_update (&context, message + (chunk_count * size),
                         remainder);
      spookyhash_final (&context, &hash1, &hash2);
      if (hash1 != reference_hash1 || hash2 != reference_hash2)
        {
          printf ("In %zu chunk(s) of size %zu, remainder %zu --\n",
                  length / size, size, length % size);
          printf ("Expected:\n");
          print_hash128_results (seed1, seed2, length, pattern,
                                 reference_hash1, reference_hash2);
          printf ("Got:\n");
          print_hash128_results (seed1, seed2, length, pattern,
                                 hash1, hash2);
          exit (1);
        }
    }

  /* In chunks of a certain size, running spookyhash_final along the
     way. */
  for (size_t size = 1; size < length; size += 1)
    {
      size_t chunk_count = length / size;
      size_t remainder = length % size;
      spookyhash_init (&context, seed1, seed2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      for (size_t i = 0; i != chunk_count; i += 1)
        {
          spookyhash_update (&context, message + (i * size), size);
          spookyhash_final (&context, &hash1, &hash2);
          spookyhash_final (&context, &hash1, &hash2);
          spookyhash_final (&context, &hash1, &hash2);
          spookyhash_final (&context, &hash1, &hash2);
          spookyhash_final (&context, &hash1, &hash2);
        }
      spookyhash_update (&context, message + (chunk_count * size),
                         remainder);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      spookyhash_final (&context, &hash1, &hash2);
      if (hash1 != reference_hash1 || hash2 != reference_hash2)
        {
          printf ("Running spookyhash_final along the way --\n");
          printf ("In %zu chunk(s) of size %zu, remainder %zu --\n",
                  length / size, size, length % size);
          printf ("Expected:\n");
          print_hash128_results (seed1, seed2, length, pattern,
                                 reference_hash1, reference_hash2);
          printf ("Got:\n");
          print_hash128_results (seed1, seed2, length, pattern,
                                 hash1, hash2);
          exit (1);
        }
    }

  free (message);

  return 0;
}
