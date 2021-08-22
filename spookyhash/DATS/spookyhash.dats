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

%{^
#include "spookyhash/CATS/spookyhash-implementation.cats"
%}

#define ATS_PACKNAME "ats2-spookyhash"
#define ATS_EXTERN_PREFIX "ats2_spookyhash_"

#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload "spookyhash/SATS/array_prf.sats"
staload "spookyhash/SATS/spookyhash.sats"

#include "spookyhash/HATS/spookyhash-parameters.hats"
#define NUMVARS ATS2_SPOOKYHASH_NUMVARS
#define TWICE_NUMVARS ATS2_SPOOKYHASH_TWICE_NUMVARS
#define BLOCKSIZE ATS2_SPOOKYHASH_BLOCKSIZE
#define BUFSIZE ATS2_SPOOKYHASH_BUFSIZE
#define CONST   ATS2_SPOOKYHASH_CONST

typedef remainder_t (i : int) = [i < BUFSIZE] g1uint (uint8knd, i)
typedef remainder_t = [i : int] remainder_t i

(********************************************************************)

%{
_Static_assert (sizeof (atstype_byte) == 1,
                "atstype_byte is not 1 byte");

_Static_assert (sizeof (atstype_uint32) == 4,
                "uint32 is not 4 bytes");

_Static_assert (sizeof (atstype_uint64) == 8,
                "uint64 is not 8 bytes");
%}

prval _ = $UNSAFE.prop_assert {sizeof (byte) == 1} ()
prval _ = $UNSAFE.prop_assert {sizeof (uint32) == 4} ()
prval _ = $UNSAFE.prop_assert {sizeof (uint64) == 8} ()

extern praxi {t : vt@ype}
array2bytes :
  {n : int}
  {p : addr}
  (@[t][n] @ p) -<prf> (@[byte][n * sizeof (t)] @ p)

extern praxi {t : vt@ype}
bytes2array :
  {n : int}
  {p : addr}
  (@[byte][n * sizeof (t)] @ p) -<prf> (@[t][n] @ p)

extern praxi {t : vt@ype}
array2bytesqmark :
  {n : int}
  {p : addr}
  (@[t][n] @ p) -<prf> (@[byte?][n * sizeof (t)] @ p)

extern praxi {t : vt@ype}
bytesqmark2array :
  {n : int}
  {p : addr}
  (@[byte?][n * sizeof (t)] @ p) -<prf> (@[t][n] @ p)

(********************************************************************)

prfn
lemma_mul_isfun {m1, n1 : int}
                {m2, n2 : int | m1 == m2; n1 == n2}
                () :<prf>
    [m1 * n1 == m2 * n2] void =
  {
    prval pf1 = mul_make {m1, n1} ()
    prval pf2 = mul_make {m2, n2} ()
    prval _ = mul_isfun {m1, n1} {m1 * n1, m2 * n2} (pf1, pf2)
  }

(********************************************************************)

(* A natural numbers mod function. *)
extern fn
natmod_size {x, y : nat | y != 0}
            (x    : size_t x,
             y    : size_t y) :<>
    [z : nat | z <= x; z < y; z == x mod y]
    size_t z = "mac#%"

overload natmod with natmod_size

(*------------------------------------------------------------------*)

extern fun
bitwise_and_ullint (x : ullint, y : ullint) :<> ullint = "mac#%"

extern fun
bitwise_and_uint64 (x : uint64, y : uint64) :<> uint64 = "mac#%"

overload bitwise_and with bitwise_and_ullint
overload bitwise_and with bitwise_and_uint64

(*------------------------------------------------------------------*)

extern fun
bitwise_xor_uint64 (x : uint64, y : uint64) :<> uint64 = "mac#%"

overload bitwise_xor with bitwise_xor_uint64

infixl ( + ) ^
overload ^ with bitwise_xor

(*------------------------------------------------------------------*)

extern fun
bitwise_lshift_uint64_uint {i : int | i < 64}
                           (x : uint64,
                            i : uint i) :<> uint64 = "mac#%"

overload bitwise_lshift with bitwise_lshift_uint64_uint

infix ( * ) <<
overload << with bitwise_lshift

(*------------------------------------------------------------------*)

extern fun
bitwise_lrotate_uint64_uint {i : int | i < 64}
                            (x : uint64,
                             i : uint i) :<> uint64 = "mac#%"

overload bitwise_lrotate with bitwise_lrotate_uint64_uint

infix ( * ) <<@
overload <<@ with bitwise_lrotate

(*------------------------------------------------------------------*)
(*
   fix_byte_order:

   On big-endian platforms, reverse the byte order.
   On little-endian platforms, make no changes.
*)

extern fun
fix_byte_order_uint32 (x : uint32) :<> uint32 = "mac#%"

extern fun
fix_byte_order_uint64 (x : uint64) :<> uint64 = "mac#%"

overload fix_byte_order with fix_byte_order_uint32
overload fix_byte_order with fix_byte_order_uint64

(*------------------------------------------------------------------*)

extern castfn
g1ofg1_g1uint {tk : tkind}
              {i  : int}
              (i  : g1uint (tk, i)) :<>
    [j : int | j == i] g1uint (tk, j)

extern castfn
g1ofg1_ptr {p : addr}
           (p : ptr p) :<>
    [q : addr | q == p] ptr q

overload g1ofg1 with g1ofg1_g1uint
overload g1ofg1 with g1ofg1_ptr

extern castfn
u2u8 {i : int} (i : uint i) :<> uint8 i

extern castfn
u8sz {i : int} (i : uint8 i) :<> size_t i

extern castfn
sz2u8 {i : int} (i : size_t i) :<> uint8 i

extern castfn
u2u64 {i : int} (i : uint i) :<> uint64 i

extern castfn
u32u64 (i : uint32) :<> uint64

fn {}
u64u32 (i : uint64) :<> uint32 =
  $UNSAFE.cast (bitwise_and (i, $UNSAFE.cast 0xFFFFFFFFULL))

fn {}
byte2u64 (b : byte) :<> uint64 =
  $UNSAFE.cast{uint64} ($UNSAFE.cast{uint8} b)

fn {}
sz2byte {i : int | i < 256}
        (i : size_t i) :<> byte =
  $UNSAFE.cast{byte} ($UNSAFE.cast{uint8} i)

fn {}
u2byte (i : uint) :<> byte =
  $UNSAFE.cast{byte} (u2u8 (g1ofg0 i))

(*------------------------------------------------------------------*)

(* An interface to memcpy or __builtin_memcpy. *)
extern fun
memcpy {n   : int}
       (dst : &(@[byte?][n]) >> @[byte][n],
        src : &RD(@[byte][n]),
        n   : size_t n) :<!refwrt> void = "mac#%"

(* An interface to memset or __builtin_memset. *)
extern fun
memset {n     : int}
       (dst   : &(@[byte?][n]) >> @[byte][n],
        value : byte,
        n     : size_t n) :<!refwrt> void = "mac#%"

(*------------------------------------------------------------------*)

extern fn
allow_direct_read_g1 {p : addr} (p : ptr p) :<> bool = "mac#%"

fn {}
allow_direct_read_g0 (p : ptr) :<> bool =
  allow_direct_read_g1 (g1ofg0 p)

overload allow_direct_read with allow_direct_read_g0 of 0
overload allow_direct_read with allow_direct_read_g1 of 10

(********************************************************************)

extern fun
m_data (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (@[uint64][TWICE_NUMVARS] @ p,
     @[uint64][TWICE_NUMVARS] @ p -<lin,prf> void |
     ptr p) = "mac#%"

extern fun
m_state (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (@[uint64][NUMVARS] @ p,
     @[uint64][NUMVARS] @ p -<lin,prf> void |
     ptr p) = "mac#%"

extern fun
m_length (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (Size_t @ p,
     Size_t @ p -<lin,prf> void |
     ptr p) = "mac#%"

extern fun
m_remainder (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (remainder_t @ p,
     remainder_t @ p -<lin,prf> void |
     ptr p) = "mac#%"

(********************************************************************)

fn {}
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
                s11  : &uint64) :<!refwrt> void =
  begin
    s0 := s0 + fix_byte_order data[0];
    s2 := s2 ^ s10;
    s11 := s11 ^ s0;
    s0 := s0 <<@ 11U;
    s11 := s11 + s1;

    s1 := s1 + fix_byte_order data[1];
    s3 := s3 ^ s11;
    s0 := s0 ^ s1;
    s1 := s1 <<@ 32U;
    s0 := s0 + s2;

    s2 := s2 + fix_byte_order data[2];
    s4 := s4 ^ s0;
    s1 := s1 ^ s2;
    s2 := s2 <<@ 43U;
    s1 := s1 + s3;

    s3 := s3 + fix_byte_order data[3];
    s5 := s5 ^ s1;
    s2 := s2 ^ s3;
    s3 := s3 <<@ 31U;
    s2 := s2 + s4;

    s4 := s4 + fix_byte_order data[4];
    s6 := s6 ^ s2;
    s3 := s3 ^ s4;
    s4 := s4 <<@ 17U;
    s3 := s3 + s5;

    s5 := s5 + fix_byte_order data[5];
    s7 := s7 ^ s3;
    s4 := s4 ^ s5;
    s5 := s5 <<@ 28U;
    s4 := s4 + s6;

    s6 := s6 + fix_byte_order data[6];
    s8 := s8 ^ s4;
    s5 := s5 ^ s6;
    s6 := s6 <<@ 39U;
    s5 := s5 + s7;

    s7 := s7 + fix_byte_order data[7];
    s9 := s9 ^ s5;
    s6 := s6 ^ s7;
    s7 := s7 <<@ 57U;
    s6 := s6 + s8;

    s8 := s8 + fix_byte_order data[8];
    s10 := s10 ^ s6;
    s7 := s7 ^ s8;
    s8 := s8 <<@ 55U;
    s7 := s7 + s9;

    s9 := s9 + fix_byte_order data[9];
    s11 := s11 ^ s7;
    s8 := s8 ^ s9;
    s9 := s9 <<@ 54U;
    s8 := s8 + s10;

    s10 := s10 + fix_byte_order data[10];
    s0 := s0 ^ s8;
    s9 := s9 ^ s10;
    s10 := s10 <<@ 22U;
    s9 := s9 + s11;

    s11 := s11 + fix_byte_order data[11];
    s1 := s1 ^ s9;
    s10 := s10 ^ s11;
    s11 := s11 <<@ 46U;
    s10 := s10 + s0
  end

fn {}
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
         s11  : &uint64) :<!refwrt> void =
  if allow_direct_read (addr@ data) then
    {
      prval _ =
        view@ data := bytes2array<uint64> {NUMVARS} (view@ data)
      val _ = spookyhash_mix (data, s0, s1, s2, s3, s4, s5,
                              s6, s7, s8, s9, s10, s11)
      prval _ =
        view@ data := array2bytes<uint64> {NUMVARS} (view@ data)
    }
  else
    {
      var buf : @[uint64][NUMVARS]
      prval _ =
        view@ buf := array2bytesqmark<uint64?> {NUMVARS} (view@ buf)
      val _ = memcpy (buf, data, (i2sz NUMVARS) * sizeof<uint64>)
      prval _ =
        view@ buf := bytes2array<uint64> {NUMVARS} (view@ buf)
      val _ = spookyhash_mix (buf, s0, s1, s2, s3, s4, s5,
                              s6, s7, s8, s9, s10, s11)
    }

(********************************************************************)
(*
 * spookyhash_end_partial, spookyhash_end:
 *
 * Mix all 12 inputs together so that h0, h1 are a hash of them all.
 *
 * For two inputs differing in just the input bits
 * Where "differ" means xor or subtraction
 * And the base value is random, or a counting value starting at that bit
 * The final result will have each bit of h0, h1 flip
 * For every input bit,
 * with probability 50 +- .3%
 * For every pair of input bits,
 * with probability 50 +- 3%
 *
 * This does not rely on the last Mix() call having already mixed some.
 * Two iterations was almost good enough for a 64-bit result, but a
 * 128-bit result is reported, so End() does three iterations.
 *
 *)

fn {}
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
                        h11 : &uint64) :<!refwrt> void =
  begin
    h11 := h11 + h1;
    h2 := h2 ^ h11;
    h1 := h1 <<@ 44U;

    h0 := h0 + h2;
    h3 := h3 ^ h0;
    h2 := h2 <<@ 15U;

    h1 := h1 + h3;
    h4 := h4 ^ h1;
    h3 := h3 <<@ 34U;

    h2 := h2 + h4;
    h5 := h5 ^ h2;
    h4 := h4 <<@ 21U;

    h3 := h3 + h5;
    h6 := h6 ^ h3;
    h5 := h5 <<@ 38U;

    h4 := h4 + h6;
    h7 := h7 ^ h4;
    h6 := h6 <<@ 33U;

    h5 := h5 + h7;
    h8 := h8 ^ h5;
    h7 := h7 <<@ 10U;

    h6 := h6 + h8;
    h9 := h9 ^ h6;
    h8 := h8 <<@ 13U;

    h7 := h7 + h9;
    h10 := h10 ^ h7;
    h9 := h9 <<@ 38U;

    h8 := h8 + h10;
    h11 := h11 ^ h8;
    h10:= h10 <<@ 53U;

    h9 := h9 + h11;
    h0 := h0 ^ h9;
    h11:= h11 <<@ 42U;

    h10 := h10 + h0;
    h1 := h1 ^ h10;
    h0 := h0 <<@ 54U
  end

fn {}
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
                h11  : &uint64) :<!refwrt> void =
  begin
    h0 := h0 + fix_byte_order data[0];
    h1 := h1 + fix_byte_order data[1];
    h2 := h2 + fix_byte_order data[2];
    h3 := h3 + fix_byte_order data[3];
    h4 := h4 + fix_byte_order data[4];
    h5 := h5 + fix_byte_order data[5];
    h6 := h6 + fix_byte_order data[6];
    h7 := h7 + fix_byte_order data[7];
    h8 := h8 + fix_byte_order data[8];
    h9 := h9 + fix_byte_order data[9];
    h10 := h10 + fix_byte_order data[10];
    h11 := h11 + fix_byte_order data[11];
    spookyhash_end_partial<> (h0, h1, h2, h3, h4, h5,
                              h6, h7, h8, h9, h10, h11);
    spookyhash_end_partial<> (h0, h1, h2, h3, h4, h5,
                              h6, h7, h8, h9, h10, h11);
    spookyhash_end_partial<> (h0, h1, h2, h3, h4, h5,
                              h6, h7, h8, h9, h10, h11)
  end

(********************************************************************)
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
 *
 *)

fn {}
spookyhash_short_mix (h0 : &uint64,
                      h1 : &uint64,
                      h2 : &uint64,
                      h3 : &uint64) :<!refwrt> void =
  begin
    h2 := h2 <<@ 50U;
    h2 := h2 + h3;
    h0 := h0 ^ h2;

    h3 := h3 <<@ 52U;
    h3 := h3 + h0;
    h1 := h1 ^ h3;

    h0 := h0 <<@ 30U;
    h0 := h0 + h1;
    h2 := h2 ^ h0;

    h1 := h1 <<@ 41U;
    h1 := h1 + h2;
    h3 := h3 ^ h1;

    h2 := h2 <<@ 54U;
    h2 := h2 + h3;
    h0 := h0 ^ h2;

    h3 := h3 <<@ 48U;
    h3 := h3 + h0;
    h1 := h1 ^ h3;

    h0 := h0 <<@ 38U;
    h0 := h0 + h1;
    h2 := h2 ^ h0;

    h1 := h1 <<@ 37U;
    h1 := h1 + h2;
    h3 := h3 ^ h1;

    h2 := h2 <<@ 62U;
    h2 := h2 + h3;
    h0 := h0 ^ h2;

    h3 := h3 <<@ 34U;
    h3 := h3 + h0;
    h1 := h1 ^ h3;

    h0 := h0 <<@ 5U;
    h0 := h0 + h1;
    h2 := h2 ^ h0;

    h1 := h1 <<@ 36U;
    h1 := h1 + h2;
    h3 := h3 ^ h1
  end

(********************************************************************)
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
 *
 *)

fn {}
spookyhash_short_end (h0 : &uint64,
                      h1 : &uint64,
                      h2 : &uint64,
                      h3 : &uint64) :<!refwrt> void =
  begin
    h3 := h3 ^ h2;
    h2 := h2 <<@ 15U;
    h3 := h3 + h2;
    
    h0 := h0 ^ h3;
    h3 := h3 <<@ 52U;
    h0 := h0 + h3;
    
    h1 := h1 ^ h0;
    h0 := h0 <<@ 26U;
    h1 := h1 + h0;
    
    h2 := h2 ^ h1;
    h1 := h1 <<@ 51U;
    h2 := h2 + h1;
    
    h3 := h3 ^ h2;
    h2 := h2 <<@ 28U;
    h3 := h3 + h2;
    
    h0 := h0 ^ h3;
    h3 := h3 <<@ 9U;
    h0 := h0 + h3;
    
    h1 := h1 ^ h0;
    h0 := h0 <<@ 47U;
    h1 := h1 + h0;
    
    h2 := h2 ^ h1;
    h1 := h1 <<@ 54U;
    h2 := h2 + h1;
    
    h3 := h3 ^ h2;
    h2 := h2 <<@ 32U;
    h3 := h3 + h2;
    
    h0 := h0 ^ h3;
    h3 := h3 <<@ 25U;
    h0 := h0 + h3;
    
    h1 := h1 ^ h0;
    h0 := h0 <<@ 63U;
    h1 := h1 + h0
  end

(********************************************************************)
(*
 * spookyhash_short:
 *
 * Short is used for messages under 192 bytes in length
 * (although it could be used for any message).
 *
 * Short has a low startup cost, the normal mode is good for long
 * keys, the cost crossover is at about 192 bytes.
 * The two modes were held to the same quality bar.
 *
 *)

fn {}
_short {length  : int}
       (message : &(@[byte][length]), (* Message aligned for uint64 *)
        length  : size_t length,
        seed1   : uint64,
        seed2   : uint64) :<!refwrt>
    @(uint64,         (* The first 64 bits (in native byte order). *)
      uint64) =       (* The second 64 bits (in native byte order). *)
  let
    prval _ = lemma_g1uint_param length

    stadef block_count = ndiv (length, 32)
    stadef remainder = nmod (length, 32)
    val block_count : size_t block_count =
      g1uint_div (length, i2sz 32)
    val remainder : size_t remainder =
      natmod (length, i2sz 32)

    stadef past_blocks = block_count * 32
    val past_blocks : size_t past_blocks = block_count * 32

    var a : uint64 = seed1
    var b : uint64 = seed2
    var c : uint64 = $UNSAFE.cast CONST
    var d : uint64 = $UNSAFE.cast CONST

    fun
    handle_blocks {i : int | 0 <= i; i <= block_count}
                  .<block_count - i>.
                  (message     : &(@[byte][length]),
                   block_count : size_t block_count,
                   i           : size_t i,
                   a           : &uint64,
                   b           : &uint64,
                   c           : &uint64,
                   d           : &uint64) :<!refwrt> void =
      if i <> block_count then
        let
          val p_data = ptr_add<byte> (addr@ message, i2sz 32 * i)

          prval (pf_before, pf_data, pf_after) =
            array_v_subdivide3 {byte} {..}
                               {32 * i, 32, length - 32 * i - 32}
                               (view@ message)
          prval pf_uint64 = bytes2array<uint64> {4} pf_data

          macdef data = !p_data

          val _ = c := c + fix_byte_order data[0]
          val _ = d := d + fix_byte_order data[1]
          val _ = spookyhash_short_mix<> (a, b, c, d)
          val _ = a := a + fix_byte_order data[2]
          val _ = b := b + fix_byte_order data[3]

          prval _ = pf_data := array2bytes<uint64> {4} pf_uint64
          prval _ = view@ message :=
            array_v_join3 {byte} {..}
                          {32 * i, 32, length - 32 * i - 32}
                          (pf_before, pf_data, pf_after)
        in
          handle_blocks (message, block_count, succ i, a, b, c, d)
        end

    fn {}
    handle_16_bytes {length : int |
                        32 * block_count + 16 <= length}
                    (message     : &(@[byte][length]),
                     past_blocks : size_t past_blocks,
                     a           : &uint64,
                     b           : &uint64,
                     c           : &uint64,
                     d           : &uint64) :<!refwrt> void =
      {
        val p_data = ptr_add<byte> (addr@ message, past_blocks)

        prval (pf_before, pf_data, pf_after) =
          array_v_subdivide3
            {byte} {..}
            {past_blocks, 16, length - past_blocks - 16}
            (view@ message)
        prval pf_uint64 = bytes2array<uint64> {2} pf_data

        macdef data = !p_data

        val _ = c := c + fix_byte_order data[0]
        val _ = d := d + fix_byte_order data[1]
        val _ = spookyhash_short_mix<> (a, b, c, d)

        prval _ = pf_data := array2bytes<uint64> {2} pf_uint64
        prval _ = view@ message :=
          array_v_join3
            {byte} {..}
            {past_blocks, 16, length - past_blocks - 16}
            (pf_before, pf_data, pf_after)
      }

    fn {}
    handle_last_bytes {length    : int}
                      {offset    : int | offset == past_blocks ||
                                         offset == past_blocks + 16}
                      {num_bytes : int | 0 <= num_bytes;
                                         num_bytes < 16;
                                         offset + num_bytes == length}
                      (message   : &(@[byte][length]),
                       offset    : size_t offset,
                       num_bytes : size_t num_bytes,
                       a         : &uint64,
                       b         : &uint64,
                       c         : &uint64,
                       d         : &uint64) :<!refwrt> void =
      {
        val p_data = ptr_add<byte> (addr@ message, offset)

        prval (pf_before, pf_data) =
          array_v_subdivide2 {byte} {..} {offset, length - offset}
                             (view@ message)

        val _ = d := d + (($UNSAFE.cast{uint64} length) <<@ 56U)

        fn {}
        get_uint32 {index   : int | 0 <= index;
                                    index * 4 + 4 <= num_bytes}
                   {p_data  : addr}
                   (pf_data : !(@[byte][num_bytes] @ p_data) >> _ |
                    p_data  : ptr p_data,
                    index   : int index) :<!ref> uint32 =
          let
            prval _ = lemma_mul_isfun {index, 4}
                                      {index, sizeof (uint32)} ()

            prval (pf_uint32_bytes, pf_after) =
              array_v_subdivide2
                {byte} {p_data}
                {index * 4 + 4, num_bytes - index * 4 - 4}
                pf_data
            prval pf_uint32 =
              bytes2array<uint32> {index + 1} pf_uint32_bytes

            macdef data = !p_data
            val result = data[index]

            prval _ = pf_uint32_bytes :=
              array2bytes<uint32> {index + 1} pf_uint32
            prval _ = pf_data :=
              array_v_join2
                {byte} {p_data}
                {index * 4 + 4, num_bytes - index * 4 - 4}
                (pf_uint32_bytes, pf_after)
          in
            fix_byte_order result
          end

        fn {}
        get_uint64 {index   : int | 0 <= index;
                                    index * 8 + 8 <= num_bytes}
                   {p_data  : addr}
                   (pf_data : !(@[byte][num_bytes] @ p_data) >> _ |
                    p_data  : ptr p_data,
                    index   : int index) :<!ref> uint64 =
          let
            prval _ = lemma_mul_isfun {index, 8}
                                      {index, sizeof (uint64)} ()

            prval (pf_uint64_bytes, pf_after) =
              array_v_subdivide2
                {byte} {p_data}
                {index * 8 + 8, num_bytes - index * 8 - 8}
                pf_data
            prval pf_uint64 =
              bytes2array<uint64> {index + 1} pf_uint64_bytes

            macdef data = !p_data
            val result = data[index]

            prval _ = pf_uint64_bytes :=
              array2bytes<uint64> {index + 1} pf_uint64
            prval _ = pf_data :=
              array_v_join2
                {byte} {p_data}
                {index * 8 + 8, num_bytes - index * 8 - 8}
                (pf_uint64_bytes, pf_after)
          in
            fix_byte_order result
          end

        macdef data = !p_data

        val _ =
          case+ (sz2i num_bytes) of
          | 0 =>
            begin
              c := c + $UNSAFE.cast CONST;
              d := d + $UNSAFE.cast CONST
            end
          | 1 =>
            begin
              c := c + (byte2u64 data[0])
            end
          | 2 =>
            begin
              c := c + ((byte2u64 data[1]) << 8U);
              c := c + (byte2u64 data[0])
            end
          | 3 =>
            begin
              c := c + ((byte2u64 data[2]) << 16U);
              c := c + ((byte2u64 data[1]) << 8U);
              c := c + (byte2u64 data[0])
            end
          | 4 =>
            begin
              c := c + u32u64 (get_uint32 (pf_data | p_data, 0))
            end
          | 5 =>
            begin
              c := c + ((byte2u64 data[4]) << 32U);
              c := c + u32u64 (get_uint32 (pf_data | p_data, 0))
            end
          | 6 =>
            begin
              c := c + ((byte2u64 data[5]) << 40U);
              c := c + ((byte2u64 data[4]) << 32U);
              c := c + u32u64 (get_uint32 (pf_data | p_data, 0))
            end
          | 7 =>
            begin
              c := c + ((byte2u64 data[6]) << 48U);
              c := c + ((byte2u64 data[5]) << 40U);
              c := c + ((byte2u64 data[4]) << 32U);
              c := c + u32u64 (get_uint32 (pf_data | p_data, 0))
            end
          | 8 =>
            begin
              c := c + get_uint64 (pf_data | p_data, 0)
            end
          | 9 =>
            begin
              d := d + (byte2u64 data[8]);
              c := c + get_uint64 (pf_data | p_data, 0)
            end
          | 10 =>
            begin
              d := d + ((byte2u64 data[9]) << 8U);
              d := d + (byte2u64 data[8]);
              c := c + get_uint64 (pf_data | p_data, 0)
            end
          | 11 =>
            begin
              d := d + ((byte2u64 data[10]) << 16U);
              d := d + ((byte2u64 data[9]) << 8U);
              d := d + (byte2u64 data[8]);
              c := c + get_uint64 (pf_data | p_data, 0)
            end
          | 12 =>
            begin
              d := d + u32u64 (get_uint32 (pf_data | p_data, 2));
              c := c + get_uint64 (pf_data | p_data, 0)
            end
          | 13 =>
            begin
              d := d + ((byte2u64 data[12]) << 32U);
              d := d + u32u64 (get_uint32 (pf_data | p_data, 2));
              c := c + get_uint64 (pf_data | p_data, 0)
            end
          | 14 =>
            begin
              d := d + ((byte2u64 data[13]) << 40U);
              d := d + ((byte2u64 data[12]) << 32U);
              d := d + u32u64 (get_uint32 (pf_data | p_data, 2));
              c := c + get_uint64 (pf_data | p_data, 0)
            end
          | 15 =>
            begin
              d := d + ((byte2u64 data[14]) << 48U);
              d := d + ((byte2u64 data[13]) << 40U);
              d := d + ((byte2u64 data[12]) << 32U);
              d := d + u32u64 (get_uint32 (pf_data | p_data, 2));
              c := c + get_uint64 (pf_data | p_data, 0)
            end

        prval _ = view@ message :=
          array_v_join2 {byte} {..} {offset, length - offset}
                        (pf_before, pf_data)
      }
  in
    (* Handle all complete sets of 32 bytes. *)
    if block_count <> i2sz 0 then
      handle_blocks (message, block_count, i2sz 0, a, b, c, d);

    if i2sz 16 <= remainder then
      begin
        (* Handle the case of 16 or more remaining bytes. *)
        handle_16_bytes (message, past_blocks, a, b, c, d);
        handle_last_bytes (message, past_blocks + i2sz 16,
                           remainder - i2sz 16, a, b, c, d)
      end
    else
      (* Handle the case of 15 or fewer remaining bytes. *)
      handle_last_bytes (message, past_blocks, remainder,
                         a, b, c, d);

    spookyhash_short_end<> (a, b, c, d);

    @(a, b)
  end

fn {}
spookyhash_short {length  : int | length <= BUFSIZE}
                 (message : &(@[byte][length]),
                  length  : size_t length,
                  seed1   : uint64,
                  seed2   : uint64) :<!refwrt>
    @(uint64,         (* The first 64 bits (in native byte order). *)
      uint64) =       (* The second 64 bits (in native byte order). *)
  if allow_direct_read (addr@ message) then
    _short<> (message, length, seed1, seed2)
  else
    let
      prval _ = lemma_g1uint_param length

      (* A buffer that obviously is aligned for uint64. *)
      var buf : @[uint64][TWICE_NUMVARS]

      prval pf_bytes =
        array2bytesqmark<uint64?> {TWICE_NUMVARS} (view@ buf)
      prval (pf_dest, pf_after) =
        array_v_subdivide2 {byte?} {..} {length, BUFSIZE - length}
                           pf_bytes

      val _ = memcpy (buf, message, length)
      val result = _short<> (buf, length, seed1, seed2)

      extern praxi
      ignore_array :
        {n : int} {p : addr}
        (@[byte?][n] @ p) -<prf> @[byte][n] @ p
      prval pf_after = ignore_array pf_after

      prval _ = pf_bytes :=
        array_v_join2 {byte} {..} {length, BUFSIZE - length}
                      (pf_dest, pf_after)
      prval _ = view@ buf :=
        bytes2array<uint64?> {TWICE_NUMVARS} pf_bytes
    in
      result
    end

(********************************************************************)

implement
spookyhash_init (context, seed1, seed2) =
  {
    extern praxi
    initialize (ctx : &spookyhash_context_t?
                          >> spookyhash_context_t) :<prf> void
    prval _ = initialize context

    val (pf, consume_pf | p) = m_length (context)
    val _ = !p := i2sz 0
    prval _ = consume_pf pf

    val (pf, consume_pf | p) = m_remainder (context)
    val _ = !p := u2u8 0U
    prval _ = consume_pf pf

    val (pf, consume_pf | p) = m_state (context)
    macdef state = !p
    val _ = state[0] := g1ofg0 seed1
    val _ = state[1] := g1ofg0 seed2
    prval _ = consume_pf pf
  }

(********************************************************************)

fn {}
initialize_variables (len   : Size_t,
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
                      state : &RD(@[uint64][NUMVARS])) :<!refwrt>
    void =
  if len < i2sz BUFSIZE then
    let
      val state0 = state[0]
      val state1 = state[1]
    in
      h0 := state0;
      h3 := state0;
      h6 := state0;
      h9 := state0;

      h1 := state1;
      h4 := state1;
      h7 := state1;
      h10 := state1;

      h2 := $UNSAFE.cast CONST;
      h5 := $UNSAFE.cast CONST;
      h8 := $UNSAFE.cast CONST;
      h11 := $UNSAFE.cast CONST
    end
  else
    begin
      h0 := state[0];
      h1 := state[1];
      h2 := state[2];
      h3 := state[3];
      h4 := state[4];
      h5 := state[5];
      h6 := state[6];
      h7 := state[7];
      h8 := state[8];
      h9 := state[9];
      h10 := state[10];
      h11 := state[11]
    end

fn {}
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
     size_t (length - j)) =
  let
    prval _ = lemma_g1uint_param rem
  in
    if rem <> i2sz 0 then
      let
        prval (pf_prefx, pf_message) =
          array_v_subdivide2
            {byte} {p_msg}
            {BUFSIZE - rem, length - (BUFSIZE - rem)} pf_msg

        stadef prefx = BUFSIZE - rem
        val prefx : size_t prefx = (i2sz BUFSIZE) - rem

        (* Copy prefx bytes from the message to the data buffer. *)
        prval pf_bytes = array2bytes<uint64> {TWICE_NUMVARS} pf_data
        prval (pf_before, pf_dest, pf_after) =
          array_v_subdivide3 {byte} {p_data}
                             {rem, prefx, BUFSIZE - rem - prefx}
                             pf_bytes
        val _ = memcpy (!(ptr_add<byte> (p_data, rem)),
                        !p_msg, prefx)
        prval _ = pf_bytes :=
          array_v_join3 {byte} {p_data}
                        {rem, prefx, BUFSIZE - rem - prefx}
                        (pf_before, pf_dest, pf_after)
        prval _ = pf_data :=
          bytes2array<uint64> {TWICE_NUMVARS} pf_bytes

        (* Mix in both halves of the data buffer. *)
        prval (pf1, pf2) =
          array_v_subdivide2 {uint64} {p_data} {NUMVARS, NUMVARS}
                             pf_data
        val p1 = p_data
        val p2 = ptr_add<uint64> (p_data, i2sz NUMVARS)
        val _ = spookyhash_mix<> (!p1, s0, s1, s2, s3, s4, s5,
                                  s6, s7, s8, s9, s10, s11)
        val _ = spookyhash_mix<> (!p2, s0, s1, s2, s3, s4, s5,
                                  s6, s7, s8, s9, s10, s11)
        prval _ = pf_data :=
          array_v_join2 {uint64} {p_data} {NUMVARS, NUMVARS}
                        (pf1, pf2)
      in
        (* Return the rest of the message, coming after the
           first prefx bytes. *)
        (pf_prefx, pf_message | ptr_add<byte> (p_msg, prefx),
                                length - prefx)
      end
    else
      let      
        prval (pf_prefx, pf_message) =
          array_v_subdivide2 {byte} {p_msg} {0, length} pf_msg
      in
        (* Return the whole message. *)
        (pf_prefx, pf_message | p_msg, length)
      end
  end

fun {}
mix_in_blocks {block_count : int}
              {p_blocks    : addr}
              {i           : int | 0 <= i; i <= block_count}
              .<block_count - i>.
              (pf_blocks   : !(@[byte][block_count * BLOCKSIZE]
                                  @ p_blocks) >> _ |
               p_blocks    : ptr p_blocks,
               block_count : size_t block_count,
               i           : size_t i,
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
               s11         : &uint64) :<!refwrt> void =
  if i <> block_count then
    {
      stadef total_size = block_count * BLOCKSIZE
      stadef before = i * BLOCKSIZE
      stadef after = total_size - BLOCKSIZE - before
      prval (pf_before, pf_block, pf_after) =
        array_v_subdivide3 {byte} {p_blocks}
                           {before, BLOCKSIZE, after}
                           pf_blocks
      val p = ptr_add<byte> (p_blocks, i * i2sz BLOCKSIZE)
      val _ = spookyhash_mix_unaligned (!p, s0, s1, s2, s3, s4, s5,
                                        s6, s7, s8, s9, s10, s11)
      prval _ = pf_blocks :=
        array_v_join3 {byte} {p_blocks}
                      {before, BLOCKSIZE, after}
                      (pf_before, pf_block, pf_after)

      val _ = mix_in_blocks (pf_blocks | p_blocks, block_count,
                                         succ i, s0, s1, s2, s3,
                                         s4, s5, s6, s7, s8, s9,
                                         s10, s11) 
    }

implement
spookyhash_update {length} (context, message, length) =
  let
    prval _ = lemma_g1uint_param length

    val [p_data : addr]
        (pf_data, consume_pf_data | p_data) = m_data (context)
    val [p_state : addr]
        (pf_state, consume_pf_state | p_state) = m_state (context)
    val [p_len : addr]
        (pf_len, consume_pf_len | p_len) = m_length (context)
    val [p_rem : addr]
        (pf_rem, consume_pf_rem | p_rem) = m_remainder (context)

    macdef consume_views =
      {
        prval _ = consume_pf_data pf_data
        prval _ = consume_pf_state pf_state
        prval _ = consume_pf_len pf_len
        prval _ = consume_pf_rem pf_rem
      }

    val [rem : int] rem = g1ofg1 (!p_rem)
    prval _ = lemma_g1uint_param rem

    val new_length = length + u8sz rem
  in
    if new_length < i2sz BUFSIZE then
      (* The message fragment is short. Store it for later use. *)
      {
        prval pf_bytes = array2bytes<uint64> {TWICE_NUMVARS} pf_data
        prval (pf_before, pf_dest, pf_after) =
          array_v_subdivide3 {byte} {p_data}
                             {rem, length, BUFSIZE - rem - length}
                             pf_bytes

        val _ = memcpy (!(ptr_add<byte> (p_data, u8sz rem)),
                        message, length)

        prval _ = pf_bytes :=
          array_v_join3 {byte} {p_data}
                        {rem, length, BUFSIZE - rem - length}
                        (pf_before, pf_dest, pf_after)
        prval _ = pf_data :=
          bytes2array<uint64> {TWICE_NUMVARS} pf_bytes

        val _ = !p_len := !p_len + length
        val _ = !p_rem := sz2u8 new_length

        val _ = consume_views
      }
    else
      {
        var h0 : uint64
        var h1 : uint64
        var h2 : uint64
        var h3 : uint64
        var h4 : uint64
        var h5 : uint64
        var h6 : uint64
        var h7 : uint64
        var h8 : uint64
        var h9 : uint64
        var h10 : uint64
        var h11 : uint64

        val _ = initialize_variables (!p_len, h0, h1, h2, h3,
                                      h4, h5, h6, h7, h8, h9,
                                      h10, h11, !p_state);
        val _ = !p_len := !p_len + length;

        val [p_msg : addr] p_msg = g1ofg1 (addr@ message)          
        val [j : int] (pf_prefx, pf_message | p_message, length1) =
          use_buffered_data (pf_data, view@ message |
                             p_data, p_msg, u8sz rem, length,
                             h0, h1, h2, h3, h4, h5,
                             h6, h7, h8, h9, h10, h11)
        stadef length1 = length - j
        stadef p_message = p_msg + j * sizeof (byte)

        (* Divide the message into blocks and a small remainder. *)
        stadef block_count = ndiv (length1, BLOCKSIZE)
        stadef remainder = nmod (length1, BLOCKSIZE)
        val block_count : size_t block_count =
          g1uint_div (length1, i2sz BLOCKSIZE)
        val remainder : size_t remainder =
          natmod (length1, i2sz BLOCKSIZE)

        prval _ = prop_verify {block_count * BLOCKSIZE + remainder
                                    == length1} ()
        prval _ = prop_verify {remainder < BLOCKSIZE} ()

        prval (pf_blocks, pf_remainder) =
          array_v_subdivide2
            {byte} {p_message} {block_count * BLOCKSIZE, remainder}
            pf_message

        (* Handle all the full-size blocks. *)
        val _ = mix_in_blocks (pf_blocks |
                               p_message, block_count, i2sz 0,
                               h0, h1, h2, h3, h4, h5,
                               h6, h7, h8, h9, h10, h11)

        (* Store the remainder. *)
        val _ = !p_rem := sz2u8 remainder
        val p_remainder =
          ptr_add<byte> {p_message} {block_count * BLOCKSIZE}
                        (p_message, block_count * i2sz BLOCKSIZE)
        prval pf_bytes = array2bytes<uint64> {TWICE_NUMVARS} pf_data
        prval (pf_data1, pf_data2) =
          array_v_subdivide2 {byte} {p_data}
                             {remainder, BUFSIZE - remainder}
                             pf_bytes
        val _ = memcpy (!p_data, !p_remainder, remainder)
        prval _ = pf_bytes :=
          array_v_join2 {byte} {p_data}
                        {remainder, BUFSIZE - remainder}
                        (pf_data1, pf_data2)
        prval _ =
          pf_data := bytes2array<uint64> {TWICE_NUMVARS} pf_bytes

        (* Store the state variables. *)
        val _ =
          let
            macdef state = !p_state
          in
            state[0] := h0;
            state[1] := h1;
            state[2] := h2;
            state[3] := h3;
            state[4] := h4;
            state[5] := h5;
            state[6] := h6;
            state[7] := h7;
            state[8] := h8;
            state[9] := h9;
            state[10] := h10;
            state[11] := h11
          end

        prval _ = pf_message :=
          array_v_join2 {byte} {p_message}
                        {block_count * BLOCKSIZE, remainder}
                        (pf_blocks, pf_remainder)
        prval _ = view@ message :=
          array_v_join2 (pf_prefx, pf_message)

        val _ = consume_views
      }
  end

(********************************************************************)

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
              h11     : &uint64) :<!refwrt> void =
  {
    (* Mix in the last partial block, and the length mod BLOCKSIZE. *)

    prval _ = lemma_g1uint_param rem

    prval pf_bytes = array2bytes<uint64> {NUMVARS} pf_data
    prval (pf_before, pf_fill) =
      array_v_subdivide2 {byte} {p_data} {rem, BLOCKSIZE - rem}
                         pf_bytes

    val _ = memset (!(ptr_add<byte> (p_data, rem)),
                    u2byte 0U, i2sz BLOCKSIZE - rem)
    prval _ = pf_bytes :=
      array_v_join2 {byte} {p_data} {rem, BLOCKSIZE - rem}
                    (pf_before, pf_fill)

    macdef data = !p_data
    val _ = data[BLOCKSIZE - 1] := sz2byte rem

    prval _ = pf_data := bytes2array<uint64> {NUMVARS} pf_bytes

    val _ = spookyhash_end<> (data, h0, h1, h2, h3, h4, h5, h6,
                              h7, h8, h9, h10, h11)
  }

implement
spookyhash_final (context) =
  let
    val [p_data : addr]
        (pf_data, consume_pf_data | p_data) = m_data (context)
    val [p_state : addr]
        (pf_state, consume_pf_state | p_state) = m_state (context)
    val [p_len : addr]
        (pf_len, consume_pf_len | p_len) = m_length (context)

    macdef state = !p_state
  
    val [len : int] len = g1ofg1 (!p_len)
    prval _ = lemma_g1uint_param len
  in
    if len < i2sz BUFSIZE then
      let
        prval pf_bytes =
          array2bytes<uint64> {TWICE_NUMVARS} {p_data} pf_data
        prval (pf_src, pf_after) =
          array_v_subdivide2
            {byte} {p_data} {len, BUFSIZE - len} pf_bytes
        val result =
          spookyhash_short<> (!p_data, len, state[0], state[1])
        prval _ = pf_bytes :=
          array_v_join2
            {byte} {p_data} {len, BUFSIZE - len} (pf_src, pf_after)
        prval _ = pf_data :=
          bytes2array<uint64> {TWICE_NUMVARS} {p_data} pf_bytes
        prval _ = consume_pf_data pf_data
        prval _ = consume_pf_state pf_state
        prval _ = consume_pf_len pf_len
      in
        result
      end
    else
      let
        var h0 : uint64 = state[0]
        var h1 : uint64 = state[1]
        var h2 : uint64 = state[2]
        var h3 : uint64 = state[3]
        var h4 : uint64 = state[4]
        var h5 : uint64 = state[5]
        var h6 : uint64 = state[6]
        var h7 : uint64 = state[7]
        var h8 : uint64 = state[8]
        var h9 : uint64 = state[9]
        var h10 : uint64 = state[10]
        var h11 : uint64 = state[11]

        val [p_rem : addr]
            (pf_rem, consume_pf_rem | p_rem) = m_remainder (context)

        val [rem : int] rem = g1ofg1 (!p_rem)
        val rem = u8sz rem
        prval _ = lemma_g1uint_param rem

        prval (pf_half1, pf_half2) =
          array_v_subdivide2
            {uint64} {p_data} {NUMVARS, NUMVARS} pf_data

        val _ =
          if i2sz BLOCKSIZE <= rem then
            {

              (* The data field of a spookyhash_context_t
                 can contain two blocks; handle any whole
                 first block. *)
              val _ = spookyhash_mix<> (!p_data, h0, h1, h2, h3, h4,
                                        h5, h6, h7, h8, h9, h10, h11)

              val p_half2 = ptr_add<uint64> (p_data, i2sz NUMVARS)
              val _ =
                final_mixing<> (pf_half2 | p_half2,
                                rem - i2sz BLOCKSIZE, h0, h1, h2, h3,
                                h4, h5, h6, h7, h8, h9, h10, h11)
            }
          else
            final_mixing<> (pf_half1 | p_data,
                            rem, h0, h1, h2, h3, h4, h5, h6, h7, h8,
                            h9, h10, h11)

        prval _ = pf_data :=
          array_v_join2 {uint64} {p_data} {NUMVARS, NUMVARS}
                        (pf_half1, pf_half2)

        prval _ = consume_pf_data pf_data
        prval _ = consume_pf_state pf_state
        prval _ = consume_pf_len pf_len
        prval _ = consume_pf_rem pf_rem
      in
        (h0, h1)
      end
  end

(********************************************************************)

implement
spookyhash_hash128 {length} (message, length, seed1, seed2) =
  if length < i2sz BUFSIZE then
    spookyhash_short<> (message, length, seed1, seed2)
  else
    let
      var h0 : uint64 = seed1
      var h1 : uint64 = seed2
      var h2 : uint64 = $UNSAFE.cast CONST
      var h3 : uint64 = seed1
      var h4 : uint64 = seed2
      var h5 : uint64 = $UNSAFE.cast CONST
      var h6 : uint64 = seed1
      var h7 : uint64 = seed2
      var h8 : uint64 = $UNSAFE.cast CONST
      var h9 : uint64 = seed1
      var h10 : uint64 = seed2
      var h11 : uint64 = $UNSAFE.cast CONST

      (* Divide the message into blocks and a small remainder. *)
      stadef block_count = ndiv (length, BLOCKSIZE)
      stadef remainder = nmod (length, BLOCKSIZE)
      val block_count : size_t block_count =
        g1uint_div (length, i2sz BLOCKSIZE)
      val remainder : size_t remainder =
        natmod (length, i2sz BLOCKSIZE)

      prval _ = prop_verify {block_count * BLOCKSIZE + remainder
                                  == length} ()
      prval _ = prop_verify {remainder < BLOCKSIZE} ()

      prval (pf_blocks, pf_remainder) =
        array_v_subdivide2
          {byte} {..} {block_count * BLOCKSIZE, remainder}
          (view@ message)

      (* Handle all the full-size blocks. *)
      val _ = mix_in_blocks (pf_blocks |
                             addr@ message, block_count, i2sz 0,
                             h0, h1, h2, h3, h4, h5,
                             h6, h7, h8, h9, h10, h11)

      (* Handle the remainder. *)

      var buf : @[uint64][NUMVARS]

      prval pf_bytes = array2bytesqmark<uint64?> {NUMVARS} (view@ buf)
      prval (pf_memcpy, pf_memset) =
        array_v_subdivide2
          {byte?} {..} {remainder, BLOCKSIZE - remainder}
          pf_bytes

      val p_remainder =
        ptr_add<byte> {..} {block_count * BLOCKSIZE}
                      (addr@ message, block_count * i2sz BLOCKSIZE)
      val p_memcpy = addr@ buf
      val p_memset = ptr_add<byte> {..} {remainder}
                                   (p_memcpy, remainder)
      val _ = memcpy (!p_memcpy, !p_remainder, remainder)
      val _ = memset (!p_memset, u2byte 0U,
                      i2sz BLOCKSIZE - remainder)

      prval _ = pf_bytes :=
        array_v_join2
          {byte} {..} {remainder, BLOCKSIZE - remainder}
          (pf_memcpy, pf_memset)

      val _ = buf[BLOCKSIZE - 1] := sz2byte remainder

      prval _ = view@ buf := bytes2array<uint64> {NUMVARS} pf_bytes
      prval _ = view@ message :=
        array_v_join2
          {byte} {..} {block_count * BLOCKSIZE, remainder}
          (pf_blocks, pf_remainder)

      val _ = spookyhash_end<> (buf, h0, h1, h2, h3, h4, h5,
                                h6, h7, h8, h9, h10, h11)
    in
      (h0, h1)
    end

(********************************************************************)
(* Hash functions that are just spookyhash_hash128 with the
   result truncated. *)

implement
spookyhash_hash64 (message, length, seed) =
  (spookyhash_hash128 (message, length, seed, seed)).0

implement
spookyhash_hash32 (message, length, seed) =
  u64u32 (spookyhash_hash64 (message, length, u32u64 seed))

(********************************************************************)
