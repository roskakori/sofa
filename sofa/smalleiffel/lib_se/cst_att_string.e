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
class CST_ATT_STRING

inherit CST_ATT;

creation make

feature {NONE}

   first_value: MANIFEST_STRING;

   remainder: FIXED_ARRAY[MANIFEST_STRING];

feature {NONE}

   make(n: like names; t: like result_type; v: like value) is
      require
         n /= Void;
         t /= Void;
         v /= Void
      local
         i: INTEGER;
      do
         make_e_feature(n);
         result_type := t;
         first_value := v;
         i := names.count;
         if i > 1 then
            from
               i := i - 1;
               !!remainder.make(i);
            until
               i = 0
            loop
               i := i - 1;
               remainder.put(v.twin,i);
            end;
         end;
      ensure
         names = n;
         result_type = t;
      end;

feature

   value(i: INTEGER): MANIFEST_STRING is
      do
         if i = 1 then
            Result := first_value;
         else
            Result := remainder.item(i - 2);
         end;
      end;

end -- CST_ATT_STRING

