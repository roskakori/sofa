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

-- The Maximum_integer number is 2147483647 so a SMALL INTEGER must 
-- be on 9 digits, so the biggest SMALL INTEGER is 999999999 and the 
-- smallest SMALL INTEGER is -999999999

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

   is_integer_value: BOOLEAN is
      do
	 Result := true;
      end;
   
   to_integer: INTEGER is
      do
	 Result := value;
      end;
   
   to_double: DOUBLE is
      do
	 Result := value;
      end;   
   
   
   append_in(str:STRING) is
      do
	 str.append(value.to_string);
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
	 sum : INTEGER;
	 an : NUMBER;
      do
	 sum := value + other;
	 if other >= Base then
	    !LARGE_POSITIVE_INTEGER!an.make_smaller(other);
	    Result := an @+ value;
	 elseif other <= -Base then
	    !LARGE_NEGATIVE_INTEGER!an.make_smaller(other);
	    Result := an @+ value;
	 else
	    if sum >= Base then
	       !LARGE_POSITIVE_INTEGER!Result.make_smaller(sum);
	    elseif sum <= -Base then
	       !LARGE_NEGATIVE_INTEGER!Result.make_smaller(-sum);
	    else
	       !SMALL_INTEGER!Result.make(sum);
	    end;
	 end;
      end;
	 
--	    if value <= 0 and (other < 0) and (sum > 0) then
--	    !LARGE_NEGATIVE_INTEGER!Result.make_smaller(-sum - Base)
--	 elseif (sum = -Base) then
--	    Result := greater_large_negative_integer;
--	 else
--	    !SMALL_INTEGER!Result.make(sum);
--	 end;
--      end;
   
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
	 d1, d2: INTEGER;
      do
	 if other = 0 or else value = 0 then
	    !SMALL_INTEGER!Result.make(0);
	 elseif other = 1 then
	    !SMALL_INTEGER!Result.make(value);
	 elseif value = 1 then
	    if other >= Base then
	       !LARGE_POSITIVE_INTEGER!Result.make_smaller(other);
	    elseif other <= -Base then
	       !LARGE_NEGATIVE_INTEGER!Result.make_smaller(other);
	    else
	       !SMALL_INTEGER!Result.make(other);
	    end;
	 elseif other >= Base then
	    if value > 0 then
	       !LARGE_POSITIVE_INTEGER!Result.make_from_large_product(value, other);
	    else
	       !LARGE_NEGATIVE_INTEGER!Result.make_from_large_product(value, other);
	    end;
	 elseif other <= -Base then
	    if value > 0 then
	       !LARGE_NEGATIVE_INTEGER!Result.make_from_large_product(value, other);
	    else
	       !LARGE_POSITIVE_INTEGER!Result.make_from_large_product(value, other);
	    end;
	 else
	    d1 := value.abs;
	    d2 := other.abs;
	    if ((d1.log + d2.log - Log_base) * 10000).truncated_to_integer >= 0  or else d1 * d2 < 0 then
	       if value > 0 then
		  if other > 0 then
		     !LARGE_POSITIVE_INTEGER!Result.make_from_product(d1, d2);
		  else
		     !LARGE_NEGATIVE_INTEGER!Result.make_from_product(d1, d2);
		  end;
	       else
		  if other > 0 then
		     !LARGE_NEGATIVE_INTEGER!Result.make_from_product(d1, d2);
		  else
		     !LARGE_POSITIVE_INTEGER!Result.make_from_product(d1, d2);
		  end;
	       end;
	    else
	       !SMALL_INTEGER!Result.make(value * other);
	    end;
	 end;
      end;
   
   infix "@/" (other: INTEGER): NUMBER is
      local
	 tmp: INTEGER_FRACTION;
	 n, d: ABSTRACT_INTEGER;
	 val: INTEGER;
      do
	 if (other = 1) then
	    Result := Current;
	 else	    
	    if (value \\ other) = 0  then
	       val := value // other;
	       if val >= Base then
		  !LARGE_POSITIVE_INTEGER!Result.make_smaller(val);
	       elseif val <= (-1 * Base) then
		  !LARGE_NEGATIVE_INTEGER!Result.make_smaller(val);
	       else
		  !SMALL_INTEGER!Result.make(value // other);
	       end;
	    elseif other <= (-1 * Base) then
	       n ?= abs;
	       !LARGE_NEGATIVE_INTEGER!d.make_smaller(other);
	       !NUMBER_FRACTION!Result.make( n, d, is_positive);
	    elseif other >= Base then
	       n ?= abs;
	       !LARGE_NEGATIVE_INTEGER!d.make_smaller(other);
	       !NUMBER_FRACTION!Result.make( n, d, is_positive);
	    else       
	       !!tmp.make(1,2);
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
      local
	 tmp: INTEGER;
      do
	 tmp := value // other;
	 if tmp >= Base then
	    !LARGE_POSITIVE_INTEGER!Result.make_smaller(tmp);
	 elseif tmp <= (-1 * Base) then
	    !LARGE_NEGATIVE_INTEGER!Result.make_smaller(tmp);
	 else
	    !SMALL_INTEGER!Result.make(value // other);
	 end;
      end;
   
   infix "\\" (other: NUMBER): NUMBER is
      local
	 oth: ABSTRACT_INTEGER;
      do
	 oth ?= other;
	 Result := oth.remainder_of_divide_small_integer(Current);
      end;
   
   infix "@\\" (other : INTEGER): NUMBER is
      local
	 tmp: INTEGER;
      do
	 tmp := value \\ other;
	 if tmp >= Base then
	    !LARGE_POSITIVE_INTEGER!Result.make_smaller(tmp);
	 elseif tmp <= (-1 * Base) then
	    !LARGE_NEGATIVE_INTEGER!Result.make_smaller(tmp);
	 else
	    !SMALL_INTEGER!Result.make(tmp);
	 end;
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
   
   add_with_small_fraction (other: INTEGER_FRACTION ): NUMBER is
      do
	 Result:= other @+ value;
      end;
   
   add_with_large_fraction (other: NUMBER_FRACTION): NUMBER is
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
   
   multiply_with_small_fraction (other: INTEGER_FRACTION): NUMBER is
      do
	 Result:=other.multiply_with_small_integer(Current);
      end;
   
   multiply_with_large_fraction (other: NUMBER_FRACTION): NUMBER is
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
	    !INTEGER_FRACTION!Result.make(sign, value.abs);
	 end;
      end;
   
   greater_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): BOOLEAN is 
      do
      end;
    
   greater_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): BOOLEAN is 
      do
	 Result := true; 
      end;
   
   greater_with_small_fraction(other: INTEGER_FRACTION): BOOLEAN is  
      do   
	 Result := (Current @* other.denominator) @> other.numerator; 
      end;  
   
   greater_with_large_fraction(other: NUMBER_FRACTION): BOOLEAN is  
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
   
   value < Base and value > -Base;
   
end
