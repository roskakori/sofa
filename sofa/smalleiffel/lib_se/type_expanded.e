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
class TYPE_EXPANDED
   --
   -- Outside expanded types like :
   --
   --        foo : expanded BAR;
   --

inherit
   TYPE
      redefine generic_list, is_boolean, is_character,
         is_integer, is_real, is_double, is_pointer, is_bit
      end;

creation make, from_other

feature

   start_position: POSITION;
         -- Of first letter of keyword `expanded'.

   written_mark: STRING;

   mapped: TYPE;
         -- Corresponding mapped type (usualy the reference type).

   run_time_mark: STRING;

   run_type: TYPE;
         -- When runnable only.

   is_expanded: BOOLEAN is true;

   is_reference: BOOLEAN is false;

   is_array: BOOLEAN is false;

   is_none: BOOLEAN is false;

   is_any: BOOLEAN is false;

   is_like_current: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   jvm_method_flags: INTEGER is 17;

   pretty_print is
      do
         fmt.keyword(fz_expanded);
         mapped.pretty_print;
      end;

   actual_reference(destination: TYPE): TYPE is
      local
         sp: POSITION;
      do
         sp := destination.start_position;
         if mapped.is_expanded then
            !TYPE_REF_TO_EXP!Result.from_expanded(sp,mapped);
         else
--	    Result := destination;
	    Result := mapped;
         end;
      end;

   static_base_class_name: CLASS_NAME is    
      do
         Result := base_class_name;
      end;

   is_basic_eiffel_expanded: BOOLEAN is
      do
         if run_type = mapped then
            Result := mapped.is_basic_eiffel_expanded;
         end;
      end;

   expanded_initializer: RUN_FEATURE_3 is
      do
         Result := base_class.expanded_initializer(Current);
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := mapped.stupid_switch(r);
      end;
   
   is_generic: BOOLEAN is
      do
         Result := mapped.is_generic;
      end;

   generic_list: ARRAY[TYPE] is
      do
         Result := mapped.generic_list;
      end;

   is_user_expanded: BOOLEAN is
      do
         if mapped.is_basic_eiffel_expanded then
         else
            Result := true;
         end;
      end;

   is_dummy_expanded: BOOLEAN is
      do
         if is_user_expanded then
            Result := run_class.writable_attributes = Void;
         end;
      end;

   id: INTEGER is
      do
         Result := run_class.id;
      end;

   has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
         Result := base_class.has_creation(fn);
      end;

   smallest_ancestor(other: TYPE): TYPE is
      do
         if run_time_mark = other.run_time_mark then
            Result := run_type;
         else
            Result := mapped.smallest_ancestor(other).run_type;
         end;
      end;

   is_a(other: TYPE): BOOLEAN is
      do
         Result := mapped.is_a(other);
         if not Result then
            eh.cancel;
            eh.add_type(Current,fz_inako);
            eh.add_type(other,fz_dot);
         end;
      end;

   c_header_pass1 is
      do
         standard_c_typedef;
      end;

   c_header_pass2 is
      do
      end;

   c_header_pass3 is
      do
         if need_c_struct then
            if run_type = Current then
               standard_c_struct;
            else
               run_type.c_header_pass3;
            end;
            standard_c_object_model;
         end;
      end;

   c_header_pass4 is
      do
         standard_c_print_function;
      end;

   c_type_for_argument_in(str: STRING) is
      do
         if mapped.is_expanded then
            mapped.c_type_for_argument_in(str);
         elseif is_dummy_expanded then
            str.append(fz_int);
         else
            str.extend('T');
            id.append_in(str);
         end;
      end;

   c_type_for_target_in(str: STRING) is
      do
         if is_dummy_expanded then
            str.append(fz_int);
         else
            str.extend('T');
            id.append_in(str);
            str.extend('*');
         end;
      end;

   c_type_for_result_in(str: STRING) is
      do
         if is_dummy_expanded then
            str.append(fz_int);
         else
            str.extend('T');
            id.append_in(str);
         end;
      end;

   need_c_struct: BOOLEAN is
      do
         if mapped.is_expanded then
            Result := mapped.need_c_struct;
         else
            Result := run_class.writable_attributes /= Void;
         end;
      end;

   is_run_type: BOOLEAN is
      do
         Result := run_type /= Void;
      end;

   c_sizeof: INTEGER is
      do
         Result := run_class.c_sizeof;
      end;

   base_class_name: CLASS_NAME is
      do
         Result := mapped.base_class_name;
      end;

   to_runnable(rt: TYPE): like Current is
      local
         m: like mapped;
      do
         if run_type = Current then
            -- Context change nothing :
            Result := Current;
         elseif run_type = mapped then
            -- Mapped is already expanded :
            Result := Current;
         else
            m := mapped.to_runnable(rt);
            if m = Void then
               eh.add_position(start_position);
               fatal_error("Bad outside expanded type.");
            end;
            if run_type /= Void then
               !TYPE_EXPANDED!Result.from_other(Current,m.run_type);
            elseif m.is_expanded then
               run_type := m;
               run_time_mark := m.run_time_mark;
               Result := Current;
            elseif mapped = m.run_type then
               run_time_mark := compute_mark(m.run_time_mark);
               run_type := Current;
               Result := Current;
            else
               run_time_mark := compute_mark(m.run_time_mark);
               !TYPE_EXPANDED!run_type.from_other(Current,m.run_type);
               Result := Current;
            end;
            mapped.run_class.set_at_run_time;
            Result.run_type.run_class.set_at_run_time;
         end;
      end;

   c_initialize is
      do
         if is_basic_eiffel_expanded then
            run_type.c_initialize;
         else
            c_initialize_expanded;
         end;
      end;

   c_initialize_in(str: STRING) is
      do
         if is_basic_eiffel_expanded then
            run_type.c_initialize_in(str);
         else
            if need_c_struct then
               run_class.c_object_model_in(str);
            else
               str.extend('0');
            end;
         end;
      end;

   jvm_descriptor_in(str: STRING) is
      do
         run_class.jvm_type_descriptor_in(str);
      end;

   jvm_target_descriptor_in(str: STRING) is
      do
      end;

   jvm_return_code is
      do
         code_attribute.opcode_areturn;
      end;

   jvm_push_local(offset: INTEGER) is
      do
         code_attribute.opcode_aload(offset);
      end;

   jvm_check_class_invariant is
      do
         standard_jvm_check_class_invariant;
      end;

   jvm_push_default: INTEGER is
      local
         rt: TYPE;
      do
         rt := run_type;
         if rt.is_basic_eiffel_expanded then
            Result := jvm_push_default;
         else
            run_class.jvm_expanded_push_default;
            Result := 1;
         end;
      end;

   jvm_write_local(offset: INTEGER) is
      local
         rt: TYPE;
      do
         rt := run_type;
         if rt.is_basic_eiffel_expanded then
            rt.jvm_write_local(offset);
         else
            code_attribute.opcode_astore(offset);
         end;
      end;

   jvm_xnewarray is
      local
         idx: INTEGER;
         rt: TYPE;
      do
         rt := run_type;
         if rt.is_basic_eiffel_expanded then
            rt.jvm_xnewarray;
         else
            check
               is_user_expanded
            end;
            idx := run_class.jvm_constant_pool_index;
            code_attribute.opcode_anewarray(idx);
         end;
      end;

   jvm_xastore is
      do
         code_attribute.opcode_aastore;
      end;

   jvm_xaload is
      do
         code_attribute.opcode_aaload;
      end;

   jvm_if_x_eq: INTEGER is
      do
         Result := code_attribute.opcode_if_acmpeq;
      end;

   jvm_if_x_ne: INTEGER is
      do
         Result := code_attribute.opcode_if_acmpne;
      end;

   jvm_to_reference is
      local
         wa: ARRAY[RUN_FEATURE_2];
      do
         if mapped.is_expanded then
            run_class.jvm_to_reference;
         else
            mapped.run_class.jvm_basic_new;
            wa := run_class.writable_attributes;
            code_attribute.opcode_swap;
            jvm.fields_by_fields_copy(wa);
         end;
      end;

   jvm_expanded_from_reference(other: TYPE): INTEGER is
      do
         check
            false
         end;
      end;

   jvm_convert_to(destination: TYPE): INTEGER is
      do
         if destination.is_reference then
            jvm_to_reference;
         end;
         Result := 1;
      end;

   jvm_standard_is_equal is
      local
         rc: RUN_CLASS;
         wa: ARRAY[RUN_FEATURE_2];
      do
         rc := run_class;
         wa := rc.writable_attributes;
         jvm.std_is_equal(rc,wa);
      end;

   is_boolean: BOOLEAN is
      do
         Result := mapped.is_boolean;
      end;

   is_character: BOOLEAN is
      do
         Result := mapped.is_character;
      end;

   is_integer: BOOLEAN is
      do
         Result := mapped.is_integer;
      end;

   is_real: BOOLEAN is
      do
         Result := mapped.is_real;
      end;

   is_double: BOOLEAN is
      do
         Result := mapped.is_double;
      end;

   is_bit: BOOLEAN is
      do
         Result := mapped.is_bit;
      end;

   is_pointer: BOOLEAN is
      do
         Result := mapped.is_pointer;
      end;

feature {RUN_CLASS,TYPE}

   need_gc_mark_function: BOOLEAN is
      do
         Result := run_class.gc_mark_to_follow;
      end;

   just_before_gc_mark_in(str: STRING) is
      do
      end;

   gc_info_in(str: STRING) is
      do
      end;

   gc_define1 is
      do
      end;

   gc_define2 is
      do
         standard_gc_define2_for_expanded;
      end;

feature {TYPE}

   frozen short_hook is
      do
         short_print.hook_or(fz_expanded,"expanded ");
         mapped.short_hook;
      end;

feature {NONE}

   compute_mark(str: STRING): STRING is
      do
         tmp_string.copy(fz_expanded);
         tmp_string.extend(' ');
         tmp_string.append(str);
         Result := string_aliaser.item(tmp_string);
      end;

   make(sp: like start_position; m: like mapped) is
      require
         not sp.is_unknown;
         m /= Void
      do
         start_position := sp;
         mapped := m;
         written_mark := compute_mark(mapped.written_mark);
      ensure
         start_position = sp;
         mapped = m
      end;

   from_other(other: like Current; m: like mapped) is
      require
         other /= Void;
         m.run_type = m
      do
         start_position := other.start_position;
         written_mark := other.written_mark;
         mapped := m;
         if mapped.is_expanded then
            run_time_mark := mapped.run_time_mark;
            run_type := mapped;
         else
            run_time_mark := compute_mark(mapped.run_time_mark);
            run_type := Current;
         end;
      ensure
         run_type /= Void
      end;

end -- TYPE_EXPANDED
