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
class INDEX_CLAUSE
   --
   --

inherit GLOBALS;

creation with_tag, without_tag

feature {NONE}

   tag: STRING;

   list: FIXED_ARRAY[EXPRESSION];

   with_tag(i: like tag) is
      require
         i /= Void
      do
         tag := i;
      ensure
         tag = i
      end;

   without_tag(index_value: EXPRESSION) is
      do
         add_last(index_value);
      end;

feature

   pretty_print is
      local
         i: INTEGER;
         tag_column: INTEGER;
      do
         if tag /= void then
            fmt.put_string(tag);
            fmt.put_string(": ");
            tag_column := fmt.column;
         end;
         if list /= Void then
            fmt.level_incr;
            from
               i := list.lower;
            until
               i > list.upper
            loop
               list.item(i).pretty_print;
               i := i + 1;
               if i <= list.upper then
                  fmt.put_string(",%N");
                  if tag_column > 0 then
                     from
                     until
                        fmt.column >= tag_column
                     loop
                        fmt.put_character(' ');
                     end;
                  else
                     fmt.indent;
                  end;
               end;
            end;
            fmt.level_decr;
         end;
      end;

feature {EIFFEL_PARSER}

   add_last(index_value: EXPRESSION) is
      require
         index_value /= Void;
      do
         if list = Void then
            !!list.with_capacity(4);
         end;
         list.add_last(index_value);
      end;

invariant

   tag /= Void or else list /= Void

end -- INDEX_CLAUSE

