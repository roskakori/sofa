-- This file is  free  software, which  comes  along  with  SmallEiffel. This
-- software  is  distributed  in the hope that it will be useful, but WITHOUT
-- ANY  WARRANTY;  without  even  the  implied warranty of MERCHANTABILITY or
-- FITNESS  FOR A PARTICULAR PURPOSE. You can modify it as you want, provided
-- this header is kept unaltered, and a notification of the changes is added.
-- You  are  allowed  to  redistribute  it and sell it, alone or as a part of
-- another product.
--          Copyright (C) 1994-98 LORIA - UHP - CRIN - INRIA - FRANCE
--            Dominique COLNET and Suzanne COLLIN - colnet@loria.fr
--                       http://SmallEiffel.loria.fr
--
class EXAMPLE2
   --
   -- To start with NUMBERs, just compile an run it :
   -- 
   --            compile -o example2 -boost example2
   --

inherit NUMBER_TOOLS;

creation make

feature

   make is
      local
         n1, n2, n3: NUMBER;
      do
         n1 := from_string("1/3");
         n2 := from_integer(1) / from_integer(3);
         n3 := n1 + n2;
         io.put_number(n1);
         io.put_string(" + ");
         io.put_number(n2);
         io.put_string(" = ");
         io.put_number(n3);
         io.put_new_line;
         io.put_number(n1);
         io.put_string(" + ");
         io.put_number(n3);
         io.put_string(" = ");
         io.put_number(n1 + n3);
         io.put_string("%NDo you like NUMBERs ?%N%
                       %Have a look at example #3 to know more about NUMBERs%N");
      end;

end -- EXAMPLE2

