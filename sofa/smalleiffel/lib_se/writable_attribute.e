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
class WRITABLE_ATTRIBUTE
   --
   -- For instance variables (ordinary attribute).
   --

inherit ATTRIBUTE;

creation make

feature

   to_run_feature(t: TYPE; fn: FEATURE_NAME): RUN_FEATURE_2 is
      do
         !!Result.make(t,fn,Current);
      end;

feature {NONE}

   make(n: like names; t: like result_type) is
      require
         n /= Void;
         t /= Void
      do
         make_e_feature(n);
         result_type := t;
      ensure
         names = n;
         result_type = t
      end;

   pretty_tail is
      do
      end;

end -- WRITABLE_ATTRIBUTE
