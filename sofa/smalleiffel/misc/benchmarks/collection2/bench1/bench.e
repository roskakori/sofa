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
   -- Comparison : ARRAY2 Vs. FIXED_ARRAY2.
   --

feature

   -- According to the power of your computer, set `tuning'
   -- to a good positive value. Default is for very small
   -- computer :
   tuning: INTEGER is 2000; -- 300;

feature {NONE}

   cltn: COLLECTION2[DOUBLE] is
      deferred
      end;

   count1: INTEGER is
      do
         Result := 1 + tuning;
      end;

   count2: INTEGER is
      do
         Result := 7 + tuning;
      end;

   frozen bench is
      require
         cltn.count = count1 * count2
      do
         increment(cltn,+2.5);
         increment(cltn,-2.5);
         increment(cltn,+2.5);
         increment(cltn,-2.5);
         check_all(cltn,0.0);
      end;

   increment(c: like cltn; value: DOUBLE) is
      local
         i1, i2: INTEGER;
      do
         from
            i1 := c.upper1;
         until
            i1 < c.lower1
         loop
            from
               i2 := c.upper2;
            until
               i2 < c.lower2
            loop
               c.put(c.item(i1,i2) + value,i1,i2);
               i2 := i2 - 1;
            end;
            i1 := i1 - 1;
         end;
      end;

   check_all(c: like cltn; value: DOUBLE) is
      local
         i1, i2: INTEGER;
      do
         from
            i1 := c.upper1;
         until
            i1 < c.lower1
         loop
            from
               i2 := c.upper2;
            until
               i2 < c.lower2
            loop
               if c.item(i1,i2) /= value then
                  std_output.put_string("Error bench.%N");
               end;
               i2 := i2 - 1;
            end;
            i1 := i1 - 1;
         end;
      end;

end -- BENCH
