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
class RUN_FEATURE_1

inherit RUN_FEATURE;

creation make

feature

   base_feature: CST_ATT;

   value: EXPRESSION;

   result_type: TYPE;

   is_deferred: BOOLEAN is false;

   is_pre_computable: BOOLEAN is true;

   can_be_dropped: BOOLEAN is true;

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

   ensure_assertion: E_ENSURE is
      do
      end;

   rescue_compound: COMPOUND is
      do
      end;

   is_static: BOOLEAN is
      do
         Result := value.is_static;
      end;

   static_value_mem: INTEGER is
      do
         Result := value.static_value;
      end;

   afd_check is
      do
      end;

   mapping_c is
      local
         real_constant: REAL_CONSTANT;
      do
         if result_type.is_double then
            real_constant ?= value;
            check
               real_constant /= Void;
            end;
            cpp.put_string(real_constant.to_string);
         else
            value.compile_to_c;
         end;
      end;

   c_define is
      do
      end;

feature {ADDRESS_OF_POOL}

   address_of_c_define(caller: ADDRESS_OF) is
      do
         eh.add_position(caller.start_position);
         eh.add_position(start_position);
         fatal_error("Cannot access address of a constant (VZAA).");
      end;

feature {ADDRESS_OF}

   address_of_c_mapping is
      do
      end;

feature {CALL_PROC_CALL}

   collect_c_tmp is
      do
      end;

feature {RUN_FEATURE}

   compute_use_current is
      do
         use_current_state := ucs_false;
      end;

   jvm_field_or_method is
      do
      end;

feature

   mapping_jvm is
      local
         space: INTEGER;
      do
         jvm.drop_target;
         space := value.compile_to_jvm_into(result_type);
      end;

feature {JVM}

   jvm_define is
      do
      end;

feature {NONE}

   initialize is
      local
         i: INTEGER;
         bc: BASE_CLASS;
         original_name: FEATURE_NAME;
      do
         result_type := base_feature.result_type;
         result_type := result_type.to_runnable(current_type);
         bc := current_type.base_class;
         original_name := bc.original_name(base_feature.base_class,name);
         i := base_feature.names.index_of(original_name);
         check i > 0 end;
         value := base_feature.value(i);
         value := value.to_runnable(current_type);
      end;

   compute_stupid_switch(r: ARRAY[RUN_CLASS]) is
      do
         stupid_switch_state := ucs_true;
      end;

   update_tmp_jvm_descriptor is
      do
      end;

   stupid_switch_comment: STRING is "SSCARF1";

end -- RUN_FEATURE_1
