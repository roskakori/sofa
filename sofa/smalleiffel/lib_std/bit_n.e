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
expanded class BIT_N
--
-- Indexed Bit sequences of length `N'. This class is a template,
-- not a real class; to obtain a meaningful class, replace `N' 
-- with a positive integer throughout.
-- 
-- An INTEGER index can be used to access each bit of the sequence.
-- The leftmost bit has index 1 and the rightmost bit has index `N'.
--
-- Note 1 : corresponding C mapping depends on actual `N' and is 
--        PLATFORM dependant (see class PLATFORM).
--        When `N' is in range [0  .. Character_bits], C type 
--        is a simple "unsigned char".
--        When `N' is in range [Character_bits+1 .. Integer_bits],
--        C type is "unsigned".
--        When `N' is greater than Integer_bits, C type is C array
--        of "unsigned" of the form :
--                 "unsigned storage[`N' div Integer_bits]"
--        The array is obviously big enough to fit with `N'. As
--        for previous mapping, the left most bit (at index 1 in 
--        Eiffel) is always the left most in C memory.
--
-- Note 2 : Eiffel BIT code is portable. Generated C code for class
--        BIT may not be portable (because sizeof(int) may change).
--        To produce a portable C code, you can compile your Eiffel
--        code using a machine with very small sizeof(int). Also note
--        that doing this may run a little bit slowly.
--
-- Also consider class BIT_STRING for long bit sequences.
--
inherit 
   BIT_N_REF 
      redefine out_in_tagged_out_memory, fill_tagged_out_memory
   end;

feature -- Basic Accessing :
   
   count: INTEGER is
         -- Number of bits in the sequence (the value of `N').
      external "SmallEiffel"
      end;

   item(idx: INTEGER): BOOLEAN is
         -- True if `idx'-th bit is 1, false otherwise.
      require
         inside_bounds: 1 <= idx and then idx <= count
      external "SmallEiffel"
      end;
   
   put(value: BOOLEAN; idx: INTEGER) is
         -- Set bit `idx' to 1 if value is true, 0 otherwise.
      require
         inside_bounds: 1 <= idx and idx <= count
      external "SmallEiffel"
      ensure
         value = item(idx)
      end;

   put_1(idx: INTEGER) is
         -- Set bit `idx' to 1.
      require
         inside_bounds: 1 <= idx and idx <= count
      external "SmallEiffel"
      ensure
         item(idx)
      end;

   put_0(idx: INTEGER) is
         -- Set bit `idx' to 0.
      require
         inside_bounds: 1 <= idx and idx <= count
      external "SmallEiffel"
      ensure
         not item(idx)
      end;

   first: BOOLEAN is
         -- The value of the right-most bit.
      do
         Result := item(1);
      ensure
         definition: Result = item(1)
      end;

   last: BOOLEAN is
         -- The value of the right-most bit.
      external "SmallEiffel"
      ensure
         definition: Result = item(count)
      end;

feature -- Rotating and shifting :

   infix "^" (s: INTEGER): like Current is 
         -- Sequence shifted by `s' positions (positive `s' shifts 
         -- right, negative left; bits falling off the sequence's
         -- bounds are lost).
         -- See also infix "@>>" and infix "@<<".
      require
         s.abs < count
      do
         if s >= 0 then
            if s = 0 then
               Result := Current;
            else
               Result := Current @>> s;
            end;
         else
            Result := Current @<< -s;
         end;
      end;

   infix "@>>" (s: INTEGER): like Current is 
         -- Sequence shifted right by `s' positions.
         -- Same as infix "^" when `s' is positive (may run a little 
         -- bit faster).
      require
         s > 0
      external "SmallEiffel"
      end;

   infix "@<<" (s: INTEGER): like Current is 
         -- Sequence shifted left by `s' positions.
         -- Same as infix "^" when `s' is negative (may run a little 
         -- bit faster.
      require
         s > 0
      external "SmallEiffel"
      end;

   infix "#" (s: INTEGER): like Current is 
         -- Sequence rotated by `s' positions (positive right,
         -- negative left).
      require
         s.abs < count;
      do
         if s >= 0 then
            Result := Current #>> s;
         else
            Result := Current #<< -s;
         end;
      end
 
   infix "#>>" (s: INTEGER): like Current is 
         -- Sequence rotated by `s' positions right.      
      require
         s >= 0;
         s < count
      local
         i: INTEGER;
         bit: BOOLEAN;
      do
         Result := Current;
         from
            i := s;
         until
            i = 0
         loop
            bit := Result.item(count);
            Result := Result @>> 1;
            Result.put(bit,1);
            i := i - 1;
         end;
      end;
   
   infix "#<<" (s: INTEGER): like Current is 
             -- Sequence rotated by `s' positions left.      
      require
         s >= 0;
         s < count
      local
         i: INTEGER;
         bit: BOOLEAN;
      do
         from
            i := s;
            Result := Current;
         until
            i = 0
         loop
            bit := Result.item(1);
            Result := Result @<< 1;
            Result.put(bit,count);
            i := i - 1;
         end;
      end;
   
feature -- Bitwise Logical Operators :

   infix "and" (other: like Current): like Current is
         -- Bitwise `and' of Current with `other'
      external "SmallEiffel"
      end;

   infix "implies" (other: like Current): like Current is
         -- Bitwise implication of Current with `other'
      do
         Result := (not Current) or other;
      end;

   prefix "not": like Current is
         -- Bitwise `not' of Current.
      external "SmallEiffel"
      end;

   infix "or" (other: like Current): like Current is
         -- Bitwise `or' of Current with `other'
      external "SmallEiffel"
      end;

   infix "xor" (other : like Current) : like Current is
         -- Bitwise `xor' of Current with `other'
      external "SmallEiffel"
      end;

feature -- Conversions :

   to_string: STRING is
         -- String representation of bit sequence. 
         -- A zero bit is mapped to '0', a one bit to '1'. 
         -- Leftmost bit is at index 1 in the returned string.
         --
         -- Note: see `append_in' to save memory.
      do
         tmp_string.clear;
         append_in(tmp_string);
         Result := tmp_string.twin;
      ensure then
         Result.count = count
      end;
   
   to_integer: INTEGER is
         -- The corresponding INTEGER value.
         -- No sign-extension when `count' < `Integer_bits'.
      require
         count <= Integer_bits
      external "SmallEiffel"
      end;

   to_character: CHARACTER is
      require
         count <= Character_bits
      external "SmallEiffel"
      end;

   to_boolean: BOOLEAN is
         -- Return false if and only if all bits are set to 0, 
         -- true otherwise.
      local
         zero: like Current;
      do
         Result := Current /= zero;
      end;

   to_bit_string: BIT_STRING is
      local
         i: INTEGER;
      do
         from
            !!Result.make(count);
            i := count;
         until
            i = 0
         loop
            if item(i) then
               Result.put_1(i);
            end;
            i := i - 1;
         end;
      ensure
         count = Result.count
      end;

feature -- Others :

   all_cleared, all_default: BOOLEAN is
         -- Are all bits set to 0 ?
      local
         zero: like Current;
      do
         Result := Current = zero;
      end;

   all_set: BOOLEAN is
         -- Are all bits set to 1 ?
      local
         zero: like Current;
      do
         Result := Current = not zero;
      end;

feature -- Printing :

   append_in(str: STRING) is
      local
         i: INTEGER;
      do
         from  
            i := 1;
         until
            i > count
         loop
            if item(i) then
               str.extend('1');
            else
               str.extend('0');
            end;
            i := i + 1;
         end;
      end;
   
   out_in_tagged_out_memory, fill_tagged_out_memory is
      do
         Current.append_in(tagged_out_memory);
         tagged_out_memory.extend('B');
      end;

feature {NONE}

   tmp_string: STRING is
      once
         !!Result.make(128);
      end;

end -- BIT_N

