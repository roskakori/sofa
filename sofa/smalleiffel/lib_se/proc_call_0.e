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
class PROC_CALL_0
   --
   -- For procedure calls without argument (only Current).
   --

inherit PROC_CALL;

creation make, with

feature

   arg_count: INTEGER is 0;

feature {NONE}

   make(t: like target; fn: like feature_name) is
      require
         t /= Void;
         fn /= Void;
      do
         target := t;
         feature_name := fn;
      ensure
         target = t;
         feature_name = fn
      end;

   with(t: like target; fn: like feature_name; rf: RUN_FEATURE) is
      require
         t /= Void;
         fn /= Void;
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

   arguments: EFFECTIVE_ARG_LIST is
      do
      end;

   to_runnable(ct: TYPE): like Current is
      local
         t: like target;
         rf: RUN_FEATURE;
      do
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
            !!Result.make(t,feature_name);
            Result := Result.to_runnable(ct);
         end;
      end;

   compile_to_jvm is
      do
         call_proc_call_c2jvm;
      end;

   pretty_print is
      do
         target.print_as_target;
         fmt.put_string(feature_name.to_string);
         if fmt.semi_colon_flag then
            fmt.put_character(';');
         end;
      end;

feature -- {CREATION_CALL}

   make_runnable(w: like target; a: like arguments;
                 rf: RUN_FEATURE): like Current is
      do
         if run_feature = Void then
            target := w;
            run_feature := rf;
            Result := Current;
         else
            !!Result.make(w,feature_name);
            Result.set_run_feature(rf);
         end;
      end;

feature {NONE}

   run_feature_match is
      do
         run_feature_has_no_result;
         if run_feature.arguments /= Void then
            eh.add_position(feature_name.start_position);
            eh.add_position(run_feature.start_position);
            fatal_error("Feature found has arguments.");
         end;
      end;

invariant

   arguments = Void;

end -- PROC_CALL_0

