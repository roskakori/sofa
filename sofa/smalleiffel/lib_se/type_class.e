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
class TYPE_CLASS

inherit TYPE;

creation make

feature

   base_class_name: CLASS_NAME;

   is_generic: BOOLEAN is false;

   is_run_type: BOOLEAN is true;

   is_basic_eiffel_expanded: BOOLEAN is false;

   is_array: BOOLEAN is false;

   is_none: BOOLEAN is false;

   is_any: BOOLEAN is false;

   is_like_current: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   jvm_method_flags: INTEGER is 17;

   pretty_print is
      do
         fmt.put_string(written_mark);
      end;

   actual_reference(destination: TYPE): TYPE is
      local
         sp: POSITION;
      do
         sp := destination.start_position;
         !TYPE_REF_TO_EXP!Result.from_expanded(sp,Current);
      end;

   static_base_class_name: CLASS_NAME is
      do
         Result := base_class_name;
      end;

   is_expanded: BOOLEAN is
      do
         Result := base_class.is_expanded;
      end;

   is_reference: BOOLEAN is
      do
         Result := not base_class.is_expanded;
      end;

   is_user_expanded: BOOLEAN is
      do
         Result := is_expanded;
      end;

   is_dummy_expanded: BOOLEAN is
      do
         if is_expanded then
            Result := run_class.writable_attributes = Void;
         end;
      end;

   generic_list: ARRAY[TYPE] is
      do
         fatal_error_generic_list;
      end;

   expanded_initializer: RUN_FEATURE_3 is
      do
         if is_expanded then
            Result := base_class.expanded_initializer(Current);
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := true;
      end;
   
   id: INTEGER is
      do
         Result := base_class.id;
      end;

   c_sizeof: INTEGER is
      do
         if is_reference then
            Result := c_sizeof_pointer;
         else
            Result := run_class.c_sizeof;
         end;
      end;

   has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
         Result := base_class.has_creation(fn);
      end;

   smallest_ancestor(other: TYPE): TYPE is
      local
         rto: TYPE;
         bc, bc2: BASE_CLASS;
      do
         rto := other.run_type;
         if other.is_none then
            Result := Current;
         elseif rto.is_any then
            Result := rto;
         else
            bc := base_class;
            bc2 := rto.base_class;
            if bc2 = bc then
               Result := Current;
            elseif bc2.is_subclass_of(bc) then
               Result := Current;
            elseif bc.is_subclass_of(bc2) then
               Result := rto;
            elseif rto.is_expanded and then not is_expanded then
               Result := rto.smallest_ancestor(Current);
            else
               Result := bc2.smallest_ancestor(rto,Current);
            end;
         end;
      end;

   jvm_descriptor_in(str: STRING) is
      do
         if is_reference then
            str.append(jvm_root_descriptor);
         else
            run_class.jvm_type_descriptor_in(str);
         end;
      end;

   jvm_target_descriptor_in(str: STRING) is
      do
      end;

   jvm_return_code is
      do
         code_attribute.opcode_areturn;
      end;

   jvm_check_class_invariant is
      do
         standard_jvm_check_class_invariant;
      end;

   jvm_push_local(offset: INTEGER) is
      do
         code_attribute.opcode_aload(offset);
      end;

   jvm_push_default: INTEGER is
      do
         Result := 1;
         if is_reference then
            code_attribute.opcode_aconst_null;
         else
            run_class.jvm_expanded_push_default;
         end;
      end;

   jvm_write_local(offset: INTEGER) is
      do
         code_attribute.opcode_astore(offset);
      end;

   jvm_xnewarray is
      local
         idx: INTEGER;
      do
         if is_reference then
            idx := constant_pool.idx_jvm_root_class;
         else
            check
               is_user_expanded
            end;
            idx := run_class.jvm_constant_pool_index;
         end;
         code_attribute.opcode_anewarray(idx);
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
      do
         if is_expanded then
            run_class.jvm_to_reference;
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
         if is_reference then
            if destination.is_reference then
               Result := 1;
            else
               Result := destination.jvm_expanded_from_reference(Current)
            end;
         elseif destination.is_reference then
            jvm_to_reference;
            Result := 1;
         else
            Result := 1;
         end;
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

   is_a(other: TYPE): BOOLEAN is
      local
         bcn, obcn: CLASS_NAME;
      do
         bcn := base_class_name;
         obcn := other.base_class_name;
         if bcn.to_string = obcn.to_string then
            Result := true;
	 elseif is_reference and then other.is_expanded then
         elseif bcn.is_subclass_of(obcn) then
            if other.is_generic then
               Result := bcn.base_class.is_a_vncg(Current,other);
            else
               Result := true;
            end;
         end;
         if not Result then
            eh.add_type(Current,fz_inako);
            eh.add_type(other,fz_dot);
         end;
      end;

   run_type: TYPE is
      do
         Result := Current;
      end;

   run_class: RUN_CLASS is
      do
         Result := small_eiffel.run_class(Current);
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
         if is_expanded then
            if need_c_struct then
               standard_c_struct;
            end;
         end;
      end;

   c_header_pass4 is
      do
         if is_reference then
            if need_c_struct then
               standard_c_struct;
            end;
         end;
         standard_c_object_model;
         standard_c_print_function;
      end;

   c_type_for_argument_in(str: STRING) is
      do
         if is_reference then
            str.append(fz_t0_star);
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
         if is_reference then
            str.append(fz_t0_star);
         elseif is_dummy_expanded then
            str.append(fz_int);
         else
            str.extend('T');
            id.append_in(str);
         end;
      end;

   need_c_struct: BOOLEAN is
      do
         if is_dummy_expanded then
         elseif is_expanded then
            Result := true;
         elseif run_class.is_tagged then
            Result := true;
         else
            Result := run_class.writable_attributes /= Void;
         end;
      end;

   start_position: POSITION is
      do
         Result := base_class_name.start_position;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         bc: BASE_CLASS;
      do
         bc := base_class_name.base_class;
         if bc.is_expanded and then not check_memory.fast_has(bc) then
            check_memory.add_last(bc);
            run_class.set_at_run_time;
         end;
         if bc.formal_generic_list /= Void then
            eh.add_position(bc.formal_generic_list.start_position);
            eh.add_type(Current," is generic. Wrong type mark.");
            eh.print_as_fatal_error;
         end;
         Result := Current;
      end;

   written_mark, run_time_mark: STRING is
      do
         Result := base_class_name.to_string;
      end;

   c_initialize is
      do
         if is_expanded then
            c_initialize_expanded;
         else
            cpp.put_string(fz_null);
         end;
      end;

   c_initialize_in(str: STRING) is
      do
         if is_expanded then
            if need_c_struct then
               run_class.c_object_model_in(str);
            else
               str.extend('0');
            end;
         else
            str.append(fz_null);
         end;
      end;

feature {RUN_CLASS,TYPE}

   need_gc_mark_function: BOOLEAN is
      do
         if is_reference then
            Result := true;
         else
            Result := run_class.gc_mark_to_follow;
         end;
      end;

   just_before_gc_mark_in(str: STRING) is
      do
         if is_reference then
            standard_just_before_gc_mark_in(str);
         end;
      end;

   gc_info_in(str: STRING) is
      do
         if is_reference then
            standard_gc_info_in(str);
         end;
      end;

   gc_define1 is
      do
         if is_reference then
            standard_gc_define1;
         end;
      end;

   gc_define2 is
      do
         if is_reference then
            standard_gc_define2;
         else
            standard_gc_define2_for_expanded;
         end;
      end;

feature {TYPE}

   frozen short_hook is
      do
         short_print.a_class_name(base_class_name);
      end;

feature {NONE}

   make(bcn: like base_class_name) is
      require
         not bcn.predefined;
      do
         base_class_name := bcn;
      ensure
         base_class_name = bcn
      end;

   check_memory: FIXED_ARRAY[BASE_CLASS] is
      once
         !!Result.with_capacity(16);
      end;

end -- TYPE_CLASS

