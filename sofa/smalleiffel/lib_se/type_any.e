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
class TYPE_ANY
   --
   -- Handling of the type ANY.
   --

inherit TYPE;

creation make

feature

   base_class_name: CLASS_NAME;

   id: INTEGER is 10;

   is_any: BOOLEAN is true;

   is_none: BOOLEAN is false;

   is_expanded: BOOLEAN is false;

   is_basic_eiffel_expanded: BOOLEAN is false;

   is_reference: BOOLEAN is true;

   is_dummy_expanded: BOOLEAN is false;

   is_user_expanded: BOOLEAN is false;

   is_run_type: BOOLEAN is true;

   is_generic: BOOLEAN is false;

   is_array: BOOLEAN is false;

   is_like_current: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   jvm_method_flags: INTEGER is 17;

   pretty_print is
      do
         fmt.put_string(as_any);
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

   run_class: RUN_CLASS is
      do
         Result := small_eiffel.run_class(Current);
      end;

   run_type: TYPE is
      do
         Result := Current;
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
         Result := true;
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

   need_c_struct: BOOLEAN is
      do
         if run_class.is_tagged then
            Result := true;
         else
            Result := run_class.writable_attributes /= Void;
         end;
      end;

   c_initialize is
      do
         cpp.put_string(fz_null);
      end;

   c_initialize_in(str: STRING) is
      do
         str.append(fz_null);
      end;

   has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
         eh.add_position(fn.start_position);
         error(start_position,"No creation for ANY.");
      end;

   start_position: POSITION is
      do
         Result := base_class_name.start_position;
      end;

   to_runnable(ct: TYPE): like Current is
      do
         Result := Current;
         check_type;
      end;

   run_time_mark, written_mark: STRING is
      do
         Result := as_any;
      end;

   smallest_ancestor(other: TYPE): TYPE is
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

   jvm_push_local(offset: INTEGER) is
      do
         code_attribute.opcode_aload(offset);
      end;

   jvm_check_class_invariant is
      do
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
         if destination.is_reference then
            Result := 1;
         else
            Result := destination.jvm_expanded_from_reference(Current)
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
      do
         if other.is_any then
            Result := true;
         elseif other.is_none then
         else
            Result := base_class.is_subclass_of(other.base_class);
         end;
         if not Result then
            eh.add_type(Current,fz_inako);
            eh.add_type(other,fz_dot);
         end;
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

   check_type is
      -- Do some checking for type ANY to be runnable.
      local
         bc: BASE_CLASS;
         rc: RUN_CLASS;
      once
         bc := base_class;
         if nb_errors = 0 then
            rc := run_class;
         end;
         if nb_errors = 0 then
            if bc.is_expanded then
               error(start_position,"ANY must not be expanded.");
            end;
         end;
      end;

   make(sp: like start_position) is
      do
         !!base_class_name.make(as_any,sp);
      ensure
         start_position = sp
      end;

end -- TYPE_ANY

