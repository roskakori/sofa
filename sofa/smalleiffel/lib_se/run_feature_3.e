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
class RUN_FEATURE_3

inherit RUN_FEATURE;

creation make

feature

   base_feature: PROCEDURE;

   arguments: FORMAL_ARG_LIST;

   require_assertion: RUN_REQUIRE;

   local_vars: LOCAL_VAR_LIST;

   routine_body: COMPOUND;

   rescue_compound: COMPOUND;

   ensure_assertion: E_ENSURE;

   is_deferred: BOOLEAN is false;

   is_static: BOOLEAN is false;

   static_value_mem: INTEGER is 0;

   can_be_dropped: BOOLEAN is false

   is_once_procedure: BOOLEAN is false;

   is_once_function: BOOLEAN is false;

   result_type: TYPE is
      do
      end;

   is_pre_computable: BOOLEAN is
      do
         if arguments = Void then
            if routine_body = Void then
               Result := true;
            else
               if local_vars = Void then
                  Result := routine_body.is_pre_computable;
               end;
            end;
         end;
      end;

   afd_check is
      do
         routine_afd_check;
      end;

   mapping_c is
      do
         if isa_in_line then
            if cpp.stack_not_full then
               in_line;
            else
               in_line_status := -1;
               small_eiffel.register_for_c_define(Current);
               mapping_c;
            end;
         else
            default_mapping_procedure;
         end;
      end;

   c_define is
      do
         if isa_in_line then
            cpp.incr_inlined_procedure_count;
         elseif c_define_done then
         else
            in_line_status := -2;
            if use_current then
               cpp.incr_procedure_count;
            else
               cpp.incr_real_procedure_count;
            end;
            define_prototype;
            c_define_opening;
            if routine_body /= Void then
               routine_body.compile_to_c;
            end;
            c_define_closing;
            cpp.put_string(fz_12);
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

feature {RUN_FEATURE_3}

   initialize is
      do
         arguments := base_feature.arguments;
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
      end;

   in_line_status: INTEGER;
         -- Possible values :
         --  Value 0 means not computed.
         --  Value -1 means not `isa_in_line' and `c_define' not yet done.
         --  Value -2 means not `isa_in_line' and `c_define' already done.
         --  Other possible values are :

   C_empty_or_null_body : INTEGER is 1;
   C_do_not_use_current : INTEGER is 2;
   C_attribute_writer   : INTEGER is 3;
   C_direct_call        : INTEGER is 4;
   C_dca                : INTEGER is 5;
   C_one_pc             : INTEGER is 6;

   in_line_status_not_computed: BOOLEAN is
      do
         Result := in_line_status = 0;
      end;

   c_define_done: BOOLEAN is
      require
         not isa_in_line
      do
         Result := in_line_status = -2;
      end;

   isa_in_line: BOOLEAN is
      do
         if run_control.boost then
            if in_line_status_not_computed then
               if rescue_compound /= Void then
                  in_line_status := -1;
               elseif as_copy = name.to_string then
                  in_line_status := -1;
               elseif empty_or_null_body then
                  in_line_status := C_empty_or_null_body;
               elseif do_not_use_current then
                  in_line_status := C_do_not_use_current;
               elseif attribute_writer then
                  in_line_status := C_attribute_writer;
               elseif direct_call then
                  in_line_status := C_direct_call;
                  -- *** SHOULD USE isa_dca_inline TOO ??
               elseif dca then
                  in_line_status := C_dca;
               elseif one_pc then
                  in_line_status := C_one_pc;
               else
                  in_line_status := -1;
               end;
            end;
            Result := in_line_status > 0;
         end;
      end;

   in_line is
      require
         isa_in_line;
      local
         flag: BOOLEAN;
         a: ASSIGNMENT;
         e: EXPRESSION;
         pc: PROC_CALL;
         rf: RUN_FEATURE;
         sfn: SIMPLE_FEATURE_NAME;
         rf2: RUN_FEATURE;
      do
         cpp.put_string("/*[IRF3.");
         cpp.put_integer(in_line_status);
         cpp.put_string(name.to_string);
         cpp.put_string(fz_close_c_comment);
         inspect
            in_line_status
         when C_empty_or_null_body then
            if cpp.cannot_drop_all then
               cpp.put_string(fz_14);
            end;
            if need_local_vars then
               cpp.put_character('{');
               c_define_opening;
               c_define_closing;
               cpp.put_character('}');
            end;
         when C_do_not_use_current then
            if cpp.target_cannot_be_dropped then
               cpp.put_string(fz_14);
            end;
            flag := need_local_vars;
            if flag then
               cpp.put_character('{');
               c_define_opening;
            end;
            routine_body.compile_to_c;
            if flag then
               c_define_closing;
               cpp.put_character('}');
            end;
         when C_attribute_writer then
            flag := need_local_vars;
            if flag then
               cpp.put_character('{');
               c_define_opening;
            end;
            a ?= routine_body.first;
            sfn ?= a.left_side;
            cpp.put_string("(((");
            current_type.mapping_cast;
            cpp.put_character('(');
            cpp.put_target_as_target;
            cpp.put_string(")))->_");
            rf2 := sfn.run_feature_2;
            cpp.put_string(rf2.name.to_string);
            cpp.put_string(")=(");
            e := a.right_side;
            if arguments = Void then
               e.compile_to_c;
            else
               cpp.put_arguments;
            end;
            cpp.put_string(");%N");
            if flag then
               c_define_closing;
               cpp.put_character('}');
            end;
         when C_direct_call then
            flag := need_local_vars;
            if flag then
               cpp.put_character('{');
               c_define_opening;
            end;
            pc ?= routine_body.first;
            rf := pc.run_feature;
            cpp.push_same_target(rf,pc.arguments);
            rf.mapping_c;
            cpp.pop;
            if flag then
               c_define_closing;
               cpp.put_character('}');
            end;
         when C_dca then
            pc ?= routine_body.first;
            pc.finalize;
            cpp.push_inline_dca(Current,pc);
            pc.run_feature.mapping_c;
            cpp.pop;
         when C_one_pc then
            if not use_current then
               if cpp.target_cannot_be_dropped then
                  cpp.put_string(fz_14);
               end;
            end;
            cpp.put_character('{');
            if use_current then
               tmp_string.clear;
               current_type.c_type_for_target_in(tmp_string);
               tmp_string.extend(' ');
               cpp.put_string(tmp_string);
               cpp.inline_level_incr;
               cpp.print_current;
               cpp.inline_level_decr;
               cpp.put_character('=');
               cpp.put_target_as_target;
               cpp.put_string(fz_00);
            end;
            if arguments /= Void then
               arguments.inline_one_pc;
            end;
            if need_local_vars then
               local_vars.inline_one_pc;
               cpp.inline_level_incr;
               local_vars.initialize_expanded;
               cpp.inline_level_decr;
            end;
            cpp.push_inline_one_pc;
            cpp.inline_level_incr;
            routine_body.compile_to_c;
            cpp.inline_level_decr;
            cpp.pop;
            cpp.put_character('}');
         end;
         cpp.put_string("/*]*/%N");
      end;

   compute_use_current is
      local
         ct: like current_type;
      do
         ct := current_type;
         if ct.is_reference then
            if run_control.no_check then
               use_current_state := ucs_true;
            else
               std_compute_use_current;
            end;
         else
            std_compute_use_current;
         end;
      end;

   empty_or_null_body: BOOLEAN is
         -- The body is empty or has only unreacheable code.
      local
         rb: COMPOUND;
      do
         rb := routine_body;
         Result := (rb = Void or else rb.empty_or_null_body);
      end;

   do_not_use_current: BOOLEAN is
      do
         if not routine_body.use_current then
            Result := arguments = Void;
         end;
      end;

   attribute_writer: BOOLEAN is
         -- True when body as only one instruction is of
         -- the form :
         --            feature_name := <expression>;
         -- And when <expression> is an argument or a statically
         -- computable value.
      local
         rb: like routine_body;
         a: ASSIGNMENT;
         args: like arguments;
         an2: ARGUMENT_NAME2;
         sfn: SIMPLE_FEATURE_NAME;
      do
         rb := routine_body;
         args := arguments;
         if rb /= Void and then rb.count = 1 then
            a ?= rb.first;
            if a /= Void then
               sfn ?= a.left_side;
               if sfn /= Void then
                  if args = Void then
                     Result := not a.right_side.use_current;
                  elseif args.count = 1 then
                     an2 ?= a.right_side;
                     Result := an2 /= Void;
                  end;
               end;
            end;
         end;
      end;

   direct_call: BOOLEAN is
         -- True when the procedure has no arguments, no locals,
         -- and when the body has only one instruction of the
         -- form : foo(<args>);
         -- Where <args> can be an empty list or a statically
         -- computable one and where `foo' is a RUN_FEATURE_3.
      local
         rb: like routine_body;
         pc: PROC_CALL;
         args: EFFECTIVE_ARG_LIST;
         rf3: RUN_FEATURE_3;
      do
         rb := routine_body;
         if rb /= Void and then
            rb.count = 1 and then
            arguments = Void and then
            local_vars = Void
          then
            pc ?= rb.first;
            if pc /= Void then
               if pc.target.is_current then
                  rf3 ?= pc.run_feature;
                  if rf3 /= Void then
                     args := pc.arguments;
                     if args = Void then
                        Result := true;
                     else
                        Result := args.is_static;
                     end;
                  end;
               end;
            end;
         end;
      end;

   dca: BOOLEAN is
      local
         pc: PROC_CALL;
         rf: RUN_FEATURE;
         args: EFFECTIVE_ARG_LIST;
      do
         pc := body_one_dpca;
         if pc /= Void and then local_vars = Void then
            rf := pc.run_feature;
            if rf /= Current then
               if rf.current_type.is_user_expanded then
                  -- Not yet inlined :-(
               else
                  args := pc.arguments;
                  if args = Void then
                     Result := arguments = Void;
                  else
                     Result := args.isa_dca_inline(Current,rf);
                  end;
               end;
            end;
         end;
      end;

   one_pc: BOOLEAN is
      local
         rb: like routine_body;
         pc: PROC_CALL;
         rf: RUN_FEATURE;
         r: ARRAY[RUN_CLASS];
      do
         rb := routine_body;
         if rb /= Void and then rb.count = 1 then
            pc ?= rb.first;
            if pc /= Void then
               rf := pc.run_feature;
               if rf /= Void and then rf /= Current then
                  r := rf.run_class.running;
                  if r /= Void and then r.count = 1 then
                     Result := true;
                  end;
               end;
            end;
         end;
      end;

   body_one_dpca: PROC_CALL is
         -- Gives Void or the only one direct PROC_CALL on
         -- an attribute of Current target.
      local
         rb: like routine_body;
         pc: PROC_CALL;
         c0c: CALL_0_C;
         rf2: RUN_FEATURE_2;
         r: ARRAY[RUN_CLASS];
      do
         if local_vars = Void then
            rb := routine_body;
            if rb /= Void and then rb.count = 1 then
               pc ?= rb.first;
               if pc /= Void then
                  c0c ?= pc.target;
                  if c0c /= Void and then c0c.target.is_current then
                     rf2 ?= c0c.run_feature;
                     if rf2 /= Void then
                        r := rf2.run_class.running;
                        if r /= Void and then r.count = 1 then
                           r := pc.run_feature.run_class.running;
                           if r /= Void and then r.count = 1 then
                              Result := pc;
                           end;
                        end;
                     end;
                  end;
               end;
            end;
         end;
      end;

   need_local_vars: BOOLEAN is
      do
         if local_vars /= Void then
            Result := local_vars.produce_c;
         end;
      end;

   tmp_string: STRING is
      once
         !!Result.make(32);
      end;

   update_tmp_jvm_descriptor is
      do
         routine_update_tmp_jvm_descriptor;
      end;

feature {RUN_CLASS}

   memory_dispose: like Current is
         -- Squeeze dummy empty `dispose' and set the appropriate
         -- `in_line_status' (no inlining).
      do
         if not is_empty_or_null_body then
            Result := Current;
            in_line_status := -1;
         end;
      end;

   jvm_field_or_method is
      do
         jvm.add_method(Current);
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
         code_attribute.opcode_return;
         method_info.finish;
      end;

feature {ADDRESS_OF_POOL}

   address_of_c_define(caller: ADDRESS_OF) is
      do
         if run_control.boost then
            if isa_in_line then
               address_of_c_define_wrapper(caller);
            elseif use_current then
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
            if isa_in_line then
               address_of_c_mapping_wrapper;
            elseif use_current then
               mapping_name;
            else
               address_of_c_mapping_wrapper;
            end;
         else
            address_of_c_mapping_wrapper;
         end;
      end;

feature {PROCEDURE}

   is_empty_or_null_body: BOOLEAN is
      do
         if isa_in_line then
            Result := in_line_status = C_empty_or_null_body;
         end;
      end;

   is_attribute_writer: RUN_FEATURE_2 is
      -- If true, gives the corresponding attribute.
      local
         a: ASSIGNMENT;
         sfn: SIMPLE_FEATURE_NAME;
      do
         if isa_in_line then
            if in_line_status = C_attribute_writer then
               a ?= routine_body.first;
               sfn ?= a.left_side;
               Result := sfn.run_feature_2;
            end;
         end;
      end;

feature {NONE}

   compute_stupid_switch(r: ARRAY[RUN_CLASS]) is
      do
         std_compute_stupid_switch(r);
      end;

   stupid_switch_comment: STRING is "SSPRF3";

end -- RUN_FEATURE_3

