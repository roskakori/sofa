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
class SIMPLE_FEATURE_NAME
   --
   -- Is used for simple (not infix or prefix) names of feature in the
   -- declaration part of a feature but is also used when writing an
   -- attribute as a left hand side of an assignment.
   --

inherit FEATURE_NAME; EXPRESSION;

creation make, unknown_position, with

feature

   start_position: POSITION;

   to_string: STRING;

   run_feature_2: RUN_FEATURE_2;
         -- The corresponding one when runnable.

   is_frozen: BOOLEAN is false;

   is_current: BOOLEAN is false;

   is_writable: BOOLEAN is true;

   use_current: BOOLEAN is true;

   to_integer_or_error: INTEGER is
      do
	 to_integer_error;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      local
         rf2: RUN_FEATURE_2;
      do
         rf2 := run_feature_2;
         if rf2 /= Void then
            if small_eiffel.same_base_feature(rf2,r) then
               Result := rf2.stupid_switch(r) /= Void;
            end;
         end;
      end;
   
   is_pre_computable: BOOLEAN is false;

   isa_dca_inline_argument: INTEGER is 0;

   is_static: BOOLEAN is false;

   static_result_base_class: BASE_CLASS is    
      local
         bc: BASE_CLASS;
         e_feature: E_FEATURE;
         rt: TYPE;
         cn: CLASS_NAME;
      do
         bc := start_position.base_class;
         if bc /= Void then
            e_feature := bc.e_feature(Current);
            if e_feature /= Void then
               rt := e_feature.result_type;
               if rt /= Void then
                  cn := rt.static_base_class_name;
                  if cn /= Void then
                     Result := cn.base_class;
                  end;
               end;
            end;
         end;
      end;

   static_value: INTEGER is
      do
      end;

   to_key: STRING is
      do
         Result := to_string;
      end;

   result_type: TYPE is
      do
         Result := run_feature_2.result_type;
      end;

   can_be_dropped: BOOLEAN is
      do
         eh.add_position(start_position);
         fatal_error("FEATURE_NAME/Should never be called.");
      end;

   to_runnable(ct: TYPE): like Current is
      local
         wbc: BASE_CLASS;
         rf: RUN_FEATURE;
         new_name:  FEATURE_NAME;
         rf2: RUN_FEATURE_2;
      do
         wbc := start_position.base_class;
         new_name := ct.base_class.new_name_of(wbc,Current);
         rf := ct.run_class.get_feature(new_name);
         if rf = Void then
            eh.add_feature_name(new_name);
            fatal_error(fz_feature_not_found);
         else
            rf2 ?= rf;
            if rf2 = Void then
               eh.add_position(rf.start_position);
               eh.add_position(start_position);
	       eh.append("Feature found is not writable.");
	       eh.print_as_fatal_error;
            end;
         end;
         if run_feature_2 = Void then
            run_feature_2 := rf2;
            Result := Current;
         elseif run_feature_2 = rf then
            Result := Current;
         else
            !!Result.with(Current,rf2);
         end;
      end;

   precedence: INTEGER is
      do
         Result := atomic_precedence;
      end;

   assertion_check(tag: CHARACTER) is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   mapping_c_target(target_type: TYPE) is
      local
         flag: BOOLEAN;
      do
         flag := cpp.call_invariant_start(target_type);
         compile_to_c;
         if flag then
            cpp.call_invariant_end;
         end;
      end;

   mapping_c_arg(formal_arg_type: TYPE) is
      do
         compile_to_c;
      end;

   collect_c_tmp is
      do
      end;

   compile_to_c is
      do
         cpp.put_string("(/*SFN*/C->_");
         cpp.put_string(run_feature_2.name.to_string);
         cpp.put_character(')');
      end;

   c_declare_for_old is
      do
      end;

   compile_to_c_old is
      do
      end;

   compile_to_jvm_old is
      do
      end;

   print_as_target is
      do
         fmt.put_string(to_string);
         fmt.put_character('.');
      end;

   mapping_c_in(str: STRING) is
      do
         str.append(to_string);
      end;

   declaration_in(str: STRING) is
      do
         str.append(to_string);
      end;

   pretty_print, declaration_pretty_print is
      do
         fmt.put_string(to_string);
      end;

   short is
      local
         i: INTEGER;
         c: CHARACTER;
      do
         short_print.hook("Bsfn");
         from
            i := 1;
         until
            i > to_string.count
         loop
            c := to_string.item(i);
            if c = '_' then
               short_print.hook_or("Usfn","_");
            else
               short_print.a_character(c);
            end;
            i := i + 1;
         end;
         short_print.hook("Asfn");
      end;

   short_target is
      do
         short;
         short_print.a_dot;
      end;

   compile_target_to_jvm, compile_to_jvm is
      do
         eh.add_position(start_position);
         fatal_error(fz_jvm_error);
      end;

   jvm_branch_if_false: INTEGER is
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifeq;
      end;

   jvm_branch_if_true: INTEGER is
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifne;
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := standard_compile_to_jvm_into(dest);
      end;

   jvm_assign is
      local
         space, idx: INTEGER;
         rf2: like run_feature_2;
         ca: like code_attribute;
      do
         rf2 := run_feature_2;
         ca := code_attribute;
         space := rf2.result_type.jvm_stack_space;
         ca.opcode_aload_0;
         if space = 1 then
            ca.opcode_swap;
         else
            ca.opcode_dup_x2;
            ca.opcode_pop;
         end;
         idx := constant_pool.idx_fieldref(rf2);
         ca.opcode_putfield(idx,-(space + 1));
      end;

feature {RUN_CLASS}

   set_run_feature_2(rf2: RUN_FEATURE_2) is
      require
	 rf2 /= Void
      do
	 run_feature_2 := rf2;
      ensure
	 run_feature_2 = rf2
      end;

feature {TYPE_BIT_2}

   run_feature(t: TYPE): RUN_FEATURE is
         -- Look for the corresponding runnable feature in `t';
      require
         t.is_run_type
      do
         Result := t.run_class.get_rf_with(Current);
      end;


feature {BASE_CLASS}

   make(n: STRING; sp: like start_position) is
      require
         n.count >= 1;
         n = string_aliaser.item(n)
      do
         to_string := n;
         start_position := sp;
      ensure
         to_string = n;
         start_position = sp
      end;

feature {NONE}

   unknown_position(n: STRING) is
      require
         n.count >= 1;
         n = string_aliaser.item(n)
      do
         to_string := n;
      ensure
         to_string = n
      end;

feature {RUN_FEATURE,FEATURE_NAME}

   put_cpp_tag is
      do
      end;

feature {NONE}

   with(model: like Current; rf2: RUN_FEATURE_2) is
      require
         model /= Void;
         rf2 /= Void
      do
         to_string := model.to_string;
         start_position := model.start_position;
         run_feature_2 := rf2;
      ensure
         to_string = model.to_string;
         start_position = model.start_position;
         run_feature_2 = rf2
      end;

end -- SIMPLE_FEATURE_NAME

