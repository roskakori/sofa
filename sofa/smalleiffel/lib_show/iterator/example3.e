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
class EXAMPLE3
   --
   -- To add a loop variant for any knid of ITERATOR (for loop variant
   -- fans only ;-).
   --

creation make

feature {NONE}

   iterator: ITERATOR_WITH_VARIANT[INTEGER];
   
   make is
      local
	 simple_iterator: ITERATOR[INTEGER];
      do
	 !ITERATOR_ON_RANDOM_GENERATOR!simple_iterator.make(10);
	 !!iterator.make(simple_iterator);
	 io.put_string("First traversal :%N");
	 traverse;
	 io.put_string("Second traversal :%N");
	 traverse;
      end;

   traverse is
      do
	 from
	    iterator.start;
	 variant
	    iterator.variant_value
	 until
	    iterator.is_off
	 loop
	    io.put_integer(iterator.item);
            io.put_character(' ');
	    iterator.next;
	 end;
         io.put_new_line;
      end;

end
