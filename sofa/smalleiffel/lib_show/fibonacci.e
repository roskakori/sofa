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
class FIBONACCI

creation make

feature

   make is
      do
         if argument_count /= 1 or else
            not argument(1).is_integer
          then
            io.put_string("Usage: ");
            io.put_string(argument(0));
            io.put_string(" <Integer_value>%N");
            die_with_code(exit_failure_code);
         end;
         io.put_integer(fibonacci(argument(1).to_integer));
         io.put_new_line;
      end;

   fibonacci(i: INTEGER): INTEGER is
      require
         i >= 0
      do
         if i = 0 then
            Result := 1;
         elseif i = 1 then
            Result := 1;
         else
            Result := fibonacci(i - 1) + fibonacci(i - 2) ;
         end;
      end;

end

