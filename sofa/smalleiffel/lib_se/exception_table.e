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
class EXCEPTION_TABLE
   --
   -- Unique Global Object in charge of the exception table of
   -- a method_info as describe in the JVM specification.
   -- Obviously, the same object is recycled.
   --
inherit GLOBALS;

creation {CODE_ATTRIBUTE} make

feature {NONE}

   from_pc: FIXED_ARRAY[INTEGER] is
      once
         !!Result.with_capacity(4);
      end;

   to_pc: FIXED_ARRAY[INTEGER] is
      once
         !!Result.with_capacity(4);
      end;

   handler_pc: FIXED_ARRAY[INTEGER] is
      once
         !!Result.with_capacity(4);
      end;

   type_idx: FIXED_ARRAY[INTEGER] is
      once
         !!Result.with_capacity(4);
      end;

feature {NONE}

   make is
      do
      end;

feature {NONE}

   count: INTEGER is
      do
         Result := from_pc.count;
      end;

feature {CODE_ATTRIBUTE}

   clear is
      do
         from_pc.clear;
         to_pc.clear;
         handler_pc.clear;
         type_idx.clear;
      end;

   add(f,t,h,type: INTEGER) is
      do
         from_pc.add_last(f);
         to_pc.add_last(t);
         handler_pc.add_last(h);
         type_idx.add_last(type);
      end;

   store_in(storage: STRING) is
      local
         c, i: INTEGER;
      do
         c := count;
         append_u2(storage,c);
         from
            i := 0;
         until
            i >= c
         loop
            append_u2(storage,from_pc.item(i));
            append_u2(storage,to_pc.item(i));
            append_u2(storage,handler_pc.item(i));
            append_u2(storage,type_idx.item(i));
            i := i + 1;
         end;
      end;

end -- EXCEPTION_TABLE

