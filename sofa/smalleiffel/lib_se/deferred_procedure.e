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
class DEFERRED_PROCEDURE
   --
   -- For deferred routines.
   --

inherit DEFERRED_ROUTINE;

creation make, from_effective

feature {NONE}

   make(n: like names;
        fa: like arguments;
        om: like obsolete_mark;
        hc: like header_comment;
        ra: like require_assertion) is
      do
         make_routine(n,fa,om,hc,ra);
      end;

feature

   result_type: TYPE is
      do
      end;

   from_effective(fn: FEATURE_NAME;
        fa: like arguments;
        ra: like require_assertion;
        ea: like ensure_assertion;
        bc: like base_class) is
      do
         !!names.make_1(fn);
         make_routine(names,fa,Void,Void,ra);
         set_ensure_assertion(ea);
         base_class := bc;
      end;

end -- DEFERRED_PROCEDURE

