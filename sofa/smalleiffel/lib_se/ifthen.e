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
class IFTHEN
   --
   -- Note : it is not really a complete Eiffel INSTRUCTION.
   -- It is just a small part of an IFTHENELSE.
   --

inherit IF_GLOBALS;

creation make

feature

   expression: EXPRESSION;

   then_compound: COMPOUND;
     -- Not Void if any.

feature {NONE}

   current_type: TYPE;
         -- Not Void when instruction is checked for.

   point2: INTEGER;
         -- To reach the end of IFTHENELSE.

feature

   make(exp: like expression; tc: like then_compound) is
      require
         exp /= void;
      do
         expression := exp;
         then_compound := tc;
      ensure
         expression = exp;
         then_compound = tc;
      end;

feature {IFTHENLIST}

   afd_check is
      do
         expression.afd_check;
         if then_compound /= Void then
            then_compound.afd_check;
         end;
      end;

   collect_c_tmp is
      do
         expression.collect_c_tmp;
      end;

feature

   compile_to_c(need_else: BOOLEAN): INTEGER is
      local
         trace: BOOLEAN;
      do
         if expression.is_static then
            cpp.incr_static_expression_count;
            if expression.static_value = 1 then
               print_else(need_else);
               cpp.put_string("{/*AT*/");
               if then_compound /= Void then
                  then_compound.compile_to_c;
               end;
               cpp.put_string(fz_12);
               Result := static_true;
            else
               cpp.put_string("/*AF*/");
               Result := static_false;
            end;
         else
            Result := non_static;
            trace := not expression.c_simple and then run_control.no_check;
            print_else(need_else);
            cpp.put_string(fz_if);
            cpp.put_character('(');
            if trace then
               cpp.trace_boolean_expression(expression);
            else
               expression.compile_to_c;
            end;
            cpp.put_character(')');
            cpp.put_string(fz_11);
            if then_compound /= Void then
               then_compound.compile_to_c;
            end;
            cpp.put_string(fz_12);
         end;
      end;

   compile_to_jvm: INTEGER is
      local
         point1: INTEGER;
      do
         if expression.is_static then
            jvm.incr_static_expression_count;
            if expression.static_value = 1 then
               if then_compound /= Void then
                  then_compound.compile_to_jvm;
               end;
               Result := static_true;
            else
               Result := static_false;
            end;
         else
            Result := non_static;
            point1 := expression.jvm_branch_if_false;
            if then_compound /= Void then
               then_compound.compile_to_jvm;
            end;
            point2 := code_attribute.opcode_goto;
            code_attribute.resolve_u2_branch(point1);
         end;
      ensure
         (<<static_true,static_false,non_static>>).fast_has(Result)
      end;

   compile_to_jvm_resolve_branch: INTEGER is
      do
         if expression.is_static then
            if expression.static_value = 1 then
               Result := static_true;
            else
               Result := static_false;
            end;
         else
            Result := non_static;
            if point2 > 0 then
               code_attribute.resolve_u2_branch(point2);
            end;
         end;
      ensure
         (<<static_true,static_false,non_static>>).fast_has(Result)
      end;

   use_current: BOOLEAN is
      do
         Result := expression.use_current;
         if not Result and then then_compound /= Void then
            Result := then_compound.use_current;
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := expression.stupid_switch(r) and then
                   (then_compound = Void or else then_compound.stupid_switch(r));
      end;

   start_position: POSITION is
      do
         Result := expression.start_position;
      end;

   pretty_print is
      do
         fmt.level_incr;
         fmt.set_semi_colon_flag(false);
         expression.pretty_print;
         fmt.level_decr;
         fmt.keyword("then");
         fmt.indent;
         if then_compound /= Void then
            then_compound.pretty_print;
         end;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         e: like expression;
         tc: like then_compound;
         t: TYPE;
      do
         if current_type = Void then
            current_type := ct;
            e := expression.to_runnable(ct)
            if e = Void then
               error(expression.start_position,
                     "Bad BOOLEAN expression.");
            else
               expression := e;
               t := expression.result_type;
               if not t.is_boolean then
                  eh.append("Expression of if/elseif must be BOOLEAN. ");
                  eh.add_type(expression.result_type,fz_is_not_boolean);
                  eh.add_position(expression.start_position);
                  eh.print_as_error;
               end;
            end;
            if then_compound /= Void then
               tc := then_compound.to_runnable(ct);
               if tc /= Void then
                  then_compound := tc;
               end;
            end;
            if nb_errors = 0 then
               Result := Current;
            end;
         else
            !!Result.make(expression,then_compound);
            Result := Result.to_runnable(ct);
         end;
      end;

feature {NONE}

   print_else(need_else: BOOLEAN) is
      do
         if need_else then
            cpp.put_string(" else ");
         end;
      end;

invariant

   expression /= Void;

end -- IFTHEN

