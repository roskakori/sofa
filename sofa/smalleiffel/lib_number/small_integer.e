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
class SMALL_INTEGER
--
-- To implement NUMBER (do not use this class, see NUMBER).
--
inherit ABSTRACT_INTEGER;
   
creation make
   
feature

   is_zero: BOOLEAN is
      do
	 Result := value = 0;
      end;
   
   is_one: BOOLEAN is
      do
	 Result := value = 1;
      end;
   
   is_positive: BOOLEAN is
      do
	 Result := value >= 0;
      end;

   is_negative: BOOLEAN is
      do
	 Result := value < 0;
      end;

   to_integer: INTEGER is
      do
	 Result := value;
      end;
   
   to_double: DOUBLE is
      do
	 Result := value;
      end;   
   
   prefix "-" : NUMBER is
      do
	 !SMALL_INTEGER!Result.make(- value);
      end;

   infix "+" (other: NUMBER): NUMBER is
      do
	 Result := other @+ value;
      end;
   
   infix "@+" (other: INTEGER): NUMBER is
      local
	 sum : INTEGER
      do
	 sum := value + other;
	 if is_positive and (other >= 0) and (sum < 0) then
	    !LARGE_POSITIVE_INTEGER!Result.make_smaller(sum - Base)
	 elseif is_negative and (other < 0) and (sum > 0) then
	    !LARGE_NEGATIVE_INTEGER!Result.make_smaller(-sum - Base)
	 elseif (sum = -Base) then
	    Result := greater_large_negative_integer;
	 else
	    !SMALL_INTEGER!Result.make(sum);
	 end;
      end;
   
   infix "*" (other: NUMBER): NUMBER is
      do
	 if is_zero then
	    Result := zero;
	 else
	    Result := other @* value;
	 end;
      end;
   
   infix "@*" (other : INTEGER): NUMBER is
      local
	 results_sign, is_mini, other_is_mini: BOOLEAN; 
	 int : INTEGER;
      do
	 if (other = 1) then
	    Result := Current;
	 else	    
	    results_sign := (is_positive = (other >= 0));
	    is_mini := value = Minimum_integer;
	    other_is_mini := other = Minimum_integer;
	    if is_mini or other_is_mini then
	       if is_mini and other_is_mini then
		  !LARGE_POSITIVE_INTEGER!Result.make_big;
	       else
		  if other_is_mini then
		     int := value.abs;
		  else
		     int := other.abs;
		  end;	 
		  if results_sign then
		     !LARGE_POSITIVE_INTEGER!Result.make_from_product(int);
		  else
		     !LARGE_NEGATIVE_INTEGER!Result.make_from_product(int);
		  end;
	       end;
	    else
	       mult_2_integer(value.abs, other.abs);
	       if results_sign then
		  if (temp_2_digints @ 1) /= 0 then 
		     !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(
                                                         clone(temp_2_digints));
		  else
		     !SMALL_INTEGER!Result.make(temp_2_digints @ 0);
		  end;
	       else 
		  if ((temp_2_digints @ 1) = 0) then 
		     !SMALL_INTEGER!Result.make(-(temp_2_digints @ 0));
		  else
		     if ((temp_2_digints @ 1)= 1) 
			and ((temp_2_digints @ 0)=0) then 
			Result := greater_large_negative_integer;
		     else
			!LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(
                                                          clone(temp_2_digints));
		     end;
		  end;
	       end;
	    end;
	 end;	 
      end; 
   
   infix "@/" (other: INTEGER): NUMBER is
      local
	 tmp: SMALL_FRACTION;
	 n, d: ABSTRACT_INTEGER;
      do
	 if (other = 1) then
	    Result := Current;
	 else	    
	    if (value \\ other) = 0  then
	       !SMALL_INTEGER!Result.make(value // other);
	    elseif (other = Minimum_integer) then
	       n ?= abs;
	       d ?= greater_large_negative_integer.abs;
	       !LARGE_FRACTION!Result.make( n, d, is_positive);	       
	    else	       
	       Result := tmp.from_two_integer(value,other);
	    end;
	 end;
      end; 
   
   infix "//" (other: NUMBER): NUMBER is
      local
	 oth: ABSTRACT_INTEGER;
      do
	 oth ?= other;
	 Result := oth.integer_divide_small_integer(Current);
      end;
   
   infix "@//" (other: INTEGER): NUMBER is
      do
	 !SMALL_INTEGER!Result.make(value // other);
      end;
   
   infix "\\" (other: NUMBER): NUMBER is
      local
	 oth: ABSTRACT_INTEGER;
      do
	 oth ?= other;
	 Result := oth.remainder_of_divide_small_integer(Current);
      end;
   
   infix "@\\" (other : INTEGER): NUMBER is
      do
	 !SMALL_INTEGER!Result.make(value \\ other);
      end;
   
   
   infix "@=" (other: INTEGER): BOOLEAN is
      do
	 Result := value = other;
      end;
   
   infix "@<" (other: INTEGER): BOOLEAN is
      do
	 Result := value < other;
      end;
   
   infix "@<=" (other: INTEGER): BOOLEAN is
      do
	 Result := value <= other;
      end;   
   
   infix "@>" (other: INTEGER): BOOLEAN is
      do
	 Result := value > other;
      end;
   
   infix "@>=" (other: INTEGER): BOOLEAN is
      do
	 Result := value >= other;
      end;
   
   infix "#=" (other: DOUBLE): BOOLEAN is
      do
	 Result := other = value;
      end;
   
   infix "#<" (other: DOUBLE): BOOLEAN is
      do
	 Result := value < other;
      end;
   
   infix "#<=" (other: DOUBLE): BOOLEAN is
      do
	 Result := value <= other;
      end;
   
   infix "#>" (other: DOUBLE): BOOLEAN is
      do
	 Result := value > other;
      end;
   
   infix "#>=" (other: DOUBLE): BOOLEAN is
      do
	 Result := value >= other;
      end;
      
   infix "<" (other: NUMBER): BOOLEAN is
      do
	 Result := other @> value;
      end;
   
   is_equal(other: like Current): BOOLEAN is
      do
	 Result := value = other.value;
      end; 
   
feature {NUMBER}   
   
   value: INTEGER;
   
   add_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is
      do
	 Result:= other @+ value;
      end;
   
   add_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is
      do 
	 Result:= other @+ value;
      end;
   
   add_with_small_fraction (other: SMALL_FRACTION ): NUMBER is
      do
	 Result:= other @+ value;
      end;
   
   add_with_large_fraction (other: LARGE_FRACTION): NUMBER is
      do
	 Result := other @+ value;
      end;
      
   multiply_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is
      do
	 Result:=other.multiply_with_small_integer(Current);
      end;
   
   multiply_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is
      do 
	 Result:=other.multiply_with_small_integer(Current);
      end;
   
   multiply_with_small_fraction (other: SMALL_FRACTION): NUMBER is
      do
	 Result:=other.multiply_with_small_integer(Current);
      end;
   
   multiply_with_large_fraction (other: LARGE_FRACTION): NUMBER is
      do
	 Result := other.multiply_with_small_integer(Current); 
      end;
   
   integer_divide_small_integer(other: SMALL_INTEGER): ABSTRACT_INTEGER is
      do
	 Result ?= other @// value;
      end;
      
   integer_divide_large_positive_integer(other: LARGE_POSITIVE_INTEGER): ABSTRACT_INTEGER is
      do
	 Result ?= other @// value;
      end;
   
   integer_divide_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): ABSTRACT_INTEGER is
      do
	 Result ?= other @// value;      
      end;
   
   remainder_of_divide_small_integer(other: SMALL_INTEGER): ABSTRACT_INTEGER is
      do
	 Result ?= other @\\ value;
      end; 
            
   remainder_of_divide_large_positive_integer(other: LARGE_POSITIVE_INTEGER): ABSTRACT_INTEGER is
      do
	 Result ?= other @\\ value;
      end;
   
   remainder_of_divide_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): ABSTRACT_INTEGER is
      do
	 Result ?= other @\\ value;
      end;
   
   inverse: NUMBER is
      do	 	 
	 if (is_one) or else (Current @= -1) then
	    Result := Current;
	 else
	    !SMALL_FRACTION!Result.make(sign, value.abs);
	 end;
      end;
   
   greater_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): BOOLEAN is 
      do
      end;
    
   greater_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): BOOLEAN is 
      do
	 Result := true; 
      end;
   
   greater_with_small_fraction(other: SMALL_FRACTION): BOOLEAN is  
      do   
	 Result := (Current @* other.denominator) @> other.numerator; 
      end;  
   
   greater_with_large_fraction(other: LARGE_FRACTION): BOOLEAN is  
      do   
	 if other.is_negative then
	     Result := (other.denominator * Current) > (- other.numerator);
	 else
	    Result := (other.denominator * Current) > other.numerator;
	 end;
      end;     
   
feature {NONE}
   
   make(val: INTEGER) is
      do
	 value := val;
      end;

invariant   
   
   value /= Minimum_integer;
   
end
