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
class FORMAL_GENERIC_LIST
--
-- To store the list of formal generic arguments of (a generic) class.
--

inherit GLOBALS;

creation make

feature

   start_position: POSITION;
         -- Of first "[".

feature {NONE}

   list: ARRAY[FORMAL_GENERIC_ARG];

feature

   make(sp: like start_position; l: like list) is
      require
         not sp.is_unknown;
         l /= Void;
         not l.is_empty;
         l.lower = 1;
      local
         rank, i: INTEGER;
         fga: FORMAL_GENERIC_ARG;
      do
         start_position := sp;
         list := l;
         from
            i := l.upper;
         until
            i = 0
         loop
            fga := l.item(i);
            check
               fga /= Void;
            end;
            rank := index_of(fga.name);
            if rank /= i then
               eh.add_position(l.item(rank).start_position);
               eh.add_position(fga.start_position);
               fatal_error("Formal generic name appears twice in %
                           %formal generic list (VCFG.2).");
            end;
            i := i - 1;
         end;
      ensure
         start_position = sp;
         list = l;
      end;

   count: INTEGER is
      do
         Result := list.upper;
      end;

   item(i: INTEGER): FORMAL_GENERIC_ARG is
      require
         1 <= i;
         i <= count;
      do
         Result := list.item(i);
      ensure
         Result /= Void;
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         fmt.put_character('[');
         fmt.level_incr;
         from
            i := 1;
         until
            i > list.upper
         loop
            list.item(i).pretty_print;
            i := i + 1;
            if i <= list.upper then
               fmt.put_string(",");
            end;
         end;
         fmt.put_character(']');
         fmt.level_decr;
      ensure
         fmt.indent_level = old fmt.indent_level;
      end;

   short is
      local
         i: INTEGER;
      do
         short_print.hook_or("open_sb","[");
         from
            i := 1;
         until
            i > list.upper
         loop
            list.item(i).short;
            i := i + 1;
            if i <= list.upper then
               short_print.hook_or("fgl_sep",",");
            end;
         end;
         short_print.hook_or("close_sb","]");
      end;

feature {FORMAL_GENERIC_ARG}

   index_of(n: CLASS_NAME): INTEGER is
         -- Index of `n' or 0 when not found.
      require
         n /= Void
      local
         to_string: STRING;
      do
         from
            to_string := n.to_string;
            Result := list.upper;
         until
            Result = 0 or else
            to_string = list.item(Result).name.to_string
         loop
            Result := Result - 1;
         end;
      ensure
         0 <= Result;
         Result <= list.upper;
      end;

feature {BASE_CLASS}

   check_generic_formal_arguments is
      local
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            i = 0
         loop
            list.item(i).check_generic_formal_arguments;
            i := i - 1;
         end;
      end;

invariant

   list.lower = 1;

   not list.is_empty;

end -- FORMAL_GENERIC_LIST
