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
   -- Comparison : `add_first' for  ARRAY, FIXED_ARRAY, LINKED_LIST
   --                               and TWO_WAY_LINKED_LIST.
   --

feature

   -- According to the power of your computer, set `tuning'
   -- to a good positive value. Default is for very small
   -- computer :
   tuning: INTEGER is 1; -- 6000;

feature {NONE}

   frozen bench(cltn: COLLECTION[INTEGER]) is
      require
         cltn.count = 0
      local
         i: INTEGER;
      do
         from
            i := tuning + 5;
         until
            i = 0
         loop
            cltn.add_first(i);
            check
               cltn.item(cltn.lower) = i
            end;
            i := i - 1;
         end;
         debug
            from
               i := cltn.upper - 1;
            until
               i < cltn.lower
            loop
               check
                  cltn.item(i) = cltn.item(i + 1) - 1
               end;
               i := i - 1;
            end;
         end;
      end;

end -- BENCH
