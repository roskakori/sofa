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
class ITERATOR_ON_LINKED_LIST[E]

inherit ITERATOR[E];

creation make

feature {NONE}

   linked_list: LINKED_LIST[E];
	 -- The one to be traversed.

   current_link: LINK[E];
	 --  Memorize the current position.

feature

   make(ll: LINKED_LIST[E]) is
      require
	 ll /= Void
      do
	 linked_list := ll;
	 current_link := linked_list.first_link;
      ensure
	 linked_list = ll
      end;

   start is
      do
	 current_link := linked_list.first_link;
      end;

   is_off: BOOLEAN is
      do
	 Result := current_link = Void;
      end;

   item: E is
      do
	 Result := current_link.item;
      end;

   next is
      do
	 current_link := current_link.next;
      end;

end
