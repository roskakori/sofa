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
class DECLARATION_GROUP
   --
   -- When a group of variable have the same type mark.
   --
   -- Exemple 1 :
   --         local
   --           foo, bar : ZOO;
   --           --------------
   --
   -- Exemple 2 :
   --         bip(foo, bar : ZOO) is
   --             --------------
   --
   -- See Eiffel3 grammar for more details.
   --
   -- Note : it is necessary to have a good pretty pretty_printing to store
   --        the user's original text.
   --

inherit DECLARATION;

creation {EIFFEL_PARSER} make

feature {NONE}

   name_list: ARRAY[LOCAL_ARGUMENT1];

feature {NONE}

   make(nl: like name_list; type: TYPE) is
      require
         nl /= Void;
         1 < nl.count;
         type /= Void;
      local
         i: INTEGER;
      do
         name_list := nl;
         from
            i := name_list.upper;
         until
            i = 0
         loop
            name_list.item(i).set_result_type(type);
            i := i - 1;
         end;
      ensure
         name_list = nl;
      end;

feature

   pretty_print is
      local
         i: INTEGER;
      do
         from
            i := name_list.lower;
            name_list.item(i).pretty_print;
            i := i + 1;
         until
            i > name_list.upper
         loop
            fmt.put_string(", ");
            name_list.item(i).pretty_print;
            i := i + 1;
         end;
         fmt.put_string(": ");
         name_list.item(1).result_type.pretty_print;
      end;

   short is
      local
         i: INTEGER;
      do
         from
            i := name_list.lower;
            name_list.item(i).short;
            i := i + 1;
         until
            i > name_list.upper
         loop
            short_print.hook_or("hook304",", ");
            name_list.item(i).short;
            i := i + 1;
         end;
         short_print.hook_or("hook305",": ");
         name_list.item(1).result_type.short;
      end;

feature {DECLARATION_LIST}

   count: INTEGER is
      do
         Result := name_list.upper;
      end;

feature {DECLARATION_LIST}

   append_in(dl: DECLARATION_LIST) is
      local
         i: INTEGER;
      do
         from
            i := name_list.lower;
         until
            i > name_list.upper
         loop
            dl.add_last(name_list.item(i));
            i := i + 1;
         end;
      end;

invariant

   name_list.lower = 1;

   name_list.upper >= 2;

end -- DECLARATION_GROUP

