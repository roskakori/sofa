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
deferred class DECLARATION
   --
   -- To store the syntax of the user in a declaration list, a single
   -- declaration is a DECLARATION_1 and a group of variables with the
   -- the same type is a DECLARATION_GROUP.
   --

inherit GLOBALS;

feature

   pretty_print is
      deferred
      end;

   short is
      deferred
      end;

feature {DECLARATION_LIST}

   count: INTEGER is
         -- One or more items.
      deferred
      ensure
         Result >= 1;
      end;

feature {DECLARATION_LIST}

   append_in(dl: DECLARATION_LIST) is
         -- Append current declaration in `fl'.
      require
         dl /= Void
      deferred
      end;

end -- DECLARATION

