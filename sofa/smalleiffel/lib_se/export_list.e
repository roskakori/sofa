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
class EXPORT_LIST

inherit GLOBALS;

creation make

feature {ANY}

   start_position: POSITION;
         -- Of keyword "export".

feature {NONE}

   items: array[EXPORT_ITEM]

feature {NONE}

   make(sp: like start_position; i: like items) is
      require
         not sp.is_unknown;
         i.lower = 1;
         not i.is_empty;
      do
         start_position := sp;
         items := i;
         -- *** ADD some validity checking...
      ensure
         start_position = sp;
         items = i;
      end;

feature

   clients_for(fn: FEATURE_NAME): CLIENT_LIST is
      local
         i: INTEGER;
         ei: EXPORT_ITEM;
      do
         from
            i := items.upper;
         until
            i = 0
         loop
            ei := items.item(i);
            if ei.affect(fn) then
               if Result = Void then
                  Result := ei.clients;
               else
                  Result := Result.merge_with(ei.clients);
               end;
            end;
            i := i - 1;
         end;
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         fmt.set_indent_level(2);
         fmt.indent;
         fmt.keyword("export");
         from
            i := 1;
         until
            i > items.upper
         loop
            fmt.set_indent_level(3);
            items.item(i).pretty_print;
            i := i + 1;
            if i <= items.upper then
               fmt.put_character(';');
               fmt.set_indent_level(3);
               fmt.indent;
            end;
         end;
      end;

invariant

   items.lower = 1;

   not items.is_empty;

end -- EXPORT_LIST

