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
deferred class ATTRIBUTE
   --
   -- For all sorts of attributes : constants (CST_ATT), unique
   --   (CST_ATT_UNIQUE) and instance variables (WRITABLE_ATTRIBUTE).
   --

inherit E_FEATURE;

feature

   result_type: TYPE;

feature

   is_deferred: BOOLEAN is false;

feature

   obsolete_mark: MANIFEST_STRING is
      do
      end;

   require_assertion: E_REQUIRE is
      do
      end;

   ensure_assertion: E_ENSURE is
      do
      end;

   pretty_print is
      do
         pretty_print_profile;
         pretty_tail;
         fmt.put_character(';');
         if header_comment /= void then
            fmt.set_indent_level(2);
            fmt.indent;
            fmt.set_indent_level(1);
            header_comment.pretty_print;
         else
            fmt.set_indent_level(1);
         end;
      end;

   pretty_print_arguments is
      do
      end;

   arguments: FORMAL_ARG_LIST is
      do
      end;

feature {NONE}

   pretty_tail is
      deferred
      end;

   try_to_undefine_aux(fn: FEATURE_NAME;
                       bc: BASE_CLASS): DEFERRED_ROUTINE is
      do
         eh.add_position(start_position);
         error(fn.start_position,
               "An attribute must not be undefined (VDUS).");
         bc.fatal_undefine(fn);
      end;

invariant

   no_arguments: arguments = Void

end -- ATTRIBUTE

