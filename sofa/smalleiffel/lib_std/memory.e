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
expanded class MEMORY
--
-- Facilities for tuning up the garbage collection, and
-- everything about memory control.
--

feature -- Status Report :

   frozen collecting: BOOLEAN is
         -- Is garbage collection enabled ?
      external "SmallEiffel"
      end;

feature -- Status setting :

   frozen collection_off is
         -- Disable garbage collection.
      external "SmallEiffel"
      end;
   
   frozen collection_on is
         -- Enable garbage collection.
      external "SmallEiffel"
      end;

feature -- Removal :

   dispose is
         -- Action to be executed just before garbage collection 
         -- reclaims an object.
      do
      end;

   frozen full_collect is
         -- Force a full collection cycle if garbage collection is
         -- enabled; do nothing otherwise.
      external "SmallEiffel"
      end;

feature -- Low level memory management :

   pointer_size: INTEGER is
         -- The size in number of bytes for a pointer.
      external "SmallEiffel"
      end;

end -- MEMORY
