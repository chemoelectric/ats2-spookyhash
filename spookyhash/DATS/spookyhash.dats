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

#define ATS_PACKNAME "ats2-spookyhash"
#define ATS_EXTERN_PREFIX "ats2_spookyhash_"

#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload "spookyhash/SATS/array_prf.sats"
staload "spookyhash/SATS/spookyhash.sats"

#include "spookyhash/HATS/spookyhash-parameters.hats"
#define NUMVARS ATS2_SPOOKYHASH_NUMVARS
#define BUFSIZE ATS2_SPOOKYHASH_BUFSIZE
#define CONST   ATS2_SPOOKYHASH_CONST

typedef remainder_t (i : int) = [i < BUFSIZE] g1uint (uint8knd, i)
typedef remainder_t = [i : int] remainder_t i

(*
typedef u64_t (i : int) = g1uint (uint64knd, i)
typedef u64_t = [i : int] g1uint (uint64knd, i)
*)

(********************************************************************)

%{
_Static_assert (sizeof (atstype_byte) == 1,
                "atstype_byte is not 1 byte");

_Static_assert (sizeof (atstype_uint64) == 8,
                "uint64 is not 8 bytes");
%}

prval _ = $UNSAFE.prop_assert {sizeof (byte) == 1} ()
prval _ = $UNSAFE.prop_assert {sizeof (uint64) == 8} ()

extern praxi {t : vt@ype}
array2bytes_v :
  {n : int}
  {p : addr}
  (@[t][n] @ p) -<prf> (@[byte][n * sizeof (t)] @ p)

extern praxi {t : vt@ype}
bytes2array_v :
  {n : int}
  {p : addr}
  (@[byte][n * sizeof (t)] @ p) -<prf> (@[t][n] @ p)

extern praxi {t : vt@ype}
array2bytesqmark_v :
  {n : int}
  {p : addr}
  (@[t][n] @ p) -<prf> (@[byte?][n * sizeof (t)] @ p)

extern praxi {t : vt@ype}
bytesqmark2array_v :
  {n : int}
  {p : addr}
  (@[byte?][n * sizeof (t)] @ p) -<prf> (@[t][n] @ p)

(********************************************************************)

extern castfn
g1ofg1_g1uint {tk : tkind}
              {i  : int}
              (i  : g1uint (tk, i)) :<>
    [j : int | j == i] g1uint (tk, j)

overload g1ofg1 with g1ofg1_g1uint

extern castfn
u2u8 {i : int} (i : uint i) :<> uint8 i

extern castfn
u8sz {i : int} (i : uint8 i) :<> size_t i

extern castfn
sz2u8 {i : int} (i : size_t i) :<> uint8 i

extern fun
memcpy {n   : int}
       (dst : &(@[byte?][n]) >> @[byte][n],
        src : &RD(@[byte][n]),
        n   : size_t n) :<!refwrt> void = "mac#%"

extern fun
bitwise_and_ullint (x : ullint, y : ullint) :<> ullint = "mac#%"

overload bitwise_and with bitwise_and_ullint

extern fun
bitwise_xor_uint64 (x : uint64, y : uint64) :<> uint64 = "mac#%"

overload bitwise_xor with bitwise_xor_uint64

infixl ( + ) ^
overload ^ with bitwise_xor

extern fun
bitwise_lrotate_uint64_uint {i : int | i < 64}
                            (x : uint64,
                             i : uint i) :<> uint64 = "mac#%"

overload bitwise_lrotate with bitwise_lrotate_uint64_uint

infix ( * ) <<@
overload <<@ with bitwise_lrotate

(* On big-endian platforms, swap the byte order.
   On little-endian platforms, make no changes. *)
extern fun
fix_byte_order_uint64 (x : uint64) :<> uint64 = "mac#%"

overload fix_byte_order with fix_byte_order_uint64

fn {}
allow_direct_read_g1 {p : addr}
                         (p : ptr p) :<> bool =
  if $extval (int, "ATS2_SPOOKYHASH_ALLOW_UNALIGNED_READS") <> 0 then
    true
  else
    let
      (* FIXME: Use actual uintptr_t if possible. *)
      typedef my_uintptr_t = ullint
      val i = $UNSAFE.cast{my_uintptr_t} p
      val mask = $UNSAFE.cast{my_uintptr_t} 0x07U
    in
      bitwise_and (i, mask) = $UNSAFE.cast{my_uintptr_t} 0
    end

fn {}
allow_direct_read_g0 (p : ptr) :<> bool =
  allow_direct_read_g1 (g1ofg0 p)

overload allow_direct_read with allow_direct_read_g0 of 0
overload allow_direct_read with allow_direct_read_g1 of 10

(********************************************************************)

extern fun
m_data (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (@[uint64][2 * NUMVARS] @ p,
     @[uint64][2 * NUMVARS] @ p -<lin,prf> void |
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
        (data : &RD(@[byte][NUMVARS * sizeof (uint64)]),
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
        view@ data := bytes2array_v<uint64> {NUMVARS} (view@ data)
      val _ = spookyhash_mix (data, s0, s1, s2, s3, s4, s5,
                              s6, s7, s8, s9, s10, s11)
      prval _ =
        view@ data := array2bytes_v<uint64> {NUMVARS} (view@ data)
    }
  else
    {
      var buf : @[uint64][NUMVARS]
      prval _ =
        view@ buf := array2bytesqmark_v<uint64?> {NUMVARS} (view@ buf)
      val _ = memcpy (buf, data, (i2sz NUMVARS) * sizeof<uint64>)
      prval _ =
        view@ buf := bytes2array_v<uint64> {NUMVARS} (view@ buf)
      val _ = spookyhash_mix (buf, s0, s1, s2, s3, s4, s5,
                              s6, s7, s8, s9, s10, s11)
    }

(********************************************************************)

implement
spookyhash_init (context, seed1, seed2) =
  {
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
                  (pf_data : !(@[uint64][2 * NUMVARS] @ p_data) >> _,
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
        prval pf_bytes = array2bytes_v<uint64> {2 * NUMVARS} pf_data
        prval (pf1, pf2, pf3) =
          array_v_subdivide3 {byte} {p_data}
                             {rem, prefx, BUFSIZE - rem - prefx}
                             pf_bytes
        val _ = memcpy (!(ptr_add<byte> (p_data, rem)),
                        !p_msg, prefx)
        prval _ = pf_bytes := array_v_join3 (pf1, pf2, pf3)
        prval _ =
          pf_data := bytes2array_v<uint64> {2 * NUMVARS} pf_bytes

        (* Mix in both halves of the data buffer. *)
        prval (pf1, pf2) =
          array_v_subdivide2 {uint64} {p_data} {NUMVARS, NUMVARS}
                             pf_data
        val p1 = p_data
        val p2 = ptr_add<uint64> (p_data, i2sz NUMVARS)
        val _ = spookyhash_mix (!p1, s0, s1, s2, s3, s4, s5,
                                s6, s7, s8, s9, s10, s11)
        val _ = spookyhash_mix (!p2, s0, s1, s2, s3, s4, s5,
                                s6, s7, s8, s9, s10, s11)
        prval _ = pf_data := array_v_join2 (pf1, pf2)
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
        prval pf_bytes = array2bytes_v<uint64> {2 * NUMVARS} pf_data
        prval (pf1, pf2, pf3) =
          array_v_subdivide3 {byte} {p_data}
                             {rem, length, BUFSIZE - rem - length}
                             pf_bytes

        val _ = memcpy (!(ptr_add<byte> (p_data, u8sz rem)),
                        message, length)
        val _ = !p_len := !p_len + length
        val _ = !p_rem := sz2u8 new_length

        prval _ = pf_bytes := array_v_join3 (pf1, pf2, pf3)
        prval _ =
          pf_data := bytes2array_v<uint64> {2 * NUMVARS} pf_bytes
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
          
        val (pf_prefx, pf_message | p_message, length) =
          use_buffered_data (pf_data, view@ message |
                             p_data, addr@ message, u8sz rem, length,
                             h0, h1, h2, h3, h4, h5,
                             h6, h7, h8, h9, h10, h11)

        // FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME

        prval _ = view@ message := array_v_join2 (pf_prefx, pf_message)
        val _ = consume_views
      }
  end

(*
    // if we've got anything stuffed away, use it now
    if (m_remainder)
    {
        uint8 prefix = sc_bufSize-m_remainder;
        memcpy(&(((uint8 * )m_data)[m_remainder]), message, prefix);
        u.p64 = m_data;
        Mix(u.p64, h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11);
        Mix(&u.p64[sc_numVars], h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11);
        u.p8 = ((const uint8 * )message) + prefix;
        length -= prefix;
    }
    else
    {
        u.p8 = (const uint8 * )message;
    }
    
    // handle all whole blocks of sc_blockSize bytes
    end = u.p64 + (length/sc_blockSize)*sc_numVars;
    remainder = (uint8)(length-((const uint8 * )end-u.p8));
    if (ALLOW_UNALIGNED_READS || (u.i & 0x7) == 0)
    {
        while (u.p64 < end)
        { 
            Mix(u.p64, h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11);
	    u.p64 += sc_numVars;
        }
    }
    else
    {
        while (u.p64 < end)
        { 
            memcpy(m_data, u.p8, sc_blockSize);
            Mix(m_data, h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11);
	    u.p64 += sc_numVars;
        }
    }

    // stuff away the last few bytes
    m_remainder = remainder;
    memcpy(m_data, end, remainder);
    
    // stuff away the variables
    m_state[0] = h0;
    m_state[1] = h1;
    m_state[2] = h2;
    m_state[3] = h3;
    m_state[4] = h4;
    m_state[5] = h5;
    m_state[6] = h6;
    m_state[7] = h7;
    m_state[8] = h8;
    m_state[9] = h9;
    m_state[10] = h10;
    m_state[11] = h11;
}
*)

(********************************************************************)
