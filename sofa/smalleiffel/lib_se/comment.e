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
class COMMENT
   --
   -- To store a comment (of one or more lines).
   --
   -- Note : for pretty printing, the original text source is stored.
   --

inherit GLOBALS;

creation make

feature 

   start_position: POSITION;

feature

   short(h1, r1, h2, r2: STRING) is
      local
         i, j: INTEGER;
         l: STRING;
         c: CHARACTER;
         open_quote: BOOLEAN;
      do
         from
            i := list.lower;
         until
            i > list.upper
         loop
            short_print.hook_or(h1,r1);
            short_print.hook("BECL");
            l := list.item(i);
            from
               j := 1;
            until
               j > l.count
            loop
               c := l.item(j);
               inspect
                  c
               when '_' then
                  short_print.hook_or("Ucomment","_");
               when '`' then
                  open_quote := true;
                  short_print.hook_or("op_quote","`");
               when '%'' then
                  if open_quote then
                     open_quote := false;
                     short_print.hook_or("cl_quote","'");
                  else
                     short_print.a_character(c);
                  end;
               else
                  short_print.a_character(c);
               end;
               j := j + 1;
            end;
            short_print.hook("AECL");
            short_print.hook_or(h2,r2);
            i := i + 1;
         end;
      end;

   pretty_print is
      -- Print the comment, and indent.
      local
         i, column: INTEGER;
      do
         if fmt.column > 1 and fmt.last_character /= ' ' then
            fmt.put_character(' ');
         end;
         from
            column := fmt.column;
            i := list.lower;
         until
            i > list.upper
         loop
            fmt.put_string("--");
            fmt.put_string(list.item(i));
            i := i + 1;
            if i <= list.upper then
               from
                  fmt.put_character('%N');
               until
                  fmt.column = column
               loop
                  fmt.put_character(' ');
               end;
            end;
         end;
         fmt.put_character('%N');
         fmt.indent;
      ensure
         fmt.indent_level = old fmt.indent_level
      end;

   count: INTEGER is
         -- Number of lines of the comment.
      do
         Result := list.count;
      end;

   dummy: BOOLEAN is
         -- Thus this comment can be dropped :-)
      local
         first_line: STRING;
         c: INTEGER;
      do
         if list.count = 1 then
            first_line := list.first;
            c := first_line.count;
            if c < 40 then
               if first_line.index_of_string(" end ") < c then
                  Result := true;
               elseif first_line.index_of_string(" class ") < c then
                  Result := true;
               end;
            end;
         end;
      end;

feature {BASE_CLASS}

   good_end(name: CLASS_NAME) is
      do
         if not list.item(1).has_string(name.to_string) then
            eh.add_position(name.start_position);
            warning(start_position,"Bad comment to end a class.");
         end;
      end;

feature {COMMENT}

   list: ARRAY[STRING];
         -- The contents of the comment.

feature {EIFFEL_PARSER}

   add_last(l: STRING) is
      require
         l /= Void
      do
         list.add_last(l);
      ensure
         count = 1 + old count
      end;

   append(other: like Current) is
      require
         other /= Void
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > other.list.upper
         loop
            add_last(other.list.item(i));
            i := i + 1;
         end;
      end;

feature {NONE}

   make(sp: like start_position; first: STRING) is
      require
         not sp.is_unknown;
         first /= Void
      do
         start_position := sp;
	 !!list.with_capacity(4,1);
         list.add_last(first);
      ensure
         start_position = sp;
         list.first = first
      end;

invariant

   not start_position.is_unknown;

   not list.is_empty;

   list.lower = 1;

end -- COMMENT
