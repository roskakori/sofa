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
class LOCAL_NAME2
   --
   -- A local name used somewhere.
   --

inherit LOCAL_NAME;

creation refer_to

feature

   rank: INTEGER;

feature {NONE}

   local_var_list: LOCAL_VAR_LIST;

feature {NONE}

   refer_to(sp: POSITION; lvl: LOCAL_VAR_LIST; r: like rank) is
         -- Using name `r' of `dcl' at place `sp'.
      require
         not sp.is_unknown;
         r.in_range(1,lvl.count)
      do
         start_position := sp;
         local_var_list := lvl;
         rank := r;
      ensure
         start_position = sp;
         local_var_list = lvl;
         rank = r
      end;

feature

   assertion_check(tag: CHARACTER) is
      do
         check tag /= 'R' end;
         if tag = 'E' then
            eh.add_position(start_position);
            fatal_error("Cannot use local variable here (VEEN).");
         end;
      end;

   to_string: STRING is
      do
         Result := local_var_list.name(rank).to_string;
      end;

   result_type: TYPE is
      do
         Result := local_var_list.type(rank);
      end;

   to_runnable(ct: TYPE): like Current is
      local
         rf: RUN_FEATURE;
         lvl: LOCAL_VAR_LIST;
      do
         rf := small_eiffel.top_rf;
         lvl := rf.local_vars;
         if local_var_list = lvl then
            Result := Current;
         else
            !!Result.refer_to(start_position,lvl,rank);
         end;
         lvl.name(rank).set_is_used;
      end;
   
end -- LOCAL_NAME2

