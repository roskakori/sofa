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
class TYPE_STRING

inherit TYPE redefine is_string end;

creation make

feature

   base_class_name: CLASS_NAME;

   id: INTEGER is 7;

   is_string: BOOLEAN is true;

   is_none: BOOLEAN is false;

   is_expanded: BOOLEAN is false;

   is_basic_eiffel_expanded: BOOLEAN is false;

   is_reference: BOOLEAN is true;

   is_dummy_expanded: BOOLEAN is false;

   is_user_expanded: BOOLEAN is false;

   is_generic: BOOLEAN is false;

   need_c_struct: BOOLEAN is true;

   is_run_type: BOOLEAN is true;

   is_array: BOOLEAN is false;

   is_like_current: BOOLEAN is false;

   is_any: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   jvm_method_flags: INTEGER is 17;

   pretty_print is
      do
         fmt.put_string(as_string);
      end;

   actual_reference(destination: TYPE): TYPE is
      do
      end;

   static_base_class_name: CLASS_NAME is
      do
         Result := base_class_name;
      end;

   c_sizeof: INTEGER is
      do
         Result := c_sizeof_pointer;
      end;

   generic_list: ARRAY[TYPE] is
      do
         fatal_error_generic_list;
      end;

   has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
         Result := base_class.has_creation(fn);
      end;

   set_at_run_time is
      local
         bc: BASE_CLASS;
         rc: RUN_CLASS;
         rf: RUN_FEATURE;
      once
         bc := type_string.base_class;
         rc := type_string.run_class;
         rc.set_at_run_time;
         rf := rc.get_feature_with(as_capacity);
         rf := rc.get_feature_with(as_count);
         rf := rc.get_feature_with(as_storage);
         rf.result_type.run_class.set_at_run_time;
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
      end;

   c_header_pass4 is
      do
         standard_c_struct;
         standard_c_object_model;
      end;

   c_initialize is
      do
         cpp.put_string(fz_null);
      end;

   c_initialize_in(str: STRING) is
      do
         str.append(fz_null);
      end;

   run_type: TYPE is
      do
         Result := Current;
      end;

   jvm_descriptor_in(str: STRING) is
      do
         str.append(jvm_root_descriptor);
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
         code_attribute.opcode_aconst_null;
         Result := 1;
      end;

   jvm_write_local(offset: INTEGER) is
      do
         code_attribute.opcode_astore(offset);
      end;

   jvm_xnewarray is
      local
         idx: INTEGER;
      do
         idx := constant_pool.idx_jvm_root_class;
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
      end;

   jvm_expanded_from_reference(other: TYPE): INTEGER is
      do
         check
            false
         end;
      end;

   jvm_convert_to(destination: TYPE): INTEGER is
      do
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

   is_a(other: TYPE): BOOLEAN is
      do
         if other.is_string then
            Result := true;
         else
            Result := base_class.is_subclass_of(other.base_class);
         end;
         if not Result then
            eh.add_type(Current,fz_inako);
            eh.add_type(other,fz_dot);
         end;
      end;

   smallest_ancestor(other: TYPE): TYPE is
      local
         rto: TYPE;
         bc, bc2: BASE_CLASS;
      do
         rto := other.run_type;
         if rto.is_string then
            Result := Current;
         elseif rto.is_none then
            Result := Current;
         elseif rto.is_any then
            Result := rto;
         elseif rto.is_expanded then
            Result := rto.smallest_ancestor(Current);
         else
            bc := base_class;
            bc2 := rto.base_class;
            if bc2.is_subclass_of(bc) then
               Result := Current;
            elseif bc.is_subclass_of(bc2) then
               Result := rto;
            else
               Result := type_any;
            end;
         end;
      end;

   start_position: POSITION is
      do
         Result := base_class_name.start_position;
      end;

   to_runnable(rt: TYPE): like Current is
      do
         Result := Current;
      end;

   written_mark, run_time_mark: STRING is
      do
         Result := as_string;
      end;

   c_type_for_argument_in(str: STRING) is
      do
         str.append(fz_t0_star);
      end;

   c_type_for_target_in(str: STRING) is
      do
         str.append("T7*");
      end;

   c_type_for_result_in(str: STRING) is
      do
         str.append(fz_t0_star);
      end;

   expanded_initializer: RUN_FEATURE_3 is
      do
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := true;
      end;
   
feature {RUN_CLASS,TYPE}

   need_gc_mark_function: BOOLEAN is true;

   just_before_gc_mark_in(str: STRING) is
      do
         standard_just_before_gc_mark_in(str);
      end;

   gc_info_in(str: STRING) is
      do
         standard_gc_info_in(str);
      end;

   gc_define1 is
      do
         standard_gc_define1;
      end;

   gc_define2 is
      do
         standard_gc_define2;
      end;

feature {TYPE}

   frozen short_hook is
      do
         short_print.a_class_name(base_class_name);
      end;

feature {NONE}

   make(sp: like start_position) is
      do
         !!base_class_name.make(as_string,sp);
      end;

invariant

   written_mark = as_string

end -- TYPE_STRING

