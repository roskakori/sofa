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
class CECIL_TARGET
   --
   -- Pseudo expression to handle CECIL target.
   --

inherit EXPRESSION;

creation make

feature

   is_current: BOOLEAN is true;

   is_writable: BOOLEAN is false;

   is_static: BOOLEAN is false;

   is_pre_computable: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   is_result: BOOLEAN is false;

   is_void: BOOLEAN is false;

   can_be_dropped: BOOLEAN is true;

   use_current: BOOLEAN is true;

   isa_dca_inline_argument: INTEGER is 0;

   c_simple: BOOLEAN is true;

   to_integer_or_error: INTEGER is
      do
	 to_integer_error;
      end;

   static_result_base_class: BASE_CLASS is
      do
         Result := result_type.base_class;
      end;

   result_type: TYPE is
      do
         Result := run_feature.current_type;
      end;

   static_value: INTEGER is
      do
      end;

   start_position: POSITION is
      do
      end;

   assertion_check(tag: CHARACTER) is
      do
      end;

   afd_check is
      do
      end;

   to_runnable(ct: TYPE): like Current is
      do
         Result := Current;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   mapping_c_target(target_type: TYPE) is
      do
--         run_feature.current_type.mapping_cast;
	 target_type.mapping_cast;
         cpp.put_character('C');
      end;

   mapping_c_arg(formal_arg_type: TYPE) is
      do
         mapping_c_target(result_type);
      end;

   c_declare_for_old is
      do
      end;

   compile_to_c_old is
      do
      end;

   compile_to_jvm_old is
      do
      end;

   collect_c_tmp is
      do
      end;

   compile_to_c is
      do
         if result_type.is_user_expanded then
            cpp.put_character('*');
         end;
         cpp.print_current;
      end;

   compile_to_jvm is
      do
         result_type.jvm_push_local(0);
      end;

   compile_target_to_jvm is
      do
         compile_to_jvm;
      end;

   jvm_branch_if_false: INTEGER is
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifeq;
      end;

   jvm_branch_if_true: INTEGER is
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifne;
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
      end;

feature {NONE}

   run_feature: RUN_FEATURE;

   make(rf: RUN_FEATURE) is
      require
         rf /= Void
      do
         run_feature := rf;
      ensure
         run_feature = rf
      end;

end -- CECIL_TARGET

