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
class ITERATOR_ON_RANDOM_GENERATOR

inherit ITERATOR[INTEGER];

creation make

feature

   count: INTEGER;
	 -- Of the sequence.

   item: INTEGER;

   start is
      do
	 random_generator.with_seed(seed);
	 random_generator.next;
	 left := count;
	 item := random_generator.last_integer(range);
      end;

   next is
      do
	 random_generator.next;
	 left := left - 1;
	 item := random_generator.last_integer(range);
      end;

   is_off: BOOLEAN is
      do
	 Result := left = 0;
      end;

feature {NONE}

   seed: INTEGER is 5555;

   range: INTEGER is 256;
   
   left: INTEGER;

   random_generator: MIN_STAND;

   make(c: like count) is
      require
	 count >= 0
      do
	 count := c;
	 !!random_generator.with_seed(seed);
      end;

end -- ITERATOR_ON_RANDOM_GENERATOR

