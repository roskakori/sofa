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
class ARGUMENT_NAME1
   --
   -- An argument name in some declaration list.
   --

inherit LOCAL_ARGUMENT1; ARGUMENT_NAME;

creation make

feature {NONE}

   make(sp: POSITION; n: STRING) is
      require
         not sp.is_unknown;
         n = string_aliaser.item(n)
      do
         start_position := sp;
         to_string := n;
      ensure
         start_position = sp;
         to_string = n
      end;

feature

   to_runnable(ct: TYPE): like Current is
      require
	 result_type /= Void
      local
         rt: TYPE;
      do
         rt := result_type.to_runnable(ct);
         if rt = Void then
            eh.add_position(result_type.start_position);
            error(start_position,"Bad argument.");
         end;
	 if result_type = rt then
            Result := Current;
         else
            Result := twin;
            Result.set_result_type(rt);
         end;
      end;

feature {DECLARATION_LIST}

   name_clash(ct: TYPE) is
      do
         name_clash_for(ct,"Conflict between argument/feature name (VRFA).");
      end;

end -- ARGUMENT_NAME1

