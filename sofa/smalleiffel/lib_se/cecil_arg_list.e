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
class CECIL_ARG_LIST
   --
   -- Pseudo effective argument list to handle cecil EFFECTIVE_ARG_LIST.
   --

inherit EFFECTIVE_ARG_LIST;

creation {CECIL_POOL} run_feature

creation {EFFECTIVE_ARG_LIST} from_model

feature

   run_feature(rf: RUN_FEATURE) is
      require
         rf.arguments /= Void
      local
         i: INTEGER;
         fal: FORMAL_ARG_LIST;
      do
         from
            fal := rf.arguments;
            i := fal.count;
            !!remainder.make(i - 1);
         until
            i = 0
         loop
            put(fal.name(i),i);
            i := i - 1;
         end;
         current_type := rf.current_type;
      end;

end -- CECIL_ARG_LIST

