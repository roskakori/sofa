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
class CREATION_CALL_4
   --
   -- For creation call like :
   --                           !BAR!foo.bar(...)
   --

inherit
   CREATION_CALL_3_4;
   CREATION_CALL_2_4;

creation make

feature

   make(sp: like start_position; t: like type; w: like writable; c: like call) is
      require
         not sp.is_unknown;
         t /= Void;
         w /= Void;
         c /= Void;
      do
         start_position := sp;
         type := t;
         writable := w;
         call := c;
      ensure
         start_position = sp;
         type = t;
         writable = w;
         call = c;
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
            !!Result.make(start_position,type,writable,call);
            Result := Result.to_runnable(ct);
         end;
      end;

   compile_to_c is
      do
         if type.is_reference then
            c2c_opening(type);
            cpp.push_new(run_feature,run_args);
            run_feature.mapping_c;
            cpp.pop;
            c2c_closing(type);
         else
            c2c_clear_expanded(type.id);
            c2c_expanded_initializer(type);
         end;
      end;

   compile_to_jvm is
      local
         w: EXPRESSION;
         t: TYPE;
      do
         w := writable;
         t := type.run_type;
         compile_to_jvm0(t);
         jvm.inside_new(run_feature,call);
         t.jvm_check_class_invariant;
         w.jvm_assign;
      end;

   use_current: BOOLEAN is
      do
         if run_args /= Void then
            Result := run_args.use_current;
         end;
         Result := Result or else writable.use_current;
      end;

   pretty_print is
      do
         fmt.put_character('!');
         type.pretty_print;
         fmt.put_character('!');
         call.pretty_print;
      end;

invariant

   type /= Void;

   call /= Void;

end -- CREATION_CALL_4


