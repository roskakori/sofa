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
deferred class EXTERNAL_ROUTINE
   --
   -- For routines implemented with a call to a foreign language.
   -- Root of EXTERNAL_PROCEDURE and EXTERNAL_FUNCTION.
   --

inherit ROUTINE;

feature

   native: NATIVE;

   alias_string: STRING;

feature

   is_deferred: BOOLEAN is false;

feature {NONE}

   make_external_routine(n: like native; desc: STRING) is
      require
         n /= void
      do
         native := n;
         alias_string := desc;
      end;

feature

   frozen set_rescue_compound(c: COMPOUND) is
      do
         if c /= Void then
            eh.add_position(c.start_position);
         else
            eh.add_position(start_position);
         end;
         eh.append("External feature must not have rescue compound.");
         eh.print_as_fatal_error;
      end;

   frozen use_current: BOOLEAN is
      do
         Result := native.use_current(Current);
      end;

   external_c_name: STRING is
      do
         if alias_string = Void then
            Result := first_name.to_string;
         else
            Result := alias_string;
         end;
      end;

feature {NONE}

   pretty_print_routine_body is
      do
         fmt.keyword("external");
         native.pretty_print;
         if not external_c_name.is_equal(first_name.to_string) or else
            names.count > 1 then
            fmt.indent;
            fmt.keyword("alias");
            fmt.put_character('%"');
            fmt.put_string(external_c_name);
            fmt.put_character('%"');
         end;
      end;

   pretty_print_rescue is
      do
      end;

end -- EXTERNAL_ROUTINE

