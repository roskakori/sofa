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
class RUN_FEATURE_11
   --
   -- Wrapped some function called via the Precursor construct.
   --
inherit RUN_FEATURE redefine fall_down end;

creation {E_PRECURSOR_FUNCTION} make

feature

   base_feature: EFFECTIVE_ROUTINE;

   arguments: FORMAL_ARG_LIST;

   result_type: TYPE;

   require_assertion: RUN_REQUIRE;

   local_vars: LOCAL_VAR_LIST;

   routine_body: COMPOUND;

   rescue_compound: COMPOUND;

   ensure_assertion: E_ENSURE;

   is_deferred: BOOLEAN is false;

   is_static: BOOLEAN is false;

   can_be_dropped: BOOLEAN is false;

   is_once_procedure: BOOLEAN is false;

   is_once_function: BOOLEAN is
	 -- True when some once function is wrapped.
      local
	 once_function: ONCE_FUNCTION;
      do
	 once_function ?= base_feature;
	 Result := once_function /= Void;
      end;

   is_pre_computable: BOOLEAN is
      do
	 if is_once_function then
	    Result := once_routine_pool.is_pre_computable(Current);
	 end;
      end;

   fall_down is
      do
      end;

   static_value_mem: INTEGER is
      do
      end;

   afd_check is
      do
         routine_afd_check;
      end;

   mapping_c is
      local
         tmp_expanded_idx: INTEGER;
      do
	 if is_pre_computable then
            once_routine_pool.c_put_o_result(Current);	    
	 else
	    tmp_expanded_idx := cpp.se_tmp_open(Current);
	    default_mapping_function;
	    if tmp_expanded_idx >= 0 then
	       cpp.se_tmp_close(tmp_expanded_idx);
	    end;
	 end;
      end;

   c_define is
      local
	 once_wrapper: BOOLEAN;
      do
	 cpp.incr_precursor_routine_count;
	 once_wrapper := is_once_function;
	 if once_wrapper then
	    once_routine_pool.c_define_o_result(Current);
	 end;
	 if not is_pre_computable then
	    if once_wrapper then
	       once_routine_pool.c_define_o_flag(Current);
	    end;
	    define_prototype;
	    if once_wrapper then
	       once_routine_pool.c_test_o_flag(Current);
	    end;
	    c_define_opening;
	    if routine_body /= Void then
	       routine_body.compile_to_c;
	    end;
	    c_define_closing;
	    if once_wrapper then
	       once_routine_pool.c_return_o_result(Current);
	    else
	       cpp.put_string(fz_15);
	    end;
	    c_frame_descriptor;
	 end;
      end;

feature {RUN_CLASS}

   jvm_field_or_method is
      do
         jvm.add_method(Current);
      end;

feature

   mapping_jvm is
      do
         routine_mapping_jvm;
      end;

feature {JVM}

   jvm_define is
      do
         method_info_start;
         jvm_define_opening;
         if routine_body /= Void then
            routine_body.compile_to_jvm;
         end;
         jvm_define_closing;
         result_type.jvm_push_local(jvm_result_offset);
         result_type.run_type.jvm_return_code;
         method_info.finish;
      end;

feature {NONE}

   update_tmp_jvm_descriptor is
      do
         routine_update_tmp_jvm_descriptor;
      end;

feature {E_PRECURSOR}

   collect_c_tmp is
      do
         if result_type.is_user_expanded then
            if result_type.is_dummy_expanded then
            else
               cpp.se_tmp_add(Current);
            end;
         end;
      end;

feature {ADDRESS_OF_POOL}

   address_of_c_define(caller: ADDRESS_OF) is
      do
      end;

feature {ADDRESS_OF}

   address_of_c_mapping is
      do
      end;

feature {NONE}

   compute_use_current is
      do
         std_compute_use_current;
      end;

   initialize is
      do
         arguments := base_feature.arguments;
         if arguments /= Void then
            if not arguments.is_runnable(current_type) then
               !!arguments.with(arguments,current_type);
            end;
         end;
         result_type := base_feature.result_type.to_runnable(current_type);
         local_vars := base_feature.local_vars;
         if local_vars /= Void then
            local_vars := local_vars.to_runnable(current_type);
         end;
         routine_body := base_feature.routine_body;
         if routine_body /= Void then
            routine_body := routine_body.to_runnable(current_type);
         end;
         if run_control.require_check then
            require_assertion := run_require;
         end;
         if run_control.ensure_check then
            ensure_assertion := run_ensure;
         end;
         rescue_compound := base_feature.rescue_compound;
         if rescue_compound /= Void then
            exceptions_handler.set_used;
            rescue_compound := rescue_compound.to_runnable(current_type);
         end;
	 if is_once_function then
	    once_routine_pool.register_function(Current);
	 end;
      end;

   compute_stupid_switch(r: ARRAY[RUN_CLASS]) is
      do
         std_compute_stupid_switch(r);
      end;

   stupid_switch_comment: STRING is "SSPRF11";

end -- RUN_FEATURE_11
