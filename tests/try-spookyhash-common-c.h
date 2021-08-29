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

#include <spookyhash/spookyhash.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>

static uint64_t
get_seed1 (int argc, char *argv[])
{
  return (2 <= argc) ? strtoull (argv[1], NULL, 16) : 0;
}

static uint64_t
get_seed2 (int argc, char *argv[])
{
  return (3 <= argc) ? strtoull (argv[2], NULL, 16) : 0;
}

static size_t
get_length (int argc, char *argv[])
{
  return (4 <= argc) ? atoll (argv[3]) : 0;
}

static int
get_pattern (int argc, char *argv[])
{
  return (5 <= argc) ? atoll (argv[4]) : 0;
}

static uint64_t
get_reference_hash1 (int argc, char *argv[])
{
  return (6 <= argc) ? strtoull (argv[5], NULL, 16) : 0;
}

static uint64_t
get_reference_hash2 (int argc, char *argv[])
{
  return (7 <= argc) ? strtoull (argv[6], NULL, 16) : 0;
}

static void
print_hash128_results (uint64_t seed1,
                       uint64_t seed2,
                       size_t length,
                       int pattern,
                       uint64_t hash1,
                       uint64_t hash2)
{
  printf ("%016" PRIX64 " %016" PRIX64 " %zu %d "
          "%016" PRIX64 " %016" PRIX64 "\n",
          seed1, seed2, length, pattern, hash1, hash2);
}

static void
print_hash64_results (uint64_t seed,
                      size_t length,
                      int pattern,
                      uint64_t hash)
{
  printf ("%08" PRIX64 " %zu %d %08" PRIX64 "\n",
          seed, length, pattern, hash);
}

static void
print_hash32_results (uint32_t seed,
                      size_t length,
                      int pattern,
                      uint32_t hash)
{
  printf ("%08" PRIX32 " %zu %d %08" PRIX32 "\n",
          seed, length, pattern, hash);
}

static void
fill_message_0 (uint8_t *message, size_t length)
{
  for (size_t i = 0; i != length; i += 1)
    message[i] = (uint8_t) ((i + 128) % 256);
}

static void
fill_message (uint8_t *message, size_t length, int pattern)
{
  if (pattern == 0)
    fill_message_0 (message, length);
  else
    {
      printf ("pattern other than 0 is not supported.\n");
      exit (1);
    }
}
