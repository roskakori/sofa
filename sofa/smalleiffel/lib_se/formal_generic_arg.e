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
class FORMAL_GENERIC_ARG
   --
   -- To store one formal generic argument.
   --

inherit GLOBALS;

creation make

feature

   name: CLASS_NAME;
         -- Name of the formal generic argument.

   constraint: TYPE;

feature {NONE}

   make(n: like name; c: like constraint) is
      require
         n /= Void
      do
         name := n;
         constraint := c;
      ensure
         name = n;
         constraint = c
      end;

feature

   base_class: BASE_CLASS is
      do
         Result := name.start_position.base_class;
      ensure
         Result.is_generic
      end;

   rank: INTEGER is
         -- In the corresponding declation list.
      do
         check
            base_class /= Void;
            base_class.is_generic;
            base_class.formal_generic_list.count >= 1;
         end;
         Result := base_class.formal_generic_list.index_of(Current.name);
      ensure
         Result >= 1
      end;

   constrained: BOOLEAN is
      do
         Result := (constraint /= void);
      end;

   start_position: POSITION is
      do
         Result := name.start_position;
      end;

   pretty_print is
      do
         name.pretty_print;
         if constrained then
            fmt.level_incr;
            fmt.put_string("->");
            constraint.pretty_print;
            fmt.level_decr;
         end;
      end;

   short is
      do
         short_print.a_class_name(name);
         if constrained then
            short_print.hook_or("arrow","->");
            constraint.short;
         end;
      end;

feature {FORMAL_GENERIC_LIST}

   check_generic_formal_arguments is
      do
         if small_eiffel.is_used(name.to_string) then
            eh.add_position(name.start_position);
            fatal_error("A formal generic argument must not be the %
                        %name of an existing class (VCFG.1).");

         end;
      end;

invariant

   name /= Void;

end -- FORMAL_GENERIC_ARG

