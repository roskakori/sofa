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
deferred class ABSTRACT_CURRENT
   --
   -- Handling of the pseudo variable "Current".
   --

inherit EXPRESSION;

feature

   start_position: POSITION;

   result_type: TYPE;
         -- Non Void when checked;

   is_current: BOOLEAN is true;

   is_writable: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   is_static: BOOLEAN is false;

   is_pre_computable: BOOLEAN is false;

   is_result: BOOLEAN is false;

   is_void: BOOLEAN is false;

   can_be_dropped: BOOLEAN is true;

   c_simple: BOOLEAN is true;

   use_current: BOOLEAN is true;

   isa_dca_inline_argument: INTEGER is 0;

   static_result_base_class: BASE_CLASS is
      do
         Result := start_position.base_class;
      end;

   to_string, to_key: STRING is
      do
         Result := as_current;
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

   frozen mapping_c_target(target_type: TYPE) is
      local
         flag: BOOLEAN;
      do
         if is_written then
            flag := cpp.call_invariant_start(target_type);
         end;
         cpp.print_current;
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
               cpp.put_string(fz_cast_t0_star);
               cpp.print_current;
            else
               -- Reference into Expanded :
               cpp.print_current;
            end;
         elseif formal_arg_type.is_reference then
            -- Expanded into Reference :
            cpp.print_current;
         elseif rt.is_user_expanded then
            -- User Expanded into User Expanded :
            if not rt.is_dummy_expanded then
               cpp.put_character('*');
            end;
            cpp.print_current;
         else
            -- Kernel Expanded into Kernel Expanded :
            cpp.print_current;
         end;
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

   frozen collect_c_tmp is
      do
      end;

   frozen compile_to_c is
      do
         if result_type.is_user_expanded then
            cpp.put_character('*');
         end;
         cpp.print_current;
      end;

   frozen compile_to_jvm is
      do
         result_type.jvm_push_local(0);
      end;

   frozen compile_target_to_jvm is
      do
         if is_written then
            standard_compile_target_to_jvm;
         else
            compile_to_jvm;
         end;
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

   frozen to_runnable(ct: TYPE): like Current is
      do
         if result_type = Void then
            result_type := ct;
            Result := Current
         elseif result_type = ct then
            Result := Current
         else
            !!Result.make(start_position);
            Result := Result.to_runnable(ct);
         end;
      end;

   frozen stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
      end;

   frozen precedence: INTEGER is
      do
         Result := atomic_precedence;
      end;

   frozen bracketed_pretty_print, frozen pretty_print is
      do
         fmt.put_string(as_current);
      end;

   frozen print_as_target is
      do
         if is_written or else fmt.print_current then
            fmt.put_string(as_current);
            fmt.put_character('.');
         end;
      end;

   frozen short is
      do
         short_print.hook_or(as_current,as_current);
      end;

   frozen short_target is
      do
         if is_written then
            short;
            short_print.a_dot;
         end;
      end;

   frozen jvm_assign is
      do
      end;

feature {NONE}

   is_written: BOOLEAN is
         -- True when it is a really written Current.
      deferred
      end;

   make(sp: like start_position) is
      require
         not sp.is_unknown
      do
         start_position := sp;
      ensure
         start_position = sp
      end;

end -- ABSTRACT_CURRENT

