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

#include "try-spookyhash-common.hats"

prval _ = $UNSAFE.prop_assert {sizeof (byte) == 1} ()

prfn
mul_compare_lte {i, j, n : nat | i <= j}
                () :<prf> [i * n <= j * n] void =
  mul_gte_gte_gte {j - i, n} ()

%{^

/* A natural numbers mod function. */
static inline atstype_size
natmod_size (atstype_size x, atstype_size y)
{
  return (x % y);
}

%}

(* A natural numbers mod function. *)
extern fn
natmod_size {x, y : nat | y != 0}
            (x    : size_t x,
             y    : size_t y) :<>
    [z : nat | z <= x; z < y; z == x mod y]
    size_t z = "mac#natmod_size"

overload natmod with natmod_size

implement
main0 (argc, argv) =
  {
    val seed1 = get_seed1 (argc, argv)
    val seed2 = get_seed2 (argc, argv)
    val length = get_length (argc, argv)
    val pattern = get_pattern (argc, argv)
    val reference_hash1 = get_reference_hash1 (argc, argv)
    val reference_hash2 = get_reference_hash2 (argc, argv)

    val [length : int] length = g1ofg0 length

    (* In one piece. *)

    var context : spookyhash_context_t

    val () = spookyhash_init (context, seed1, seed2)

    val (pf_msg, pf_msg_mem | p_msg) = malloc_gc (length)
    val _ = fill_message (pf_msg | p_msg, length, pattern)
    val () = spookyhash_update (context, !p_msg, length)
    val _ = mfree_gc (pf_msg, pf_msg_mem | p_msg)

    val (hash1, hash2) = spookyhash_final (context)

    var h1 : uint64
    var h2 : uint64
    val () = spookyhash_final_vars (context, h1, h2)

    val () = assertloc (h1 = hash1)
    val () = assertloc (h2 = hash2)

    val _ = 
      if hash1 <> reference_hash1 || hash2 <> reference_hash2 then
        {
          val _ = $extfcall (int, "printf", "In one piece --\n")
          val _ = $extfcall (int, "printf", "Expected:\n")
          val _ = $extfcall (void, "print_hash128_results",
                             seed1, seed2, length, pattern,
                             reference_hash1, reference_hash2)
          val _ = $extfcall (int, "printf", "Got:\n")
          val _ = $extfcall (void, "print_hash128_results",
                             seed1, seed2, length, pattern,
                             hash1, hash2)
          val _ = $extfcall (void, "exit", 1)
        }

    (* In two consecutive pieces, cut all the different ways. *)

    fn
    in_two_pieces {length  : int}
                  {i       : int | 0 <= i; i <= length}
                  (length  : size_t length,
                   pattern : int,
                   seed1   : uint64,
                   seed2   : uint64,
                   i       : size_t i,
                   finals  : bool) : @(uint64, uint64) =
      let
        val (pf_msg, pf_msg_mem | p_msg) = malloc_gc (length)
        val _ = fill_message (pf_msg | p_msg, length, pattern)

        var context : spookyhash_context_t
        val () = spookyhash_init (context, seed1, seed2)

        val p1 = p_msg
        val p2 = ptr_add<byte> (p1, i)

        prval (pf1, pf2) =
          array_v_split {byte} {..} {length} {i} pf_msg
        val () = spookyhash_update (context, !p1, i)
        val _ =
          if finals then
            {
              val _ = spookyhash_final (context)
            }
        val () = spookyhash_update (context, !p2, length - i)
        val _ =
          if finals then
            {
              val _ = spookyhash_final (context)
            }
        prval _ = pf_msg :=
          array_v_unsplit {byte} {..} {i, length - i} (pf1, pf2)

        val _ = mfree_gc (pf_msg, pf_msg_mem | p_msg)
      in
        spookyhash_final (context)
      end

    val _ =
      let
        var i : [i : int | 0 <= i; i <= length + 1] size_t i
      in
        (* Test all the possible splits into two pieces. *)
        for (i := i2sz 0; i <> succ length; i := succ i)
          let
            val (hash1, hash2) =
              in_two_pieces (length, pattern, seed1, seed2, i, false)
          in
            if (hash1 <> reference_hash1 ||
                  hash2 <> reference_hash2) then
              {
                val _ = $extfcall (int, "printf",
                                   "In two pieces (%zu, %zu) --\n",
                                   i, length - i)
                val _ = $extfcall (int, "printf", "Expected:\n")
                val _ = $extfcall (void, "print_hash128_results",
                                   seed1, seed2, length, pattern,
                                   reference_hash1, reference_hash2)
                val _ = $extfcall (int, "printf", "Got:\n")
                val _ = $extfcall (void, "print_hash128_results",
                                   seed1, seed2, length, pattern,
                                   hash1, hash2)
                val _ = $extfcall (void, "exit", 1)
              }
          end
      end

    val _ =
      let
        var i : [i : int | 0 <= i; i <= length + 1] size_t i
      in
        (* Test all the possible splits into two pieces,
           and run spookyhash_final along the way. *)
        for (i := i2sz 0; i <> succ length; i := succ i)
          let
            val (hash1, hash2) =
              in_two_pieces (length, pattern, seed1, seed2, i, true)
          in
            if (hash1 <> reference_hash1 ||
                  hash2 <> reference_hash2) then
              {
                val _ =
                  $extfcall
                    (int, "printf",
                     "Running spookyhash_final along the way --\n")
                val _ = $extfcall (int, "printf",
                                   "In two pieces (%zu, %zu) --\n",
                                   i, length - i)
                val _ = $extfcall (int, "printf", "Expected:\n")
                val _ = $extfcall (void, "print_hash128_results",
                                   seed1, seed2, length, pattern,
                                   reference_hash1, reference_hash2)
                val _ = $extfcall (int, "printf", "Got:\n")
                val _ = $extfcall (void, "print_hash128_results",
                                   seed1, seed2, length, pattern,
                                   hash1, hash2)
                val _ = $extfcall (void, "exit", 1)
              }
          end
      end

    (* In chunks of a certain size. *)
    
    fn
    in_chunks {length  : int}
              {size    : int | 1 <= size; size <= length}
              (length  : size_t length,
               pattern : int,
               seed1   : uint64,
               seed2   : uint64,
               size    : size_t size,
               finals  : bool) : @(uint64, uint64) =
      let
        val (pf_msg, pf_msg_mem | p_msg) = malloc_gc (length)
        val _ = fill_message (pf_msg | p_msg, length, pattern)

        var context : spookyhash_context_t
        val () = spookyhash_init (context, seed1, seed2)

        stadef chunk_count = ndiv (length, size)
        stadef remainder = nmod (length, size)
        val chunk_count : size_t chunk_count =
          g1uint_div (length, size)
        val remainder : size_t remainder =
          natmod (length, size)

        prval _ = lemma_g1uint_param chunk_count
        prval _ = lemma_g1uint_param remainder

        fun
        loop {length, size, chunk_count, remainder : int |
                  0 <= length;
                  0 <= size;
                  0 <= chunk_count;
                  0 <= remainder;
                  remainder < size;
                  chunk_count * size == length - remainder}
             {i           : int | 0 <= i; i <= chunk_count}
             {p_msg       : addr}
             .<chunk_count - i>.
             (pf_msg      : !(@[byte][length] @ p_msg) >> _ |
              p_msg       : ptr p_msg,
              length      : size_t length,
              size        : size_t size,
              context     : &spookyhash_context_t,
              chunk_count : size_t chunk_count,
              remainder   : size_t remainder,
              i           : size_t i,
              finals      : bool) : void =
          if i < chunk_count then
            {
              prval _ = prop_verify {chunk_count * size <= length} ()

              prval _ = mul_gte_gte_gte {i, size} ()
              
              prval _ = mul_compare_lte {i + 1, chunk_count, size} ()
              prval _ = prop_verify {i * size + size <= length} ()

              val p = ptr_add<byte> (p_msg, i * size)

              prval (pf1, pf23) =
                array_v_split {byte} {p_msg} {length} {i * size}
                              pf_msg
              prval (pf2, pf3) =
                array_v_split {byte}
                              {p_msg + i * size * sizeof (byte)}
                              {length - i * size} {size}
                              pf23

              val _ = spookyhash_update (context, !p, size)
              val _ =
                if finals then
                  {
                    val _ = spookyhash_final (context)
                  }

              prval _ = pf23 :=
                array_v_unsplit {byte}
                                {p_msg + i * size * sizeof (byte)}
                                {size, length - i * size - size}
                                (pf2, pf3)
              prval _ = pf_msg :=
                array_v_unsplit {byte} {p_msg}
                                {i * size, length - i * size}
                                (pf1, pf23)

              val _ = loop (pf_msg | p_msg, length, size, context,
                                     chunk_count, remainder, succ i,
                                     finals)
            }
          else
            {
              prval _ =
                prop_verify
                  {remainder == length - chunk_count * size} ()

              prval _ = mul_gte_gte_gte {chunk_count, size} ()

              val p = ptr_add<byte> (p_msg, chunk_count * size)

              prval (pf1, pf2) =
                array_v_split
                  {byte} {..} {length} {chunk_count * size}
                  pf_msg

              val _ = spookyhash_update (context, !p, remainder)
              val _ =
                if finals then
                  {
                    val _ = spookyhash_final (context)
                  }

              prval _ = pf_msg :=
                array_v_unsplit
                  {byte} {..} {chunk_count * size, remainder}
                  (pf1, pf2)
            }
  
        (* FIXME: Prove this. *)
        val _ = assertloc (i2sz 1 <= chunk_count)

        val _ = loop {length, size, chunk_count, remainder}
                     (pf_msg | p_msg, length, size,
                               context, chunk_count,
                               remainder, i2sz 0, finals)

        val _ = mfree_gc (pf_msg, pf_msg_mem | p_msg)
      in
        spookyhash_final (context)
      end
    
    val _ =
      if length <> i2sz 0 then
        let
          var size : [size : int | 1 <= size; size <= length + 1]
                     size_t size
        in
          (* Test all the possible chunk sizes. *)
          for (size := i2sz 1; size <= length; size := succ size)
            let
              val (hash1, hash2) =
                in_chunks (length, pattern, seed1, seed2, size, false)
            in
              if (hash1 <> reference_hash1 ||
                    hash2 <> reference_hash2) then
                {
                  val _ =
                    $extfcall
                      (int, "printf",
                       "In %zu chunk(s) of size %zu, remainder %zu --\n",
                       g1uint_div (length, size), size,
                       natmod (length, size))
                  val _ = $extfcall (int, "printf", "Expected:\n")
                  val _ = $extfcall (void, "print_hash128_results",
                                     seed1, seed2, length, pattern,
                                     reference_hash1, reference_hash2)
                  val _ = $extfcall (int, "printf", "Got:\n")
                  val _ = $extfcall (void, "print_hash128_results",
                                     seed1, seed2, length, pattern,
                                     hash1, hash2)
                  val _ = $extfcall (void, "exit", 1)
                }
            end
        end


    val _ =
      if length <> i2sz 0 then
        let
          var size : [size : int | 1 <= size; size <= length + 1]
                     size_t size
        in
          (* Test all the possible chunk sizes, and run
             spookyhash_final along the way. *)
          for (size := i2sz 1; size <= length; size := succ size)
            let
              val (hash1, hash2) =
                in_chunks (length, pattern, seed1, seed2, size, true)
            in
              if (hash1 <> reference_hash1 ||
                    hash2 <> reference_hash2) then
                {
                  val _ =
                    $extfcall
                      (int, "printf",
                       "Running spookyhash_final along the way --\n")
                  val _ =
                    $extfcall
                      (int, "printf",
                       "In %zu chunk(s) of size %zu, remainder %zu --\n",
                       g1uint_div (length, size), size,
                       natmod (length, size))
                  val _ = $extfcall (int, "printf", "Expected:\n")
                  val _ = $extfcall (void, "print_hash128_results",
                                     seed1, seed2, length, pattern,
                                     reference_hash1, reference_hash2)
                  val _ = $extfcall (int, "printf", "Got:\n")
                  val _ = $extfcall (void, "print_hash128_results",
                                     seed1, seed2, length, pattern,
                                     hash1, hash2)
                  val _ = $extfcall (void, "exit", 1)
                }
            end
        end
  }
