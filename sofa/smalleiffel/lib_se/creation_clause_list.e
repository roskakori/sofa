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
class CREATION_CLAUSE_LIST

inherit GLOBALS;

creation {BASE_CLASS} make

feature

   start_position: POSITION is
      do
         Result := list.first.start_position;
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         from
            i := list.lower;
         until
            i > list.upper
         loop
            list.item(i).pretty_print;
            if not fmt.zen_mode then
               fmt.set_indent_level(0);
               fmt.skip(1);
            end;
            i := i + 1;
         end;
      end;

   short: BOOLEAN is
         -- True when at least one creation list is printed.
      local
         i: INTEGER;
      do
         from
            i := list.lower;
         until
            i > list.upper
         loop
            Result := list.item(i).short(Result) or else Result;
            i := i + 1;
         end;
      end;

   get_clause(fn: FEATURE_NAME): CREATION_CLAUSE is
      local
         i: INTEGER;
      do
         from
            i := list.lower;
         until
            i > list.upper or else list.item(i).has(fn)
         loop
            i := i + 1;
         end;
         if i <= list.upper then
            Result := list.item(i);
         end;
      end;

feature {BASE_CLASS}

   root_procedure_name(procedure_name: STRING): SIMPLE_FEATURE_NAME is
      local
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            i < list.lower or else Result /= Void
         loop
            Result := list.item(i).root_procedure_name(procedure_name);
            i := i - 1;
         end;
      end;

   add_last(cc: CREATION_CLAUSE) is
      require
         cc /= Void
      do
         list.add_last(cc);
      end;

   check_expanded_with(t: TYPE) is
      require
         t.is_expanded;
      local
	 lower: INTEGER;
      do
         if list.count > 1 then
            eh.add_type(t,fz_cbe);
	    lower := list.lower;
            eh.add_position(list.item(lower).start_position);
	    lower := lower + 1;
            eh.add_position(list.item(lower).start_position);
            fatal_error_vtec_2;
         end;
         list.first.check_expanded_with(t);
      end;

   expanded_initializer(t: TYPE): RUN_FEATURE_3 is
      require
         t.is_expanded;
         not t.is_basic_eiffel_expanded
      do
         check
            list.count = 1
         end;
         Result := list.first.expanded_initializer(t);
      end;

feature {NONE}

   list: FIXED_ARRAY[CREATION_CLAUSE];

   make(first: CREATION_CLAUSE) is
      require
         first /= Void
      do
         !!list.with_capacity(4);
	 list.add_last(first);
      ensure
         list.first = first
      end;

invariant

   not list.is_empty;

end -- CREATION_CLAUSE_LIST

