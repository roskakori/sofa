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
class EXPORT_ITEM
   --
   -- To store one item of the option "inherit ... export ... end".
   --

inherit GLOBALS;

creation make_all, make

feature

   clients: CLIENT_LIST;

   list: FEATURE_NAME_LIST;

feature {NONE}

   make_all(c: like clients) is
      require
         c /= Void;
      do
         clients := c;
         list := Void;
      end;

   make(c: like clients; l: like list) is
      require
         c /= Void;
      do
         clients := c;
         list := l;
      ensure
         clients = c;
         list = l
      end;

feature

   for_all: BOOLEAN is
         -- True when "all" primitives affected;
      do
         Result := list = Void;
      end;

   affect(fn: FEATURE_NAME): BOOLEAN is
      do
         if for_all then
            Result := true;
         else
            Result := list.has(fn);
         end;
      end;

   pretty_print is
      do
         clients.pretty_print;
         if for_all then
            fmt.keyword("all");
         else
            list.pretty_print;
         end;
      end;

invariant

   clients /= Void;

end -- EXPORT_ITEM

