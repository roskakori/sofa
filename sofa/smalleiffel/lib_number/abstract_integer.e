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
deferred class ABSTRACT_INTEGER
--
-- To implement NUMBER (do not use this class, see NUMBER).
--
   
inherit NUMBER   
   
feature 
   
   append_in(str: STRING) is
	 -- Append the equivalent of `to_string' at the end of 
	 -- `str'. Thus you can save memory because no other
	 -- STRING is allocate for the job.
      local
	 val: NUMBER;
	 i, j: INTEGER;
      do
	 if is_zero then
	    str.extend('0');
	 else
	    if is_negative then
	       str.extend('-');
	    end;
	    from
	       i := str.count + 1;
	       val := Current.abs;
	    until
	       val.is_zero
	    loop
	       str.extend((val @\\ 10).digit);
	       val := val @// 10;
	    end;
	    from  
	       j := str.count;
	    until
	       i >= j
	    loop
	       str.swap(i,j);
	       j := j - 1;
	       i := i + 1 ;
	    end;
	 end;
      end; 
   
feature {NUMBER}
   
   integer_divide_small_integer(other: SMALL_INTEGER): ABSTRACT_INTEGER is
      require
	 other /= Void;
      deferred      
      ensure
	 Result /= Void;
      end;
      
   remainder_of_divide_small_integer(other: SMALL_INTEGER): ABSTRACT_INTEGER is
      require
	 other /= Void;
      deferred      
      ensure
	 Result /= Void;
      end;
   
   
   integer_divide_large_positive_integer(other: LARGE_POSITIVE_INTEGER): ABSTRACT_INTEGER is
      require
	 other /= Void;
      deferred
      ensure
	 Result /= Void;
      end;
   
   remainder_of_divide_large_positive_integer(other: LARGE_POSITIVE_INTEGER): ABSTRACT_INTEGER is
      require
	 other /= Void;
      deferred
      ensure
	 Result /= Void;
      end;
   
   
   integer_divide_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): ABSTRACT_INTEGER is
      require
	 other /= Void;
      deferred 
      ensure
	 Result /= Void;
      end;
   
   remainder_of_divide_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): ABSTRACT_INTEGER is
      require
	 other /= Void;
      deferred 
      ensure
	 Result /= Void;
      end;
   
   
feature{NONE}
   
   mult_2_integer(a, b: INTEGER) is
	 -- multiply a and b and store the result in temp_2_digints
      require
	 a >= 0; 
	 b >= 0;
      local
	 left_a, left_b, right_a, right_b: INTEGER;
	 upper_half_base: INTEGER;
	 temp1, temp2: INTEGER;
      do
	 upper_half_base := 2*Half_base;
	 left_a := a // upper_half_base;
	 right_a := a \\ upper_half_base;
	 left_b := b // Half_base;
	 right_b := b \\ Half_base;
	 
	 temp_2_digints.put(left_a * left_b, 1);
	 temp_2_digints.put(right_a * right_b, 0);
	 
	 temp1 := left_a * right_b;
	 temp_2_digints.put((temp_2_digints @ 1) + (temp1 // Half_base), 1);
	 temp2 := (temp1 \\ Half_base)*upper_half_base + (temp_2_digints @ 0);
	 if (temp2 < 0) then
	    temp_2_digints.put(temp2 - Base, 0);
	    temp_2_digints.put((temp_2_digints @ 1) + 1, 1);
	 else
	    temp_2_digints.put(temp2 , 0);
	 end;
	 
	 temp1 := left_b * right_a;
	 if (temp1 < 0) then
	    temp1 := temp1 - Base;
	    temp_2_digints.put((temp_2_digints @ 1) + Half_base, 1);
	 end;
	 temp_2_digints.put((temp_2_digints @ 1)+(temp1 // upper_half_base), 1);
	 temp2 := (temp1 \\ upper_half_base)*Half_base + (temp_2_digints @ 0);
	 if (temp2 < 0) then
	    temp_2_digints.put(temp2 - Base, 0);
	    temp_2_digints.put((temp_2_digints @ 1) + 1, 1);
	 else
	    temp_2_digints.put(temp2, 0);
	 end;
      end;
      
end -- ABSTRACT_INTEGER









