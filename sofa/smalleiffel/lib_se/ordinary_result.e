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
class ORDINARY_RESULT
   --
   -- Pseudo variable `Result' inside and ordinary (non once) function.
   --

inherit ABSTRACT_RESULT;

creation make

feature

   to_runnable(ct: TYPE): like Current is
      local
         rf: RUN_FEATURE;
         rt: TYPE;
      do
         rf := small_eiffel.top_rf;
         rt := rf.result_type;
         if run_feature = Void then
            run_feature := rf;
            Result := Current;
         else
            !!Result.make(start_position);
            Result := Result.to_runnable(ct);
         end;
      end;

   compile_to_c is
      do
         if run_feature.is_once_function then
            -- inherited in some ensure clause :
            once_routine_pool.c_put_o_result(run_feature);
         else
            cpp.put_character('R');
         end;
      end;

   compile_to_jvm is
      local
         jvm_offset: INTEGER;
      do
	 if run_feature.is_once_routine then
	    once_routine_pool.jvm_result_load(run_feature);
	 else
	    jvm_offset := run_feature.jvm_result_offset;
	    result_type.run_type.jvm_push_local(jvm_offset);
	 end;
      end;

   jvm_assign is
      local
         jvm_offset: INTEGER;
      do
	 if run_feature.is_once_routine then
	    once_routine_pool.jvm_result_store(run_feature);
	 else
	    jvm_offset := run_feature.jvm_result_offset;
	    result_type.run_type.jvm_write_local(jvm_offset);
	 end;
      end;

end -- ORDINARY_RESULT

