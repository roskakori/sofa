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
class RUN_FEATURE_2

inherit RUN_FEATURE;

creation make

feature

   base_feature: WRITABLE_ATTRIBUTE;

   result_type: TYPE;

   is_deferred: BOOLEAN is false;

   can_be_dropped: BOOLEAN is true;

   is_pre_computable: BOOLEAN is false;

   is_static: BOOLEAN is false;

   is_once_procedure: BOOLEAN is false;

   is_once_function: BOOLEAN is false;

   arguments: FORMAL_ARG_LIST is
      do
      end;

   require_assertion: RUN_REQUIRE is
      do
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

   ensure_assertion: E_ENSURE is
      do
      end;

   static_value_mem: INTEGER is
      do
      end;

   afd_check is
      local
         rc: RUN_CLASS;
      do
         rc := result_type.run_type.run_class;
      end;

   mapping_c is
      local
         ct: TYPE;
      do
         cpp.put_string("(/*RF2*/");
         ct := current_type;
         if ct.is_basic_eiffel_expanded then
            check
               as_item = name.to_string
            end;
            cpp.put_target_as_value;
         elseif ct.is_reference then
	    cpp.put_character('(');
	    cpp.put_target_as_target;
	    cpp.put_string(")->_");
	    cpp.put_string(name.to_string);
	    run_class.force_c_recompilation_comment(Current);
         else
            check
               ct.is_user_expanded;
            end;
            cpp.put_character('(');
            cpp.put_target_as_value;
            cpp.put_string(")._");
            cpp.put_string(name.to_string);
            run_class.force_c_recompilation_comment(Current);
         end;
         cpp.put_character(')');
      end;

   c_define is
      do
      end;

feature {ADDRESS_OF_POOL}

   address_of_c_define(caller: ADDRESS_OF) is
      do
      end;

feature {ADDRESS_OF}

   address_of_c_mapping is
      do
         cpp.put_string("&(");
         cpp.print_current;
         cpp.put_string("->_");
         cpp.put_string(name.to_string);
         cpp.put_character(')');
      end;

feature {CALL_PROC_CALL}

   collect_c_tmp is
      do
      end;

feature {NONE}

   initialize is
      do
         result_type := base_feature.result_type;
         result_type := result_type.to_runnable(current_type);
      end;

   compute_use_current is
      do
         use_current_state := ucs_true;
      end;

   compute_stupid_switch(r: ARRAY[RUN_CLASS]) is
      do
         if cpp.attribute_read_removal(Current,r) then
            stupid_switch_state := ucs_true;
         else
            stupid_switch_state := ucs_false;
         end;
      end;

feature {RUN_CLASS}

   jvm_field_or_method is
      do
         jvm.add_field(Current);
      end;

feature

   mapping_jvm is
      local
         idx: INTEGER;
         stack_level: INTEGER;
      do
         jvm.push_target_as_target;
         if current_type.is_basic_eiffel_expanded then
            check
               as_item = name.to_string
            end;
         else
            stack_level := result_type.jvm_stack_space - 1;
            idx := constant_pool.idx_fieldref(Current);
            code_attribute.opcode_getfield(idx,stack_level);
         end;
      end;

feature {JVM}

   jvm_define is
      local
         name_idx, descriptor: INTEGER;
         cp: like constant_pool;
      do
         cp := constant_pool;
         name_idx := cp.idx_utf8(name.to_string);
         descriptor := cp.idx_utf8(jvm_descriptor);
         field_info.add(1,name_idx,descriptor);
      end;

feature {NONE}

   update_tmp_jvm_descriptor is
      local
         rt: TYPE;
      do
         rt := result_type.run_type;
         if rt.is_reference then
            tmp_jvm_descriptor.append(jvm_root_descriptor);
         else
            rt.jvm_descriptor_in(tmp_jvm_descriptor);
         end;
      end;

   stupid_switch_comment: STRING is "SSWARF2";

end -- RUN_FEATURE_2

