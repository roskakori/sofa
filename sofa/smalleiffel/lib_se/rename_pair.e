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
class RENAME_PAIR
   --
   -- To store a rename pair of Eiffel construct :
   --    "inherit ... rename ... as ... end"
   --

inherit GLOBALS;

creation make

feature

   old_name, new_name: FEATURE_NAME;

   make(on, nn: like old_name) is
      require
         on /= Void;
         nn /= Void
      do
         if on.to_string = nn.to_string then
            eh.add_position(on.start_position);
            eh.add_position(nn.start_position);
            fatal_error("New name and old name must be different.");
         end;
         old_name := on;
         new_name := nn;
      ensure
         old_name = on;
         new_name = nn
      end;

   pretty_print is
      do
         old_name.declaration_pretty_print;
         fmt.keyword("as");
         new_name.declaration_pretty_print;
      end;

end -- RENAME_PAIR

