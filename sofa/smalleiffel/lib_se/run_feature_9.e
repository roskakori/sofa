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
class RUN_FEATURE_9

inherit RUN_FEATURE;

creation make

feature

   base_feature: DEFERRED_ROUTINE;

   arguments: FORMAL_ARG_LIST;

   result_type: TYPE;

   require_assertion: RUN_REQUIRE;

   ensure_assertion: E_ENSURE;

   is_deferred: BOOLEAN is true;

   is_pre_computable: BOOLEAN is false;

   is_static: BOOLEAN is false;

   can_be_dropped: BOOLEAN is false;

   is_once_procedure: BOOLEAN is false;

   is_once_function: BOOLEAN is false;

   routine_body: COMPOUND is
      do
      end;

   rescue_compound: COMPOUND is
      do
      end;

   afd_check is
      do
         routine_afd_check;
         small_eiffel.afd_check_deferred(Current);
      end;

   mapping_c is
      do
         if run_control.no_check then
            if result_type = Void then
               default_mapping_procedure;
            else
               default_mapping_function;
            end;
         elseif result_type /= Void then
            result_type.c_initialize;
         end;
      end;

   c_define is
      do
         if run_control.no_check then
            define_prototype;
            c_define_opening;
            cpp.put_error0("Deferred routine called.");
            c_define_closing;
            cpp.put_string(fz_12);
            c_frame_descriptor;
         end;
      end;

   local_vars: LOCAL_VAR_LIST is do end;

   static_value_mem: INTEGER is do end;

feature {CALL_PROC_CALL}

   collect_c_tmp is
      local
         rt: TYPE;
      do
         rt := result_type;
         if rt /= Void and then rt.is_user_expanded then
            if rt.is_dummy_expanded then
            else
               cpp.se_tmp_add(Current);
            end;
         end;
      end;

feature {ADDRESS_OF_POOL}

   address_of_c_define(caller: ADDRESS_OF) is
      do
         eh.add_position(caller.start_position);
         eh.add_position(start_position);
         fatal_error("Cannot access address of a deferred routine.");
      end;

feature {ADDRESS_OF}

   address_of_c_mapping is
      do
      end;

feature {NONE}

   initialize is
      do
         result_type := base_feature.result_type;
         arguments := base_feature.arguments;
         if result_type /= Void then
            if result_type.is_like_argument then
               if not arguments.is_runnable(current_type) then
                  !!arguments.with(arguments,current_type);
               end;
               result_type := result_type.to_runnable(current_type);
            else
               result_type := result_type.to_runnable(current_type);
               if arguments /= Void then
                  if not arguments.is_runnable(current_type) then
                     !!arguments.with(arguments,current_type);
                  end;
               end;
            end;
         elseif arguments /= Void then
            if not arguments.is_runnable(current_type) then
               !!arguments.with(arguments,current_type);
            end;
         end;
         if small_eiffel.short_flag then
            require_assertion := run_require;
            ensure_assertion := run_ensure;
         end;
      end;

   compute_use_current is
      do
         use_current_state := ucs_true;
      end;

feature {RUN_CLASS}

   jvm_field_or_method is
      do
      end;

feature

   mapping_jvm is
      do
      end;

feature {JVM}

   jvm_define is
      do
      end;

feature {NONE}

   compute_stupid_switch(r: ARRAY[RUN_CLASS]) is
      do
         stupid_switch_state := ucs_false;
      end;

   update_tmp_jvm_descriptor is
      do
         routine_update_tmp_jvm_descriptor;
      end;

   stupid_switch_comment: STRING is "SSDRRF9";

end -- RUN_FEATURE_9
