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
class TAG_NAME

inherit GLOBALS;

creation make

feature

   to_string: STRING;

   start_position: POSITION;

feature {NONE}

   make(n: STRING; sp: like start_position) is
      require
         n = string_aliaser.item(n)
      do
         to_string := n;
         start_position := sp;
      ensure
         to_string = n;
         start_position = sp
      end;

feature

   to_key: STRING is
      do
         Result := to_string;
      end;

   short is
      local
         i: INTEGER;
         c: CHARACTER;
      do
         short_print.hook("Btag");
         from
            i := 1;
         until
            i > to_string.count
         loop
            c := to_string.item(i);
            if c = '_' then
               short_print.hook_or("Utag","_");
            else
               short_print.a_character(c);
            end;
            i := i + 1;
         end;
         short_print.hook("Atag");
      end;

end -- TAG_NAME

