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
   -- Using ITERATOR allows the user to traverse any aggregate object
   -- in a more abstract way.
   --

creation make

feature

   my_loop(type: STRING; my_iterator: ITERATOR[CHARACTER]) is
      local
	 element: CHARACTER;
      do
         io.put_string("Loop on ");
         io.put_string(type);
         io.put_string(": ");
	 from
	    my_iterator.start;
	 until
	    my_iterator.is_off
	 loop
	    element := my_iterator.item;
            io.put_character(element);
	    my_iterator.next;
	 end;
         io.put_new_line;
      end;

feature {NONE}

   make is
      do
	 use_iterator_on_string;
	 use_iterator_on_array;
	 use_iterator_on_fixed_array;
	 use_iterator_on_linked_list;
	 use_iterator_on_two_way_linked_list;
         io.put_string("Do you like ITERATORs ?%N");

         io.put_string("So let's see what happends with a DICTIONARY.%N");
	 use_iterator_on_dictionary;
         io.put_string("And this is not a bug!%N");
      end;

   use_iterator_on_string is
      local
         iterator: ITERATOR[CHARACTER];
      do
	 iterator := ("foo").get_new_iterator;
	 my_loop("STRING",iterator);
      end;

   use_iterator_on_array is
      local
	 iterator: ITERATOR[CHARACTER];
      do
	 iterator := (<<'b','a','r'>>).get_new_iterator;
	 my_loop("ARRAY",iterator);
      end;

   use_iterator_on_fixed_array is
      local
	 iterator: ITERATOR[CHARACTER];
         my_fa: FIXED_ARRAY[CHARACTER];
      do
         !!my_fa.with_capacity(4);
         my_fa.add_last('f');
         my_fa.add_last('O');
         my_fa.add_last('o');
         iterator := my_fa.get_new_iterator;
	 my_loop("FIXED_ARRAY",iterator);
      end;

   use_iterator_on_linked_list is
      local
	 iterator: ITERATOR[CHARACTER];
	 ll: LINKED_LIST[CHARACTER];
      do
	 !!ll.make;
	 ll.add_last('B');
	 ll.add_last('a');
	 ll.add_last('R');
	 iterator := ll.get_new_iterator;
	 my_loop("LINKED_LIST",iterator);
      end;

   use_iterator_on_two_way_linked_list is
      local
	 iterator: ITERATOR[CHARACTER];
	 twll: TWO_WAY_LINKED_LIST[CHARACTER];
      do
	 !!twll.make;
	 twll.add_last('F');
	 twll.add_last('o');
	 twll.add_last('O');
	 iterator := twll.get_new_iterator;
	 my_loop("TWO_WAY_LINKED_LIST",iterator);
      end;

   use_iterator_on_dictionary is
      local
	 iterator: ITERATOR[CHARACTER];
	 d: DICTIONARY[CHARACTER,CHARACTER];
      do
	 !!d.make;
	 d.put('o','B');
	 d.put('f','a');
	 d.put('O','R');
         iterator := d.get_new_iterator_on_items;
	 my_loop("DICTIONARY (items)",iterator);
         iterator := d.get_new_iterator_on_keys;
	 my_loop("DICTIONARY (keys)",iterator);
      end;

end
