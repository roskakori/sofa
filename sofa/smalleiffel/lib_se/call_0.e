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
deferred class CALL_0
   --
   -- For calls without argument (only Current).
   --

inherit CALL redefine to_integer end;

feature

   arg_count: INTEGER is 0;

feature

   run_feature: RUN_FEATURE;

feature

   frozen arguments: EFFECTIVE_ARG_LIST is
      do
      end;

   frozen result_type: TYPE is
      do
         Result := run_feature.result_type;
         if Result.is_like_current then
            Result := run_feature.current_type;
         end;
      end;

   frozen to_integer: INTEGER is
      local
         rf1: RUN_FEATURE_1;
      do
         rf1 ?= run_feature;
         if rf1 = Void then
            error(start_position,fz_iinaiv);
         else
            Result := rf1.value.to_integer;
         end;
      end;

   frozen assertion_check(tag: CHARACTER) is
      do
         if tag = 'R' then
            run_feature.vape_check_from(start_position);
         end;
         target.assertion_check(tag);
      end;

   frozen can_be_dropped: BOOLEAN is
      do
         if target.can_be_dropped then
            Result := run_feature.can_be_dropped;
         end;
      end;

   frozen run_feature_match is
      do
         run_feature_has_result;
         if run_feature.arguments /= Void then
            eh.add_position(feature_name.start_position);
            eh.add_position(run_feature.start_position);
            fatal_error("Feature found has arguments.");
         end;
      end;

feature {RUN_FEATURE_3,RUN_FEATURE_4}

   frozen finalize is
      local
         rc: RUN_CLASS;
         rf: RUN_FEATURE;
      do
         rf := run_feature;
         rc := rf.current_type.run_class;
         run_feature := rc.running.first.dynamic(rf);
      end;

end -- CALL_0
