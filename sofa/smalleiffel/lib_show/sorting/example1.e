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
   -- Yes it is easy to sort any COLLECTION :
   -- 
   --            compile -o example1 -boost example1
   --

creation make

feature

   make is
      local
         c: COLLECTION[INTEGER];
         sorter: COLLECTION_SORTER[INTEGER];
      do
         c := <<10, 3, 5, 11, 1>>;
         io.put_string("My collection not sorted : ");
         print_collection(c);
         io.put_string("My sorted collection     : ");
         sorter.sort(c);
         print_collection(c);
         io.put_string("To know more about sorting, have a look %
		       %at example #2.%N");
      end;

feature {NONE}

   print_collection(c: COLLECTION[INTEGER]) is
      local
         i: INTEGER;
      do
         from
            i := c.lower;
         until
            i > c.upper
         loop
            io.put_integer(c.item(i));
            io.put_character(' ');
            i := i + 1;
         end;
         io.put_character('%N');
      end;
   

end -- EXAMPLE1

