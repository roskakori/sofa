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
class CHARACTER_REF

inherit
   HASHABLE;
   COMPARABLE 
      redefine out_in_tagged_out_memory, fill_tagged_out_memory
      end;
   
feature 
   
   item: CHARACTER;

feature
   
   set_item(value: like item) is
      do
         item := value;
      end;

   infix "<" (other: like Current): BOOLEAN is
      do
         Result := item < other.item
      end;

   code: INTEGER is
         -- ASCII code of Current
      do
         Result := item.code
      end;
   
   to_upper: like Current is
         -- Conversion of Current to upper case
      do
         Result := item.to_upper;
      end;

   to_lower: like Current is
         -- Conversion of Current to lower case
      do
         Result := item.to_lower;
      end;

feature -- Object Printing :

   out_in_tagged_out_memory, fill_tagged_out_memory is
      do
         item.fill_tagged_out_memory;
      end;

feature -- Hashing :
   
   hash_code: INTEGER is
      do
         Result := item.hash_code;
      end;

end -- CHARACTER_REF

