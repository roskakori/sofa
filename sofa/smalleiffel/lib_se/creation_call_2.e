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
class CREATION_CALL_2
   --
   -- For creation call like :
   --                           !BAR!foo
   --

inherit
   CREATION_CALL_1_2;
   CREATION_CALL_2_4;

creation make

feature

   make(sp: like start_position; t: like type; w: like writable) is
      require
         not sp.is_unknown;
         t /= Void;
         w /= Void;
      do
         start_position := sp;
         type := t;
         writable := w;
      end;

   compile_to_c is
      do
         if type.is_reference then
            c2c_opening(type);
            c2c_closing(type);
         else
            c2c_clear_expanded(type.id);
         end;
      end;

   compile_to_jvm is
      local
         t: TYPE;
      do
         t := type.run_type;
         compile_to_jvm0(t);
         t.jvm_check_class_invariant;
         writable.jvm_assign;
      end;

   use_current: BOOLEAN is
      do
         Result := writable.use_current;
      end;

   to_runnable(ct: TYPE): like Current is
      do
         if current_type = Void then
            check_writable(ct);
            check_explicit_type;
            check_created_type(type);
            check_creation_clause(type);
            Result := Current;
         else
            !!Result.make(start_position,type,writable);
            Result := Result.to_runnable(ct);
         end;
      end;

   pretty_print is
      do
         fmt.put_character('!');
         type.pretty_print;
         fmt.put_character('!');
         writable.pretty_print;
         if fmt.semi_colon_flag then
            fmt.put_character(';');
         end;
      end;

invariant

   type /= Void;

   call = Void;

   run_feature = Void;

end -- CREATION_CALL_2

