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
class CLASS_NAME_LIST

inherit GLOBALS;

creation make_1, merge

feature {NONE}

   first: CLASS_NAME;

   remainder: FIXED_ARRAY[CLASS_NAME];

feature {NONE}

   make_1(cn: CLASS_NAME) is
      require
         cn /= Void
      do
         first := cn;
      ensure
         count = 1;
         item(1) = cn
      end;

   merge(l1, l2: like Current) is
      require
         l1 /= Void;
         l2 /= Void
      local
         i: INTEGER;
         cn: CLASS_NAME;
      do
         first := l1.item(1);
         !!remainder.with_capacity(l1.count + l2.count - 1);
         from
            i := l1.count;
         until
            i = 1
         loop
            remainder.add_last(l1.item(i));
            i := i - 1;
         end;
         from
            i := l2.count;
         until
            i = 0
         loop
            cn := l2.item(i);
            if index_of(cn) = 0 then
               remainder.add_last(cn);
            end;
            i := i - 1;
         end;
      end;

feature

   count: INTEGER is
      do
         if remainder = Void then
            Result := 1;
         else
            Result := 2 + remainder.upper;
         end;
      end;

   item(i: INTEGER): CLASS_NAME is
      require
         i.in_range(1,count)
      do
         if i = 1 then
            Result := first;
         else
            Result := remainder.item(i - 2);
         end;
      ensure
         Result /= Void
      end;

feature {EIFFEL_PARSER}

   add_last(cn: CLASS_NAME) is
      require
         cn /= Void
      local
         i: INTEGER;
      do
         i := index_of(cn);
         if i > 0 then
            eh.add_position(item(i).start_position);
            warning(cn.start_position,"Same Class Name appears twice.");
         end;
         if remainder = Void then
            !!remainder.with_capacity(4);
         end;
         remainder.add_last(cn);
      ensure
         count = 1 + old count;
         item(count) = cn
      end;

feature {CLIENT_LIST}

   pretty_print is
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > count
         loop
            item(i).pretty_print;
            if i < count then
               fmt.put_string(", ");
            end;
            i := i + 1;
         end;
      end;

   gives_permission_to(cn: CLASS_NAME): BOOLEAN is
      local
         i: INTEGER;
      do
         if index_of(cn) > 0 then
            Result := true;
         else
            from
               i := count;
            until
               Result or else i = 0
            loop
               Result := cn.is_subclass_of(item(i));
               i := i - 1;
            end;

         end;
      end;

   gives_permission_to_any: BOOLEAN is
      local
         i: INTEGER;
         cn: CLASS_NAME;
      do
         from
            i := count;
         until
            Result or else i = 0
         loop
            cn := item(i);
            Result := cn.to_string = as_any;
            i := i - 1;
         end;
      end;

feature {}

   index_of(n: CLASS_NAME): INTEGER is
      -- Use `to_string' for comparison.
      -- Gives 0 when `n' is not in the `list'.
      require
         n /= Void;
      local
         to_string: STRING;
      do
         from
            to_string := n.to_string;
            Result := count;
         until
            Result = 0 or else to_string = item(Result).to_string
         loop
            Result := Result - 1;
         end;
      ensure
         Result.in_range(0,count);
         Result > 0 implies n.to_string = item(Result).to_string
      end;

invariant

   first /= Void;

   remainder /= Void implies count = 1 + remainder.count;

end -- CLASS_NAME_LIST

