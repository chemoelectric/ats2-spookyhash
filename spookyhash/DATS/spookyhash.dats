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

typedef u64_t (i : int) = g1uint (uint64knd, i)
typedef u64_t = [i : int] g1uint (uint64knd, i)

(********************************************************************)

%{
_Static_assert (sizeof (atstype_uint64) == 8,
                "uint64 is not 8 bytes");
%}

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
spookyhash_mix (data : &RD(@[u64_t][NUMVARS]),
                s0   : &u64_t,
                s1   : &u64_t,
                s2   : &u64_t,
                s3   : &u64_t,
                s4   : &u64_t,
                s5   : &u64_t,
                s6   : &u64_t,
                s7   : &u64_t,
                s8   : &u64_t,
                s9   : &u64_t,
                s10  : &u64_t,
                s11  : &u64_t) :<!refwrt> void = "mac#%"

(********************************************************************)

extern fun
m_data (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (@[u64_t][2 * NUMVARS] @ p,
     @[u64_t][2 * NUMVARS] @ p -<lin,prf> void |
     ptr p) = "mac#%"

extern fun
m_state (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (@[u64_t][NUMVARS] @ p,
     @[u64_t][NUMVARS] @ p -<lin,prf> void |
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
                      h0    : &u64_t? >> u64_t,
                      h1    : &u64_t? >> u64_t,
                      h2    : &u64_t? >> u64_t,
                      h3    : &u64_t? >> u64_t,
                      h4    : &u64_t? >> u64_t,
                      h5    : &u64_t? >> u64_t,
                      h6    : &u64_t? >> u64_t,
                      h7    : &u64_t? >> u64_t,
                      h8    : &u64_t? >> u64_t,
                      h9    : &u64_t? >> u64_t,
                      h10   : &u64_t? >> u64_t,
                      h11   : &u64_t? >> u64_t,
                      state : &RD(@[u64_t][NUMVARS])) :<!refwrt>
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
        prval pf_bytes = array2bytes_v<u64_t> {2 * NUMVARS} pf_data
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
          pf_data := bytes2array_v<u64_t> {2 * NUMVARS} pf_bytes
        val _ = consume_views
      }
    else
      let
        var h0 : u64_t
        var h1 : u64_t
        var h2 : u64_t
        var h3 : u64_t
        var h4 : u64_t
        var h5 : u64_t
        var h6 : u64_t
        var h7 : u64_t
        var h8 : u64_t
        var h9 : u64_t
        var h10 : u64_t
        var h11 : u64_t
      in
        initialize_variables (!p_len, h0, h1, h2, h3,
                              h4, h5, h6, h7, h8, h9,
                              h10, h11, !p_state);
        !p_len := !p_len + length;

        /* FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME */

        consume_views
      end
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
