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
class PLATFORM

inherit GENERAL;
   
feature -- Maximum :

   Maximum_character_code : INTEGER is
         -- Largest supported code for CHARACTER values.
      external "SmallEiffel"
      ensure
         meaningful: Result >= 127
      end;

   Maximum_integer: INTEGER is
         -- Largest supported value of type INTEGER.
      external "SmallEiffel"
      ensure
         meaningful: Result >= 0
      end;

   Maximum_real: REAL is
         -- Largest supported value of type REAL.
      external "SmallEiffel"
      ensure
         meaningful: Result >= 0.0
      end;

   Maximum_double: DOUBLE is
         -- Largest supported value of type DOUBLE.
      external "SmallEiffel"
      ensure
         meaningful: Result >= Maximum_real
      end;

feature -- Minimum :

   Minimum_character_code: INTEGER is
         -- Smallest supported code for CHARACTER values.
      external "SmallEiffel"
      ensure
         meaningful: Result <= 0
      end;
   
   Minimum_integer: INTEGER is
         -- Smallest supported value of type INTEGER.
      external "SmallEiffel"
      ensure
         meaningful: Result <= 0
      end;

   Minimum_double: DOUBLE is
         -- Smallest supported value of type DOUBLE.
      external "SmallEiffel"
      ensure
         meaningful: Result <= 0.0
      end;

   Minimum_real: REAL is
         -- Smallest supported value of type REAL.
      external "SmallEiffel"
      ensure
         meaningful: Result <= 0.0
      end;

feature -- Bits :

   Boolean_bits: INTEGER is
         -- Number of bits in a value of type BOOLEAN.
      external "SmallEiffel"
      ensure
         meaningful: Result >= 1
      end;

   Character_bits: INTEGER is
         -- Number of bits in a value of type CHARACTER.
      external "SmallEiffel"
      ensure
         meaningful: Result >= 1;
         large_enough: (2^Result) >= Maximum_character_code;
      end;

   Integer_bits: INTEGER is
         -- Number of bits in a value of type INTEGER.
      external "SmallEiffel"
      ensure
         meaningful: Result >= 1;
      end;
   
   Real_bits: INTEGER is
         -- Number of bits in a value of type REAL.
      external "SmallEiffel"
      ensure
         meaningful: Result >= 1
      end;

   Double_bits: INTEGER is
         -- Number of bits in a value of type DOUBLE.
      external "SmallEiffel"
      ensure
         meaningful: Result >= 1;
         meaningful: Result >= Real_bits
      end;

   Pointer_bits: INTEGER is
         -- Number of bits in a value of type POINTER.
      external "SmallEiffel"
      end;

end -- PLATFORM

