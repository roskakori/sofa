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
deferred class BENCH
   --
   -- Comparison :  ARRAY, FIXED_ARRAY, LINKED_LIST and TWO_WAY_LINKED_LIST.
   --

feature

   -- According to the power of your computer, set `tuning'
   -- to a good positive value. Default is for very small
   -- computer :
   tuning: INTEGER is 1; -- 500000;

feature {NONE}

   cltn: COLLECTION[INTEGER] is
      deferred
      end;

   count: INTEGER is
      do
         Result := 1 + tuning;
      end;

   frozen bench is
      require
         cltn.count = count
      do
         increment(cltn,1);
         increment(cltn,1);
         increment(cltn,-2);
         check_all(cltn,0);
      end;

   increment(c: like cltn; value: INTEGER) is
      local
         i: INTEGER;
      do
         from
            i := c.upper;
         until
            i = c.lower
         loop
            c.put(c.item(i-1),i);
            i := i - 1;
         end;
      end;

   check_all(c: like cltn; value: DOUBLE) is
      local
         i: INTEGER;
      do
         from
            i := c.upper;
         until
            i = c.lower
         loop
            if c.item(i) /= value then
               std_output.put_string("Error in bench.%N");
            end;
            i := i - 1;
         end;
      end;

end -- BENCH
