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
class DOUBLE_REF

inherit
   HASHABLE;
   NUMERIC
      undefine out_in_tagged_out_memory, fill_tagged_out_memory
      redefine
         infix "^", prefix "+", prefix "-"
      end;
   COMPARABLE
      redefine
         out_in_tagged_out_memory, fill_tagged_out_memory
      end;

feature 

   item: DOUBLE;

feature
   
   set_item(value: like item) is
      do
         item := value;
      end;

   infix "+" (other: like Current): like Current is
      do
         !!Result;
         Result.set_item(item + other.item);
      end;

   infix "-" (other: like Current): like Current is
      do
         !!Result;
         Result.set_item(item - other.item);
      end;

   infix "*" (other: like Current): like Current is
      do
         !!Result;
         Result.set_item(item * other.item);
      end;

   infix "/" (other: like Current): like Current is
      do
         !!Result;
         Result.set_item(item / other.item);
      end;

   infix "^" (exp: INTEGER): like Current is
      do
         !!Result;
         Result.set_item(item ^ exp);
      end;

   prefix "+" : like Current is
      do
         !!Result;
         Result.set_item(item);
      end;

   prefix "-" : like Current is
      do
         !!Result;
         Result.set_item(-item);
      end;

   infix "<" (other: like Current): BOOLEAN is
      do
         Result := item < other.item
      end;

   divisible (other: like Current): BOOLEAN is
      do
         Result := (other.item /= 0.0)
      end;

   one: like Current is
      do
         !!Result;
         Result.set_item(1.0);
      end;

   zero: like Current is
      do
         !!Result;
         Result.set_item(0.0);
      end;

   out_in_tagged_out_memory, fill_tagged_out_memory is
      do
         tagged_out_memory.append("item: "); 
         item.fill_tagged_out_memory;
      end;

   hash_code: INTEGER is
      do
         Result := item.hash_code;
      end;

end -- DOUBLE_REF

