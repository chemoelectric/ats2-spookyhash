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

#include "spookyhash/DATS/include/spookyhash-templates.inc"

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
        val _ = mix_in_blocks<> (pf_blocks |
                                 p_message, block_count,
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
