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
deferred class CREATION_CALL_1_2

inherit CREATION_CALL;

feature

   call: PROC_CALL is do end;

   is_pre_computable: BOOLEAN is
      do
         Result := writable.is_result;
      end;

   frozen afd_check is do end;

   frozen collect_c_tmp is do end;

feature {NONE}

   check_creation_clause(t: TYPE) is
      require
         t.is_run_type;
      do
         if t.base_class.has_creation_clause then
            eh.append("Creation clause exists for ");
            eh.add_type(t,". ");
            error(start_position,"You must use a constructor.");
         end;
      end;

end -- CREATION_CALL_1_2

