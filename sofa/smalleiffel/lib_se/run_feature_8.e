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
class RUN_FEATURE_8

inherit RUN_FEATURE;

creation make

feature

   base_feature: EXTERNAL_FUNCTION;

   static_value_mem: INTEGER;

   arguments: FORMAL_ARG_LIST;

   result_type: TYPE;

   require_assertion: RUN_REQUIRE;

   ensure_assertion: E_ENSURE;

   is_deferred: BOOLEAN is false;

   is_pre_computable: BOOLEAN is false;

   can_be_dropped: BOOLEAN is false;

   is_once_procedure: BOOLEAN is false;

   is_once_function: BOOLEAN is false;

   arg_count: INTEGER is
      do
         if arguments /= Void then
            Result := arguments.count;
         end;
      end;

   local_vars: LOCAL_VAR_LIST is
      do
      end;

   routine_body: COMPOUND is
      do
      end;

   rescue_compound: COMPOUND is
      do
      end;

   afd_check is
      do
         routine_afd_check;
      end;

   is_static: BOOLEAN is
      local
         n: STRING;
         type_bit: TYPE_BIT;
      do
         n := name.to_string;
         if as_is_expanded_type = n then
            Result := true;
            if current_type.is_expanded then
               static_value_mem := 1;
            end;
         elseif as_is_basic_expanded_type = n then
            Result := true;
            if current_type.is_basic_eiffel_expanded then
               static_value_mem := 1;
            end;
         elseif as_count = n and then current_type.is_bit then
            Result := true;
            type_bit ?= current_type;
            static_value_mem := type_bit.nb;
         end;
      end;

   mapping_c is
      local
         bf: like base_feature;
         native: NATIVE;
         bcn: STRING;
      do
         bf := base_feature;
         native := bf.native;
         bcn := bf.base_class.name.to_string;
         native.c_mapping_function(Current,bcn,bf.first_name.to_string);
      end;

   c_define is
      local
         bf: like base_feature;
         native: NATIVE;
         bcn: STRING;
      do
         bf := base_feature;
         native := bf.native;
         bcn := bf.base_class.name.to_string;
         native.c_define_function(Current,bcn,bf.first_name.to_string);
      end;

   mapping_jvm is
      local
         bf: like base_feature;
         native: NATIVE;
         bcn: STRING;
      do
         bf := base_feature;
         native := bf.native;
         bcn := bf.base_class.name.to_string;
         native.jvm_mapping_function(Current,bcn,bf.first_name.to_string);
      end;

feature {TYPE_BIT_2}

   integer_value(p: POSITION): INTEGER is
      local
         n: STRING;
      do
         n := name.to_string;
         if as_integer_bits = n then
            Result := Integer_bits;
         elseif as_character_bits = n then
            Result := Character_bits;
         else
            eh.add_position(p);
            eh.add_position(start_position);
            fatal_error(fz_iinaiv);
         end;
      end;

feature {RUN_CLASS}

   jvm_field_or_method is
      local
         bf: like base_feature;
         native: NATIVE;
         n, bcn: STRING;
         type_bit_ref: TYPE_BIT_REF;
      do
         bf := base_feature;
         n := bf.first_name.to_string;
         type_bit_ref ?= current_type;
         if type_bit_ref /= Void and then as_item = n then
            jvm.add_field(Current);
         else
            native := base_feature.native;
            bcn := bf.base_class.name.to_string;
            native.jvm_add_method_for_function(Current,bcn,n);
         end;
      end;

feature {JVM}

   jvm_define is
      local
         bf: like base_feature;
         native: NATIVE;
         n, bcn: STRING;
         type_bit_ref: TYPE_BIT_REF;
         cp: like constant_pool;
      do
         bf := base_feature;
         n := bf.first_name.to_string;
         type_bit_ref ?= current_type;
         if type_bit_ref /= Void and then as_item = n then
            cp := constant_pool;
            field_info.add(1,cp.idx_utf8(n),cp.idx_utf8(fz_a9));
         else
            native := bf.native;
            bcn := bf.base_class.name.to_string;
            native.jvm_define_function(Current,bcn,n);
         end;
      end;

feature {NATIVE}

   c_prototype is
      do
         external_prototype(base_feature);
      end;

feature {NATIVE_SMALL_EIFFEL}

   c_opening is
      do
         define_prototype;
         c_define_opening;
      end;

   c_closing is
      do
         c_define_closing;
         cpp.put_string(fz_15);
         c_frame_descriptor;
      end;

feature {NATIVE}

   jvm_opening is
      do
         method_info_start;
         jvm_define_opening;
      end;

   jvm_closing is
      do
         jvm_define_closing;
         result_type.jvm_push_local(jvm_result_offset);
         result_type.run_type.jvm_return_code;
         method_info.finish;
      end;

   jvm_closing_fast is
         -- Skip ensure and assume the result is already pushed.
      do
         result_type.run_type.jvm_return_code;
         method_info.finish;
      end;

feature {CALL_PROC_CALL}

   collect_c_tmp is
      do
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

   tmp_string: STRING is
      once
         !!Result.make(80);
      end;

   initialize is
      local
         n: STRING;
         rf: RUN_FEATURE;
         type_bit_ref: TYPE_BIT_REF;
      do
         n := base_feature.first_name.to_string;
         arguments := base_feature.arguments;
         type_bit_ref ?= current_type;
         if type_bit_ref /= Void and then as_item = n then
            result_type := type_bit_ref.type_bit;
            if arguments /= Void then
               if not arguments.is_runnable(current_type) then
                  !!arguments.with(arguments,current_type);
               end;
            end;
         else
            result_type := base_feature.result_type;
            if arguments = Void then
               result_type := result_type.to_runnable(current_type);
            elseif result_type.is_like_argument then
               if not arguments.is_runnable(current_type) then
                  !!arguments.with(arguments,current_type);
               end;
               result_type := result_type.to_runnable(current_type);
            else
               result_type := result_type.to_runnable(current_type);
               if not arguments.is_runnable(current_type) then
                  !!arguments.with(arguments,current_type);
               end;
            end;
         end;
         if run_control.require_check then
            require_assertion := run_require;
         end;
         if run_control.ensure_check then
            ensure_assertion := run_ensure;
         end;
         if as_twin = n then
            rf := run_class.get_copy;
         elseif as_se_argc = n then
            type_string.set_at_run_time;
         elseif as_generating_type = n then
            run_control.set_generator_used;
            run_control.set_generating_type_used;
         elseif as_generator = n then
            run_control.set_generator_used;
         elseif as_deep_twin = n then
            run_control.set_deep_twin_used;
	    rf := type_any.run_class.get_feature_with(as_deep_clone);
         elseif as_is_deep_equal = n then
            run_control.set_is_deep_equal_used;
         elseif as_exception = n then
            exceptions_handler.set_used;
         elseif as_signal_number = n then
            exceptions_handler.set_used;
         elseif n.has_prefix(fz_basic_) then
            small_eiffel.register_sys_runtime_basic_of(n);
         end;
      end;

   compute_use_current is
      do
         if base_feature.use_current then
            use_current_state := ucs_true;
         else
            std_compute_use_current;
         end;
      end;

   compute_stupid_switch(r: ARRAY[RUN_CLASS]) is
      do
         if base_feature.native.stupid_switch_function(r,name.to_string) then
            stupid_switch_state := ucs_true;
         else
            stupid_switch_state := ucs_false;
         end;
      end;

   update_tmp_jvm_descriptor is
      do
         routine_update_tmp_jvm_descriptor;
      end;

   stupid_switch_comment: STRING is "SSERRF8";

end -- RUN_FEATURE_8
