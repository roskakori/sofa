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
class EXAMPLE1
   --
   -- To start with NUMBERs, just compile an run it :
   -- 
   --            compile -o example1 -boost example1
   --

inherit NUMBER_TOOLS;

creation make

feature

   make is
      local
         max, n1, n2: NUMBER;
      do
         max := from_integer(Maximum_integer);
         io.put_string("The maximum integer value on this architecture is:%N%
                       %      max = ");
         io.put_number(max);
         io.put_string("%Nmax + max = ");
         io.put_number(max + max);
         io.put_string("%Nmax * max = ");
         io.put_number(max * max);
         io.put_string("%NDo you like NUMBERs ?%N");

         io.put_string("So have a look at NUMBERs division:%N");
         n1 := from_integer(2);
         n2 := from_integer(6);
         io.put_string("Assume n1 = ");
         io.put_number(n1);
         io.put_string("  and n2 = ");
         io.put_number(n2);
         io.put_string("  then  n1/n2 = ");
         io.put_number(n1 / n2);
         io.put_string("%NWith NUMBER, you always get the exact result.%N");
         io.put_string("%NDo you like NUMBERs ?%N%
                       %Have a look at example #2 to know more about NUMBERs%N");
      end;

end -- EXAMPLE1

