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
class TYPE_GENERIC
   --
   -- For all generic declarations (except ARRAY) :
   --        x : FOO[BAR];
   --

inherit  TYPE;

creation make

creation {TYPE_GENERIC} set, make_runnable

feature

   base_class_name: CLASS_NAME;

   generic_list: ARRAY[TYPE];

   written_mark: STRING;

feature {NONE}

   run_type_memory: like Current;
         -- The final `is_written_runnable' corresponding type when runnable.

   is_written_runnable: BOOLEAN is
      local
         i: INTEGER;
         t: TYPE;
      do
         if run_type_memory = Current then
            Result := true;
         elseif run_type_memory = Void then
            from
               Result := true;
               i := generic_list.upper;
            until
               not Result or else i = 0
            loop
               t := generic_list.item(i);
               if t.is_run_type then
                  if t.run_type = t then
                  else
                     Result := false;
                  end;
               else
                  Result := false;
               end;
               i := i - 1;
            end;
            if Result then
               run_type_memory := Current;
               basic_checks;
            end;
         end;
      end;

feature

   is_generic: BOOLEAN is true;

   is_basic_eiffel_expanded: BOOLEAN is false;

   is_array: BOOLEAN is false;

   is_none: BOOLEAN is false;

   is_any: BOOLEAN is false;

   is_like_current: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   jvm_method_flags: INTEGER is 17;

feature {NONE}

   make(bcn: like base_class_name; gl: like generic_list) is
      require
         bcn /= Void;
         gl.lower = 1;
         not gl.is_empty
      local
         i: INTEGER;
         t: TYPE;
      do
         base_class_name := bcn;
         generic_list := gl;
         from
            tmp_mark.copy(bcn.to_string);
            tmp_mark.extend('[');
            i := 1;
         until
            i > gl.upper
         loop
            t := gl.item(i);
            tmp_mark.append(t.written_mark);
            i := i + 1;
            if i <= gl.upper then
               tmp_mark.extend(',');
            end;
         end;
         tmp_mark.extend(']');
         written_mark := string_aliaser.item(tmp_mark);
      ensure
         base_class_name = bcn;
         generic_list = gl;
         written_mark /= Void
      end;

   make_runnable(model: like Current; bcm: like base_class_memory;
		 gl: like generic_list) is
      local
         i: INTEGER;
         t: TYPE;
      do
         base_class_name := model.base_class_name;
	 base_class_memory := bcm;
         generic_list := gl;
         from
            tmp_mark.copy(base_class_name.to_string);
            tmp_mark.extend('[');
            i := 1;
         until
            i > gl.upper
         loop
            t := gl.item(i);
            tmp_mark.append(t.run_time_mark);
            i := i + 1;
            if i <= gl.upper then
               tmp_mark.extend(',');
            end;
         end;
         tmp_mark.extend(']');
         written_mark := string_aliaser.item(tmp_mark);
         run_type_memory := Current;
      ensure
         written_mark = run_time_mark;
         is_written_runnable
      end;

   set(bcm: like base_class_memory; rcm: like run_class_memory;
       bcn: like base_class_name; gl: like generic_list;
       wm: like written_mark; rtm: like run_type_memory) is
      require
	 
	 rcm /= Void;
	 bcn /= Void
	 gl /= Void;
	 rtm.is_run_type
      do
	 base_class_memory := bcm;
	 run_class_memory := rcm;
	 base_class_name := bcn;
	 generic_list := gl;
	 written_mark := wm;
	 run_type_memory := rtm;
      ensure
	 base_class_memory = bcm;
	 run_class_memory = rcm;
	 base_class_name = bcn;
	 generic_list = gl;
	 written_mark = wm;
	 run_type_memory = rtm
      end;

feature

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

   is_run_type: BOOLEAN is
      do
         if run_type_memory /= Void then
            Result := true;
         elseif is_written_runnable then
            Result := true;
         end;
      end;

   run_type: like Current is
      do
         if is_run_type then
            Result := run_type_memory;
         end;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         i: INTEGER;
         rgl: like generic_list;
         t1, t2: TYPE;
         rtm: like Current;
      do
         if is_written_runnable then
	    from
	       i := generic_list.upper;
	    until
	       i < generic_list.lower
	    loop
	       t1 := generic_list.item(i);
	       t2 := t1.to_runnable(ct);
	       check t1 = t2 end;
	       i := i - 1;
	    end;
            Result := Current;
         else
            from
               rgl := generic_list.twin;
               i := rgl.upper;
            until
               i = 0
            loop
               t1 := rgl.item(i);
               t2 := t1.to_runnable(ct);
               if t2 = Void or else not t2.is_run_type then
                  eh.add_type(t1,fz_is_invalid);
                  eh.print_as_error;
                  i := 0;
               else
                  rgl.put(t2,i);
               end;
               t2 := t2.run_type;
               if t2.is_expanded then
                  t2.run_class.set_at_run_time;
               end;
               i := i - 1;
            end;
            !!rtm.make_runnable(Current,base_class_memory,rgl);
            if run_type_memory = Void then
               run_type_memory := rtm;
               Result := Current;
            else
	       !!Result.set(base_class_memory,
			    rtm.run_class,
			    base_class_name,
			    generic_list,
			    written_mark,
			    rtm);
            end;
            Result.run_type.basic_checks;
         end;
      end;

   c_sizeof: INTEGER is
      do
         if is_reference then
            Result := c_sizeof_pointer;
         else
            Result := run_class.c_sizeof;
         end;
      end;

   expanded_initializer: RUN_FEATURE_3 is
      do
         if is_expanded then
            Result := base_class.expanded_initializer(Current);
         end;
      end;
   
   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      local
         i: INTEGER;
      do
         from
            i := generic_list.upper;
            Result := true;
         until
            not Result or else i = 0
         loop
            Result := generic_list.item(i).stupid_switch(r);
            i := i - 1;
         end;
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
         Result := base_class.is_expanded;
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

   run_time_mark: STRING is
      do
         if is_run_type then
            Result := run_type_memory.written_mark;
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
         if is_expanded then
            run_class.jvm_expanded_push_default;
         else
            code_attribute.opcode_aconst_null;
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
            standard_c_object_model;
         end;
      end;

   c_header_pass4 is
      do
         if is_reference then
            if need_c_struct then
               standard_c_struct;
               standard_c_object_model;
            end;
         end;
         standard_c_print_function;
      end;

   c_initialize is
      do
         if run_type_memory.is_expanded then
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

   smallest_ancestor(other: TYPE): TYPE is
      local
         rto: TYPE;
      do
         rto := other.run_type;
         if other.is_none then
            Result := Current;
         elseif rto.is_any then
            Result := rto;
         elseif rto.is_a(run_type) then
            Result := run_type_memory;
         else
            eh.cancel;
            if run_type.is_a(rto) then
               Result := rto;
            else
               eh.cancel;
               if rto.is_generic then
                  Result := type_any;
                  -- *** PAS FIN DU TOUT ;-)
                  -- *** FAIRE COMME DANS TYPE_CLASS.
               else
                  Result := rto.smallest_ancestor(Current);
               end;
            end;
         end;
      end;

   is_a(other: TYPE): BOOLEAN is
      local
         i: INTEGER;
         t1, t2: TYPE;
	 gl1, gl2: ARRAY[TYPE];
      do
         if other.is_none then
         elseif run_class = other.run_class then
            Result := true;
         elseif other.is_generic then
            if base_class = other.base_class then
               from
                  Result := true;
		  gl1 := run_type.generic_list;
		  gl2 := other.run_type.generic_list;
                  i := gl1.upper
               until
                  not Result or else i = 0
               loop
                  t1 := gl1.item(i).run_type;
                  t2 := gl2.item(i).run_type;
                  if t1.is_a(t2) then
                     i := i - 1;
                  else
                     Result := false;
                     eh.append(fz_bga);
		     eh.extend(' ');
                  end;
               end;
            elseif base_class.is_subclass_of(other.base_class) then
               Result := base_class.is_a_vncg(Current,other);
            end;
         else
            check
               not other.is_generic;
            end;
            if base_class.is_subclass_of(other.base_class) then
               Result := true;
            end;
         end;
         if not Result then
            eh.add_type(Current,fz_inako);
            eh.add_type(other," (TYPE_GENERIC).");
         end;
      end;

   start_position: POSITION is
      do
         Result := base_class_name.start_position;
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

   has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
         Result := base_class.has_creation(fn);
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

feature {TYPE_GENERIC}

   basic_checks is
      local
         bc: BASE_CLASS;
         fgl: FORMAL_GENERIC_LIST;
      do
         bc := base_class;
         fgl := bc.formal_generic_list;
         if fgl = Void then
            eh.add_position(start_position);
            eh.append(bc.name.to_string);
            fatal_error(" is not a generic class.");
         elseif fgl.count /= generic_list.count then
            eh.add_position(start_position);
            eh.add_position(fgl.start_position);
            fatal_error(fz_bnga);
         end;
      end;

feature {TYPE}

   frozen short_hook is
      local
         i: INTEGER;
      do
         short_print.a_class_name(base_class_name);
         short_print.hook_or("open_sb","[");
         from
            i := 1;
         until
            i > generic_list.count
         loop
            generic_list.item(i).short_hook;
            if i < generic_list.count then
               short_print.hook_or("tm_sep",",");
            end;
            i := i + 1;
         end;
         short_print.hook_or("close_sb","]");
      end;

feature {NONE}

   tmp_mark: STRING is
      once
         !!Result.make(16);
      end;

end -- TYPE_GENERIC

