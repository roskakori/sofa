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
class PROC_CALL_1
   --
   -- For a procedure call with only one argument.
   --

inherit PROC_CALL redefine use_current end;

creation make, with

feature

   arguments: EFFECTIVE_ARG_LIST;

feature {NONE}

   make(t: like target; pn: like feature_name; a: like arguments) is
      require
         t /= Void;
         pn /= Void;
         a /= Void;
      do
         target := t;
         feature_name := pn;
         arguments := a;
      ensure
         target = t;
         feature_name = pn;
         arguments = a;
      end;

   with(t: like target; pn: like feature_name; a: like arguments;
        rf: RUN_FEATURE; ct: TYPE) is
      require
         t /= Void;
         pn /= Void;
         a /= Void;
         rf /= Void;
         ct /= Void
      do
         target := t;
         feature_name := pn;
         arguments := a;
         run_feature := rf;
         run_feature_match(ct);
      ensure
         target = t;
         feature_name = pn;
         arguments = a;
         run_feature = rf
      end;

feature

   arg_count: INTEGER is 1;

   arg1: EXPRESSION is
      do
         Result := arguments.first;
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

   compile_to_jvm is
      do
         if as_c_inline_c = feature_name.to_string then
            eh.add_position(start_position);
            fatal_error(
               "Cannot use %"c_inline_c%" to produce Java byte code.");
         else
            call_proc_call_c2jvm;
         end;
      end;

   use_current: BOOLEAN is
      local
         ms: MANIFEST_STRING;
         s: STRING;
      do
         if as_c_inline_c = feature_name.to_string then
            ms ?= arg1;
            if ms /= Void then
               manifest_string_pool.used_for_c_inline(ms);
               s := ms.to_string;
               Result := s.has('C');
            end;
         else
            Result := standard_use_current;
         end;
      end;

   pretty_print is
      do
         target.print_as_target;
         fmt.put_string(feature_name.to_string);
         fmt.put_character('(');
         arg1.pretty_print;
         fmt.put_character(')');
         if fmt.semi_colon_flag then
            fmt.put_character(';');
         end;
      end;

feature {CREATION_CALL}

   make_runnable(w: like target; a: like arguments;
                 rf: RUN_FEATURE): like Current is
      do
         if run_feature = Void then
            target := w;
            arguments := a;
            run_feature := rf;
            Result := Current;
         else
            !!Result.make(w,feature_name,a);
            Result.set_run_feature(rf);
         end;
      end;

feature {NONE}

   run_feature_match(ct: TYPE) is
      do
         run_feature_has_no_result;
         arguments.match_with(run_feature,ct);
      end;

invariant

   arguments.count = 1

end -- PROC_CALL_1

