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

(********************************************************************)

typedef remainder_t (i : int) = [i < BUFSIZE] g1uint (uint8knd, i)
typedef remainder_t = [i : int] remainder_t i

extern fun
m_data (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (@[g1uint uint64knd][2 * NUMVARS] @ p,
     @[g1uint uint64knd][2 * NUMVARS] @ p -<lin,prf> void |
     ptr p) = "mac#%"

extern fun
m_state (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (@[g1uint uint64knd][NUMVARS] @ p,
     @[g1uint uint64knd][NUMVARS] @ p -<lin,prf> void |
     ptr p) = "mac#%"

extern fun
m_length (context : &spookyhash_context_t) :<!ref>
    [p : addr]
    (g1uint sizeknd @ p,
     g1uint sizeknd @ p -<lin,prf> void |
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

implement
spookyhash_update {length} (context, message, length) =
  let
    prval _ = lemma_g1uint_param length

    val [p_data : addr]
        (pf_data, consume_pf_data | p_data) =
      m_data (context)
    val [p_state : addr]
        (pf_state, consume_pf_state | p_state) =
      m_state (context)
    val [p_length : addr]
        (pf_length, consume_pf_length | p_length) =
      m_length (context)
    val [p_remainder : addr]
        (pf_remainder, consume_pf_remainder | p_remainder) =
      m_remainder (context)

    macdef consume_views =
      {
        prval _ = consume_pf_data pf_data
        prval _ = consume_pf_state pf_state
        prval _ = consume_pf_length pf_length
        prval _ = consume_pf_remainder pf_remainder
      }

    val [rem : int] rem = g1ofg1 (!p_remainder)
    val rem = u8sz rem
    val new_length = length + rem
  in
    if new_length < i2sz BUFSIZE then
      (* The message fragment is short. Store it for later use. *)
      {
        prval pf_bytes =
          array2bytes_v<g1uint uint64knd> {2 * NUMVARS} pf_data
        prval _ = lemma_g1uint_param rem
        prval (pf1, pf2, pf3) =
          array_v_subdivide3 {byte} {p_data}
                             {rem, length, BUFSIZE - rem - length}
                             pf_bytes
        val _ = memcpy (!(ptr_add<byte> (p_data, rem)), message,
                        length)
        prval _ = pf_bytes := array_v_join3 (pf1, pf2, pf3)
        prval _ = pf_data :=
          bytes2array_v<g1uint uint64knd> {2 * NUMVARS} pf_bytes

        val _ = !p_length := !p_length + length
        val _ = !p_remainder := sz2u8 new_length
        val _ = consume_views
      }
    else
      /* FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME */
      consume_views
  end

(*
// add a message fragment to the state
void SpookyHash::Update(const void *message, size_t length)
{
    uint64 h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11;
    size_t newLength = length + m_remainder;
    uint8  remainder;
    union 
    { 
        const uint8 *p8; 
        uint64 *p64; 
        size_t i; 
    } u;
    const uint64 *end;
    
    // Is this message fragment too short?  If it is, stuff it away.
    if (newLength < sc_bufSize)
    {
        memcpy(&((uint8 * )m_data)[m_remainder], message, length);
        m_length = length + m_length;
        m_remainder = (uint8)newLength;
        return;
    }
    
    // init the variables
    if (m_length < sc_bufSize)
    {
        h0=h3=h6=h9  = m_state[0];
        h1=h4=h7=h10 = m_state[1];
        h2=h5=h8=h11 = sc_const;
    }
    else
    {
        h0 = m_state[0];
        h1 = m_state[1];
        h2 = m_state[2];
        h3 = m_state[3];
        h4 = m_state[4];
        h5 = m_state[5];
        h6 = m_state[6];
        h7 = m_state[7];
        h8 = m_state[8];
        h9 = m_state[9];
        h10 = m_state[10];
        h11 = m_state[11];
    }
    m_length = length + m_length;
    
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
