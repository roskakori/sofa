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
   -- To store the list of formal generic arguments of a generic
   -- class :
   --              [X,Y->Z]
   --

inherit GLOBALS;

creation make

feature

   start_position: POSITION;
         -- Of the opening square bracket.

   count: INTEGER is
      do
         Result := list.count;
      end;

   item(i: INTEGER): FORMAL_GENERIC_ARG is
      require
         i.in_range(1,count)
      do
         Result := list.item(i);
      ensure
         Result /= Void
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         fmt.put_character('[');
         fmt.level_incr;
         from
            i := list.lower;
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
            i := list.lower;
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

feature {BASE_CLASS}

   check_generic_formal_arguments is
      local
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            i < list.lower
         loop
            list.item(i).check_generic_formal_arguments;
            i := i - 1;
         end;
      end;

feature {EIFFEL_PARSER}

   add_last(fga: FORMAL_GENERIC_ARG) is
      require
	 fga /= Void
      local
	 fga2: FORMAL_GENERIC_ARG;
	 i: INTEGER;
         n1, n2: STRING;
      do
         from
            i := list.upper;
	    fga.set_rank(i + 1);
	    n1 := fga.name.to_string;
         until
            i < list.lower
         loop
	    fga2 := list.item(i);
            n2 := fga2.name.to_string;
            if n1 = n2 then
               eh.add_position(fga.start_position);
               eh.add_position(fga2.start_position);
               fatal_error("Formal generic name appears twice in %
                           %formal generic list (VCFG.2).");
            end;
	    fga2.constraint_substitution(fga,list.upper + 1);
            i := i - 1;
         end;
         list.add_last(fga);
      end;
   
feature {NONE}
   
   list: ARRAY[FORMAL_GENERIC_ARG];
   
   make(sp: like start_position) is
      require
         not sp.is_unknown
      do
	 !!list.with_capacity(4,1);
         start_position := sp;
      ensure
         start_position = sp
      end;

end -- FORMAL_GENERIC_LIST
