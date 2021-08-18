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

/* This file can be read as either C or ATS2. */

#define ATS2_SPOOKYHASH_NUMVARS 12
#define ATS2_SPOOKYHASH_BLOCKSIZE 96 /* = (NUMVARS * 8) */
#define ATS2_SPOOKYHASH_BUFSIZE 192 /* = (BLOCKSIZE * 2) */

/*
 * sc_const: a constant which:
 *    is not zero
 *    is odd
 *    is a not-very-regular mix of 1's and 0's
 *    does not need any other special mathematical properties
 */
#define ATS2_SPOOKYHASH_CONST 0xdeadbeefdeadbeefLL
