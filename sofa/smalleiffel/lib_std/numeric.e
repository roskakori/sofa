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
deferred class  NUMERIC
   --
   -- This class describes a ring.
   --
   
inherit HASHABLE undefine is_equal end;
   
feature  

   infix "+" (other: like Current): like Current is
         -- Sum with 'other' (commutative).
      require
         other /= Void
      deferred
      end;
   
   infix "-" (other: like Current): like Current is
         -- Result of substracting `other'.
      require
         other /= Void
      deferred
      end;

   infix "*" (other: like Current): like Current is
         -- Product by `other'.
      require
         other /= Void
      deferred
      end;
   
   infix "/" (other: like Current): NUMERIC is
         -- Division by `other'.
      require
         other /= Void;
         divisible (other)
      deferred
      end;

   infix "^" (exp: INTEGER): NUMERIC is
         -- `Current' raised to `exp'-th power.
      require
         exp >= 0 
      local
         e      : INTEGER;
         product: like Current;
         factor : like Current;
      do
         product := one;
         factor  := Current;
         from
            e := exp;
         until
            e = 0
         loop
            if (e \\ 2) = 1 then
               product := product * factor
            end;
            e := e // 2;
            factor := factor * factor;
         end;
         Result := product;
      end;

   prefix "+" : like Current is
         -- Unary plus of `Current'.
      do
         Result := Current
      end;

   prefix "-" : like Current is
         -- Unary minus of `Current'.
      do
         Result := zero - Current
      end;

   divisible(other: like Current): BOOLEAN is
         -- May `Current' be divided by `other' ?
      require
         other /= Void
      deferred
      end;

   one: like Current is
         -- Neutral element for "*" and "/".
      deferred
      end;

   zero: like Current is
         -- Neutral element for "+" and "-".
      deferred
      end;
   
   sign: INTEGER is
         -- Sign of Current (0 -1 or 1).
      deferred
      ensure
         -1 <= Result; Result <= 1
      end;

end --  NUMERIC


