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
class FIELD_INFO
   --
   -- Unique Global Object to delay field info writing.
   -- Obviously, the same object is recycled.
   --
inherit GLOBALS;

feature {NONE}

   count: INTEGER;
         -- Number of fields.

   storage: STRING is
         -- To store the final JVM `method_info'.
      once
         !!Result.make(512);
      end;

feature {JVM}

   clear is
      do
         count := 0;
         storage.clear;
      end;

   write_bytes is
      do
         echo.print_count("field",count);
         jvm.b_put_u2(count);
         jvm.b_put_byte_string(storage);
      end;

feature

   add(access_flags, name_idx, descriptor: INTEGER) is
      do
         count := count + 1;
         append_u2(storage,access_flags);
         append_u2(storage,name_idx);
         append_u2(storage,descriptor);
         -- attributes_count :
         append_u2(storage,0);
      end;

end -- FIELD_INFO

