(*

Copyright © 2018, 2021 Barry Schwartz

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

#include "spookyhash/HATS/spookyhash-ats-parameters.hats"

(*
 * spookyhash_mix:
 *
 * Mix an array of NUMVARS uint64, which is equivalent
 * to BLOCKSIZE bytes aligned on a uint64 boundary.
 *)
fun {}
spookyhash_mix (data : &RD(@[uint64][NUMVARS]),
                s0   : &uint64,
                s1   : &uint64,
                s2   : &uint64,
                s3   : &uint64,
                s4   : &uint64,
                s5   : &uint64,
                s6   : &uint64,
                s7   : &uint64,
                s8   : &uint64,
                s9   : &uint64,
                s10  : &uint64,
                s11  : &uint64) :<!refwrt> void

(*
 * spookyhash_mix_bytes:
 *
 * Mix BLOCKSIZE bytes that *are* presumed to be aligned
 * on a uint64 boundary.
 *)
fun {}
spookyhash_mix_bytes
        (data : &RD(@[byte][BLOCKSIZE]),
         s0   : &uint64,
         s1   : &uint64,
         s2   : &uint64,
         s3   : &uint64,
         s4   : &uint64,
         s5   : &uint64,
         s6   : &uint64,
         s7   : &uint64,
         s8   : &uint64,
         s9   : &uint64,
         s10  : &uint64,
         s11  : &uint64) :<!refwrt> void

(*
 * spookyhash_mix_unaligned:
 *
 * Mix BLOCKSIZE bytes that *are not* presumed to be aligned
 * on a uint64 boundary.
 *)
fun {}
spookyhash_mix_unaligned
        (data : &RD(@[byte][BLOCKSIZE]),
         s0   : &uint64,
         s1   : &uint64,
         s2   : &uint64,
         s3   : &uint64,
         s4   : &uint64,
         s5   : &uint64,
         s6   : &uint64,
         s7   : &uint64,
         s8   : &uint64,
         s9   : &uint64,
         s10  : &uint64,
         s11  : &uint64) :<!refwrt> void

(*
 * spookyhash_end_partial, spookyhash_end:
 *
 * Mix all 12 inputs together so that h0, h1 are a hash of them all.
 *
 * For two inputs differing in just the input bits
 * Where "differ" means xor or subtraction
 * And the base value is random, or a counting value starting at
 * that bit.
 * The final result will have each bit of h0, h1 flip
 * For every input bit,
 * with probability 50 +- .3%
 * For every pair of input bits,
 * with probability 50 +- 3%
 *
 * This does not rely on the last spookyhash_mix() call having
 * already mixed some.
 * Two iterations was almost good enough for a 64-bit result, but a
 * 128-bit result is reported, so spookyhash_end() does three
 * iterations of spookyhash_end_partial().
 *)
fun {}
spookyhash_end_partial (h0  : &uint64,
                        h1  : &uint64,
                        h2  : &uint64,
                        h3  : &uint64,
                        h4  : &uint64,
                        h5  : &uint64,
                        h6  : &uint64,
                        h7  : &uint64,
                        h8  : &uint64,
                        h9  : &uint64,
                        h10 : &uint64,
                        h11 : &uint64) :<!refwrt> void
fun {}
spookyhash_end (data : &RD(@[uint64][NUMVARS]),
                h0   : &uint64,
                h1   : &uint64,
                h2   : &uint64,
                h3   : &uint64,
                h4   : &uint64,
                h5   : &uint64,
                h6   : &uint64,
                h7   : &uint64,
                h8   : &uint64,
                h9   : &uint64,
                h10  : &uint64,
                h11  : &uint64) :<!refwrt> void

(*
 * spookyhash_short_mix:
 *
 * The goal is for each bit of the input to expand into 128 bits of 
 *   apparent entropy before it is fully overwritten.
 * n trials both set and cleared at least m bits of h0 h1 h2 h3
 *   n: 2   m: 29
 *   n: 3   m: 46
 *   n: 4   m: 57
 *   n: 5   m: 107
 *   n: 6   m: 146
 *   n: 7   m: 152
 * when run forwards or backwards
 * for all 1-bit and 2-bit diffs
 * with diffs defined by either xor or subtraction
 * with a base of all zeros plus a counter, or plus another bit, or random
 *)
fun {}
spookyhash_short_mix (h0 : &uint64,
                      h1 : &uint64,
                      h2 : &uint64,
                      h3 : &uint64) :<!refwrt> void

(*
 * spookyhash_short_end:
 *
 * Mix all 4 inputs together so that h0, h1 are a hash of them all.
 *
 * For two inputs differing in just the input bits
 * Where "differ" means xor or subtraction
 * And the base value is random, or a counting value starting at that bit
 * The final result will have each bit of h0, h1 flip
 * For every input bit,
 * with probability 50 +- .3% (it is probably better than that)
 * For every pair of input bits,
 * with probability 50 +- .75% (the worst case is approximately that)
 *)
fun {}
spookyhash_short_end (h0 : &uint64,
                      h1 : &uint64,
                      h2 : &uint64,
                      h3 : &uint64) :<!refwrt> void

(*
 * spookyhash_short:
 *
 * Short is used for messages under 192 bytes in length
 * (although it could be used for any message).
 *
 * Short has a low startup cost, the normal mode is good for long
 * keys, the cost crossover is at about 192 bytes.
 * The two modes were held to the same quality bar.
 *)
fun {}
spookyhash_short {length  : int | length <= BUFSIZE}
                 (message : &(@[byte][length]),
                  length  : size_t length,
                  seed1   : uint64,
                  seed2   : uint64) :<!refwrt>
    @(uint64,         (* The first 64 bits (in native byte order). *)
      uint64)         (* The second 64 bits (in native byte order). *)

(*
 * initialize_variables:
 *
 * FIXME: Document this.
 *)
fun {}
initialize_variables
        (len   : Size_t,
         h0    : &uint64? >> uint64,
         h1    : &uint64? >> uint64,
         h2    : &uint64? >> uint64,
         h3    : &uint64? >> uint64,
         h4    : &uint64? >> uint64,
         h5    : &uint64? >> uint64,
         h6    : &uint64? >> uint64,
         h7    : &uint64? >> uint64,
         h8    : &uint64? >> uint64,
         h9    : &uint64? >> uint64,
         h10   : &uint64? >> uint64,
         h11   : &uint64? >> uint64,
         state : &RD(@[uint64][NUMVARS])) :<!refwrt> void

(*
 * use_buffered_data:
 *
 * FIXME: Document this.
 *)
fun {}
use_buffered_data {p_data  : addr}
                  {length  : int}
                  {p_msg   : addr}
                  {rem     : int | rem < BUFSIZE;
                                   BUFSIZE - rem <= length}
                  (pf_data : !(@[uint64][TWICE_NUMVARS] @ p_data)
                                  >> _,
                   pf_msg  : @[byte][length] @ p_msg |
                   p_data  : ptr p_data,
                   p_msg   : ptr p_msg,
                   rem     : size_t rem,
                   length  : size_t length,
                   s0      : &uint64,
                   s1      : &uint64,
                   s2      : &uint64,
                   s3      : &uint64,
                   s4      : &uint64,
                   s5      : &uint64,
                   s6      : &uint64,
                   s7      : &uint64,
                   s8      : &uint64,
                   s9      : &uint64,
                   s10     : &uint64,
                   s11     : &uint64) :<!refwrt>
    [j : int | ifintrel (rem == 0, 0, BUFSIZE - rem, j)]
    (@[byte][j] @ p_msg,
     @[byte][length - j] @ (p_msg + j * sizeof (byte)) |
     ptr (p_msg + j * sizeof (byte)),
     size_t (length - j))

(*
 * mix_in_blocks:
 *
 * FIXME: Document this.
 *)
fun {}
mix_in_blocks {block_count : int}
              {p_blocks    : addr}
              (pf_blocks   : !(@[byte][block_count * BLOCKSIZE]
                                  @ p_blocks) >> _ |
               p_blocks    : ptr p_blocks,
               block_count : size_t block_count,
               s0          : &uint64,
               s1          : &uint64,
               s2          : &uint64,
               s3          : &uint64,
               s4          : &uint64,
               s5          : &uint64,
               s6          : &uint64,
               s7          : &uint64,
               s8          : &uint64,
               s9          : &uint64,
               s10         : &uint64,
               s11         : &uint64) :<!refwrt> void

(*
 * final_mixing:
 *
 * FIXME: Document this.
 *)
fn {}
final_mixing {p_data  : addr}
             {rem     : int | rem < BLOCKSIZE}
             (pf_data : !(@[uint64][NUMVARS] @ p_data) >> _ |
              p_data  : ptr p_data,
              rem     : size_t rem,
              h0      : &uint64,
              h1      : &uint64,
              h2      : &uint64,
              h3      : &uint64,
              h4      : &uint64,
              h5      : &uint64,
              h6      : &uint64,
              h7      : &uint64,
              h8      : &uint64,
              h9      : &uint64,
              h10     : &uint64,
              h11     : &uint64) :<!refwrt> void
