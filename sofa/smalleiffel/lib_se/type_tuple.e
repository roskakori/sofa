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
class TYPE_TUPLE
   --
   -- For the TUPLE type.
   --

inherit TYPE;

creation make

feature

   is_any: BOOLEAN is false;

   is_none: BOOLEAN is false;

   is_reference: BOOLEAN is true;

   is_expanded: BOOLEAN is false;

   is_user_expanded: BOOLEAN is false;
 
   is_basic_eiffel_expanded: BOOLEAN is false;

   is_generic: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_current: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   is_array: BOOLEAN is false;

   is_dummy_expanded: BOOLEAN is false;
   
   start_position: POSITION;

   base_class_name: CLASS_NAME;

   written_mark: STRING;

   run_time_mark: STRING;

   run_type: like Current;

   pretty_print is
      do
         fmt.put_string(written_mark);
      end;

   is_run_type: BOOLEAN is
      do
	 Result := run_type /= Void;
      end;

   expanded_initializer: RUN_FEATURE_3 is
      do
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := written_mark = run_time_mark;
      end;
   
   id: INTEGER is
      do
         Result := run_class.id;
      end;

   c_sizeof: INTEGER is
      do
	 Result := c_sizeof_pointer;
      end;

   is_a(other: TYPE): BOOLEAN is
      local
	 other_tuple: like Current;
	 other_run_types: ARRAY[TYPE];
         i: INTEGER;
         t1, t2: TYPE;
      do
	 Result := true;
	 other_tuple ?= other.run_type;
         if other_tuple /= Void then
	    if other_tuple.count > count then
	       Result := false;
	    else
	       from
		  other_run_types := other_tuple.run_types;
		  if other_run_types /= Void then
		     i := other_run_types.upper;
		  end;
	       until
		  not Result or else i <= 0
	       loop
		  t1 := run_types.item(i);
		  t2 := other_run_types.item(i);
		  if t1.is_a(t2) then
		     i := i - 1;
		  else
		     Result := false;
		     eh.add_position(t1.start_position);
		     eh.add_position(t2.start_position);
		  end;
	       end;
	    end;
	 else
	    Result := false;
         end;
         if not Result then
            eh.add_type(Current,fz_inako);
            eh.add_type(other,".");
         end;
      end;

   smallest_ancestor(other: TYPE): TYPE is
      do
	 fatal_not_yet_implemented("smallest_ancestor");
      end;

   to_runnable(ct: TYPE): like Current is
      local
	 i: INTEGER;
	 t1, t2: TYPE;
      do
	 if run_time_mark = written_mark then
	    if run_types /= Void then
	       from
		  i := run_types.lower;
	       until
		  i > run_types.upper
	       loop
		  t1 := run_types.item(i);
		  t2 := t1.to_runnable(ct);
		  check t1 = t2 end;
		  i := i + 1;
	       end;
	    end;
	    load_basic_features;
	    Result := Current;
	 else
	    fatal_not_yet_implemented("to_runnable");
	 end;
      end;

   generic_list: ARRAY[TYPE] is
      do
      end;

   has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
      end;

   actual_reference(destination: TYPE): TYPE is
      do
      end;

   static_base_class_name: CLASS_NAME is
      do
         Result := base_class_name;
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
         if types /= Void then
	    Result := true;
         else
	    Result := run_class.is_tagged;
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
      end;

   c_header_pass4 is
      local
	 i: INTEGER;
	 t: TYPE;
      do
	 if need_c_struct then
	    standard_c_struct;
	    standard_c_object_model;
	 end;
	 -- Definition of new_tupleXXX:
         standard_c_print_function;
	 header.copy("T0*new_tuple");
	 id.append_in(header);
	 header.extend('(');
	 if run_types /= Void then
	    from
	       i := run_types.lower;
	    until
	       i > run_types.upper
	    loop
	       t := run_types.item(i);
	       t.c_type_for_argument_in(header);
	       header.append(" i");
	       i.append_in(header);
	       if i < run_types.upper then
		  header.extend(',');
	       end;
	       i := i + 1;
	    end;
	 end;
	 header.extend(')');
	 cpp.put_c_heading(header);
	 cpp.swap_on_c;
	 gc_handler.allocation(run_class);
	 if run_types /= Void then
	    cpp.put_string("n->_first=i1;%N");
	    if run_types.count >= 2 then
	       cpp.put_string("n->_second=i2;%N");
	    end;
	    if run_types.count >= 3 then
	       cpp.put_string("n->_third=i3;%N");
	    end;
	    if run_types.count >= 4 then
	       cpp.put_string("n->_fourth=i4;%N");
	    end;
	    if run_types.count >= 5 then
	       cpp.put_string("n->_fifth=i5;%N");
	    end;
	    from
	       i := 6;
	    until
	       i > run_types.upper
	    loop
	       cpp.put_string("n->_item_");
	       cpp.put_integer(i);
	       cpp.put_string("=i");
	       cpp.put_integer(i);
	       cpp.put_string("%N;");
	       i := i + 1;
	    end;
	 end;	 
	 cpp.put_string("return (T0*)n;}%N");
	 cpp.swap_on_h;
      end;

   c_initialize is
      do
	 cpp.put_string(fz_null);
      end;

   c_initialize_in(str: STRING) is
      do
	 str.append(fz_null);
      end;

   jvm_method_flags: INTEGER is 17;

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

feature {TYPE}

   frozen short_hook is
      local
         i: INTEGER;
      do
         short_print.a_class_name(base_class_name);
	 if types /= Void then
	    short_print.hook_or("open_sb","[");
	    from
	       i := 1;
	    until
	       i > types.count
	    loop
	       types.item(i).short_hook;
	       if i < types.count then
		  short_print.hook_or("tm_sep",",");
	       end;
	       i := i + 1;
	    end;
	    short_print.hook_or("close_sb","]");
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

feature {RUN_CLASS}

   load_basic_features is
      do
	 if not load_basic_features_flag then
	    load_basic_features_flag := true;
	    run_class.definitions_for_tuple(Current,run_types);
	 end;
      end;

feature {TYPE_TUPLE}

   types: ARRAY[TYPE];
	 -- Written `types' of the TUPLE.

   run_types: ARRAY[TYPE];
	 -- The runnable version of `types'.

   fatal_not_yet_implemented(method: STRING) is
      do
	 eh.add_position(start_position);
	 eh.append("TUPLE.");
	 eh.append(method);
	 eh.append(" not yet implemented.%N");
	 eh.print_as_fatal_error;
      end;

   make(sp: like start_position; t: like types) is
      require
	 t /= Void implies (t.lower = 1 and t.count > 0)
      local
	 i: INTEGER;
	 is_written_runnable: BOOLEAN;
	 type: TYPE;
      do
	 start_position := sp;
	 types := t;
	 base_class_memory := unique_base_class_memory;
         !!base_class_name.make(as_tuple,start_position);
	 written_mark := compute_mark(types);
	 if types /= Void then
	    from
	       i := types.upper;
	       is_written_runnable := true;
	    until
	       not is_written_runnable or else i < types.lower
	    loop
	       type := types.item(i);
	       if type.is_run_type then
		  if type.run_type /= type then
		     is_written_runnable := false;
		  end;
	       else
		  is_written_runnable := false;
	       end;
	       i := i - 1;
	    end;
	 else
	    is_written_runnable := true;
	 end;
	 if is_written_runnable then
	    run_types := types;
	    run_time_mark := written_mark;
	    run_type := Current;
	 end;
      ensure
	 types = t
      end;

   count: INTEGER is
      do
	 if types /= Void then
	    Result := types.count;
	 end;
      end;

feature {NONE}

   compute_mark(t: like types): STRING is
      local
	 i: INTEGER;
      do
	 compute_mark_buffer.clear;
	 compute_mark_buffer.append(as_tuple);
	 if t /= Void then
	    compute_mark_buffer.extend('[');
	    from
	       i := t.lower;
	    until
	       i > t.upper
	    loop
	       compute_mark_buffer.append(t.item(i).written_mark);
	       if i < t.upper then
		  compute_mark_buffer.extend(',');
	       end;
	       i := i + 1;
	    end;
	    compute_mark_buffer.extend(']');
	 end;
	 Result := string_aliaser.item(compute_mark_buffer);
      end;

   compute_mark_buffer: STRING is
      once
	 !!Result.make(128);
      end;

   unique_base_class_memory: BASE_CLASS is
      once
         !!Result.make(as_tuple,as_tuple,11);
      end;

   load_basic_features_flag: BOOLEAN;

end

