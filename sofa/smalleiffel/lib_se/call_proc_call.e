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
deferred class CALL_PROC_CALL
   --
   -- Common root for CALL and PROC_CALL.
   --

inherit GLOBALS;

feature -- Common attributes :

   target: EXPRESSION;
         -- Target of the call.

   feature_name: FEATURE_NAME;
         -- Written selector name of the call.

feature -- Common deferred :

   run_feature: RUN_FEATURE is
         -- Non void when runnable if any `run_feature'.
      deferred
      end;

   arguments: EFFECTIVE_ARG_LIST is
         -- Arguments of the call if any.
      deferred
      ensure
         Result = Void or else Result.count > 0
      end;

   arg_count: INTEGER is
         -- The `arguments' count or 0.
      deferred
      ensure
         Result >= 0
      end;

feature -- Common frozen :

   frozen collect_c_tmp is
      do
         if run_feature /= Void then
            run_feature.collect_c_tmp;
         end;
         target.collect_c_tmp;
         if arguments /= Void then
            arguments.collect_c_tmp;
         end;
      end;

   frozen start_position: POSITION is
      do
         Result := feature_name.start_position;
      end;

   use_current, frozen standard_use_current: BOOLEAN is
      do
         if arg_count > 0 then
            Result := arguments.use_current;
         end;
         if Result then
         elseif target.is_current then
            Result := run_feature.use_current;
         else
            Result := target.use_current;
         end;
      end;

feature

   frozen afd_check is
      local
         rc: RUN_CLASS;
         running: ARRAY[RUN_CLASS];
      do
         if run_feature /= Void then
            rc := target.result_type.run_class;
            running := rc.running;
            if running = Void then
            elseif running.count > 1 then
               switch_collection.update(target,run_feature);
            end;
         end;
         target.afd_check;
         if arg_count > 0 then
            arguments.afd_check;
         end;
      end;

feature {RUN_FEATURE_3,RUN_FEATURE_4}

   finalize is
         -- For inlining of direct calls on an attribute.
      require
         run_control.boost;
         small_eiffel.is_ready;
         run_feature.current_type.run_class.running.count = 1
      deferred
      ensure
         run_feature.current_type.run_class.at_run_time
      end;

feature {NONE}

   frozen call_proc_call_c2c is
      do
         cpp.put_cpc(Current);
      end;

   frozen call_proc_call_c2jvm is
      do
         jvm.call_proc_call_mapping(Current);
      end;

   frozen runnable_expression(expression: EXPRESSION; ct: TYPE): EXPRESSION is
      require
         expression /= Void;
         ct /= Void
      do
         Result := expression.to_runnable(ct);
         if Result = Void then
            eh.add_position(expression.start_position);
            fatal_error("Bad expression.");
         end;
      ensure
         Result /= Void
      end;

   frozen runnable_args(args: like arguments; ct: TYPE): like arguments is
      require
         args /= Void;
         ct /= Void
      do
         Result := args.to_runnable(ct);
         if Result = Void then
            eh.add_position(args.start_position);
            fatal_error(fz_bad_argument);
         end;
      ensure
         Result /= Void
      end;

   frozen run_feature_for(targ: EXPRESSION; ct: TYPE): RUN_FEATURE is
      require
         targ /= Void
      local
         rc: RUN_CLASS;
         rt: TYPE;
         bc: BASE_CLASS;
      do
         rt := targ.result_type;
         if rt /= Void then 
            rc := rt.run_class;
            if rc /= Void then
               bc := rc.base_class;
               Result := bc.run_feature_for(rc,targ,feature_name,ct);
            end;
         end;
         if Result = Void then
            eh.add_position(feature_name.start_position);
            eh.append("Bad target for this call.");
            eh.print_as_fatal_error;
         end;
      ensure
         Result /= Void
      end;

   frozen call_proc_call_stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         if arguments = Void then
            Result := true;
         else
            Result := arguments.stupid_switch(r);
         end;
         if Result then
            if target.is_current then
               if small_eiffel.same_base_feature(run_feature,r) then
                  Result := run_feature.stupid_switch(r) /= Void;
               else
                  Result := false;
               end;
            else
               Result := target.stupid_switch(r);
            end;
         end;
      end;

invariant

   target /= Void;

   feature_name /= Void;

end -- CALL_PROC_CALL

