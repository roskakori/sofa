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
class INDEX_LIST
   --
   -- For the indexing clause in the heading part of a class.
   --

inherit GLOBALS;

creation {BASE_CLASS} make

feature {NONE}

   list: ARRAY[INDEX_CLAUSE];

   make(first: INDEX_CLAUSE) is
      require
         first /= Void
      do
         !!list.with_capacity(4,1);
	 list.add_last(first);
      ensure
         list.first = first
      end;

feature

   pretty_print is
      require
         fmt.indent_level = 0;
      local
         i: INTEGER;
      do
         fmt.put_string("indexing");
         fmt.level_incr;
         fmt.indent;
         from
            i := 1;
         until
            i > list.upper
         loop
            list.item(i).pretty_print;
            i := i + 1;
            if i <= list.upper then
               fmt.put_string(fz_00);
               fmt.indent;
            end;
         end;
         fmt.put_string(";%N%N");
         fmt.level_decr;
         fmt.indent;
      ensure
         fmt.indent_level = old fmt.indent_level;
      end;

feature {BASE_CLASS}

   add_last(ic: INDEX_CLAUSE) is
      require
         ic /= Void
      do
         list.add_last(ic);
      end;

invariant

   list.lower = 1;

   not list.is_empty;

end -- INDEX_LIST

