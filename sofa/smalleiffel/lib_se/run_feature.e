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
deferred class RUN_FEATURE
   --
   -- A feature at run time : assertions collected and only run types.
   --
   --   RUN_FEATURE_1  : constant attribute.
   --   RUN_FEATURE_2  : attribute.
   --   RUN_FEATURE_3  : procedure.
   --   RUN_FEATURE_4  : function.
   --   RUN_FEATURE_5  : once procedure.
   --   RUN_FEATURE_6  : once function.
   --   RUN_FEATURE_7  : external procedure.
   --   RUN_FEATURE_8  : external function.
   --   RUN_FEATURE_9  : deferred routine.
   --   RUN_FEATURE_10 : Precursor procedure.
   --   RUN_FEATURE_11 : Precursor function.
   --

inherit GLOBALS;

feature {NONE}

   clients_memory: CLIENT_LIST;

feature

   current_type: TYPE;
         -- The type of Current in this feature.

   run_class: RUN_CLASS;
	 -- Alias the one of `current_type'.

   name: FEATURE_NAME;
         -- Final name (the only one really used) of the feature.

   base_feature: E_FEATURE is
         -- Original base feature definition.
      deferred
      end;

   arguments: FORMAL_ARG_LIST is
         -- Runnable arguments list if any.
      deferred
      end;

   result_type: TYPE is
         -- Runnable Result type if any.
      deferred
      end;

   require_assertion: RUN_REQUIRE is
         -- Runnable collected require assertion if any.
      deferred
      end;

   local_vars: LOCAL_VAR_LIST is
         -- Runnable local var list if any.
      deferred
      end;

   routine_body: COMPOUND is
         -- Runnable routine body if any.
      deferred
      end;

   ensure_assertion: E_ENSURE is
         -- Runnable collected ensure assertion if any.
      deferred
      end;

   rescue_compound: COMPOUND is
         -- Runnable rescue compound if any.
      deferred
      end;

   is_once_procedure: BOOLEAN is
	 -- This is not only true for RUN_FEATURE_5, but it may be also 
	 -- true when some once procedure is wrapped (RUN_FEATURE_10).
      deferred
      ensure
	 Result implies result_type = Void
      end;

   is_once_function: BOOLEAN is
	 -- This is not only true for RUN_FEATURE_6, but it may be also 
	 -- true when some once function is wrapped (RUN_FEATURE_11).
      deferred
      ensure
	 Result implies result_type /= Void
      end;

   is_deferred: BOOLEAN is
      deferred
      end;

   is_pre_computable: BOOLEAN is
      require
         small_eiffel.is_ready
      deferred
      end;

   can_be_dropped: BOOLEAN is
	 -- If calling has no side effect at all.
      require
         small_eiffel.is_ready
      deferred
      end;

   frozen is_once_routine: BOOLEAN is
      do
	 Result := is_once_function or else is_once_procedure;
      end;

   frozen use_current: BOOLEAN is
      require
         small_eiffel.is_ready
      do
         inspect
            use_current_state
         when ucs_true then
            Result := true;
         when ucs_false then
         when ucs_not_computed then
            use_current_state := ucs_in_computation;
            compute_use_current;
            Result := use_current_state = ucs_true;
         when ucs_in_computation then
            Result := true;
         end;
      end;

   frozen stupid_switch(r: ARRAY[RUN_CLASS]): STRING is
         -- Non-Void `Result' indicates a `stupid_switch' as well as the very 
         -- nature of the stupid call site in order to print the 
         -- associated comment in the generated C code.
      require
         run_control.boost;
         small_eiffel.same_base_feature(Current,r)
      do
         check
            -- Must always be called with the same array of run classes.
            r = run_class.running
         end;
         inspect
            stupid_switch_state
         when ucs_true then
            Result := stupid_switch_comment;
         when ucs_false then
         when ucs_not_computed then
            stupid_switch_state := ucs_in_computation;
            compute_stupid_switch(r);
            if stupid_switch_state = ucs_true then
               Result := stupid_switch_comment;
            end;
         when ucs_in_computation then
         end;
      end;

   fall_down is
      local
         running: ARRAY[RUN_CLASS];
         i: INTEGER;
         current_rc, sub_rc: RUN_CLASS;
         current_bc, sub_bc: BASE_CLASS;
         sub_name: FEATURE_NAME;
         rf: RUN_FEATURE;
      do
         current_rc := run_class;
         running := current_rc.running;
         if running /= Void then
            from
               current_bc := current_type.base_class;
               i := running.lower;
            until
               i > running.upper
            loop
               sub_rc := running.item(i);
               if sub_rc /= current_rc then
                  sub_bc := sub_rc.current_type.base_class;
                  sub_name := sub_bc.new_name_of(current_bc,name);
                  rf := sub_rc.get_feature(sub_name);
               end;
               i := i + 1;
            end;
         end;
      end;

   afd_check is
      deferred
      end;

   frozen is_exported_in(cn: CLASS_NAME): BOOLEAN is
         -- True if using of the receiver is legal when written in `cn'.
         -- When false, `eh' is updated with the beginning of the
         -- error message.
      require
         cn /= Void
      do
         Result := clients.gives_permission_to(cn);
      end;

   frozen start_position: POSITION is
      do
         Result := base_feature.start_position;
      end;

   c_define is
         -- Produce C code for definition.
      require
         cpp.on_c
      deferred
      ensure
         cpp.on_c
      end;

   mapping_c is
         -- Produce C code when current is called and when the
         -- concrete type of target is unique (`cpp' is in charge
         -- of the context).
      require
         cpp.on_c
      deferred
      ensure
         cpp.on_c
      end;

   mapping_jvm is
      deferred
      end;

   frozen id: INTEGER is
      do
         Result := current_type.id;
      end;

   mapping_name is
      do
         c_code.clear;
         c_code.extend('r');
         id.append_in(c_code);
         name.mapping_c_in(c_code);
         cpp.put_string(c_code);
      end;

   frozen jvm_max_locals: INTEGER is
      do
         Result := current_type.jvm_stack_space;
         if arguments /= Void then
            Result := Result + arguments.jvm_stack_space;
         end;
         if local_vars /= Void then
            Result := Result + local_vars.jvm_stack_space;
         end;
         if result_type /= Void then
            Result := Result + result_type.jvm_stack_space;
         end;
      end;

feature {CALL}

   frozen vape_check_from(call_site: POSITION) is
         -- Check VAPE rule for this `call_site'.
      require
         not call_site.is_unknown
      do
         small_eiffel.top_rf.clients.vape_check(call_site,clients);
      end;

feature {ADDRESS_OF_POOL}

   address_of_c_define(caller: ADDRESS_OF) is
         -- Corresponding `caller' is used for error messages.
      require
         caller /= Void
      deferred
      end;

feature {ADDRESS_OF}

   address_of_c_mapping is
         -- Produce C code for operator $<feature_name>
      require
         run_class.at_run_time;
         cpp.on_c
      deferred
      ensure
         cpp.on_c
      end;

feature {EXPRESSION}

   is_static: BOOLEAN is
      require
         small_eiffel.is_ready
      deferred
      end;

   static_value_mem: INTEGER is
      require
         is_static;
      deferred
      end;

feature 

   collect_c_tmp is
	 -- Collect needed temporary for user expanded.
      deferred
      end;

feature {E_RETRY,ASSERTION_LIST}

   c_assertion_flag is
      do
         c_code.clear;
         c_frame_descriptor_name_in(c_code);
         c_code.append(".assertion_flag");
         cpp.put_string(c_code);
      end;

feature {NATIVE}

   frozen default_mapping_procedure is
         -- Default mapping for procedure calls with target.
      do
         default_mapping_function;
         cpp.put_string(fz_00);
      end;

   frozen default_mapping_function is
         -- Default mapping for function calls with target.
      local
         no_check, uc, tcbd: BOOLEAN;
      do
         no_check := run_control.no_check;
         uc := use_current;
         if not uc then
            tcbd := cpp.target_cannot_be_dropped;
            if tcbd then
               cpp.put_character(',');
            end;
         end;
         mapping_name;
         cpp.put_character('(');
         if no_check then
            cpp.put_string("&ds");
         end;
         if uc then
            if no_check then
               cpp.put_character(',');
            end;
            cpp.put_target_as_target;
         end;
         if arguments /= Void then
            if uc or else no_check then
               cpp.put_character(',');
            end;
            cpp.put_arguments;
         end;
         cpp.put_character(')');
         if not uc and then tcbd then
            cpp.put_character(')');
         end;
      end;

   routine_mapping_jvm is
      local
         rt, ct: TYPE;
         idx, stack_level: INTEGER;
      do
         ct := current_type;
         jvm.push_target_as_target;
         stack_level := -(1 + jvm.push_arguments);
         rt := result_type;
         if rt /= Void then
            stack_level := stack_level + rt.jvm_stack_space;
         end
         idx := constant_pool.idx_methodref(Current);
         ct.run_class.jvm_invoke(idx,stack_level);
      end;

   frozen c_define_with_body(body: STRING) is
      require
         body /= Void
      do
         define_prototype;
         c_define_opening;
         cpp.put_string(body);
         c_define_closing;
         if result_type = Void then
            cpp.put_string(fz_12);
         else
            cpp.put_string(fz_15);
         end;
         c_frame_descriptor;
      end;

feature {RUN_CLASS}

   jvm_field_or_method is
         -- Update jvm's `fields' or `methods' if needed.
      deferred
      end;

feature {CONSTANT_POOL,SWITCH_COLLECTION}

   frozen jvm_descriptor: STRING is
      do
         tmp_jvm_descriptor.clear;
         update_tmp_jvm_descriptor;
         Result := tmp_jvm_descriptor;
      end;

feature {JVM,ORDINARY_RESULT}

   frozen jvm_result_offset: INTEGER is
         -- Offset of the Result local variable if any.
      require
         result_type /= Void
      do
         Result := current_type.jvm_stack_space;
         if arguments /= Void then
            Result := Result + arguments.jvm_stack_space;
         end;
         if local_vars /= Void then
            Result := Result + local_vars.jvm_stack_space;
         end;
      end;

feature {JVM}

   jvm_define is
         -- To compute the constant pool, the number of fields,
         -- the number of methods, etc.
      require
         small_eiffel.is_ready
      deferred
      end;

   frozen jvm_argument_offset(a: ARGUMENT_NAME): INTEGER is
      require
         arguments /= Void
      do
         Result := current_type.jvm_stack_space;
         Result := Result + arguments.jvm_offset_of(a);
      ensure
         Result >= a.rank - 1
      end;

   frozen jvm_local_variable_offset(ln: LOCAL_NAME): INTEGER is
      require
         local_vars /= Void
      do
         Result := current_type.jvm_stack_space;
         if arguments /= Void then
            Result := Result + arguments.jvm_stack_space;
         end;
         Result := Result + local_vars.jvm_offset_of(ln);
      ensure
         Result >= ln.rank - 1
      end;

feature {ONCE_RESULT}

   fe_vffd7 is
      do
         eh.add_position(result_type.start_position);
         fatal_error("Result type of a once function must %
                     %not be anchored (VFFD.7).");
      end;

feature {RUN_FEATURE}

   is_in_computation: BOOLEAN is
      do
         Result := use_current_state = ucs_in_computation;
      end;

   clients: like clients_memory is
         -- Effective client list for the receiver (inherited "export"
         -- clauses are also considered)..
      local
         bc, bfbc: BASE_CLASS;
      do
         if clients_memory = Void then
            bc := current_type.base_class;
            bfbc := base_feature.base_class;
            if bc = bfbc then
               Result := base_feature.clients;
            else
               check
                  bc.is_subclass_of(bfbc)
               end;
               Result := bc.clients_for(name);
            end;
            clients_memory := Result;
         else
            Result := clients_memory;
         end;
      ensure
         Result /= Void
      end;

feature {NATIVE_C_PLUS_PLUS}

   c_plus_plus_prototype(er: EXTERNAL_ROUTINE) is
      require
         er = base_feature
      local
	 comment: STRING;
      do
	 comment := c_plus_plus_prototype_buffer;
	 comment.copy("%N// C++ wrapper for ");
	 comment.append(er.base_class.name.to_string);
	 comment.extend('.');
	 comment.append(name.to_string);
	 comment.append("%N");
         external_prototype_for(comment,er);
-- ????
--	 cpp.put_string_on_h("%Nextern %"C%" {");
         cpp.put_c_heading(c_code);
--	 cpp.put_string_on_h("}%N");
      end;

feature {NONE}

   c_plus_plus_prototype_buffer: STRING is
      once
	 !!Result.make(128);
      end;

   compute_stupid_switch(r: ARRAY[RUN_CLASS]) is
      require
         stupid_switch_state = ucs_in_computation
      deferred
      ensure
         stupid_switch_state = ucs_true or else stupid_switch_state = ucs_false
      end;

   frozen external_prototype_for(tag: STRING; er: EXTERNAL_ROUTINE) is
      local
         t: TYPE;
      do
         c_code.clear;
         c_code.append(tag);
         -- Define heading of corresponding C function.
         t := result_type;
         if t = Void then
            c_code.append(fz_void);
         else
            t.c_type_for_external_in(c_code);
         end;
         c_code.extend(' ');
         c_code.append(er.external_name);
         c_code.extend('(');
         if er.use_current then
            current_type.c_type_for_external_in(c_code);
            c_code.extend(' ');
            c_code.extend('C');
            if arguments /= Void then
               c_code.extend(',');
            end;
         end;
         if arguments = Void then
            if not er.use_current then
               c_code.append(fz_void);
            end;
         else
            arguments.external_prototype_in(c_code);
         end;
         c_code.extend(')');
      end;

   frozen put_c_name_tag is
      require
         run_control.no_check
      local
         fn: FEATURE_NAME;
      do
         cpp.put_character('%"');
         fn := base_feature.first_name;
         if fn.to_key /= name.to_key then
            name.put_cpp_tag;
            cpp.put_string(name.to_string);
            cpp.put_character(' ');
            cpp.put_character('(');
         end;
         fn.put_cpp_tag;
         cpp.put_string(fn.to_string);
         cpp.put_string(" of ");
         cpp.put_string(base_feature.base_class_name.to_string);
         if fn.to_key /= name.to_key then
            cpp.put_character(')');
         end;
         cpp.put_character('%"');
      end;

   frozen run_require: RUN_REQUIRE is
      do
         Result := current_type.base_class.run_require(Current);
      end;

   frozen run_ensure: E_ENSURE is
      do
         Result := current_type.base_class.run_ensure(Current);
      end;

   address_of_wrapper_name_in(str: STRING) is
      do
         str.extend('W');
         id.append_in(str);
         name.mapping_c_in(str);
      end;

   address_of_c_define_wrapper(caller: ADDRESS_OF) is
      require
         cpp.on_c
      do
         c_code.clear;
         if result_type = Void then
            c_code.append(fz_void);
         else
            result_type.c_type_for_external_in(c_code);
         end;
         c_code.extend(' ');
         address_of_wrapper_name_in(c_code);
         c_code.extend('(');
         current_type.c_type_for_external_in(c_code);
         c_code.extend(' ');
         c_code.extend('C');
         if arguments /= Void then
            c_code.extend(',');
            arguments.external_prototype_in(c_code);
         end;
         c_code.extend(')');
         cpp.put_c_heading(c_code);
	 cecil_pool.define_body_of(Current);
      end;

   address_of_c_mapping_wrapper is
      do
         c_code.clear;
         address_of_wrapper_name_in(c_code);
         cpp.put_string(c_code);
      end;

   c_frame_descriptor_name_in(str: STRING) is
      do
         str.extend('f');
         id.append_in(str);
         name.mapping_c_in(str);
      end;

   c_frame_descriptor is
      do
         if run_control.no_check then
            c_code.copy("se_frame_descriptor ");
            c_frame_descriptor_name_in(c_code);
            cpp.put_extern7(c_code);
            cpp.put_character('{');
            put_c_name_tag;
            c_code.clear;
            c_code.extend(',');
            if use_current then
               c_code.extend('1');
            else
               c_code.extend('0');
            end;
            c_code.extend(',');
            c_frame_descriptor_local_count.append_in(c_code);
            c_code.extend(',');
            c_code.append(c_frame_descriptor_format);
            c_code.append("%",1};%N");
            cpp.put_string(c_code);
         end;
      end;

   define_prototype is
      require
         run_class.at_run_time;
         cpp.on_c
      local
         mem_id: INTEGER;
         no_check: BOOLEAN;
      do
         no_check := run_control.no_check;
         if run_control.no_check then
            c_frame_descriptor_local_count.reset;
            c_frame_descriptor_format.clear;
            c_frame_descriptor_format.extend('%"');
            c_frame_descriptor_locals.clear;
         end;
         mem_id := id;
         -- Define heading of corresponding C function.
         c_code.clear;
	 -- Extra comment to debug C code :
	 -- c_code.append("/*");
	 -- c_code.append(current_type.run_time_mark);
	 -- c_code.append("*/%N");
	 --
         if result_type = Void then
            c_code.append(fz_void);
         else
            result_type.run_type.c_type_for_result_in(c_code);
         end;
         c_code.extend(' ');
         c_code.extend('r');
         mem_id.append_in(c_code);
         name.mapping_c_in(c_code);
         c_code.extend('(');
         if no_check then
            c_code.append("se_dump_stack*caller");
            if use_current or else arguments /= Void then
               c_code.extend(',');
            end;
         end;
         if use_current then
            current_type.c_type_for_target_in(c_code);
            c_code.extend(' ');
            c_code.extend('C');
            current_type.c_frame_descriptor;
            if arguments /= Void then
               c_code.extend(',');
            end;
         end;
         if arguments = Void then
            if no_check then
            elseif not use_current then
               c_code.append(fz_void);
            end;
         else
            arguments.compile_to_c_in(c_code);
         end;
         c_code.extend(')');
         cpp.put_c_heading(c_code);
         cpp.swap_on_c;
      ensure
         cpp.on_c
      end;

   c_define_opening is
         -- Define opening section in C function.
      local
         t: TYPE;
         no_check, ensure_check: BOOLEAN;
	 oresult: STRING;
	 rf3: RUN_FEATURE_3;
      do
         no_check := run_control.no_check;
         ensure_check := run_control.ensure_check;
         -- (0) --------------------------- Exception handling :
         if rescue_compound /= Void then
            cpp.put_string("struct rescue_context rc;%N");
         end;
         -- (1) -------------------- Local variable for Result :
         if is_once_function then
	    oresult := once_routine_pool.o_result(base_feature);
            if no_check then
               t := result_type.run_type;
               c_frame_descriptor_locals.append("(void**)&");
               c_frame_descriptor_locals.append(oresult);
               c_frame_descriptor_locals.extend(',');
               c_frame_descriptor_local_count.increment;
               c_frame_descriptor_format.append(as_result);
               t.c_frame_descriptor;
            end;
         elseif result_type /= Void then
            t := result_type.run_type;
            c_code.clear;
            t.c_type_for_result_in(c_code);
            c_code.append(" R=");
            t.c_initialize_in(c_code);
            c_code.append(fz_00);
            cpp.put_string(c_code);
            if no_check then
               c_frame_descriptor_locals.append("(void**)&R,");
               c_frame_descriptor_local_count.increment;
               c_frame_descriptor_format.append(as_result);
               t.c_frame_descriptor;
            end;
         end;
         -- (2) ----------------------- User's local variables :
         if local_vars /= Void then
            local_vars.c_declare;
         end;
         -- (3) ---------------- Local variable for old/ensure :
         if ensure_check then
            if ensure_assertion /= Void then
               ensure_assertion.c_declare_for_old;
            end;
         end;
         if no_check then
         -- (4) ------------------------------- Prepare locals :
            if c_frame_descriptor_local_count.value > 0 then
               c_code.copy("void**locals[");
               c_frame_descriptor_local_count.append_in(c_code);
               c_code.extend(']');
               c_code.append(fz_00);
               cpp.put_string(c_code);
            end;
         -- (5) ----------------------------------- Prepare ds :
            c_initialize_ds_one_by_one;
            c_initialize_locals_one_by_one;
         -- (6) ------------------------ Initialise Dump Stack :
            cpp.put_string("se_dst=&ds;/*link*/%N");
         end;
         -- (7) ----------------------- Execute old for ensure :
         if ensure_check then
            if ensure_assertion /= Void then
               ensure_assertion.compile_to_c_old;
            end;
         end;
         -- (8) --------------------------- Exception handling :
         if rescue_compound /= Void then
            cpp.put_string("if(SETJMP(rc.jb)!=0){/*rescue*/%N");
            rescue_compound.compile_to_c;
            cpp.put_string(
               "internal_exception_handler(Routine_failure);%N}%N");
         end;
         -- (9) -------------------- Initialize Result/local expanded :
	 if result_type /= Void then
	    rf3 := result_type.expanded_initializer;
	    if rf3 /= Void then
	       if oresult /= Void then
		  cpp.put_proc_call_0(rf3,Void,oresult);
	       else
		  cpp.put_proc_call_0(rf3,Void,"R");
	       end;
	    end;
	 end;
         if local_vars /= Void then
            local_vars.initialize_expanded;
         end;
         -- (10) --------------------------- Retry start label :
         if rescue_compound /= Void then
            cpp.put_string("retry_tag:%N");
         end;
         -- (11) ---------------------- Require assertion code :
         if require_assertion /= Void then
            require_assertion.compile_to_c;
         end;
         -- (12) ------------------------- Save rescue context :
         if rescue_compound /= Void then
            cpp.put_string("rc.next = rescue_context_top;%N%
                           %rescue_context_top = &rc;%N");
            if no_check then
	       cpp.put_string("rc.top_of_ds=&ds;%N");
               cpp.put_string("se_dst=&ds;/*link*/%N");
            end;
         end;
      end;

   c_define_closing is
         -- Define closing section in C function :
         --    - code for ensure checking.
         --    - free memory of expanded.
         --    - run stack pop.
      do
         -- (1) --------------------------- Ensure Check Code :
         if run_control.ensure_check then
            if ensure_assertion /= Void then
               ensure_assertion.compile_to_c;
            end;
         end;
         -- (2) ----------------------------- Class Invariant :
         if use_current then
	    if name.to_string /= as_dispose then
	       cpp.current_class_invariant(current_type);
	    end;
         end;
         -- (3) ---------------------------------- For rescue :
         if rescue_compound /= Void then
            cpp.put_string("rescue_context_top = rc.next;%N");
         end;
         -- (4) ------------------------------- Run Stack Pop :
         if run_control.no_check then
            cpp.put_string("se_dst=caller;/*unlink*/%N");
         end;
      end;

   external_prototype(er: EXTERNAL_ROUTINE) is
         -- Define prototype for an external routine.
      require
         er = base_feature
      do
         external_prototype_for("/*external*/",er);
         c_code.append(fz_00);
         cpp.swap_on_h;
         cpp.put_string(c_code);
         cpp.swap_on_c;
      ensure
         cpp.on_c
      end;

   use_current_state: INTEGER;
   
   stupid_switch_state: INTEGER;

   ucs_false, ucs_true, ucs_not_computed, 
   ucs_in_computation: INTEGER is unique;

   frozen std_compute_use_current is
      require
         is_in_computation
      do
         if use_current_state = ucs_in_computation then
            if require_assertion /= Void then
               if require_assertion.use_current then
                  use_current_state := ucs_true;
               end;
            end;
         end;
         if use_current_state = ucs_in_computation then
            if routine_body /= Void then
               if routine_body.use_current then
                  use_current_state := ucs_true;
               end;
            end;
         end;
         if use_current_state = ucs_in_computation then
            if rescue_compound /= Void then
               if rescue_compound.use_current then
                  use_current_state := ucs_true;
               end;
            end;
         end;
         if use_current_state = ucs_in_computation then
            if ensure_assertion /= Void then
               if ensure_assertion.use_current then
                  use_current_state := ucs_true;
               end;
            end;
         end;
         if use_current_state = ucs_in_computation then
            use_current_state := ucs_false;
         end;
      ensure
         use_current_state = ucs_false or else
         use_current_state = ucs_true;
      end;

   compute_use_current is
      require
         is_in_computation
      deferred
      ensure
         use_current_state = ucs_true or else
         use_current_state = ucs_false;
      end;

   frozen std_compute_stupid_switch(r: ARRAY[RUN_CLASS]) is
      require
         stupid_switch_state = ucs_in_computation
      local
         rt: TYPE;
      do
         check
            small_eiffel.same_base_feature(Current,r)
         end;
         rt := result_type;
         if rt /= Void and then rt.is_user_expanded then
            stupid_switch_state := ucs_false;
         end;
         if stupid_switch_state = ucs_in_computation then
            if routine_body /= Void then
               if not routine_body.stupid_switch(r) then
                  stupid_switch_state := ucs_false;
               end;
            end;
         end;
         if stupid_switch_state = ucs_in_computation then
            if rescue_compound /= Void then
               if not rescue_compound.stupid_switch(r) then
                  stupid_switch_state := ucs_false;
               end;
            end;
         end;
         if stupid_switch_state = ucs_in_computation then
            stupid_switch_state := ucs_true;
         end;
      ensure
         stupid_switch_state = ucs_true or stupid_switch_state = ucs_false;
      end;

   c_code: STRING is
      once
	 !!Result.make(512);
      end;

   update_tmp_jvm_descriptor is
      deferred
      end;

   tmp_jvm_descriptor: STRING is
      once
         !!Result.make(128);
      end;

   routine_update_tmp_jvm_descriptor is
         -- For RUN_FEATURE_3/4/5/6/7/8/9/10/11 :
      local
         ct, rt: TYPE;
      do
         tmp_jvm_descriptor.extend('(');
         ct := current_type;
         ct.jvm_target_descriptor_in(tmp_jvm_descriptor);
         if arguments /= Void then
            arguments.jvm_descriptor_in(tmp_jvm_descriptor);
         end;
         rt := result_type;
         if rt = Void then
            tmp_jvm_descriptor.append(fz_19);
         else
            rt := rt.run_type;
            tmp_jvm_descriptor.extend(')');
            rt.jvm_descriptor_in(tmp_jvm_descriptor);
         end;
      end;

   method_info_start is
      local
         flags: INTEGER;
      do
         flags := current_type.jvm_method_flags;
         method_info.start(flags,name.to_key,jvm_descriptor);
      end;

   jvm_define_opening is
      require
         jvm.current_frame = Current
      local
         space: INTEGER;
      do
         -- (1) -------------------- Local variable for Result :
         if result_type /= Void then
            space := result_type.jvm_push_default;
	    if is_once_function then 
	       once_routine_pool.jvm_result_store(Current);
	    else
	       result_type.jvm_write_local(jvm_result_offset);
	    end;
         end;
         -- (2) ----------------------- User's local variables :
         if local_vars /= Void then
            local_vars.jvm_initialize;
         end;
         -- (3) ---------------- Local variable for old/ensure :
         if run_control.ensure_check then
            if ensure_assertion /= Void then
               ensure_assertion.compile_to_jvm_old;
            end;
         end;
         -- (4) ----------------------- Require assertion code :
         if require_assertion /= Void then
            require_assertion.compile_to_jvm;
         end;
      end;

   jvm_define_closing is
      require
         jvm.current_frame = Current
      do
         -- (0) ----------------------------- Class Invariant :
         -- (1) --------------------------- Ensure Check Code :
         if run_control.ensure_check then
            if ensure_assertion /= Void then
               ensure_assertion.compile_to_jvm(true);
               code_attribute.opcode_pop;
            end;
         end;
         -- (2) --------------------- Free for local expanded :
      end;

   routine_afd_check is
      do
         if require_assertion /= Void then
            require_assertion.afd_check;
         end;
         if routine_body /= Void then
            routine_body.afd_check;
         end;
         if rescue_compound /= Void then
            rescue_compound.afd_check;
         end;
         if ensure_assertion /= Void then
            ensure_assertion.afd_check;
         end;
      end;

   c_initialize_ds_one_by_one is
      require
         run_control.no_check
      do
         c_code.copy("se_dump_stack ds;%Nds.fd=&");
         c_frame_descriptor_name_in(c_code);
         c_code.append(fz_00);
         if use_current then
            c_code.append("ds.current=((void**)&C);%N");
         else
            c_code.append("ds.current=NULL;%N");
         end;
         cpp.put_string(c_code);
         cpp.put_position_in_ds(start_position);
         cpp.put_string("ds.caller=caller;%N");
         if c_frame_descriptor_local_count.value > 0 then
            cpp.put_string("ds.locals=locals;%N");
         end;
      end;

   c_initialize_locals_one_by_one is
      require
         run_control.no_check
      local
         i, j: INTEGER;
         c: CHARACTER;
      do
         from
            j := 1;
         until
            c_frame_descriptor_local_count.value = i
         loop
            cpp.put_string("locals[");
            cpp.put_integer(i);
            cpp.put_string("]=");
            from
               c := c_frame_descriptor_locals.item(j);
            until
               c = ','
            loop
               cpp.put_character(c);
               j := j + 1;
               c := c_frame_descriptor_locals.item(j);
            end;
            j := j + 1;
            cpp.put_string(fz_00);
            i := i + 1;
         end;
      end;

   initialize is
         -- Perform carefully the initialization (must not trigger
         -- another `initialize').
      deferred
      end;

   frozen default_rescue_compound: COMPOUND is
         -- Builds and returns an "artificial" compound that simply 
         -- calls `default_rescue'.
         -- If the `default_rescue' routine is from GENERAL, then no 
         -- compound is built and Void is returned, so as to avoid 
         -- generation of costly SETJMP/LONGJMPs.
      do
         Result := run_class.get_default_rescue(name);
      end;
   
   frozen make(ct: like current_type; n: like name; bf: like base_feature) is
      require
         ct.run_type = ct;
	 ct.run_class.at(n) = Void;
         bf /= void;
         not small_eiffel.is_ready
      local
	 debug_info: STRING;
      do
	 run_class := ct.run_class;
	 debug
	    debug_info := ct.run_time_mark.twin;
	    debug_info.extend('.');
	    debug_info.append(n.to_string.twin);
	 end;
         current_type := ct;
         name := n;
         base_feature := bf;
         run_class.add_run_feature(Current,n);
         small_eiffel.incr_magic_count;
         use_current_state := ucs_not_computed;
         stupid_switch_state := ucs_not_computed;
         small_eiffel.push(Current);
         initialize;
         small_eiffel.pop;
      ensure
         run_class.at(name) = Current
      end;

   stupid_switch_comment: STRING is
      deferred
      end;

invariant

   current_type /= Void;

   name /= Void;

   base_feature /= Void;

end -- RUN_FEATURE
