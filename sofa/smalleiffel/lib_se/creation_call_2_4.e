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
deferred class CREATION_CALL_2_4

inherit CREATION_CALL;

feature

   type: TYPE;

feature {NONE}

   check_explicit_type is
      local
         ct, t: TYPE;
      do
         ct := small_eiffel.top_rf.current_type;
         t := type.to_runnable(ct);
         if t = Void or else not t.is_run_type then
            eh.add_position(type.start_position);
            fatal_error("Invalid explicit type.");
         else
            type := t;
         end;
         if not type.is_a(writable.result_type) then
            fatal_error(" Bad explicit type mark.");
         end;
      end;

end -- CREATION_CALL_2_4

