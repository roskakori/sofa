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
class ONCE_RESULT
   --
   -- Pseudo variable `Result' inside a once function.
   --

inherit ABSTRACT_RESULT;

creation make

feature

   to_runnable(ct: TYPE): like Current is
      local
	 rf: RUN_FEATURE;
         rt1, rt2: TYPE;
      do
         Result := Current;
         rf := small_eiffel.top_rf;
         if run_feature = Void then
            run_feature := rf;
         else
            rt1 := rf.result_type.run_type;
            rt2 := run_feature.result_type.run_type;
            if rt1.run_time_mark /= rt2.run_time_mark then
               eh.add_position(rt1.start_position);
               eh.add_position(rt2.start_position);
               run_feature.fe_vffd7;
            end;
         end;
      end;

   compile_to_c is
      do
         once_routine_pool.c_put_o_result(run_feature);
      end;

   compile_to_jvm is
      do
	 once_routine_pool.jvm_result_load(run_feature);
      end;

   jvm_assign is
      do
	 once_routine_pool.jvm_result_store(run_feature);
      end;

feature {CREATION_CALL}

   c_variable_name: STRING is
      local
	 bf: E_FEATURE;
      do
	 bf := run_feature.base_feature;
         Result := once_routine_pool.o_result(bf);
      end;

end -- ONCE_RESULT

