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
class ARGUMENT_NAME2
   --
   -- An argument name used somewhere.
   --

inherit ARGUMENT_NAME;

creation refer_to, with

feature

   rank: INTEGER;

feature {NONE}

   formal_arg_list: FORMAL_ARG_LIST;

feature {NONE}

   refer_to(sp: POSITION; fal: FORMAL_ARG_LIST; r: like rank) is
      require
         not sp.is_unknown;
         r.in_range(1,fal.count)
      do
         start_position := sp;
         formal_arg_list := fal;
         rank := r;
      ensure
         start_position = sp;
         rank = r
      end;

   with(model: like Current; fal: FORMAL_ARG_LIST) is
      require
         model /= Void;
         fal /= Void
      do
         standard_copy(model);
         formal_arg_list := fal;
      ensure
         start_position = model.start_position;
         rank = model.rank;
         formal_arg_list = fal
      end;

feature

   to_string: STRING is
      do
         Result := formal_arg_list.name(rank).to_string;
      end;

   result_type: TYPE is
      do
         Result := formal_arg_list.type(rank);
      end;

   to_runnable(ct: TYPE): like Current is
      local
         rf: RUN_FEATURE;
         fal: FORMAL_ARG_LIST;
      do
         rf := small_eiffel.top_rf;
         fal := rf.arguments;
         if formal_arg_list = fal then
            Result := Current;
         else
            !!Result.with(Current,fal);
         end;
      end;

end -- ARGUMENT_NAME2

