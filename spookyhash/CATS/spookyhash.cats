/*

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

*/

#ifndef ATS2_SPOOKYHASH_CATS_HEADER_GUARD__
#define ATS2_SPOOKYHASH_CATS_HEADER_GUARD__

#include "spookyhash/HATS/spookyhash-parameters.hats"

typedef struct
{
  /* Unhashed data, for partial messages. */
  atstype_uint64 data[2 * ATS2_SPOOKYHASH_NUMVARS];
  /* Internal state of the hash. */
  atstype_uint64 state[ATS2_SPOOKYHASH_NUMVARS];
  /* Total length of the input so far. */
  atstype_size length;
  /* Length of unhashed data stashed in m_data. */
  atstype_uint8 remainder;
} ats2_spookyhash_context_t;

#endif /* ATS2_SPOOKYHASH_CATS_HEADER_GUARD__ */
