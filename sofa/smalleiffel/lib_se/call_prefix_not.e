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
class CALL_PREFIX_NOT
   --
   --   Prefix operator : "not".
   --

inherit CALL_PREFIX redefine compile_to_c end;

creation make, with

feature

   precedence: INTEGER is 11;

feature {NONE}

   make(operator_position: POSITION; rp: like target) is
      require
         not operator_position.is_unknown;
         rp /= Void
      do
         !!feature_name.make(operator,operator_position);
         target := rp;
      ensure
         start_position = operator_position;
         target = rp
      end;

feature

   operator: STRING is
      do
         Result := as_not;
      end;

   isa_dca_inline_argument: INTEGER is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   is_static: BOOLEAN is
      do
         if target.result_type.is_boolean then
            if target.is_static then
               Result := true;
            end;
         end;
      end;

   static_value: INTEGER is
      do
         if target.result_type.is_boolean then
            if target.is_static then
               if target.static_value = 0 then
                  Result := 1;
               end;
            end;
         end;
      end;

   compile_to_c is
      do
         if run_control.boost and then
            target.result_type.run_type.is_boolean then
            cpp.put_string("!(");
            target.compile_to_c;
            cpp.put_character(')');
         else
            call_proc_call_c2c;
         end;
      end;

   compile_to_jvm is
      do
         call_proc_call_c2jvm;
      end;

   jvm_branch_if_false: INTEGER is
      do
         if result_type.is_boolean then
            target.compile_to_jvm;
            Result := code_attribute.opcode_ifne;
         else
            Result := jvm_standard_branch_if_false;
         end;
      end;

   jvm_branch_if_true: INTEGER is
      do
         if result_type.is_boolean then
            target.compile_to_jvm;
            Result := code_attribute.opcode_ifeq;
         else
            Result := jvm_standard_branch_if_true;
         end;
      end;

end -- CALL_PREFIX_NOT
