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
class CST_ATT_UNIQUE
   --
   -- For "unique" constant attribute.
   --

inherit CST_ATT redefine pretty_tail end;

creation make

feature {NONE}

   values: FIXED_ARRAY[INTEGER_CONSTANT];

feature {NONE}

   make(n: like names; t: like result_type) is
      require
         n /= Void;
         t.is_integer;
      local
         i, j: INTEGER;
         ic: INTEGER_CONSTANT;
      do
         make_e_feature(n);
         result_type := t;
         i := names.count;
         !!values.with_capacity(i);
         from
            j := 1;
         until
            i = 0
         loop
            counter.increment;
            !!ic.make(counter.value,names.item(j).start_position);
            values.add_last(ic);
            j := j + 1;
            i := i - 1;
         end;
      end;

feature

   value(i: INTEGER): INTEGER_CONSTANT is
      do
         Result := values.item(i - 1);
      end;

feature {NONE}

   pretty_tail is
      do
         fmt.put_string(" is unique");
      end;

feature {NONE}

   counter: COUNTER is
      once
         !!Result
      end;

end -- CST_ATT_UNIQUE

