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
class TYPE_BIT_REF

inherit TYPE;

creation from_type_bit

feature

   start_position: POSITION;

   type_bit: TYPE_BIT;

   run_time_mark: STRING;

feature {NONE}

   from_type_bit(sp: POSITION; tb: TYPE_BIT) is
      require
         not sp.is_unknown;
         tb.is_run_type
      do
         start_position := sp;
         type_bit := tb;
         run_time_mark := "BITxxx_REF";
         run_time_mark.copy(type_bit.run_time_mark);
         run_time_mark.append("_REF");
         run_time_mark := string_aliaser.item(run_time_mark);
      ensure
         type_bit = tb
      end;


feature

   is_run_type: BOOLEAN is true;

   is_expanded: BOOLEAN is false;

   is_none: BOOLEAN is false;

   is_any: BOOLEAN is false;

   is_basic_eiffel_expanded: BOOLEAN is false;

   is_reference: BOOLEAN is true;

   is_user_expanded: BOOLEAN is false;

   is_dummy_expanded: BOOLEAN is false;

   is_generic: BOOLEAN is false;

   is_array: BOOLEAN is false;

   is_like_current: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   need_c_struct: BOOLEAN is true;

   jvm_method_flags: INTEGER is 17;

   pretty_print is
      do
         fmt.put_string(written_mark);
      end;

   actual_reference(destination: TYPE): TYPE is
      do
      end;

   written_mark: STRING is
      do
         Result := run_time_mark;
      end;

   static_base_class_name: CLASS_NAME is
      do
         Result := base_class_name;
      end;

   c_sizeof: INTEGER is
      do
         Result := c_sizeof_pointer;
      end;

   run_class: RUN_CLASS is
      do
         Result := small_eiffel.run_class(run_type);
      end;

   generic_list: ARRAY[TYPE] is
      do
         fatal_error_generic_list;
      end;

   expanded_initializer: RUN_FEATURE_3 is
      do
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
      end;
   
   c_header_pass1 is
      do
         standard_c_typedef;
      end;

   c_header_pass2 is
      do
         tmp_string.copy(fz_struct);
         tmp_string.extend('S');
         id.append_in(tmp_string);
         tmp_string.append("{int id;T");
         type_bit.id.append_in(tmp_string);
         tmp_string.append(" _item;};%N");
         cpp.put_string(tmp_string);
      end;

   c_header_pass3 is
      do
      end;

   c_header_pass4 is
      local
         mem_id: INTEGER;
         rc: RUN_CLASS;
      do
         rc := run_class;
         mem_id := rc.id;
         tmp_string.copy(fz_extern);
         tmp_string.extend('T');
         mem_id.append_in(tmp_string);
         tmp_string.extend(' ');
         tmp_string.extend('M');
         mem_id.append_in(tmp_string);
         tmp_string.append(fz_00);
         cpp.put_string(tmp_string);
         cpp.swap_on_c;
         tmp_string.clear;
         tmp_string.extend('T');
         mem_id.append_in(tmp_string);
         tmp_string.extend(' ');
         tmp_string.extend('M');
         mem_id.append_in(tmp_string);
         tmp_string.extend('=');
         tmp_string.extend('{');
         if rc.is_tagged then
            mem_id.append_in(tmp_string);
            tmp_string.extend(',');
         end;
         type_bit.c_initialize_in(tmp_string);
         tmp_string.extend('}');
         tmp_string.append(fz_00);
         cpp.put_string(tmp_string);
         cpp.swap_on_h;
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

   run_type: TYPE_BIT_REF is
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
      end;

   jvm_check_class_invariant is
      do
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
         check false end;
      end;

   jvm_convert_to(destination: TYPE): INTEGER is
      do
         if destination.is_expanded then
            Result := destination.jvm_expanded_from_reference(Current);
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

   to_runnable(rt: TYPE): like Current is
      do
         Result := Current;
      end;

   base_class_name: CLASS_NAME is
      once
         !!Result.unknown_position(as_bit_n_ref);
      end;

   id: INTEGER is
      do
         Result := run_class.id;
      end;

   smallest_ancestor(other: TYPE): TYPE is
      do
         if run_time_mark = other.run_time_mark then
            Result := Current;
         else
            Result := type_any;
         end;
      end;

   is_a(other: TYPE): BOOLEAN is
      do
         if run_time_mark = other.run_time_mark then
            Result := true;
         else
            Result := base_class.is_subclass_of(other.base_class);
            if not Result then
               eh.add_type(Current,fz_inako);
               eh.add_type(other,fz_dot);
            end;
         end;
      end;

   has_creation(fn: FEATURE_NAME): BOOLEAN is do end;

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

invariant

   type_bit /= Void

end -- TYPE_BIT_REF

