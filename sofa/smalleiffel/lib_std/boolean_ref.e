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
class BOOLEAN_REF
   
inherit 
   ANY 
      redefine out_in_tagged_out_memory, fill_tagged_out_memory
      end;
   
creation make

feature 

   item: BOOLEAN;      
         -- Value of Current

   make(value: BOOLEAN) is
         -- Initialize object
      do  
         item := value
      end;

feature
   
   set_item(value: like item) is
      do
         item := value;
      end;

   infix "and" (other : like Current) : like Current is
         -- `and' of Current with `other'.
      require
         other /= Void
      do
         !!Result.make (item and other.item)
      end;

   infix "and then" (other : like Current) : like Current is
         -- Semi-strict `and' of Current with `other'.
      require
         other /= Void
      do
         !!Result.make (item and then other.item)
      end;

   infix "implies" (other : like Current) : like Current is
         -- Does Current imply `other'.
      require
         other /= Void
      do
         !!Result.make (item implies other.item)
      end;

   infix "or" (other : like Current) : like Current is
         -- `or' of Current with `other'
      require
         other_not_void : other /= Void
      do
         !!Result.make (item or other.item)
      end;

   infix "or else" (other : like Current) : like Current is
         -- Semi-strict `or' of Current with `other'
      require
         other_not_void : other /= Void
      do
         !!Result.make (item or else other.item)
      end;

   infix "xor" (other: like Current): like Current is
         -- `xor' of Current with `other'
      require
         other /= Void
      do
         !!Result.make (item xor other.item)
      end;

   prefix "not": like Current is
         -- `not' of Current.
      do
         !!Result.make(not item)
      end;

   out_in_tagged_out_memory, fill_tagged_out_memory is
      do
         item.fill_tagged_out_memory;
      end;

end -- BOOLEAN_REF

