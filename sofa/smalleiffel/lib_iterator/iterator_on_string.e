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
class ITERATOR_ON_STRING

inherit ITERATOR[CHARACTER];

creation make

feature {NONE}

   string: STRING;
	 -- The one to be traversed.

   item_index: INTEGER;
	 --  Memorize the current position.
feature

   make(s: STRING) is
      require
	 s /= Void
      do
	 string := s;
	 item_index := 1;
      ensure
	 string = s
      end;

   start is
      do
	 item_index := 1;
      end;

   is_off: BOOLEAN is
      do
	 Result :=  item_index > string.count;
      end;

   item: CHARACTER is
      do
	 Result := string.item(item_index);
      end;

   next is
      do
	 item_index := item_index + 1;
      end;

end
