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
   -- Using an ITERATOR traverse some random collection of INTEGER.
   --

creation make

feature {NONE}

   iterator: ITERATOR_ON_RANDOM_GENERATOR;
   
   make is
      do
	 !!iterator.make(10);
	 io.put_string("First traversal :%N");
	 traverse;
	 io.put_string("Second traversal :%N");
	 traverse;
      end;

   traverse is
      do
	 from
	    iterator.start;
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
