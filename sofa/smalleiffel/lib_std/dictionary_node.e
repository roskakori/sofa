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
class DICTIONARY_NODE[V,K->HASHABLE]
   --
   -- Auxilliary class to implement DICTIONARY[V,K->HASHABLE].
   --
   
creation {DICTIONARY} make
   
feature {DICTIONARY}

   item: V;

   key: K;

   next: like Current;
	 -- The `next' one when some clash occurs.

   set_item(i: like item) is
      do
         item := i;
      ensure
         item  = i
      end;
   
   set_next(i: like next) is
      do
         next := i;
      ensure
         next  = i
      end;

feature {NONE}
   
   make(i: like item; k: like key; n: like next) is
      do
         item := i;
         key := k;
         next := n;
      ensure
         item = i;
         key = k;
         next = n
      end;

end
