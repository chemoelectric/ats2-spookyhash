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

%{
_Static_assert (sizeof (atstype_byte) == 1,
                "atstype_byte is not 1 byte");

_Static_assert (sizeof (atstype_uint8) == 1,
                "atstype_uint8 is not 1 byte");

_Static_assert (sizeof (atstype_uint32) == 4,
                "uint32 is not 4 bytes");

_Static_assert (sizeof (atstype_uint64) == 8,
                "uint64 is not 8 bytes");
%}

praxi
integer_sizes () :<prf>
  [sizeof (byte) == 1]
  [sizeof (uint8) == 1]
  [sizeof (uint32) == 4]
  [sizeof (uint64) == 8]
  void

praxi {t : vt@ype}
fake_initialize_array_v :<prf>
  {n : int} {p : addr}
  (@[t?][n] @ p) -<prf> @[t][n] @ p

praxi {t : vt@ype}
array2bytes :<prf>
  {n : int}
  {p : addr}
  (@[t][n] @ p) -<prf> (@[byte][n * sizeof (t)] @ p)

praxi {t : vt@ype}
bytes2array :<prf>
  {n : int}
  {p : addr}
  (@[byte][n * sizeof (t)] @ p) -<prf> (@[t][n] @ p)

praxi {t : vt@ype}
array2bytesqmark :<prf>
  {n : int}
  {p : addr}
  (@[t][n] @ p) -<prf> (@[byte?][n * sizeof (t)] @ p)

praxi {t : vt@ype}
bytesqmark2array :<prf>
  {n : int}
  {p : addr}
  (@[byte?][n * sizeof (t)] @ p) -<prf> (@[t][n] @ p)

prfun
lemma_mul_isfun {m1, n1 : int}
                {m2, n2 : int | m1 == m2; n1 == n2}
                () :<prf>
    [m1 * n1 == m2 * n2] void
