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
class E_STRIP
   --
   -- To store a strip expression like :
   --                                        strip(foo, bar)
   --

inherit EXPRESSION;

creation make

feature

   current_type: TYPE;
         -- Context of this expression.

   start_position: POSITION;

feature {NONE}

   list: FEATURE_NAME_LIST;

   make(sp: like start_position; l: like list) is
      require
         not sp.is_unknown
      do
         start_position := sp;
         list := l;
      ensure
         start_position = sp;
         list = l
      end;

feature

   is_current: BOOLEAN is false;

   is_writable: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   is_result: BOOLEAN is false;

   is_void: BOOLEAN is false;

   use_current: BOOLEAN is true;

   can_be_dropped, c_simple: BOOLEAN is false;

   is_static: BOOLEAN is false;

   is_pre_computable: BOOLEAN is false;

   isa_dca_inline_argument: INTEGER is 0;

   static_result_base_class: BASE_CLASS is
      do
         Result := small_eiffel.get_class(as_array);
      end;

   static_value: INTEGER is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   assertion_check(tag: CHARACTER) is
      do
      end;

   afd_check is
      local
         rf2: RUN_FEATURE_2;
         i: INTEGER;
         st, dt: TYPE;
         fd: DICTIONARY[RUN_FEATURE,STRING];
      do
         fd := current_type.run_class.feature_dictionary;
         from
            i := 1;
         until
            i > fd.count
         loop
            rf2 ?= fd.item(i);
            if rf2 /= Void then
               if list = Void or else not list.has(rf2.name) then
                  st := rf2.result_type;
                  if st.is_expanded then
                     dt := st.actual_reference(type_any);
                     conversion_handler.passing(st,dt);
                  end;
               end;
            end;
            i := i + 1;
         end;
      end;

   mapping_c_target(target_type: TYPE) is
      do
         compile_to_c;
      end;

   mapping_c_arg(formal_arg_type: TYPE) is
      do
         compile_to_c;
      end;

   collect_c_tmp is
      do
      end;

   compile_to_c is
      local
         wa: ARRAY[RUN_FEATURE_2]
         rf2: RUN_FEATURE_2;
         i: INTEGER;
         ct, st, dt: TYPE;
      do
         manifest_array_pool.c_call(result_type);
         cpp.put_character('(');
         ct := current_type;
         wa := ct.run_class.writable_attributes;
         vwst1_check(wa);
         cpp.put_integer(array_count(wa));
         if wa /= Void then
            from
               i := wa.upper;
            until
               i = 0
            loop
               rf2 := wa.item(i);
               if list = Void or else not list.has(rf2.name) then
                  cpp.put_character(',');
                  st := rf2.result_type;
                  if st.is_expanded then
                     dt := st.actual_reference(type_any);
                     conversion_handler.c_function_call(st,dt);
                  end;
                  cpp.print_current;
                  if current_type.is_expanded then
                     cpp.put_character('.');
                  else
                     cpp.put_string("->");
                  end;
                  cpp.put_character('_');
                  cpp.put_string(rf2.name.to_string);
                  if st.is_expanded then
                     cpp.put_character(')');
                  end;
               end;
               i := i - 1;
            end;
         end;
         cpp.put_character(')');
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

   compile_to_jvm is
      local
         ca: like code_attribute;
         cp: like constant_pool;
         count, i, j, idx, idx_array, space: INTEGER;
         wa: ARRAY[RUN_FEATURE_2]
         rf2: RUN_FEATURE_2;
      do
         ca := code_attribute;
         cp := constant_pool;
         wa := current_type.run_class.writable_attributes;
         count := array_count(wa);
         result_type.run_class.jvm_basic_new;
         ca.opcode_dup;
         ca.opcode_iconst_1;
         idx_array := result_type.run_class.jvm_constant_pool_index;
         idx := cp.idx_fieldref4(idx_array,as_lower,fz_i);
         ca.opcode_putfield(idx,-2);
         ca.opcode_dup;
         ca.opcode_push_integer(count);
         idx := cp.idx_fieldref4(idx_array,as_upper,fz_i);
         ca.opcode_putfield(idx,-2);
         ca.opcode_dup;
         ca.opcode_push_integer(count);
         idx := cp.idx_fieldref4(idx_array,as_capacity,fz_i);
         ca.opcode_putfield(idx,-2);
         if count > 0 then
            -- pile = array
            ca.opcode_push_integer(count);
            type_any.jvm_xnewarray;
            -- pile = array storage
            ca.opcode_dup2;
            -- pile = array storage array storage
            tmp_string.clear;
            tmp_string.extend('[');
            tmp_string.append(jvm_root_descriptor);
            idx := cp.idx_fieldref4(idx_array,as_storage,tmp_string);
            ca.opcode_putfield(idx,-2);
            -- pile = array storage
            from
               i := wa.upper;
               j := 0;
            until
               i = 0
            loop
               rf2 := wa.item(i);
               if list = Void or else not list.has(rf2.name) then
                  if j < count - 1 then
                     ca.opcode_dup;
                  end;
                  ca.opcode_push_integer(j);
                  current_type.jvm_push_local(0);
                  idx := cp.idx_fieldref(rf2);
                  ca.opcode_getfield(idx,0);
                  space := rf2.result_type.jvm_convert_to(type_any);
                  result_type.jvm_xastore;
                  j := j + 1;
               end;
               i := i - 1;
            end;
         end;
      end;

   compile_target_to_jvm is
      do
      end;

   jvm_branch_if_false: INTEGER is
      do
      end;

   jvm_branch_if_true: INTEGER is
      do
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := 1;
         compile_to_jvm;
      end;

   result_type: TYPE_ARRAY is
      do
         if result_type_memory = Void then
            !!result_type_memory.make(start_position,type_any);
            result_type_memory := result_type_memory.to_runnable(type_any);
            result_type_memory.run_class.set_at_run_time;
            result_type_memory.load_basic_features;
            manifest_array_pool.register(result_type_memory);
         end;
         Result := result_type_memory;
      end;

   to_runnable(ct: TYPE): like Current is
      do
         if current_type = Void then
            current_type := ct;
            Result := Current;
         else
            !!Result.make(start_position,list);
            Result := Result.to_runnable(ct);
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
      end;

   pretty_print is
      do
         fmt.put_string("strip (");
         fmt.level_incr;
         if list /= Void then
            list.pretty_print;
         end;
         fmt.put_string(")");
         fmt.level_decr;
      end;

   print_as_target is
      do
         pretty_print;
         fmt.put_character('.');
      end;

   bracketed_pretty_print is
      do
         fmt.put_character('(');
         pretty_print;
         fmt.put_character(')');
      end;

   short is
      do
         short_print.hook_or("op_strip","strip (");
         if list /= Void then
            list.short;
         end;
         short_print.hook_or("cl_strip",")");
      end;

   short_target is
      do
         short;
         short_print.a_dot;
      end;

   precedence: INTEGER is
      do
         Result := 11;
      end;

   jvm_assign is
      do
      end;

feature {NONE}

   vwst1: STRING is "This is not an attribute of Current (VWST.1)."

   vwst1_check(wa: ARRAY[RUN_FEATURE_2]) is
      local
         i, j: INTEGER;
         fn: FEATURE_NAME;
         rf2: RUN_FEATURE_2;
      do
         if wa = Void then
            if list = Void then
            else
               eh.add_position(list.item(1).start_position);
               eh.append(vwst1);
               eh.print_as_error;
            end;
         elseif list /= Void then
            from
               i := list.count;
            until
               i = 0
            loop
               fn := list.item(i);
               from
                  j := wa.upper;
                  rf2 := Void;
               until
                  j <= 0
               loop
                  rf2 := wa.item(j);
                  if rf2.name.to_string = fn.to_string then
                     j := -1;
                  else
                     j := j - 1;
                  end;
               end;
               if j = 0 then
                  eh.add_position(fn.start_position);
                  eh.append(vwst1);
                  eh.print_as_error;
               end;
               i := i - 1;
            end;
         end;
      end;

   result_type_memory: like result_type;

   array_count(wa: ARRAY[RUN_FEATURE_2]): INTEGER is
      do
         if wa /= Void then
            Result := wa.count;
         end;
         if list /= Void then
            Result := Result - list.count;
         end;
      ensure
         Result >= 0
      end;

   tmp_string: STRING is
      once
         !!Result.make(32);
      end;

end -- E_STRIP
