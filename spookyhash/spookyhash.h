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

/* Spookyhash version 2 */

#ifndef ATS2_SPOOKYHASH_H_HEADER_GUARD__
#define ATS2_SPOOKYHASH_H_HEADER_GUARD__

#include <stdlib.h>
#include <stdint.h>
#include <spookyhash/CATS/spookyhash.cats>

typedef struct ats2_spookyhash_context_t__ spookyhash_context_t;

inline void
spookyhash_hash128 (const void *message,
                    size_t length,
                    uint64_t seed1,
                    uint64_t seed2,
                    uint64_t *hash1,
                    uint64_t *hash2)
{
  extern void ats2_055_spookyhash__spookyhash_hash128_vars
    (const void *message,
     size_t length,
     uint64_t seed1,
     uint64_t seed2,
     uint64_t *hash1,
     uint64_t *hash2);
  ats2_055_spookyhash__spookyhash_hash128_vars (message, length,
                                                seed1, seed2,
                                                hash1, hash2);
}

inline uint64_t
spookyhash_hash64 (const void *message,
                   size_t length,
                   uint64_t seed)
{
  extern uint64_t ats2_055_spookyhash__spookyhash_hash64
    (const void *message,
     size_t length,
     uint64_t seed);
  return ats2_055_spookyhash__spookyhash_hash64 (message, length,
                                                 seed);
}

inline uint32_t
spookyhash_hash32 (const void *message,
                   size_t length,
                   uint32_t seed)
{
  extern uint32_t ats2_055_spookyhash__spookyhash_hash32
    (const void *message,
     size_t length,
     uint32_t seed);
  return ats2_055_spookyhash__spookyhash_hash32 (message, length,
                                                 seed);
}

inline void
spookyhash_init (spookyhash_context_t *context,
                 uint64_t seed1,
                 uint64_t seed2)
{
  extern void ats2_055_spookyhash__spookyhash_init
    (spookyhash_context_t *context,
     uint64_t seed1,
     uint64_t seed2);
  ats2_055_spookyhash__spookyhash_init (context, seed1, seed2);
}

inline void
spookyhash_update (spookyhash_context_t *context,
                   const void *message,
                   size_t length)
{
  extern void ats2_055_spookyhash__spookyhash_update
    (spookyhash_context_t *context,
     const void *message,
     size_t length);
  ats2_055_spookyhash__spookyhash_update (context, message, length);
}

inline void
spookyhash_final (spookyhash_context_t *context,
                  uint64_t *hash1,
                  uint64_t *hash2)
{
  extern void ats2_055_spookyhash__spookyhash_final_vars
    (spookyhash_context_t *context,
     uint64_t *hash1,
     uint64_t *hash2);
  ats2_055_spookyhash__spookyhash_final_vars (context, hash1, hash2);
}

#endif /* ATS2_SPOOKYHASH_H_HEADER_GUARD__ */
