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
deferred class CALL_INFIX2
   --
   -- Root for CALL_INFIX_EQ and CALL_INFIX_NEQ.
   --

inherit CALL_INFIX redefine static_result_base_class, use_current end;

feature

   precedence: INTEGER is 6;

   left_brackets: BOOLEAN is false;

feature {NONE}

   frozen make(lp: like target; operator_position: POSITION; rp: like arg1) is
      require
         lp /= Void;
         not operator_position.is_unknown;
         rp /= Void
      do
         target := lp;
         !!feature_name.make(operator,operator_position);
         !!arguments.make_1(rp);
      ensure
         target = lp;
         start_position = operator_position;
         arguments.first = rp
      end;

   frozen with(t: like target; fn: like feature_name; a: like arguments) is
      require
         t /= Void;
         fn /= Void;
         a.count = 1
      do
         target := t;
         feature_name := fn;
         arguments := a;
      ensure
         target = t;
         feature_name = fn;
         arguments = a
      end;

feature

   frozen static_result_base_class: BASE_CLASS is
      do
         Result := small_eiffel.get_class(as_boolean);
      end;

   frozen run_feature: RUN_FEATURE is
      do
      end;

   frozen result_type: TYPE is
      do
         Result := type_boolean;
      end;

   frozen to_runnable(ct: TYPE): like Current is
      require
         ct /= Void
      local
         t: like target;
         a: like arguments;
      do
         t := runnable_expression(target,ct);
         a := runnable_args(arguments,ct);
         if t = target and then a = arguments then
            Result := Current;
         else
            !!Result.with(t,feature_name,a);
         end;
         Result.check_comparison(ct);
      end;

   frozen assertion_check(tag: CHARACTER) is
      do
         target.assertion_check(tag);
         arg1.assertion_check(tag);
      end;

   frozen use_current: BOOLEAN is
      do
         Result := target.use_current or else arg1.use_current;
      end;

   frozen isa_dca_inline_argument: INTEGER is
      do
      end;

   frozen dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

feature {RUN_FEATURE_4}

   frozen dca_inline(formal_arg_type: TYPE) is
      do
         cpp.put_character('(');
         cpp.put_target_as_value;
         cpp.put_character(')');
         if operator.first = '=' then
            cpp.put_string(fz_c_eq);
         else
            cpp.put_string(fz_c_neq);
         end;
         cpp.put_character('(');
         arg1.dca_inline_argument(formal_arg_type);
         cpp.put_character(')');
      end;

feature {RUN_FEATURE_3,RUN_FEATURE_4}

   finalize is
      do
      end;

feature {CALL_INFIX2}

   frozen check_comparison(ct: TYPE) is
      local
         tt, at: TYPE;
      do
         if nb_errors = 0 then
            tt := target.result_type.run_type;
            at := arg1.result_type.run_type;
            if tt.is_none then
            elseif at.is_none then
            elseif tt.is_reference then
               if at.is_reference then
               elseif not at.is_a(tt) then
                  error_comparison("Reference/Expanded",ct);
               end;
            else
               if at.is_expanded then
                  if at.is_basic_eiffel_expanded then
                     if tt.is_a(at) then
                     else
                        eh.cancel;
                        if at.is_a(tt) then
                        else
                           error_comparison("Expanded/Expanded",ct);
                        end;
                     end;
                  elseif tt.is_bit then
                     bit_limitation(tt,at);
                  elseif not at.is_a(tt) then
                     error_comparison("Expanded/Expanded",ct);
                  end;
               elseif not tt.is_a(at) then
                  error_comparison("Expanded/Reference",ct);
               end;
            end;
         end;
-- *** May be useful ??
-- ***   if nb_errors = 0 then
-- ***      if target.is_void then 
-- ***         void_with_expanded_comparison_warning(arg1);
-- ***      elseif arg1.is_void then
-- ***         void_with_expanded_comparison_warning(target);
-- ***      end;
-- ***   end;
      end;

feature {NONE}

   error_comparison(str: STRING; ct: TYPE) is
      do
         eh.add_position(feature_name.start_position);
         eh.append(" Comparison ");
         eh.append(str);
         eh.append(" Not Valid. Context of Types interpretation is ");
         eh.add_type(ct,fz_dot);
         eh.print_as_fatal_error;
      end;

   void_with_expanded_comparison_warning(e: EXPRESSION) is
      local
         rt: TYPE;
         do_warning: BOOLEAN;
      do
         rt := e.result_type;
         if rt.is_expanded then
            do_warning := true;
            if do_warning then
               eh.append("Strange comparison of an expanded with Void %
                         %(an expanded type is never Void).");
               eh.add_position(e.start_position);
               eh.print_as_warning;
            end;
         end;
      end;

   bit_limitation(t1, t2: TYPE) is
      require
         t1.is_bit;
         t2.is_bit
      local
         b1, b2: TYPE_BIT;
      do
         b1 ?= t1;
         b2 ?= t2;
         if b1.nb /= b2.nb then
            eh.add_position(feature_name.start_position);
            eh.append("Comparison between ");
            eh.add_type(b1," and ");
            eh.add_type(b2,
            " is not yet implemented (you can work arround doing an %
            %assignment in a local variable).");
            eh.print_as_fatal_error;
         end;
      end;

feature {NONE}

   cmp_bit(equal_test: BOOLEAN; t: TYPE) is
      require
         t.is_bit
      local
         tb: TYPE_BIT;
      do
         tb ?= t;
         if tb.is_c_unsigned_ptr then
            if equal_test then
               cpp.put_character('!');
            end;
            cpp.put_string("memcmp((");
            target.mapping_c_target(t);
            cpp.put_string(fz_20);
            arg1.mapping_c_target(t);
            cpp.put_string("),sizeof(T");
            cpp.put_integer(tb.id);
            cpp.put_string("))");
         else
            cpp.put_character('(');
            target.compile_to_c;
            cpp.put_character(')');
            if equal_test then
               cpp.put_string(fz_c_eq);
            else
               cpp.put_string(fz_c_neq);
            end;
            cpp.put_character('(');
            arg1.compile_to_c;
            cpp.put_character(')');
         end;
      end;

   cmp_user_expanded(equal_test: BOOLEAN; t: TYPE) is
      require
         t.is_user_expanded
      local
         mem_id: INTEGER;
      do
         if t.is_dummy_expanded then
            cpp.put_character('(');
            target.compile_to_c;
            cpp.put_character(',');
            arg1.compile_to_c;
            cpp.put_character(',');
            if equal_test then
               cpp.put_character('1');
            else
               cpp.put_character('0');
            end;
            cpp.put_character(')');
         else
            mem_id := t.id;
            if equal_test then
               cpp.put_character('!');
            end;
            cpp.put_string(fz_se_cmpt);
            cpp.put_integer(mem_id);
            cpp.put_string(fz_17);
            target.compile_to_c;
            cpp.put_string(fz_20);
            arg1.compile_to_c;
            cpp.put_string(fz_13);
         end;
      end;

   cmp_basic_eiffel_expanded(equal_test: BOOLEAN; t1, t2: TYPE) is
      require
         t1.is_basic_eiffel_expanded;
         t2.is_basic_eiffel_expanded
      local
         cast: STRING;
      do
	 if t1.is_double or else t2.is_double then
	    cast := "((T5)(";
	 elseif t1.is_real or else t1.is_real then
	    cast := "((T4)(";
	 end;
         if cast /= Void then
            cpp.put_string(cast);
         end;
         cpp.put_character('(');
         target.compile_to_c;
         if cast /= Void then
            cpp.put_string(fz_13);
         end;
         cpp.put_character(')');
         if equal_test then
            cpp.put_string(fz_c_eq);
         else
            cpp.put_string(fz_c_neq);
         end;
         cpp.put_character('(');
         if cast /= Void then
            cpp.put_string(cast);
         end;
         arg1.compile_to_c;
         cpp.put_character(')');
         if cast /= Void then
            cpp.put_string(fz_13);
         end;
      end;

   cmp_basic_ref(equal_test: BOOLEAN) is
         -- *** ORIGINAL ***
      do
         cpp.put_character('(');
         target.compile_to_c;
         cpp.put_character(')');
         if equal_test then
            cpp.put_string(fz_c_eq);
         else
            cpp.put_string(fz_c_neq);
         end;
         cpp.put_character('(');
         cpp.put_string(fz_cast_void_star);
         cpp.put_character('(');
         arg1.compile_to_c;
         cpp.put_character(')');
         cpp.put_character(')');
      end;

   ecoop99_1_cmp_basic_ref(equal_test: BOOLEAN) is
         -- *** `cmp_basic_ref' for ECOOP'99 benchmark ***
         -- *** With aliasing ***
      local
         string_cmp: BOOLEAN;
      do
         if target.result_type.run_type.is_string then
            if arg1.result_type.run_type.is_string then
               string_cmp := false;
            end;
         end;
         if string_cmp then
            if not equal_test then
               cpp.put_string("(!(");
            end;
            cpp.put_string("/*ECOOP*/r7is_equal(((T7*)(");
            target.compile_to_c;
            cpp.put_string(")),((T0*)(");
            arg1.compile_to_c;
            cpp.put_string(")))");
            if not equal_test then
               cpp.put_string("))");
            end;
         else
            cpp.put_character('(');
            target.compile_to_c;
            cpp.put_character(')');
            if equal_test then
               cpp.put_string(fz_c_eq);
            else
               cpp.put_string(fz_c_neq);
            end;
            cpp.put_character('(');
            cpp.put_string(fz_cast_void_star);
            cpp.put_character('(');
            arg1.compile_to_c;
            cpp.put_character(')');
            cpp.put_character(')');
         end;
      end;

   ecoop99_2_cmp_basic_ref(equal_test: BOOLEAN) is
         -- *** `cmp_basic_ref' for ECOOP'99 benchmark ***
         -- *** Without aliasing ***
      local
         string_cmp: BOOLEAN;
      do
         if target.result_type.run_type.is_string then
            if arg1.result_type.run_type.is_string then
               string_cmp := true;
            end;
         end;
         if string_cmp then
            if not equal_test then
               cpp.put_string("(!(");
            end;
            cpp.put_string("/*ECOOP*/r7is_equal(((T7*)(");
            target.compile_to_c;
            cpp.put_string(")),((T0*)(");
            arg1.compile_to_c;
            cpp.put_string(")))");
            if not equal_test then
               cpp.put_string("))");
            end;
         else
            cpp.put_character('(');
            target.compile_to_c;
            cpp.put_character(')');
            if equal_test then
               cpp.put_string(fz_c_eq);
            else
               cpp.put_string(fz_c_neq);
            end;
            cpp.put_character('(');
            cpp.put_string(fz_cast_void_star);
            cpp.put_character('(');
            arg1.compile_to_c;
            cpp.put_character(')');
            cpp.put_character(')');
         end;
      end;

end -- CALL_INFIX2

