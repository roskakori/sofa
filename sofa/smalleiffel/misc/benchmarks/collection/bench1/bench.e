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
   tuning: INTEGER is 1; -- 200;

feature {NONE}

   count: INTEGER is
      do
         Result := tuning + 1;
      end;

   frozen bench(cltn: COLLECTION[INTEGER]) is
      require
         cltn.count = count
      local
         inner, outer, nb_loops, value: INTEGER
      do
         nb_loops := tuning * tuning;
         from
            outer := 1;
         until
            outer > nb_loops
         loop
            from
               inner := cltn.lower;
            until
               inner > cltn.upper
            loop
               value := cltn.item(inner);
               cltn.put(value + 1,inner);
               inner := inner + 1;
            end;
            outer := outer + 1
         end;
      end;

end -- BENCH
