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
class TWO_WAY_LINKED_LIST_BENCH

inherit BENCH;

creation make

feature

   make is
      local
         link2_list: TWO_WAY_LINKED_LIST[INTEGER];
         i: INTEGER;
      do
         from
            !!link2_list.make;
            i := count;
         until
            i = 0
         loop
            link2_list.add_first(0);
            i := i - 1;
         end;
         bench(link2_list);
      end;

end -- TWO_WAY_LINKED_LIST_BENCH
