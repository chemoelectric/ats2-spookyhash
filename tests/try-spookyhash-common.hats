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

staload "spookyhash/SATS/spookyhash.sats"

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

%{^

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

void *
atsruntime_malloc_undef (size_t bsz)
{
  return malloc (bsz);
}

void
atsruntime_mfree_undef (void *ptr)
{
  free (ptr);
}

static atstype_uint64
get_seed1 (int argc, char *argv[])
{
  return (2 <= argc) ? strtoull (argv[1], NULL, 16) : 0;
}

static atstype_uint64
get_seed2 (int argc, char *argv[])
{
  return (3 <= argc) ? strtoull (argv[2], NULL, 16) : 0;
}

static atstype_size
get_length (int argc, char *argv[])
{
  return (4 <= argc) ? atoll (argv[3]) : 0;
}

static atstype_int
get_pattern (int argc, char *argv[])
{
  return (5 <= argc) ? atoll (argv[4]) : 0;
}

static atstype_uint64
get_reference_hash1 (int argc, char *argv[])
{
  return (6 <= argc) ? strtoull (argv[5], NULL, 16) : 0;
}

static atstype_uint64
get_reference_hash2 (int argc, char *argv[])
{
  return (7 <= argc) ? strtoull (argv[6], NULL, 16) : 0;
}

static void
print_results (atstype_uint64 seed1,
               atstype_uint64 seed2,
               atstype_size length,
               atstype_int pattern,
               atstype_uint64 hash1,
               atstype_uint64 hash2)
{
  printf ("%016" PRIX64 " %016" PRIX64 " %zu %d "
          "%016" PRIX64 " %016" PRIX64 "\n",
          seed1, seed2, length, pattern, hash1, hash2);
}

%}

extern fun
get_seed1 {n    : int}
          (argc : int n,
           argv : !argv n) : uint64 =
  "mac#get_seed1"

extern fun
get_seed2 {n    : int}
          (argc : int n,
           argv : !argv n) : uint64 =
  "mac#get_seed2"

extern fun
get_length {n    : int}
           (argc : int n,
            argv : !argv n) : size_t =
  "mac#get_length"

extern fun
get_pattern {n    : int}
            (argc : int n,
             argv : !argv n) : int =
  "mac#get_pattern"

extern fun
get_reference_hash1 {n    : int}
                    (argc : int n,
                     argv : !argv n) : uint64 =
  "mac#get_reference_hash1"

extern fun
get_reference_hash2 {n    : int}
                    (argc : int n,
                     argv : !argv n) : uint64 =
  "mac#get_reference_hash2"

fn
fill_message_0 {length  : int}
               (message : &(@[byte?][length]) >> @[byte][length],
                length  : size_t length) : void =
  let
    prval _ = lemma_g1uint_param length

    fun
    loop {i  : int | 0 <= i} {p : addr} .<i>.
         (pf : !(@[byte?][i] @ p) >> @[byte][i] @ p |
          p  : ptr p,
          i  : size_t i) : void =
      if i = i2sz 0 then
        {
          prval _ = pf := array_v_unnil_nil {byte?, byte} pf
        }
      else
        {
          val i1 = pred i
          val p_elem = ptr_add<byte> (p, i1)
          prval (pf1, pf_elem) = array_v_unextend pf
          val _ = !p_elem :=
            $UNSAFE.cast ((i1 + i2sz 128) mod i2sz 256)
          val _ = loop (pf1 | p, i1)
          prval _ = pf := array_v_extend (pf1, pf_elem)
        }
  in
    loop (view@ message | addr@ message, length)
  end

fn
fill_message {length  : int}
             {p_msg   : addr}
             (pf_msg  : !(@[byte?][length] @ p_msg)
                            >> @[byte][length] @ p_msg |
              p_msg   : ptr p_msg,
              length  : size_t length,
              pattern : int) : void =
  if pattern = 0 then
    fill_message_0 (!p_msg, length)
  else
    {
      val _ = $extfcall (int, "printf",
                         "pattern other than 0 is not supported.\n")
      val _ = $extfcall (void, "exit", 1)
      val _ = pf_msg :=
        $UNSAFE.castview0{@[byte][length] @ p_msg} pf_msg
    }
