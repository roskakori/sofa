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
deferred class CST_ATT
   --
   -- For all ConSTant Attributes.
   --

inherit ATTRIBUTE;

feature

   value(i: INTEGER): EXPRESSION is
         -- Result will be redefine as: REAL_CONSTANT, INTEGER_CONSTANT,
         -- CHARACTER_CONSTANT, BOOLEAN_CONSTANT or MANIFEST_STRING.
      require
         1 <= i;
         i <= names.count
      deferred
      ensure
         Result /= Void
      end;

   to_run_feature(ct: TYPE; fn: FEATURE_NAME): RUN_FEATURE_1 is
      local
         rc: RUN_CLASS;
      do
         rc := ct.run_class;
         Result ?= rc.at(fn);
         if Result = Void then
            !!Result.make(ct,fn,Current);
         end;
      end;

feature {NONE}

   pretty_tail is
      do
         fmt.put_string(" is ");
         value(1).pretty_print;
      end;

end -- CST_ATT

