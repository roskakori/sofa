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
class DECLARATION_1
--
-- For a single declaration like :
--             foo : BAR;
--

inherit DECLARATION;

creation {EIFFEL_PARSER} make

feature {NONE}

   name: LOCAL_ARGUMENT1;
         -- Of the declared variable.

feature {NONE}

   make(n: like name; type: TYPE) is
      require
         n /= Void;
      do
         name := n;
         name.set_result_type(type);
      ensure
         name = n;
      end;

feature

   start_position: POSITION is
      do
         Result := name.start_position;
      end;

   pretty_print is
      do
         name.pretty_print;
         fmt.put_string(": ");
         name.result_type.pretty_print;
      end;

   short is
      do
         name.short;
         short_print.hook_or("hook35",": ");
         name.result_type.short;
      end;

feature {DECLARATION_LIST}

   count: INTEGER is 1;

feature {DECLARATION_LIST}

   append_in(dl: DECLARATION_LIST) is
      do
         dl.add_last(name);
      end;

end -- DECLARATION_1

