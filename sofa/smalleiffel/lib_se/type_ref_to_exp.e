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
class TYPE_REF_TO_EXP

inherit TYPE;

creation {RUN_CLASS} make

creation {TYPE} from_expanded

feature

   start_position: POSITION;

   written_mark: STRING;

feature {NONE}

   expanded_type: TYPE;
         -- The corresponding one.

   make(model: TYPE) is
      require
         model.is_expanded;
         model.run_type = model;
	 not model.run_time_mark.has_prefix("expanded ")
      do
	 expanded_type := model;
         tmp_string.copy(fz_reference);
         tmp_string.append(model.run_time_mark);
         written_mark := string_aliaser.item(tmp_string);
         run_class.set_at_run_time;
      ensure
         run_class.at_run_time
      end;

   from_expanded(sp: POSITION; model: TYPE) is
      require
         model.is_expanded;
	 not model.run_time_mark.has_prefix("expanded ")
      do
         start_position := sp;
         expanded_type := model;
         tmp_string.copy(fz_reference);
         tmp_string.append(model.run_time_mark);
         written_mark := string_aliaser.item(tmp_string);
      end;

feature

   is_run_type: BOOLEAN is true;

   is_expanded: BOOLEAN is false;

   is_reference: BOOLEAN is true;

   is_none: BOOLEAN is false;

   is_any: BOOLEAN is false;

   is_basic_eiffel_expanded: BOOLEAN is false;

   is_user_expanded: BOOLEAN is false;

   is_dummy_expanded: BOOLEAN is false;

   need_gc_mark_function: BOOLEAN is true;

   need_c_struct: BOOLEAN is true;

   is_array: BOOLEAN is false;

   is_like_current: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   jvm_method_flags: INTEGER is 17;

   pretty_print is
      do
         check false end;
      end;

   actual_reference(destination: TYPE): TYPE is
      do
      end;

   static_base_class_name: CLASS_NAME is
      do
         Result := expanded_type.static_base_class_name;
      end;

   id: INTEGER is
      do
         Result := run_class.id;
      end;

   is_generic: BOOLEAN is
      do
         Result := expanded_type.is_generic;
      end;

   run_type: TYPE is
      do
         Result := Current;
      end;

   generic_list: ARRAY[TYPE] is
      do
         Result := expanded_type.generic_list;
      end;

   run_time_mark: STRING is
      do
         Result := written_mark;
      end;

   base_class_name: CLASS_NAME is
      do
         Result := expanded_type.base_class_name;
      end;

   to_runnable(ct: TYPE): like Current is
      do
         Result := Current;
      end;

   is_a(other: TYPE): BOOLEAN is
      do
         if other.run_time_mark /= expanded_type.run_time_mark then
            Result := expanded_type.is_a(other);
         else
            eh.add_type(Current,fz_inako);
            eh.add_type(other,fz_dot);
         end;
      end;

   has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
      end;

   smallest_ancestor(other: TYPE): TYPE is
      do
         fatal_error("TYPE_REF_TO_EXP Not Yet Implemented #1");
      end;

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

   c_sizeof: INTEGER is
      do
         Result := c_sizeof_pointer;
      end;

   expanded_initializer: RUN_FEATURE_3 is
      do
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := expanded_type.stupid_switch(r);
      end;
   
   c_type_for_argument_in(str: STRING) is
      do
         str.append(fz_t0_star);
      end;

   c_type_for_target_in(str: STRING) is
      do
         str.extend('T');
         id.append_in(str);
         str.extend('*');
      end;

   c_type_for_result_in(str: STRING) is
      do
         str.append(fz_t0_star);
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
	 if need_c_struct then
	    standard_c_struct;
         end;
         standard_c_object_model;
         standard_c_print_function;
      end;

   c_initialize is
      do
         cpp.put_string(fz_null);
      end;

   c_initialize_in(str: STRING) is
      do
         str.append(fz_null);
      end;

feature

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
         Result := 1;
         code_attribute.opcode_aconst_null;
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
         check
            destination.is_reference;
         end;
         Result := 1;
      end;

   jvm_standard_is_equal is
      local
         ca: like code_attribute;
         cp: like constant_pool;
         idx: INTEGER;
      do
         ca := code_attribute;
         cp := constant_pool;
         idx := jvm_item_field_idx;
         run_class.opcode_checkcast;
         ca.opcode_getfield(idx,0);
         ca.opcode_swap;
         run_class.opcode_checkcast;
         ca.opcode_getfield(idx,0);
         expanded_type.jvm_standard_is_equal;
      end;

feature {NONE}

   jvm_item_field_idx: INTEGER is
      local
         c, n, t: INTEGER;
         cp: like constant_pool;
      do
         cp := constant_pool;
         c := run_class.jvm_constant_pool_index;
         n := cp.idx_utf8(as_item);
         tmp_string.clear;
         expanded_type.jvm_descriptor_in(tmp_string);
         t := cp.idx_utf8(tmp_string);
         Result := cp.idx_fieldref5(c,n,t);
      end;

feature

   short_hook is
      do
         expanded_type.short_hook;
      end;

feature {RUN_CLASS}

   jvm_prepare_item_field is
      local
         name_idx, descriptor: INTEGER;
         cp: like constant_pool;
      do
         cp := constant_pool;
         name_idx := cp.idx_utf8(as_item);
         tmp_string.clear;
         expanded_type.jvm_descriptor_in(tmp_string);
         descriptor := cp.idx_utf8(tmp_string);
         field_info.add(1,name_idx,descriptor);
      end;

feature {NONE}

   fz_reference: STRING is "reference ";

end -- TYPE_REF_TO_EXP
