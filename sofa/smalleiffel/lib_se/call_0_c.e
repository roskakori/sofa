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
class CALL_0_C
   --
   -- Other calls without argument.
   --

inherit CALL_0;

creation make, with

feature {NONE}

   make(t: like target; fn: like feature_name) is
      require
         t /= void;
         fn /= void
      do
         target := t;
         feature_name := fn;
      ensure
         target = t;
         feature_name = fn
      end;

   with(t: like target; fn: like feature_name; rf: RUN_FEATURE) is
      require
         t /= void;
         fn /= void;
         rf /= Void
      do
         target := t;
         feature_name := fn;
         run_feature := rf;
         run_feature_match;
      ensure
         target = t;
         feature_name = fn;
         run_feature = rf
      end;

feature

   precedence: INTEGER is
      do
         Result := dot_precedence;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         t: like target;
         rf: RUN_FEATURE;
         -- ***
         line: INTEGER; path: STRING;
      do
         line := target.start_position.line;
         path := target.start_position.path;
         t := runnable_expression(target,ct);
         rf := run_feature_for(t,ct);
         if run_feature = Void then
            target := t;
            run_feature := rf;
            run_feature_match;
            Result := Current;
         elseif t = target then
            check
               run_feature = rf
            end;
            Result := Current;
         else
            !!Result.with(t,feature_name,rf);
         end;
      end;

feature

   short is
      do
         target.short_target;
         run_feature.name.short;
      end;

   short_target is
      do
         short;
         short_print.a_dot;
      end;

   bracketed_pretty_print, pretty_print is
      do
         target.print_as_target;
         fmt.put_string(feature_name.to_string);
      end;

   is_pre_computable: BOOLEAN is
      do
         if target.is_current then
            Result := run_feature.is_pre_computable;
         end;
      end;

   is_static: BOOLEAN is
      local
         name: STRING;
         tt: TYPE;
         running: ARRAY[RUN_CLASS];
         rf: like run_feature;
      do
         tt := target.result_type;
         name := run_feature.name.to_string;
         if as_is_expanded_type = name then
            Result := true;
         elseif as_is_basic_expanded_type = name then
            Result := true;
         elseif as_count = name and then tt.is_bit then
            Result := true;
         else
            running := run_feature.run_class.running;
            if running /= Void and then running.count = 1 then
               rf := running.first.dynamic(run_feature);
               if rf.is_static then
                  Result := true;
               end;
            end;
         end;
      end;

   static_value: INTEGER is
      local
         name: STRING;
         tt: TYPE;
         tb: TYPE_BIT;
         running: ARRAY[RUN_CLASS];
         rf: like run_feature;
      do
         tt := target.result_type;
         name := run_feature.name.to_string;
         if as_is_expanded_type = name then
            if tt.is_expanded then
               Result := 1;
            end;
         elseif as_is_basic_expanded_type = name then
            if tt.is_basic_eiffel_expanded then
               Result := 1;
            end;
         elseif as_count = name and then tt.is_bit then
            tb ?= tt;
            Result := tb.nb;
         else
            running := run_feature.run_class.running;
            if running /= Void and then running.count = 1 then
               rf := running.first.dynamic(run_feature);
               if rf.is_static then
                  Result := rf.static_value_mem;
               end;
            end;
         end;
      end;

   compile_to_c is
      local
         n: STRING;
      do
         n := feature_name.to_string;
         if as_is_expanded_type = n then
            if target.result_type.run_type.is_expanded then
               cpp.put_character('1');
            else
               cpp.put_character('0');
            end;
         elseif as_is_basic_expanded_type = n then
            if target.result_type.is_basic_eiffel_expanded then
               cpp.put_character('1');
            else
               cpp.put_character('0');
            end;
         else
            call_proc_call_c2c;
         end;
      end;

   isa_dca_inline_argument: INTEGER is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   compile_to_jvm is
      local
         n: STRING;
      do
         n := feature_name.to_string;
         if as_is_expanded_type = n then
            if target.result_type.is_expanded then
               code_attribute.opcode_iconst_1;
            else
               code_attribute.opcode_iconst_0;
            end;
         elseif as_is_basic_expanded_type = n then
            if target.result_type.is_basic_eiffel_expanded then
               code_attribute.opcode_iconst_1;
            else
               code_attribute.opcode_iconst_0;
            end;
         else
            call_proc_call_c2jvm;
         end;
      end;

   jvm_branch_if_false: INTEGER is
      do
         Result := jvm_standard_branch_if_false;
      end;

   jvm_branch_if_true: INTEGER is
      do
         Result := jvm_standard_branch_if_true;
      end;

end -- CALL_0_C

