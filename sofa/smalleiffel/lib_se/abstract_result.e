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
deferred class ABSTRACT_RESULT
   --
   -- Handling of the pseudo variable `Result'.
   -- Common root of ONCE_RESULT and ORDINARY_RESULT.
   --

inherit EXPRESSION;

feature

   start_position: POSITION;

   is_result: BOOLEAN is true;

   is_writable: BOOLEAN is true;

   is_current: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   is_void: BOOLEAN is false;

   is_static: BOOLEAN is false;

   is_pre_computable: BOOLEAN is false;

   isa_dca_inline_argument: INTEGER is 0;

   can_be_dropped: BOOLEAN is true;

   c_simple: BOOLEAN is true;

   use_current: BOOLEAN is false;

   frozen result_type: TYPE is
      do
         Result := run_feature.result_type;
      end;

   frozen to_string, frozen to_key: STRING is
      do
         Result := as_result;
      end;

   frozen static_result_base_class: BASE_CLASS is
      local
         rf: RUN_FEATURE;
         e_feature: E_FEATURE;
         rt: TYPE;
         bcn: CLASS_NAME;
      do
         rf := small_eiffel.top_rf;
         e_feature := rf.base_feature;
         rt := e_feature.result_type;
         bcn := rt.static_base_class_name;
         if bcn /= Void then
            Result := bcn.base_class;
         end;
      end;

   frozen static_value: INTEGER is
      do
      end;

   frozen assertion_check(tag: CHARACTER) is
      do
      end;

   frozen afd_check is
      do
      end;

   frozen dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   frozen bracketed_pretty_print, frozen pretty_print is
      do
         fmt.put_string(as_result);
      end;

   frozen print_as_target is
      do
         fmt.put_string(as_result);
         fmt.put_character('.');
      end;

   frozen short is
      do
         short_print.hook_or(as_result,as_result);
      end;

   frozen short_target is
      do
         short;
         short_print.a_dot;
      end;

   frozen mapping_c_target(target_type: TYPE) is
      local
         flag: BOOLEAN;
         rt: like result_type;
      do
         flag := cpp.call_invariant_start(target_type);
         rt := result_type.run_type;
         if rt.is_reference then
            if target_type.is_reference then
               -- Reference into Reference :
               cpp.put_string(fz_b7);
               cpp.put_integer(target_type.id);
               cpp.put_string(fz_b8);
               compile_to_c;
               cpp.put_character(')');
            else
               -- Reference into Expanded :
               compile_to_c;
            end;
         else
            if target_type.is_reference then
               -- Expanded into Reference :
               compile_to_c;
            else
               -- Expanded into Expanded :
               if rt.need_c_struct then
                  cpp.put_character('&');
               end;
               compile_to_c;
            end;
         end;
         if flag then
            cpp.call_invariant_end;
         end;
      end;

   frozen mapping_c_arg(formal_arg_type: TYPE) is
      local
         rt: like result_type;
      do
         rt := result_type.run_type;
         if rt.is_reference then
            if formal_arg_type.is_reference then
               -- Reference into Reference :
               compile_to_c;
            else
               -- Reference into Expanded :
               compile_to_c;
            end;
         else
            if formal_arg_type.is_reference then
               -- Expanded into Reference :
               compile_to_c;
            else
               -- Expanded into Expanded :
               if rt.need_c_struct then
                  cpp.put_character('&');
               end;
               compile_to_c;
            end;
         end;
      end;

   frozen collect_c_tmp is
      do
      end;

   frozen c_declare_for_old is
      do
      end;

   frozen compile_to_c_old is
      do
      end;

   frozen compile_to_jvm_old is
      do
      end;

   frozen compile_target_to_jvm is
      do
         standard_compile_target_to_jvm;
      end;

   frozen jvm_branch_if_false: INTEGER is
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifeq;
      end;

   frozen jvm_branch_if_true: INTEGER is
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifne;
      end;

   frozen compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := standard_compile_to_jvm_into(dest);
      end;

   frozen precedence: INTEGER is
      do
         Result := atomic_precedence;
      end;

   frozen stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         if small_eiffel.stupid_switch(result_type,r) then
            Result := true;
         end;
      end;

feature {NONE}

   run_feature: RUN_FEATURE;
	 -- The corresponding one which contains this `Result' expression.
   
   make(sp: like start_position) is
      require
         not sp.is_unknown
      do
         start_position := sp;
      ensure
         start_position = sp
      end;

invariant

   not start_position.is_unknown;

end -- ABSTRACT_RESULT

