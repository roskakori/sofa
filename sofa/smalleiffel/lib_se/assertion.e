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
class ASSERTION
   --
   -- To store one assertion.
   --

inherit GLOBALS;

creation make

feature

   tag: TAG_NAME;

   expression: EXPRESSION;

   comment: COMMENT;

   current_type: TYPE;

feature {NONE}

   make(t: like tag; exp: like expression; c: like comment) is
      require
         t /= void or exp /= Void or c /= Void;
      do
         tag := t;
         expression := exp;
         comment := c;
      ensure
         tag = t;
         expression = exp;
         comment = c;
      end;

feature

   start_position: POSITION is
      do
         if tag /= Void then
            Result := tag.start_position;
         elseif expression /= Void then
            Result := expression.start_position;
         else
            Result := comment.start_position;
         end;
      end;

   pretty_print is
      require
         fmt.indent_level >= 1;
      do
         if tag /= Void then
            fmt.put_string(tag.to_string);
            fmt.put_string(": ");
         end;
         if expression /= Void then
            expression.pretty_print;
            if fmt.semi_colon_flag then
               fmt.put_string("; ");
            end;
         end;
         if comment /= Void then
            comment.pretty_print;
         end;
      end;

   short(h01,r01,h02,r02,h03,r03,h04,r04,h05,r05,h06,r06,h07,r07,
         h08,r08,h09,r09,h10,r10,h11,r11,h12,r12,h13,r13: STRING) is
      do
         short_print.hook_or(h01,r01);
         if tag = Void then
            short_print.hook_or(h02,r02);
         else
            short_print.hook_or(h03,r03);
            tag.short;
            short_print.hook_or(h04,r04);
         end;
         if expression = Void then
            short_print.hook_or(h05,r05);
         else
            short_print.hook_or(h06,r06);
            expression.short;
            short_print.hook_or(h07,r07);
         end;
         if comment = Void then
            short_print.hook_or(h08,r08);
         else
            short_print.hook_or(h09,r09);
            comment.short(h10,r10,h11,r11);
            short_print.hook_or(h12,r12);
         end;
         short_print.hook_or(h13,r13);
      end;

   to_runnable(ct: TYPE; assertion_check_tag: CHARACTER): like Current is
      require
         ct.is_run_type;
      local
         e: like expression;
      do
         if current_type = Void then
            current_type := ct;
            Result := Current;
            if expression /= Void then
               e := expression.to_runnable(ct);
               if e = Void then
                  error(start_position,fz_bad_assertion);
               else
                  expression := e;
                  if not expression.result_type.is_boolean then
                     eh.add_type(expression.result_type,fz_is_not_boolean);
                     error(start_position,fz_bad_assertion);
                  end;
               end;
            end;
            if expression /= Void and then nb_errors = 0 then
               if run_control.require_check then
                  expression.assertion_check(assertion_check_tag);
               end;
            end;
         else
            !!Result.make(tag,expression,comment);
            Result := Result.to_runnable(ct,assertion_check_tag);
         end;
      ensure
         nb_errors = 0 implies Result.is_checked;
      end;

   is_checked: BOOLEAN is
      do
         Result := current_type /= Void;
      end;

   use_current: BOOLEAN is
      do
         if expression /= Void then
            Result := expression.use_current;
         end;
      end;

   afd_check is
      require
         is_checked
      do
         if expression /= Void then
            expression.afd_check;
         end;
      end;

   compile_to_c is
      require
         is_checked
      do
         if expression /= Void then
            cpp.check_assertion(expression,tag);
         end;
      end;

   is_pre_computable: BOOLEAN is
      do
         if expression = Void then
            Result := true;
         else
            Result := expression.is_pre_computable;
         end;
      end;

   is_always_true: BOOLEAN is
      do
         if expression = Void then
            Result := true;
         elseif expression.is_static then
            Result := expression.static_value = 1
         end;
      end;

   c_declare_for_old is
      require
         is_checked
      do
         if expression /= Void then
            expression.c_declare_for_old;
         end;
      end;

   compile_to_c_old is
      require
         is_checked
      do
         if expression /= Void then
            expression.compile_to_c_old;
         end;
      end;

   compile_to_jvm_old is
      require
         is_checked
      do
         if expression /= Void then
            expression.compile_to_jvm_old;
         end;
      end;

feature {ASSERTION_LIST}

   compile_to_jvm(last_chance: BOOLEAN) is
         -- The boolean result of the expression is pushed.
         -- When `last_chance' is true, the generated code includes an
         -- error message to be printed when assertion is false.
         --
      require
         is_checked
      local
         point1: INTEGER;
         ca: like code_attribute;
      do
         ca := code_attribute;
         if expression = Void then
            ca.opcode_iconst_1;
         else
            expression.compile_to_jvm
            if last_chance then
               point1 := code_attribute.opcode_ifne;
               ca.runtime_error(expression.start_position,Void,fz_50);
               ca.resolve_u2_branch(point1);
               ca.opcode_iconst_1;
            end;
         end;
      end;

feature {ASSERTION_LIST}

   collect_c_tmp is
      do
         if expression /= Void then
            expression.collect_c_tmp;
         end;
      end;

feature {NONE}

   tmp_string: STRING is
      once
         !!Result.make(128);
      end;

invariant

   tag /= Void or expression /= Void or comment /= Void;

end -- ASSERTION

