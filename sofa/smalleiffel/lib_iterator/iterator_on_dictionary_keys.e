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
class ITERATOR_ON_DICTIONARY_KEYS[E->HASHABLE]

inherit ITERATOR[E];

creation make

feature {NONE}

   dictionary: DICTIONARY[ANY,E];
	 -- The one to be traversed.

   item_index: INTEGER;

feature

   make(d: DICTIONARY[ANY,E]) is
      require
	 d /= Void
      do
	 dictionary := d;
	 item_index := 1;
      ensure
	 dictionary = d
      end;

   start is
      do
	 item_index := 1;
      end;

   is_off: BOOLEAN is
      do
	 Result := item_index > dictionary.count;
      end;

   item: E is
      do
	 Result := dictionary.key(item_index);
      end;

   next is
      do
	 item_index := item_index + 1;
      end;

end
