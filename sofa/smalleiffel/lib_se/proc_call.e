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
deferred class PROC_CALL
   --
   -- For all sort of procedure calls.
   -- Does not include function calls (see CALL).
   --
   -- Classification: E_PROC_0 when 0 argument, PROC_CALL_1 when
   -- 1 argument and PROC_CALL_N when N arguments.
   --

inherit CALL_PROC_CALL; INSTRUCTION redefine stupid_switch;

feature

   is_pre_computable: BOOLEAN is false;

   end_mark_comment: BOOLEAN is false;

   run_feature: RUN_FEATURE;

   frozen stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := call_proc_call_stupid_switch(r);
      end;

   frozen compile_to_c is
      do
         cpp.se_trace_ins(start_position);
         call_proc_call_c2c;
      end;

feature {RUN_FEATURE_3,RUN_FEATURE_4}

   finalize is
      local
         rc: RUN_CLASS;
         rf: RUN_FEATURE;
      do
         rf := run_feature;
         rc := rf.current_type.run_class;
         run_feature := rc.running.first.dynamic(rf);
      end;

feature {CREATION_CALL}

   make_runnable(w: like target; a: like arguments;
                 rf: RUN_FEATURE): like Current is
      require
         w /= Void
      deferred
      end;

feature {PROC_CALL}

   set_run_feature(rf: like run_feature) is
      do
         run_feature := rf;
      ensure
         run_feature = rf
      end;

feature {NONE}

   frozen run_feature_has_no_result is
      do
         if run_feature.result_type /= Void then
            eh.add_position(run_feature.start_position);
            eh.add_position(feature_name.start_position);
            fatal_error("Feature found is not a procedure.");
         end;
      end;

end -- PROC_CALL

