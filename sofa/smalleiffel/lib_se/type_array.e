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
class TYPE_ARRAY
   --
   -- For ARRAY declaration :    ARRAY[INTEGER];
   --                            ARRAY[POINT];
   --                            ARRAY[G];
   --                            ARRAY[ARRAY[ANY]];
   --
   -- Note : can be implicit when used for the type of manifest
   --        arrays.
   --

inherit TYPE;

creation make, with, final

feature

   base_class_name: CLASS_NAME;
         -- Is always "ARRAY" but with the good `start_position'.

   generic_list: ARRAY[TYPE];
         -- With exactely one element.

   written_mark: STRING;

feature {NONE}

   run_type_memory: like Current;

   make(sp: like start_position; of_what: TYPE) is
      require
         not sp.is_unknown;
         of_what /= Void
      do
         !!base_class_name.make(as_array,sp);
         set_generic_list_with(of_what);
         tmp_written_mark.copy(as_array);
         tmp_written_mark.extend('[');
         tmp_written_mark.append(of_what.written_mark);
         tmp_written_mark.extend(']');
         written_mark := string_aliaser.item(tmp_written_mark);
      ensure
         start_position = sp;
         base_class_name.to_string = as_array;
         array_of = of_what
      end;

   with(bcn: like base_class_name; bcm: like base_class_memory; 
	wm: like written_mark; of_what: TYPE) is
      require
         bcn.to_string = as_array;
         wm /= Void;
         of_what.is_run_type
      do
         base_class_name := bcn;
	 base_class_memory := bcm;
         set_generic_list_with(of_what);
         written_mark := wm;
         !!run_type_memory.final(bcn,bcm,of_what.run_type);
      ensure
         is_run_type;
         written_mark = wm
      end;

   final(bcn: like base_class_name; bcm: like base_class_memory; 
	 of_what: TYPE) is
      require
         bcn.to_string = as_array;
         of_what.run_type = of_what
      do
         base_class_name := bcn;
	 base_class_memory := bcm;
         set_generic_list_with(of_what);
         tmp_written_mark.copy(as_array);
         tmp_written_mark.extend('[');
         tmp_written_mark.append(of_what.written_mark);
         tmp_written_mark.extend(']');
         written_mark := string_aliaser.item(tmp_written_mark);
         run_type_memory := Current;
      ensure
         run_type = Current;
         written_mark = run_time_mark
      end;

feature

   is_generic: BOOLEAN is true;

   is_array: BOOLEAN is true;

   is_none: BOOLEAN is false;

   is_any: BOOLEAN is false;

   is_expanded: BOOLEAN is false;

   is_basic_eiffel_expanded: BOOLEAN is false;

   is_reference: BOOLEAN is true;

   is_dummy_expanded: BOOLEAN is false;

   is_user_expanded: BOOLEAN is false;

   is_like_current: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   jvm_method_flags: INTEGER is 17;

   need_c_struct: BOOLEAN is true;

feature

   pretty_print is
      do
         fmt.put_string(written_mark);
      end;

   actual_reference(destination: TYPE): TYPE is
      do
      end;

   static_base_class_name: CLASS_NAME is
      do
         Result := base_class_name;
      end;

   is_run_type: BOOLEAN is
      local
         et: TYPE;
      do
         if run_type_memory /= Void then
            Result := true;
         else
            et := array_of;
            if et.is_run_type and then et.run_type = et then
               run_type_memory := Current;
               Result := true;
            end;
         end;
      end;

   run_type: TYPE is
      do
         if is_run_type then
            Result := run_type_memory;
         end;
      end;

   c_sizeof: INTEGER is
      do
         Result := c_sizeof_pointer;
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

   array_of: TYPE is
      do
         Result := generic_list.first;
      end;

   expanded_initializer: RUN_FEATURE_3 is
      do
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := generic_list.first.stupid_switch(r);
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

   has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
         if Current = run_type then
            Result := base_class.has_creation(fn);
         else
            Result := run_type.has_creation(fn);
         end;
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

   start_position: POSITION is
      do
         Result := base_class_name.start_position;
      end;

   run_time_mark: STRING is
      do
         if is_run_type then
            Result := run_type.written_mark;
         end;
      end;

   smallest_ancestor(other: TYPE): TYPE is
      local
         rto, array_of1, array_of2, array_of3: TYPE;
         unknown_position: POSITION;
      do
         rto := other.run_type;
         if rto.is_array then
            array_of1 := array_of.run_type;
            array_of2 := rto.generic_list.first;
            array_of3 := array_of1.smallest_ancestor(array_of2);
            if array_of3 = array_of1 then
               Result := Current;
            elseif array_of3 = array_of2 then
               Result := other;
            else
               !TYPE_ARRAY!Result.make(unknown_position,array_of3);
            end;
         else
            Result := rto.smallest_ancestor(Current);
         end;
      end;

   is_a(other: TYPE): BOOLEAN is
      local
	 t1, t2: TYPE;
      do
	 if other.is_array then
	    t1 := run_type.generic_list.first;
	    t2 := other.run_type.generic_list.first;
            Result := t1.is_a(t2);
            if not Result then
               eh.extend(' ');
            end;
         elseif base_class.is_subclass_of(other.base_class) then
            if other.is_generic then
               Result := base_class.is_a_vncg(Current,other);
            else
               Result := true;
            end;
         end;
         if not Result then
            eh.add_type(Current,fz_inako);
            eh.add_type(other,fz_dot);
         end;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         et1, et2: TYPE;
      do
         et1 := array_of;
         et2 := et1.to_runnable(ct);
         if et2 = Void then
            if et2 /= Void then
               eh.add_position(et2.start_position);
            end;
            eh.add_position(et1.start_position);
            fatal_error(fz_bga);
         end;
         if run_type_memory = Void then
            Result := Current;
            if et2.run_type = et1 then
               run_type_memory := Current;
            else
	       et2 := et2.run_type;
               !!run_type_memory.final(base_class_name,base_class_memory,et2);
            end;
         elseif et2 = et1 then
            Result := Current;
         else
            !!Result.with(base_class_name,base_class_memory,written_mark,et2);
         end;
      end;

   id: INTEGER is
      do
         Result := run_class.id;
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

feature {MANIFEST_ARRAY,E_STRIP}

   load_basic_features is
         -- Force some basic feature to be loaded.
      require
         run_type = Current
      local
         et: TYPE;
         rf: RUN_FEATURE;
         rc: RUN_CLASS;
      do
         et := array_of;
         if et.is_expanded then
            et.run_class.set_at_run_time;
         end;
         rc := run_class;
         rf := rc.get_feature_with(as_capacity);
         rf := rc.get_feature_with(as_lower);
         rf := rc.get_feature_with(as_upper);
         rf := rc.get_feature_with(as_storage);
      end;

feature {TYPE}

   frozen short_hook is
      do
         short_print.a_class_name(base_class_name);
         short_print.hook_or("open_sb","[");
         generic_list.first.short_hook;
         short_print.hook_or("close_sb","]");
      end;

feature {NONE}

   tmp_written_mark: STRING is
      once
         !!Result.make(128);
      end;

   set_generic_list_with(t: TYPE) is
      do
	 !!generic_list.make(1,1);
	 generic_list.put(t,1);
      end;

invariant

   generic_list.count = 1;

   generic_list.lower = 1;

end -- TYPE_ARRAY


