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
deferred class CALL_1
   --
   -- For calls with only one argument.
   --

inherit CALL;

feature

   arguments: EFFECTIVE_ARG_LIST;

feature

   arg_count: INTEGER is 1;

   can_be_dropped: BOOLEAN is false;

   is_pre_computable: BOOLEAN is false;

feature

   frozen arg1: EXPRESSION is
      do
         Result := arguments.first;
      end;

feature {NONE}

   frozen run_feature_match(ct: TYPE) is
      do
         run_feature_has_result;
         arguments.match_with(run_feature,ct);
      end;

invariant

   arguments.count = 1;

end -- CALL_1

