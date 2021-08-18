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

#ifndef ATS2_SPOOKYHASH_CATS_HEADER_GUARD__
#define ATS2_SPOOKYHASH_CATS_HEADER_GUARD__

_Static_assert (sizeof (atstype_uint32) == 4,
                "uint32 is not 4 bytes");
_Static_assert (sizeof (atstype_uint64) == 8,
                "uint64 is not 8 bytes");

#define ats2_spookyhash_inline ATSinline()

#ifdef __GNUC__

#if 10 <= __GNUC__
#define ats2_spookyhash_always_inline           \
  [[gnu::always_inline]] ats2_spookyhash_inline
#else
#define ats2_spookyhash_always_inline                       \
  __attribute__((__always_inline__)) ats2_spookyhash_inline
#endif

#define ats2_spookyhash_memcpy __builtin_memcpy
#define ats2_spookyhash_bswap32 __builtin_bswap32
#define ats2_spookyhash_bswap64 __builtin_bswap64

#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define ATS2_SPOOKYHASH_BIG_ENDIAN 0
#elif __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
#define ATS2_SPOOKYHASH_BIG_ENDIAN 1
#else
#error The platform must be little endian or big endian.
#endif

#else /* not __GNUC__ */

#include <string.h>
#include <stdint.h>

#define ats2_spookyhash_always_inline ats2_spookyhash_inline

#define ats2_spookyhash_memcpy memcpy
#define ats2_spookyhash_bswap32(x)              \
  ((((x) & UINT32_C(0x000000FF)) << 24) |       \
   (((x) & UINT32_C(0x0000FF00)) << 8) |        \
   (((x) & UINT32_C(0x00FF0000)) >> 8) |        \
   (((x) & UINT32_C(0xFF000000)) >> 24))
#define ats2_spookyhash_bswap64(x)                  \
  ((((x) & UINT64_C(0x00000000000000FF)) << 56) |   \
   (((x) & UINT64_C(0x000000000000FF00)) << 40) |   \
   (((x) & UINT64_C(0x0000000000FF0000)) << 24) |   \
   (((x) & UINT64_C(0x00000000FF000000)) << 8) |    \
   (((x) & UINT64_C(0x000000FF00000000)) >> 8) |    \
   (((x) & UINT64_C(0x0000FF0000000000)) >> 24) |   \
   (((x) & UINT64_C(0x00FF000000000000)) >> 40) |   \
   (((x) & UINT64_C(0xFF00000000000000)) >> 56))

#ifndef ATS2_SPOOKYHASH_BIG_ENDIAN
#error Please set ATS2_SPOOKYHASH_BIG_ENDIAN to 0 or 1 in CFLAGS.
#endif

#endif

_Static_assert (ats2_spookyhash_bswap32 (0xDEADBEEFU) == 0xEFBEADDEU,
                "ats2_spookyhash_bswap32 does not work correctly.");
/* FIXME: Add a test of ats2_spookyhash_bswap64 */


#if 0                           /////////////////////////////////////////////////////////////////// FIXME //////////////////////////////////////////
/* A natural numbers mod function. */
ats2_spookyhash_always_inline atstype_size
ats2_spookyhash_natmod_size (atstype_size x, atstype_size y)
{
  return (x % y);
}

/* Bitwise inclusive or. */
ats2_spookyhash_always_inline atstype_uint32
ats2_spookyhash_bitwise_ior_uint32 (atstype_uint32 x,
                                    atstype_uint32 y)
{
  return (x | y);
}

/* Bitwise inclusive or. */
ats2_spookyhash_always_inline atstype_uint64
ats2_spookyhash_bitwise_ior_uint64 (atstype_uint64 x,
                                    atstype_uint64 y)
{
  return (x | y);
}

/* Bitwise exclusive or. */
ats2_spookyhash_always_inline atstype_uint32
ats2_spookyhash_bitwise_xor_uint32 (atstype_uint32 x,
                                    atstype_uint32 y)
{
  return (x ^ y);
}

/* Bitwise exclusive or. */
ats2_spookyhash_always_inline atstype_uint64
ats2_spookyhash_bitwise_xor_uint64 (atstype_uint64 x,
                                    atstype_uint64 y)
{
  return (x ^ y);
}

/* Bitwise left shift, with zero-fill. */
ats2_spookyhash_always_inline atstype_uint32
ats2_spookyhash_bitwise_lshift_uint32_uint (atstype_uint32 x,
                                            atstype_uint i)
{
  return (x << i);
}

/* Bitwise left shift, with zero-fill. */
ats2_spookyhash_always_inline atstype_uint64
ats2_spookyhash_bitwise_lshift_uint64_uint (atstype_uint64 x,
                                            atstype_uint i)
{
  return (x << i);
}

/* Bitwise right shift, with zero-fill. */
ats2_spookyhash_always_inline atstype_uint32
ats2_spookyhash_bitwise_rshift_uint32_uint (atstype_uint32 x,
                                            atstype_uint i)
{
  return (x >> i);
}

/* Bitwise right shift, with zero-fill. */
ats2_spookyhash_always_inline atstype_uint64
ats2_spookyhash_bitwise_rshift_uint64_uint (atstype_uint64 x,
                                            atstype_uint i)
{
  return (x >> i);
}

/* Bitwise left rotation by an amount less than 32. */
ats2_spookyhash_always_inline atstype_uint32
ats2_spookyhash_bitwise_lrotate_uint32_uint (atstype_uint32 x,
                                             atstype_uint i)
{
  return (x << i) | (x >> ((-i) & 31));
}

/* Bitwise left rotation by an amount less than 64. */
ats2_spookyhash_always_inline atstype_uint64
ats2_spookyhash_bitwise_lrotate_uint64_uint (atstype_uint64 x,
                                             atstype_uint i)
{
  return (x << i) | (x >> ((-i) & 63));
}

/* On big endian platforms, swap the byte order. On little endian
   platforms, do not change the value. */
ats2_spookyhash_always_inline atstype_uint32
ats2_spookyhash_fix_byte_order_uint32 (atstype_uint32 x)
{
#if ATS2_SPOOKYHASH_BIG_ENDIAN
  return ats2_spookyhash_bswap32 (x);
#else
  return x;
#endif
}

ats2_spookyhash_always_inline atstype_uint64
ats2_spookyhash_fix_byte_order_uint64 (atstype_uint64 x)
{
#if ATS2_SPOOKYHASH_BIG_ENDIAN
  return ats2_spookyhash_bswap64 (x);
#else
  return x;
#endif
}

/* Get a little endian atstype_uint32 from memory, where perhaps the
   data is misaligned. */
ats2_spookyhash_always_inline atstype_uint32
ats2_spookyhash_get32bits (const atstype_ptr p)
{
#if defined (__GNUC__) && (defined(__i386__) || defined(__x86_64__))
  return *((const atstype_uint32 *) p);
#else
  atstype_uint32 v;
  ats2_spookyhash_memcpy (&v, p, 4);
  return ats2_spookyhash_fix_byte_order_uint32 (v);
#endif
}

/* Get a little endian atstype_uint64 from memory, where perhaps the
   data is misaligned. */
ats2_spookyhash_always_inline atstype_uint64
ats2_spookyhash_get64bits (const atstype_ptr p)
{
#if defined (__GNUC__) && (defined(__i386__) || defined(__x86_64__))
  return *((const atstype_uint64 *) p);
#else
  atstype_uint64 v;
  ats2_spookyhash_memcpy (&v, p, 8);
  return ats2_spookyhash_fix_byte_order_uint64 (v);
#endif
}

/* Put a little endian atstype_uint32 to memory, where perhaps the
   data is misaligned. */
ats2_spookyhash_always_inline void
ats2_spookyhash_put32bits (atstype_ptr p, atstype_uint32 v)
{
#if defined (__GNUC__) && (defined(__i386__) || defined(__x86_64__))
  *((atstype_uint32 *) p) = v;
#else
  v = ats2_spookyhash_fix_byte_order_uint32 (v);
  ats2_spookyhash_memcpy (p, &v, 4);
#endif
}

/* Put a little endian atstype_uint64 to memory, where perhaps the
   data is misaligned. */
ats2_spookyhash_always_inline void
ats2_spookyhash_put64bits (atstype_ptr p, atstype_uint64 v)
{
#if defined (__GNUC__) && (defined(__i386__) || defined(__x86_64__))
  *((atstype_uint64 *) p) = v;
#else
  v = ats2_spookyhash_fix_byte_order_uint64 (v);
  ats2_spookyhash_memcpy (p, &v, 8);
#endif
}

#endif /////////////////////////////////////////////////////////////////// FIXME //////////////////////////////////////////

#include "spookyhash/HATS/spookyhash-parameters.hats"

typedef struct
{
  /* Unhashed data, for partial messages. */
  atstype_uint64 data[2 * ATS2_SPOOKYHASH_NUMVARS];
  /* Internal state of the hash. */
  atstype_uint64 state[ATS2_SPOOKYHASH_NUMVARS];
  /* Total length of the input so far. */
  atstype_size length;
  /* Length of unhashed data stashed in m_data. */
  atstype_uint8 remainder;
} ats2_spookyhash_context_t;

ats2_spookyhash_inline atstype_ptr
ats2_spookyhash_m_data (atstype_ref ctx)
{
  return ((ats2_spookyhash_context_t *) ctx)->data;
}

ats2_spookyhash_inline atstype_ptr
ats2_spookyhash_m_state (atstype_ref ctx)
{
  return ((ats2_spookyhash_context_t *) ctx)->state;
}

ats2_spookyhash_inline atstype_ptr
ats2_spookyhash_m_length (atstype_ref ctx)
{
  return &((ats2_spookyhash_context_t *) ctx)->length;
}

ats2_spookyhash_inline atstype_ptr
ats2_spookyhash_m_remainder (atstype_ref ctx)
{
  return &((ats2_spookyhash_context_t *) ctx)->remainder;
}

/* Bitwise left rotation by an amount less than 64. */
ats2_spookyhash_always_inline atstype_uint64
ats2_spookyhash_bitwise_lrotate_uint64_uint (atstype_uint64 x,
                                             atstype_uint i)
{
  return (x << i) | (x >> ((-i) & 63));
}

ats2_spookyhash_inline atstype_void
ats2_spookyhash_spookyhash_mix (const atstype_uint64 *data,
                                atstype_uint64 *s0,
                                atstype_uint64 *s1,
                                atstype_uint64 *s2,
                                atstype_uint64 *s3,
                                atstype_uint64 *s4,
                                atstype_uint64 *s5,
                                atstype_uint64 *s6,
                                atstype_uint64 *s7,
                                atstype_uint64 *s8,
                                atstype_uint64 *s9,
                                atstype_uint64 *s10,
                                atstype_uint64 *s11)
{
  *s0 += data[0];
  *s2 ^= *s10;
  *s11 ^= *s0;
  *s0 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s0, 11);
  *s11 += *s1;

  *s1 += data[1];
  *s3 ^= *s11;
  *s0 ^= *s1;
  *s1 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s1, 32);
  *s0 += *s2;

  *s2 += data[2];
  *s4 ^= *s0;
  *s1 ^= *s2;
  *s2 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s2, 43);
  *s1 += *s3;

  *s3 += data[3];
  *s5 ^= *s1;
  *s2 ^= *s3;
  *s3 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s3, 31);
  *s2 += *s4;

  *s4 += data[4];
  *s6 ^= *s2;
  *s3 ^= *s4;
  *s4 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s4, 17);
  *s3 += *s5;

  *s5 += data[5];
  *s7 ^= *s3;
  *s4 ^= *s5;
  *s5 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s5, 28);
  *s4 += *s6;

  *s6 += data[6];
  *s8 ^= *s4;
  *s5 ^= *s6;
  *s6 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s6, 39);
  *s5 += *s7;

  *s7 += data[7];
  *s9 ^= *s5;
  *s6 ^= *s7;
  *s7 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s7, 57);
  *s6 += *s8;

  *s8 += data[8];
  *s10 ^= *s6;
  *s7 ^= *s8;
  *s8 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s8, 55);
  *s7 += *s9;

  *s9 += data[9];
  *s11 ^= *s7;
  *s8 ^= *s9;
  *s9 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s9, 54);
  *s8 += *s10;

  *s10 += data[10];
  *s0 ^= *s8;
  *s9 ^= *s10;
  *s10 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s10, 22);
  *s9 += *s11;

  *s11 += data[11];
  *s1 ^= *s9;
  *s10 ^= *s11;
  *s11 = ats2_spookyhash_bitwise_lrotate_uint64_uint (*s11, 46);
  *s10 += *s0;
}


#endif /* ATS2_SPOOKYHASH_CATS_HEADER_GUARD__ */
