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
class LARGE_POSITIVE_INTEGER
--
-- To implement NUMBER (do not use this class, see NUMBER).
--
    
inherit LARGE_INTEGER;
   
creation make_from_fixed_array, make_smaller, make_from_product, make_big
   
feature

   is_positive: BOOLEAN is true;
   
   is_negative: BOOLEAN is false;
   
   to_integer: INTEGER is
      do
	 check false end;
      end;
   
   to_double: DOUBLE is
      do
	 Result := fixed_array_to_double(value);
      end;
   
   prefix "-" : NUMBER is
      do
	 if (value.item(1) = 1) and (value.item(0) = 0) then
	    !SMALL_INTEGER!Result.make(-Base);
	 else
	    !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(value);
	 end;
      end;
   
   
   infix "+" (other: NUMBER): NUMBER is
      do
	 Result := other.add_with_large_positive_integer(Current);
      end;
 
feature {NUMBER}
   
   add_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is
      do
	 add_fixed_arrays(value, other.value);
	 !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(clone(temp));
      end;
   
   add_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is
      do
	 if fixed_array_greater_than(value, other.value) then
	    difference_between_fixed_arrays(value, other.value);
	    Result := create_positive(temp);
	 else
	    difference_between_fixed_arrays(other.value, value);
	    Result := create_negative(temp);
	 end;
      end;
   
   add_with_small_fraction (other: SMALL_FRACTION ): NUMBER is
      do
	 Result := other.add_with_large_positive_integer( Current );
      end;
      
   add_with_large_fraction (other: LARGE_FRACTION): NUMBER is
      do
	 Result := other.add_with_large_positive_integer( Current );
      end;

   infix "@+" (other: INTEGER): NUMBER is
      do	 
	 if (other >= 0) then
	    temp_1_digint.put(other, 0);
	    add_fixed_arrays(value, temp_1_digint);
	    !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(clone(temp));
	 else
	    if (other /= Minimum_integer) then
	       temp_1_digint.put(other.abs, 0);
	       difference_between_fixed_arrays(value, temp_1_digint);
	    else
	       temp_2_digints.put(0,0);
	       temp_2_digints.put(1,1);
	       difference_between_fixed_arrays(value, temp_2_digints);
	    end;
	    Result := create_positive(temp);
	 end;
      end; 
      
feature {NUMBER} -- Multiplication
   
   infix "*" (other: NUMBER): NUMBER is
      do
	 Result := other.multiply_with_large_positive_integer(Current);
      end;
   
   multiply_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is
      do
	 mult_2_fixed(value, other.value);
	 !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(clone(temp_from_mult));
      end;
   
   multiply_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is
      do 
	 mult_2_fixed(value, other.value);
	 !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(clone(temp_from_mult));
      end;
   
   multiply_with_small_fraction (other: SMALL_FRACTION ): NUMBER is
      do
	 Result := other.multiply_with_large_positive_integer(Current);
      end;
   
   multiply_with_large_fraction (other: LARGE_FRACTION ): NUMBER is
      do
	 Result := other.multiply_with_large_positive_integer(Current);
      end; 
   
   infix "@*"(other : INTEGER): NUMBER is
      do
	 if (other = 0) then
	    Result := zero;
	 elseif (other > 0) then 
	    mult_fixed_with_integer(value, other);
	    !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(clone(temp));
	 else
	    if (other = Minimum_integer) then
	       mult_2_fixed(value, smaller_correct_fixed);
	       !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(clone(temp_from_mult));
	    else
	       mult_fixed_with_integer(value, other.abs);
	       !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(clone(temp));
	    end;
	 end;
      end;
   
   
feature {NUMBER} -- division
   
   infix "@/"(other : INTEGER): NUMBER is
      local
	 den: ABSTRACT_INTEGER;
      do
	 if (other = 1) then
	    Result := Current;
	 else
	    if (other = Minimum_integer) then
	       divise_fixed_array(value, smaller_correct_fixed);
	    else
	       temp_1_digint.put(other.abs,0);
	       divise_fixed_array(value, temp_1_digint);
	    end;
	    if (temp_remainder.upper < 0) then
	       if (other < 0) then 
		  Result := create_negative(temp_quotient);
	       else
		  Result := create_positive(temp_quotient);
	       end;
	    else
	       if (other = Minimum_integer) then
		  den := greater_large_negative_integer;
		  !LARGE_FRACTION!Result.make_simply(Current, den, true);
	       else
		  !SMALL_INTEGER!den.make(other);
		  !LARGE_FRACTION!Result.make_simply(Current, den, (other < 0));
	       end;
	    end;
	 end;
      end;

   -- Integer division
   
   infix "//" (other: NUMBER): NUMBER is
      local
	 oth: ABSTRACT_INTEGER;
      do
	 oth ?= other;
	 Result := oth.integer_divide_large_positive_integer(Current);
      end;
   
   integer_divide_small_integer(other: SMALL_INTEGER): ABSTRACT_INTEGER is
      do
	 if (other @= Minimum_integer) then
	    divise_fixed_array(smaller_correct_fixed, value);
	    Result := create_negative(temp_quotient);
	 else	
	    temp_1_digint.put(other.to_integer.abs,0); 
	    divise_fixed_array(temp_1_digint, value);
	    if (other @< 0) then
	       Result := create_negative(temp_quotient);
	    else
	       Result := create_positive(temp_quotient);
	    end;
	 end;
      end; 
      
   integer_divide_large_positive_integer(other: LARGE_POSITIVE_INTEGER): ABSTRACT_INTEGER is
      do
	 divise_fixed_array(other.value, value);
	 Result := create_positive(temp_quotient);
      end;
   
   integer_divide_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): ABSTRACT_INTEGER is
      do      
	 divise_fixed_array(other.value, value);
	 Result := create_negative(temp_quotient);
      end;
   
   infix "@//"(other : INTEGER): NUMBER is
      do
	 if (other = Minimum_integer) then
	    divise_fixed_array(value, smaller_correct_fixed);
	    Result := create_negative(temp_quotient);
	 else	
	    temp_1_digint.put(other.abs,0);
	    divise_fixed_array(value, temp_1_digint);
	    if (other < 0) then
	       Result := create_negative(temp_quotient);
	    else
	       Result := create_positive(temp_quotient);
	    end;
	 end;
      end;

   -- Remainder of an integer division
   
   infix "\\" (other: NUMBER): NUMBER is
      local
	 oth: ABSTRACT_INTEGER;
      do
	 oth ?= other;
	 Result := oth.remainder_of_divide_large_positive_integer(Current);
      end;
   
   remainder_of_divide_small_integer(other: SMALL_INTEGER): ABSTRACT_INTEGER is
      do
	 if (other @= Minimum_integer) then
	    divise_fixed_array(smaller_correct_fixed, value);
	    Result := create_negative(temp_remainder);
	 else	
	    temp_1_digint.put(other.to_integer.abs,0);
	    divise_fixed_array(temp_1_digint, value);
	    if (other @< 0) then
	       Result := create_negative(temp_remainder);
	    else
	       Result := create_positive(temp_remainder);
	    end;
	 end;
      end; 
      
   remainder_of_divide_large_positive_integer(other: LARGE_POSITIVE_INTEGER): ABSTRACT_INTEGER is
      do
	 divise_fixed_array(other.value, value);
	 Result := create_positive(temp_remainder);
      end;
   
   remainder_of_divide_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): ABSTRACT_INTEGER is
      do
	 divise_fixed_array(other.value, value);
	 Result := create_negative(temp_remainder);
      end;

   infix "@\\" (other: INTEGER): NUMBER is
      do
	 if (other = Minimum_integer) then
	    divise_fixed_array(value, smaller_correct_fixed);
	    Result := create_negative(temp_remainder);
	 else	
	    temp_1_digint.put(other.abs,0);
	    divise_fixed_array(value, temp_1_digint);
	    if (other < 0) then
	       Result := create_negative(temp_remainder);
	    else
	       Result := create_positive(temp_remainder);
	    end;
	 end;	    
      end;
   
   
feature {NUMBER} -- inverse   
   
   inverse: NUMBER is
      local
	 num: ABSTRACT_INTEGER;
      do
	 num ?= one;
	 !LARGE_FRACTION!Result.make_simply(num, Current, false);
      end;
      
   
feature -- comparisons with INTEGER
   
   infix "@=" (other: INTEGER): BOOLEAN is
      do
      end;
   
   infix "@<" (other: INTEGER): BOOLEAN is
      do
      end;
   
   infix "@>" (other: INTEGER): BOOLEAN is 
      do
	 Result := true;
      end;
   
   infix "@>=" (other: INTEGER): BOOLEAN is 
      do
	 Result := true;
      end;
   
   infix "@<=" (other: INTEGER): BOOLEAN is 
      do
      end;
   
feature -- comparisons with NUMBER
   
   infix "<" (other: NUMBER): BOOLEAN is
      do
	 Result := other.greater_with_large_positive_integer(Current);
      end;
   
feature -- comparisons with DOUBLE 
   
   infix "#=" (other: DOUBLE): BOOLEAN is
      do
	 if other <= Maximum_integer then
	 else
	    Result := to_double = other;
	 end;
      end;
   
   infix "#<" (other: DOUBLE): BOOLEAN is
      do
	 if other <= Maximum_integer then
	 else
	    Result := to_double < other;
	 end;
      end;
   
   infix "#<=" (other: DOUBLE): BOOLEAN is
      do
	 if other <= Maximum_integer then
	 else
	    Result := to_double <= other;
	 end;
      end;
   
   infix "#>" (other: DOUBLE): BOOLEAN is
      do
	 if other <= Maximum_integer then
	    Result := true 
	 else
	    Result := to_double > other;
	 end;
      end;
   
   infix "#>=" (other: DOUBLE): BOOLEAN is
      do
	 if other <= Maximum_integer then
	    Result := true
	 else
	    Result := to_double >= other;
	 end;
      end;
   
feature {NUMBER}
   
   greater_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): BOOLEAN is 
      local
	 i: INTEGER;
      do 	 
	 if (value.upper = other.value.upper) then
	    from
	       i := value.upper;
	    variant
	       i
	    until
	       (i < value.lower) or else (value.item(i) /= other.value.item(i))
	    loop
	       i := i - 1;
	    end;	    
	    Result := (i /= value.lower - 1) 
	       and then (value.item(i) > other.value.item(i));
	 else	    
	    Result := (value.upper > other.value.upper);  
	 end;
      end;   
   
   greater_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): BOOLEAN is 
      once
	 Result := true;
      end;
   
   greater_with_small_fraction (other: SMALL_FRACTION): BOOLEAN is
      once
	 Result := true;
      end;   
   
   greater_with_large_fraction (other: LARGE_FRACTION): BOOLEAN is
      do
	 Result := not other.greater_with_large_positive_integer(Current);
      end;   
   
   
end -- LARGE_POSITIVE_INTEGER




