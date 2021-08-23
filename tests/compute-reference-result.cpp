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

#include <cstdio>
#include <cstdint>
#include <cinttypes>
#include <cstdlib>
#include "SpookyV2.h"

#define BE_NOISY 0

#if BE_NOISY
#define IF_NOISY(code)                          \
  do                                            \
    {                                           \
      code;                                     \
    }                                           \
  while (0)
#else
#define IF_NOISY(code)                          \
  do                                            \
    {                                           \
      /* nothing */;                            \
    }                                           \
  while (0)
#endif

static void
fill_message_0 (char *message,
                size_t length)
{
  for (size_t i = 0; i != length; i += 1)
    message[i] = (char) (unsigned char) ((i + 0x80) % 0xFF);
}

static void
fill_message (char *message,
              size_t length,
              int pattern)
{
  switch (pattern)
    {
    case 0:
      fill_message_0 (message, length);
      break;
    default:
      printf ("pattern other than 0 is not supported.\n");
      exit (1);
    }
}

int
main (int argc, char *argv[])
{
  const uint64_t seed1 =
    (2 <= argc) ? strtoull (argv[1], NULL, 16) : 0;
  const uint64_t seed2 =
    (3 <= argc) ? strtoull (argv[2], NULL, 16) : 0;
  const size_t length = (4 <= argc) ? atoll (argv[3]) : 0;
  const int pattern = (5 <= argc) ? atoll (argv[4]) : 0;
  IF_NOISY (fprintf (stderr, "seed1 = 0x%016" PRIX64 "\n", seed1));
  IF_NOISY (fprintf (stderr, "seed2 = 0x%016" PRIX64 "\n", seed2));
  IF_NOISY (fprintf (stderr, "length = %zu\n", length));
  IF_NOISY (fprintf (stderr, "pattern = %d\n", pattern));

  char *message = new char[length];
  fill_message (message, length, pattern);

  uint64_t hash1 = seed1;
  uint64_t hash2 = seed2;
  SpookyHash::Hash128(message, length, &hash1, &hash2);
  printf ("%016" PRIX64 " %016" PRIX64 " %zu %d "
          "%016" PRIX64 " %016" PRIX64 "\n",
          seed1, seed2, length, pattern, hash1, hash2);

  return 0;
}
