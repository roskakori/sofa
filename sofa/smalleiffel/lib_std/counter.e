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
class COUNTER
--
-- Simple counter object (useful as a once function).
--
feature

   value: INTEGER;
	 -- The `value' of the counter.

   increment is
      do
         value := value + 1;
      ensure
         value = 1 + old value
      end;

   decrement is
      do
         value := value - 1;
      ensure
         value + 1 = old value
      end;

   reset is
      do
         value := 0;
      ensure
         value = 0
      end;

   append_in(buffer: STRING) is
	 -- Append the `value' of the counter in the `buffer'.
      do
         value.append_in(buffer);
      end;

end -- COUNTER
