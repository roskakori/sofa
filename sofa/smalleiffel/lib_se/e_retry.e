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
class E_RETRY
   --
   -- To store instruction "retry" for exception handling.
   --

inherit INSTRUCTION;

creation make

feature

   start_position: POSITION;

   end_mark_comment: BOOLEAN is false;

   is_pre_computable: BOOLEAN is false;

   use_current: BOOLEAN is false;

   afd_check is
      do
      end;

   collect_c_tmp is
      do
      end;

   compile_to_c is
      do
         if run_control.no_check then
            run_feature.c_assertion_flag;
            cpp.put_string("=1;%N");
         end;
         cpp.put_string("goto retry_tag;%N");
      end;

   compile_to_jvm is
      do
         eh.add_position(start_position);
         fatal_error(fz_jvm_error);
      end;

   to_runnable(ct: TYPE): like Current is
      local
         rf: RUN_FEATURE;
      do
         rf := small_eiffel.top_rf;
         if run_feature = Void then
            run_feature := rf;
            Result := Current;
         elseif run_feature = rf then
            Result := Current
         else
            !!Result.make(start_position);
            Result := Result.to_runnable(ct);
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := true;
      end;

   pretty_print is
      do
         fmt.put_string("retry");
         if fmt.semi_colon_flag then
            fmt.put_character(';');
         end;
      end;

feature {NONE}

   run_feature: RUN_FEATURE;
         -- Corresponding one when runnable.

   make(sp: like start_position) is
      do
         start_position := sp;
      end;

end -- E_RETRY

