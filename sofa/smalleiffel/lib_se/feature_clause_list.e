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
class FEATURE_CLAUSE_LIST

inherit GLOBALS;

creation {BASE_CLASS} make

feature {NONE}

   list: ARRAY[FEATURE_CLAUSE];

   make(first: FEATURE_CLAUSE) is
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
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > list.upper
         loop
            fmt.set_indent_level(0);
            fmt.indent;
            if not fmt.zen_mode then
               fmt.skip(1);
            end;
            list.item(i).pretty_print;
            i := i + 1;
         end;
      ensure
         fmt.indent_level = 0;
      end;

feature {SHORT}

   for_short(bcn: CLASS_NAME; sort: BOOLEAN;
             rf_list: FIXED_ARRAY[RUN_FEATURE]; rc: RUN_CLASS) is
      local
         i: INTEGER;
         fc: FEATURE_CLAUSE;
      do
         from
            i := 1;
         until
            i > list.upper
         loop
            fc := list.item(i);
            fc.for_short(bcn,sort,rf_list,rc);
            i := i + 1;
         end;
      end;

feature {BASE_CLASS}

   get_started(fd: DICTIONARY[E_FEATURE,STRING]) is
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > list.upper
         loop
            list.item(i).add_into(fd);
            i := i + 1;
         end;
      end;

   add_last(fc: FEATURE_CLAUSE) is
      require
         fc /= Void;
      do
         list.add_last(fc);
      end;

invariant

   list.lower = 1;

   not list.is_empty;

end -- FEATURE_CLAUSE_LIST

