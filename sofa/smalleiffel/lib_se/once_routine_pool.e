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
class ONCE_ROUTINE_POOL
   --
   -- Singleton object in charge of runnable once routines.
   -- This singleton is shared via the GLOBALS.`once_routine_pool' once function.
   --

inherit GLOBALS;

feature {RUN_FEATURE} -- For `compile_to_c' as well as `compile_to_jvm' :

   register_procedure(rf: RUN_FEATURE) is
      require
         rf.is_once_procedure
      do
         check
            not procedure_list.has(rf)
         end;
         procedure_list.add_last(rf);
      end;

   register_function(rf: RUN_FEATURE) is
      require
         rf.is_once_function
      do
         check
            not function_list.has(rf)
         end;
         function_list.add_last(rf);
      end;

feature {GC_HANDLER}

   gc_mark_in(c_code: STRING) is
	 -- To mark results of once functions because they are part 
	 -- of the root.
      local
         i: INTEGER;
         rf: RUN_FEATURE;
         of: ONCE_FUNCTION;
         mem: FIXED_ARRAY[ONCE_FUNCTION];
         rt: TYPE;
         oresult: STRING;
      do
         if function_list.count > 0 then
            from
               i := function_list.upper;
               !!mem.with_capacity(i // 2);
            until
               i < 0
            loop
               rf := function_list.item(i);
               of ?= rf.base_feature;
	       check
		  of /= Void
	       end;
               if not mem.fast_has(of) then
                  if rf.current_type.run_class.at_run_time then
                     mem.add_last(of);
                     rt := rf.result_type;
                     if rt.need_gc_mark_function then
                        oresult := o_result(of);
			gc_handler.mark_for(c_code,oresult,rt.run_class);
                     end;
                  end;
               end;
               i := i - 1;
            end;
         end;
      end;

feature {JVM}

   fields_count: INTEGER;

   jvm_define_fields is
      local
         byte_idx, idx_flag, i: INTEGER;
         rf: RUN_FEATURE;
         bf: E_FEATURE;
         name_list: FIXED_ARRAY[INTEGER];
      do
         !!name_list.with_capacity(fields_count);
         if function_list.count > 0 then
            from
               i := function_list.upper;
               byte_idx := constant_pool.idx_utf8(fz_41);
            until
               i < 0
            loop
               rf := function_list.item(i);
               bf := rf.base_feature;
               idx_flag := idx_name_for_flag(bf);
               if name_list.fast_has(idx_flag) then
               else
                  name_list.add_last(idx_flag);
                  -- ---------- Static field for flag :
                  field_info.add(9,idx_flag,byte_idx);
                  -- ---------- Static field for result :
                  field_info.add(9,
                                 idx_name_for_result(bf),
                                 idx_descriptor(rf.result_type.run_type));
               end;
               i := i - 1;
            end;
         end;
         if procedure_list.count > 0 then
            from
               i := procedure_list.upper;
               byte_idx := constant_pool.idx_utf8(fz_41);
            until
               i < 0
            loop
               rf := procedure_list.item(i);
               bf := rf.base_feature;
               idx_flag := idx_name_for_flag(bf);
               if name_list.fast_has(idx_flag) then
               else
                  name_list.add_last(idx_flag);
                  -- ---------- Static field for flag :
                  field_info.add(9,idx_flag,byte_idx);
               end;
               i := i - 1;
            end;
         end;
      end;

   jvm_initialize_fields is
      local
         i: INTEGER;
      do
         if jvm_flag_list.count > 0 then
            from
               i := jvm_flag_list.upper;
            until
               i < 0
            loop
               -- Set once flag :
               code_attribute.opcode_iconst_0;
               code_attribute.opcode_putstatic(jvm_flag_list.item(i),-1);
               i := i - 1;
            end;
         end;
      end;

feature {RUN_FEATURE} -- For `compile_to_jvm' only :

   idx_fieldref_for_flag(rf: RUN_FEATURE): INTEGER is
      require
         rf.is_once_routine
      local
	 cp: CONSTANT_POOL;
      do
	 cp := constant_pool;
         Result := cp.idx_fieldref3(jvm_root_class,
				    o_flag(rf.base_feature),
				    fz_41);
      end;

feature {NONE} -- For `compile_to_c' as well as `compile_to_jvm' :

   idx_fieldref_for_result(rf: RUN_FEATURE): INTEGER is
      require
         rf.is_once_function
      local
	 cp: CONSTANT_POOL;
	 rt: TYPE;
      do
	 cp := constant_pool;
         rt := rf.result_type.run_type;
         Result := cp.idx_fieldref3(jvm_root_class,
				    o_result(rf.base_feature),
				    jvm_descriptor(rt));
      end;

   procedure_list: FIXED_ARRAY[RUN_FEATURE] is
	 -- Live set of once procedures.
      once
         !!Result.with_capacity(32);
      end;

   function_list: FIXED_ARRAY[RUN_FEATURE] is
	 -- Live set of once functions.
      once
         !!Result.with_capacity(32);
      end;

   o_flag(bf: E_FEATURE): STRING is
	 -- Compute the only one corresponding `flag': fBCxxKey used
	 -- to check that execution is done.
      require
	 bf /= Void
      do
	 Result := ".....................";
         Result.clear;
         Result.append("fBC");
         bf.base_class.id.append_in(Result);
         Result.append(bf.first_name.to_key);
	 Result := string_aliaser.item(Result);
      ensure
	 Result = string_aliaser.item(Result)
      end;

   buffer: STRING is 
      once
	 !!Result.make(64);
      end;

   buffer2: STRING is 
      once
	 !!Result.make(64);
      end;

feature {ABSTRACT_RESULT,RUN_FEATURE}

   o_result(bf: E_FEATURE): STRING is
      require
	 bf /= Void
      do
	 Result := "................";
         Result.clear;
         Result.append("oBC");
         bf.base_class.id.append_in(Result);
         Result.append(bf.first_name.to_key);
	 Result := string_aliaser.item(Result);
      ensure
	 Result = string_aliaser.item(Result)
      end;

   c_put_o_result(rf: RUN_FEATURE) is
      require
	 rf.is_once_function
      do
	 cpp.put_string(o_result(rf.base_feature));
      end;

   jvm_result_load(rf: RUN_FEATURE) is
      require
	 rf.is_once_function
      local
         result_space, idx_result: INTEGER;
      do
         result_space := rf.result_type.jvm_stack_space;
         idx_result := idx_fieldref_for_result(rf);
         code_attribute.opcode_getstatic(idx_result,result_space);
      end;

   jvm_result_store(rf: RUN_FEATURE) is
      require
	 rf.is_once_function
      local
         result_space, idx_result: INTEGER;
      do
         result_space := rf.result_type.jvm_stack_space;
         idx_result := idx_fieldref_for_result(rf);
         code_attribute.opcode_putstatic(idx_result,- result_space);
      end;

feature {C_PRETTY_PRINTER} -- For `compile_to_c' :

   c_pre_compute is
	 -- Generate C code to pre_compute some functions.
      local
	 i: INTEGER;
	 memory: FIXED_ARRAY[E_FEATURE];
	 rf: RUN_FEATURE;
	 bf: E_FEATURE;
      do
	 echo.put_string(fz_04);
	 echo.put_string(fz_05);
	 cpp.put_string(fz_pco_comment);
	 from
	    i := function_list.upper;
	    !!memory.with_capacity(64);
	 until
	    i < 0
	 loop
	    rf := function_list.item(i);
	    if rf.run_class.at_run_time then
	       if rf.is_pre_computable then
		  bf := rf.base_feature;
		  if not memory.fast_has(bf) then
		     memory.add_last(bf);
		     echo.put_character('%T');
		     echo.put_string(bf.base_class.name.to_string);
		     echo.put_character('.');
		     echo.put_string(rf.name.to_string);
		     echo.put_character('%N');
		     c_pre_compute_of(rf,bf);
		     cpp.put_string(fz_pco_comment);
		  end;
	       end;
	    end;
	    i := i - 1;
	 end;
	 echo.print_count(fz_04,memory.count);
      end;
   
feature {RUN_FEATURE} -- For `compile_to_c' :

   c_define_o_flag(rf: RUN_FEATURE) is
	 -- Add the definition/initialization of the corresponding 
	 -- `o_flag' if not yet done.
      require
	 rf.is_once_routine
      local
	 bf: E_FEATURE;
	 bcbf: BASE_CLASS;
	 flag: STRING;
      do
	 bf := rf.base_feature;
	 bcbf := bf.base_class;
	 flag := o_flag(bf);
	 if not bcbf.once_flag(flag) then
	    buffer.copy("int ");
	    buffer.append(flag);
	    cpp.put_extern2(buffer,'0');
	 end;
      end;

   c_define_o_result(rf: RUN_FEATURE) is
      require
	 rf.is_once_function
      local
	 bf: E_FEATURE;
	 bcbf: BASE_CLASS;
	 oresult: STRING;
	 rt: TYPE;
      do
	 bf := rf.base_feature;
	 bcbf := bf.base_class;
	 oresult := o_result(bf);
	 if not bcbf.once_flag(oresult) then
	    buffer.clear;
	    buffer.extend('T');
	    rt := rf.result_type;
	    if rt.is_expanded then
	       rt.id.append_in(buffer);
	       buffer.extend(' ');
	    else
	       buffer.extend('0');
	       buffer.extend('*');
	    end;
	    buffer.append(oresult);
	    buffer2.clear;
	    rt.c_initialize_in(buffer2);
	    cpp.put_extern5(buffer,buffer2);
	 end;
     end;

   c_test_o_flag(rf: RUN_FEATURE) is
      require
	 rf.is_once_routine
      local
	 flag: STRING;
      do
	 flag := o_flag(rf.base_feature);
         cpp.put_string("if(");
         cpp.put_string(flag);
         cpp.put_string("==0){");
         cpp.put_string(flag);
	 cpp.put_string("=1;{%N");
      end;

   c_return_o_result(rf: RUN_FEATURE) is
      require
	 rf.is_once_function
      do
         cpp.put_string("}}%Nreturn ");
         cpp.put_string(o_result(rf.base_feature));
         cpp.put_string(";%N}%N");
      end;

feature {NONE} -- For `compile_to_jvm' :

   jvm_flag_list: FIXED_ARRAY[INTEGER] is
      once
         !!Result.with_capacity(32);
      end;

   idx_descriptor(rt: TYPE): INTEGER is
      require
         rt /= Void
      do
         Result := constant_pool.idx_utf8(jvm_descriptor(rt));
      end

   idx_name_for_result(bf: E_FEATURE): INTEGER is
      require
         bf /= Void
      do
         Result := constant_pool.idx_utf8(o_result(bf));
      end

   idx_name_for_flag(bf: E_FEATURE): INTEGER is
      require
         bf /= Void
      do
         Result := constant_pool.idx_utf8(o_flag(bf));
      end

   jvm_descriptor(rt: TYPE): STRING is
      do
	 Result := ".............................";
         Result.clear;
         if rt.is_reference then
            Result.append(jvm_root_descriptor)
         else
            rt.jvm_descriptor_in(Result)
         end;
      end;

feature {RUN_FEATURE_6,RUN_FEATURE_11}

   is_pre_computable(rf: RUN_FEATURE): BOOLEAN is
      require
	 rf.is_once_function
      do
         if frozen_general.fast_has(rf.name.to_string) then
            Result := true;
         elseif rf.arguments = Void and then not rf.use_current then
            if rf.routine_body = Void then
               Result := true;
            elseif not run_control.invariant_check then
               Result := rf.routine_body.is_pre_computable;
            end;
         end;
         if Result then
            if rf.require_assertion /= Void then
               rf.require_assertion.clear_run_feature;
            end;
            if rf.ensure_assertion /= Void then
               rf.ensure_assertion.clear_run_feature;
            end;
         end;
      end;

feature {NONE}

   c_pre_compute_of(rf: RUN_FEATURE; bf: E_FEATURE) is
      require
	 rf.is_once_function;
         rf.is_pre_computable;
         cpp.on_c;
      local
	 result_type: TYPE;
	 local_vars: LOCAL_VAR_LIST;
      do
         if run_control.require_check then
            if rf.require_assertion /= Void then
               rf.require_assertion.compile_to_c;
            end;
         end;
	 --
	 result_type := rf.result_type;
         if result_type.expanded_initializer /= Void then 
            c_put_o_result(rf);
	    cpp.put_character('=');
	    result_type.c_initialize;
            cpp.put_string(fz_00);
         end;
	 --
	 local_vars := rf.local_vars;
         if local_vars /= Void then
            cpp.put_character('{');
            local_vars.c_declare;
         end;
	 --
         if rf.routine_body /= Void then
            rf.routine_body.compile_to_c;
         end;
	 --
         if run_control.ensure_check then
            if rf.ensure_assertion /= Void then
               rf.ensure_assertion.compile_to_c;
            end;
         end;
	 --
         if local_vars /= Void then
            cpp.put_character('}');
         end;
      end;

   frozen_general: ARRAY[STRING] is
      once
         Result := <<as_std_error, as_std_input, as_io, as_std_output>>;
      end;

   fz_pco_comment: STRING is "/*PCO*/%N";

   singleton_memory: ONCE_ROUTINE_POOL is
      once
	 Result := Current;
      end;

invariant

   is_real_singleton: Current = singleton_memory

end -- ONCE_ROUTINE_POOL

