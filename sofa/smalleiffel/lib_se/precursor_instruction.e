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
class PRECURSOR_INSTRUCTION
   --
   -- Handling of the `Precursor' procedure call.
   --

inherit PRECURSOR_CALL; INSTRUCTION;

creation make

feature

   end_mark_comment: BOOLEAN is false;

   is_pre_computable: BOOLEAN is false;

   collect_c_tmp is
      do
         if arguments /= Void then
            arguments.collect_c_tmp;
         end;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         wrf: RUN_FEATURE;
         super: EFFECTIVE_ROUTINE;
         pn: PRECURSOR_NAME;
      do
         if current_type = Void then
            current_type := ct;
            Result := Current;
            wrf := small_eiffel.top_rf;
            if wrf.result_type /= Void then
               eh.add_position(start_position);
               fatal_error("Inside a function, a Precursor call must %
                           %be a function call (not a procedure call).");
            end;
            super := super_feature(wrf);
            pn := precursor_name(wrf.name,super)
	    run_feature := ct.run_class.at(pn);
	    if run_feature = Void then
	       !RUN_FEATURE_10!run_feature.make(ct,pn,super);
	    end;
            prepare_arguments(ct);
         else
            !!Result.make(start_position,parent,arguments);
            Result := Result.to_runnable(ct);
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := true;
      end;

feature {NONE}

   put_semi_colon is
      do
         if fmt.semi_colon_flag then
            fmt.put_character(';');
         end;
      end;

end -- PRECURSOR_INSTRUCTION
