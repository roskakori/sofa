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
class RUN_FEATURE_6

inherit RUN_FEATURE;

creation make

feature

   base_feature: ONCE_FUNCTION;

   arguments: FORMAL_ARG_LIST;

   result_type: TYPE;

   require_assertion: RUN_REQUIRE;

   local_vars: LOCAL_VAR_LIST;

   routine_body: COMPOUND;

   rescue_compound: COMPOUND;

   ensure_assertion: E_ENSURE;

   is_deferred: BOOLEAN is false;

   is_once_procedure: BOOLEAN is false;

   is_once_function: BOOLEAN is true;

   is_static: BOOLEAN is false;

   static_value_mem: INTEGER is 0;

   afd_check is
      do
         routine_afd_check;
      end;

   is_pre_computable: BOOLEAN is
      do
	 Result := once_routine_pool.is_pre_computable(Current);
      end;

   can_be_dropped: BOOLEAN is
      do
         Result := is_pre_computable;
      end;

   mapping_c is
      do
         if is_pre_computable then
            once_routine_pool.c_put_o_result(Current);
         else
            default_mapping_function;
         end;
      end;

   c_define is
      do
	 once_routine_pool.c_define_o_result(Current);
         if not is_pre_computable then
	    once_routine_pool.c_define_o_flag(Current);
            define_prototype;
	    once_routine_pool.c_test_o_flag(Current);
            c_define_opening;
	    if routine_body /= Void then
               routine_body.compile_to_c;
            end;
            c_define_closing;
	    once_routine_pool.c_return_o_result(Current);
            c_frame_descriptor;
         end;
      end;

   mapping_jvm is
      do
         routine_mapping_jvm;
      end;

feature {CALL_PROC_CALL}

   collect_c_tmp is
      do
      end;

feature {ADDRESS_OF_POOL}

   address_of_c_define(caller: ADDRESS_OF) is
      do
         if run_control.boost then
            if use_current then
            else
               address_of_c_define_wrapper(caller);
            end;
         else
            address_of_c_define_wrapper(caller);
         end;
      end;

feature {ADDRESS_OF}

   address_of_c_mapping is
      do
         if run_control.boost then
            if use_current then
               mapping_name;
            else
               address_of_c_mapping_wrapper;
            end;
         else
            address_of_c_mapping_wrapper;
         end;
      end;

feature {RUN_CLASS}

   jvm_field_or_method is
      do
         jvm.add_method(Current);
      end;

feature {JVM}

   jvm_define is
      local
         branch, idx_flag: INTEGER;
         ca: like code_attribute;
      do
         ca := code_attribute;
         idx_flag := once_routine_pool.idx_fieldref_for_flag(Current);
         method_info_start;
         ca.opcode_getstatic(idx_flag,1);
         branch := ca.opcode_ifne;
         ca.opcode_iconst_1;
         ca.opcode_putstatic(idx_flag,-1);
         jvm_define_opening;
         if routine_body /= Void then
            routine_body.compile_to_jvm;
         end;
         jvm_define_closing;
         ca.resolve_u2_branch(branch);
         once_routine_pool.jvm_result_load(Current);
         result_type.run_type.jvm_return_code;
         method_info.finish;
      end;

feature {NONE}

   initialize is
      do
         result_type := base_feature.result_type;
         arguments := base_feature.arguments;
         if result_type.is_anchored then
            fe_vffd7;
         elseif result_type.is_formal_generic then
            eh.add_position(result_type.start_position);
            fatal_error("Result type of a once function must %
                        %not be a formal generic argument (VFFD.7).");
         end;
         result_type := result_type.to_runnable(current_type);
         if arguments /= Void then
            if not arguments.is_runnable(current_type) then
               !!arguments.with(arguments,current_type);
            end;
         end;
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
         if rescue_compound = Void then
            rescue_compound := default_rescue_compound;
         end;
         if rescue_compound /= Void then
            exceptions_handler.set_used;
            rescue_compound := rescue_compound.to_runnable(current_type);
         end;
         once_routine_pool.register_function(Current);
      end;

   compute_use_current is
      do
         std_compute_use_current;
      end;

   compute_stupid_switch(r: ARRAY[RUN_CLASS]) is
      do
         std_compute_stupid_switch(r);
      end;

   update_tmp_jvm_descriptor is
      do
         routine_update_tmp_jvm_descriptor;
      end;

   stupid_switch_comment: STRING is "SSORRF6";

end -- RUN_FEATURE_6
