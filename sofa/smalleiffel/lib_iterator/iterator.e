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
deferred class ITERATOR[E]
--
-- The iterator pattern at work: this abstract class defines a 
-- traversal interface for any kind of aggregates data structure.
--

feature

   start is
	 -- Positions the iterator to the first object in the 
	 -- aggregate to be traversed.
      deferred
      end;

   is_off: BOOLEAN is
	 -- Returns true when there are no more objects in the
	 -- sequence.
      deferred
      end;

   item: E is
	 -- Returns the object at the current position in the 
	 -- sequence.
      require
	 not is_off
      deferred
      end;

   next is
	 -- Positions the iterator to the next object in the 
	 -- sequence.
      require
	 not is_off
      deferred
      end;

end
