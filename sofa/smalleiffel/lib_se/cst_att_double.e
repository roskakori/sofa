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
class CST_ATT_DOUBLE

inherit CST_ATT;

creation make

feature {NONE}

   value_mem: REAL_CONSTANT;

feature {NONE}

   make(n: like names; t: like result_type; v: like value) is
      require
         n /= Void;
         v /= Void;
         t /= Void
      do
         make_e_feature(n);
         result_type := t;
         value_mem := v;
      ensure
         names = n;
         result_type = t;
         value_mem = v;
      end;

feature

   value(i: INTEGER): REAL_CONSTANT is
      do
         Result := value_mem;
      end;

end -- CST_ATT_DOUBLE

