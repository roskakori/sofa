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
deferred class CALL_INFIX1

inherit CALL_INFIX;

feature

   run_feature: RUN_FEATURE;

feature {NONE}

   frozen with(t: like target; fn: like feature_name; a: like arguments;
        rf: RUN_FEATURE; ct: TYPE) is
      require
         t /= Void;
         fn /= Void;
         a.count = 1;
         rf /= Void;
         ct /= Void
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

   frozen result_type: TYPE is
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

feature

   frozen to_runnable(ct: TYPE): like Current is
      local
         t: like target;
         a: like arguments;
         rf: RUN_FEATURE;
         argument_type, target_type: TYPE;
      do
         t := runnable_expression(target,ct);
         a := runnable_args(arguments,ct);
         target_type := t.result_type;
         argument_type := arg1.result_type;
         if argument_type.is_real then
            if target_type.is_integer then
               t := conversion_handler.implicit_cast(t,argument_type);
            end;
         elseif argument_type.is_double then
            if target_type.is_integer or else target_type.is_real then
               t := conversion_handler.implicit_cast(t,argument_type);
            end;
         end;
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

feature

   frozen assertion_check(tag: CHARACTER) is
      do
         if tag = 'R' then
            run_feature.vape_check_from(start_position);
         end;
         target.assertion_check(tag);
         arg1.assertion_check(tag);
      end;

   frozen static_value: INTEGER is
      do
         Result := static_value_mem;
      end;

feature {NONE}

   static_value_mem: INTEGER;

   frozen call_is_static: BOOLEAN is
      local
         rc: RUN_CLASS;
         running: ARRAY[RUN_CLASS];
         rf: like run_feature;
      do
         if run_feature /= Void then
            rc := run_feature.run_class;
            if rc /= Void then
               running := rc.running;
               if running /= Void and then running.count = 1 then
                  rf := running.first.dynamic(run_feature);
                  if rf.is_static then
                     static_value_mem := rf.static_value_mem;
                     Result := true;
                  end;
               end;
            end;
         end;
      end;

end -- CALL_INFIX1

