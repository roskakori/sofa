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
class CST_ATT_INTEGER

inherit CST_ATT;

creation make, implicit

feature {NONE}

   value_mem: INTEGER_CONSTANT;

   make(n: like names; t: like result_type; v: like value) is
      require
         n /= Void;
         t.is_integer;
         v /= Void
      do
         make_e_feature(n);
         result_type := t;
         value_mem := v;
      ensure
         names = n;
         result_type = t;
         value_mem = v
      end;

   implicit(bc: like base_class; sfn: SIMPLE_FEATURE_NAME; v: INTEGER) is
	 -- Allow the creation of some implicit constant attribute of 
	 -- value `v' written in class `bc'. As an example, this routine is 
	 -- used to create the implicit `count' attribute of type TUPLE.
      require
	 bc /= Void;
	 sfn /= Void
      local
	 fnl: like names;
	 sp: POSITION;
	 type_integer: TYPE_INTEGER;
	 ic: INTEGER_CONSTANT;
      do
	 base_class := bc;
	 !!fnl.make_1(sfn);
	 sp.set_in(bc);
	 !!type_integer.make(sp);
	 !!ic.make(v,sp);
	 make(fnl,type_integer,ic);
	 !!clients.omitted;
      end;

feature

   value(i: INTEGER): INTEGER_CONSTANT is
      do
         Result := value_mem;
      end;

end -- CST_ATT_INTEGER

