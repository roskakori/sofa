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
class CALL_1_C
   --
   -- Other kinds of call with only one argument.
   --

inherit CALL_1;

creation make, with

feature

   run_feature: RUN_FEATURE;

feature {NONE}

   make(t: like target; fn: like feature_name; a: like arguments) is
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

   with(t: like target; fn: like feature_name; a: like arguments;
        rf: RUN_FEATURE; ct: TYPE) is
      require
         t /= Void;
         fn /= Void;
         a.count = 1;
         rf /= Void
      do
         target := t;
         feature_name := fn;
         arguments := a;
         run_feature := rf;
         run_feature_match(ct);
      ensure
         target = t;
         feature_name = fn;
         arguments = a;
         run_feature = rf
      end;

feature

   result_type: TYPE is
      local
         tla: TYPE_LIKE_ARGUMENT;
      do
         Result := run_feature.result_type;
         if Result.is_like_current then
            Result := run_feature.current_type;
         else
            tla ?= Result;
            if tla /= Void then
               Result := arg1.result_type.run_type;
            end;
         end;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         t: like target;
         a: like arguments;
         rf: RUN_FEATURE;
      do
         t := runnable_expression(target,ct);
         a := runnable_args(arguments,ct);
         rf := run_feature_for(t,ct);
         if run_feature = Void then
            target := t;
            arguments := a;
            run_feature := rf;
            run_feature_match(ct);
            Result := Current;
         elseif t = target and then a = arguments then
            check
               run_feature = rf
            end;
            Result := Current;
         else
            !!Result.with(t,feature_name,a,rf,ct);
         end;
      end;

   assertion_check(tag: CHARACTER) is
      do
         if tag = 'R' then
            run_feature.vape_check_from(start_position);
         end;
         target.assertion_check(tag);
         arg1.assertion_check(tag);
      end;

   is_static: BOOLEAN is
      local
         running: ARRAY[RUN_CLASS];
         rf: like run_feature;
      do
         running := run_feature.run_class.running;
         if running /= Void and then running.count = 1 then
            rf := running.first.dynamic(run_feature);
            if rf.is_static then
               Result := true;
            end;
         end;
      end;

   static_value: INTEGER is
      local
         running: ARRAY[RUN_CLASS];
         rf: like run_feature;
      do
         running := run_feature.run_class.running;
         if running /= Void and then running.count = 1 then
            rf := running.first.dynamic(run_feature);
            if rf.is_static then
               Result := rf.static_value_mem;
            end;
         end;
      end;

   precedence: INTEGER is
      do
         Result := dot_precedence;
      end;

   compile_to_c is
      do
         call_proc_call_c2c;
      end;

   short is
      do
         target.short_target;
         run_feature.name.short;
         arg1.bracketed_short;
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
         fmt.put_character('(');
         arg1.pretty_print;
         fmt.put_character(')');
      end;

   isa_dca_inline_argument: INTEGER is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   compile_to_jvm is
      do
         call_proc_call_c2jvm;
      end;

   jvm_branch_if_false: INTEGER is
      do
         Result := jvm_standard_branch_if_false;
      end;

   jvm_branch_if_true: INTEGER is
      do
         Result := jvm_standard_branch_if_true;
      end;

feature {RUN_FEATURE_3,RUN_FEATURE_4}

   finalize is
      local
         rc: RUN_CLASS;
         rf: RUN_FEATURE;
      do
         rf := run_feature;
         rc := rf.run_class;
         run_feature := rc.running.first.dynamic(rf);
      end;

end -- CALL_1_C

