--          This file is part of SmallEiffel The GNU Eiffel Compiler.
--          Copyright (C) 1994-98 LORIA - UHP - CRIN - INRIA - FRANCE
--            Dominique COLNET and Suzanne COLLIN - colnet@loria.fr
--                       http://SmallEiffel.loria.fr
-- SmallEiffel is  free  software;  you can  redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the Free
-- Software  Foundation;  either  version  2, or (at your option)  any  later
-- version. SmallEiffel is distributed in the hope that it will be useful,but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- or  FITNESS FOR A PARTICULAR PURPOSE.   See the GNU General Public License
-- for  more  details.  You  should  have  received a copy of the GNU General
-- Public  License  along  with  SmallEiffel;  see the file COPYING.  If not,
-- write to the  Free Software Foundation, Inc., 59 Temple Place - Suite 330,
-- Boston, MA 02111-1307, USA.
--
class TEST_GCD
   --
   -- Have a look to INTEGER/gcd.
   --
   -- Note: SmallEiffel handle recursivity in assertions.
   --
creation {ANY}
   make

feature {ANY}

   make is
      do
         check
            (3).gcd(4) = 1;
            (4).gcd(4) = 4;
            (8).gcd(4) = 4;
            (9).gcd(8) = 1;
            (9).gcd(12) = 3;
         end;
      end;

end -- TEST_GCD
