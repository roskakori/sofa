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
class ITERATOR_ON_COLLECTION[E]

inherit ITERATOR[E];

creation make

feature {NONE}

   collection: COLLECTION[E];
	 -- The one to be traversed.

   item_index: INTEGER;
	 --  Memorize the current position.

feature

   make(c: COLLECTION[E]) is
      require
	 c /= Void
      do
	 collection := c;
	 item_index := collection.lower;
      ensure
	 collection = c
      end;

   start is
      do
	 item_index := collection.lower;
      end;

   is_off: BOOLEAN is
      do
	 Result := not collection.valid_index(item_index);
      end;

   item: E is
      do
	 Result := collection.item(item_index);
      end;

   next is
      do
	 item_index := item_index + 1;
      end;

end
