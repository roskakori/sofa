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
deferred class WHEN_ITEM
--
--     WHEN_ITEM_1 for a single value.
--     WHEN_ITEM_2 for a slice.
--

inherit GLOBALS;

feature

   e_when: E_WHEN;
         -- Corresponding one when checked;

   start_position: POSITION is
      deferred
      end;

   pretty_print is
      deferred
      end;

feature {E_WHEN}

   to_runnable_integer(ew: E_WHEN): like Current is
      require
         ew /= Void;
      deferred
      ensure
         Result.e_when = ew
      end;

   to_runnable_character(ew: E_WHEN): like Current is
      require
         ew /= Void;
      deferred
      ensure
         Result.e_when = ew
      end;

   clear_e_when is
      do
         e_when := Void;
      ensure
         e_when = Void;
      end;

end -- WHEN_ITEM

