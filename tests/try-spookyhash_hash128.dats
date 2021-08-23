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
    implement
    array_initize$init<byte> (i, elem) =
      elem := $UNSAFE.cast (((pred i) + i2sz 128) mod (i2sz 256))
  in
    array_initize<byte> (message, length)
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

implement
main0 (argc, argv) =
  {
    val seed1 = get_seed1 (argc, argv)
    val seed2 = get_seed2 (argc, argv)
    val length = get_length (argc, argv)
    val pattern = get_pattern (argc, argv)
    val reference_hash1 = get_reference_hash1 (argc, argv)
    val reference_hash2 = get_reference_hash2 (argc, argv)

    val length = g1ofg0 length

    val (pf_msg, pf_msg_mem | p_msg) = malloc_gc (length)
    val _ = fill_message (pf_msg | p_msg, length, pattern)
    val (hash1, hash2) =
      spookyhash_hash128 (!p_msg, length, seed1, seed2)
    val _ = mfree_gc (pf_msg, pf_msg_mem | p_msg)

    val _ = $extfcall (void, "print_results", seed1, seed2,
                       length, pattern, hash1, hash2)
  }
