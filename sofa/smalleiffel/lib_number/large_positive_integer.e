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
   
creation make_from_fixed_array, make_smaller, make_from_large_product, make_from_product, make_big
   
feature
   
   is_positive: BOOLEAN is true;
   
   is_negative: BOOLEAN is false;
   
   is_integer_value:BOOLEAN is
      local
	 d_1_mi: INTEGER;
      do
	 if value.upper <= 1 then
	    d_1_mi := Maximum_integer // Base;
	    Result := (value.item(value.upper) < d_1_mi) or else ((value.item(value.upper) = d_1_mi) and then (value.item(value.lower) <= (Maximum_integer \\ Base)));
	 end;
      end;
   
   to_integer: INTEGER is
      do
	 Result := storage.item(0) + storage.item(1) * Base;
      end;
   
   to_double: DOUBLE is
      do
	 Result := fixed_array_to_double(value);
      end;
   
   prefix "-" : NUMBER is
      do
	 !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(value);
      end;   
   
   infix "+" (other: NUMBER): NUMBER is
      do
	 Result := other.add_with_large_positive_integer(Current);
      end;
 
feature {NUMBER}
   
   add_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is
      do
	 !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(add_fixed_arrays(value, other.value));
      end;
   
   add_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is
      do
	 if fixed_array_greater_than(value, other.value) then
	    Result := create_positive_directly(difference_between_fixed_arrays(value, other.value));
	 else
	    Result := create_negative_directly(difference_between_fixed_arrays(other.value, value));
	 end;
      end;
   
   add_with_small_fraction (other: INTEGER_FRACTION ): NUMBER is
      do
	 Result := other.add_with_large_positive_integer( Current );
      end;
      
   add_with_large_fraction (other: NUMBER_FRACTION): NUMBER is
      do
	 Result := other.add_with_large_positive_integer( Current );
      end;

   infix "@+" (other: INTEGER): NUMBER is
      local
	 i, calcul:INTEGER;
	 tmp: FIXED_ARRAY[INTEGER];
      do
	 if other = 0 then
	    Result := Current;
	 else
	    if other >= Base then
	       temp_2_digints.put(other \\ Base, 0);
	       temp_2_digints.put(other // Base, 1);
	       !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(add_fixed_arrays(value,temp_2_digints));
	    elseif other <= -Base then
	       temp_2_digints.put((other \\ Base).abs, 0);
	       temp_2_digints.put((other // Base).abs, 1);
	       if fixed_array_greater_than(value, temp_2_digints) then
		  Result := create_positive_directly(difference_between_fixed_arrays(value, temp_2_digints));
	       else
		  Result := create_negative(difference_between_fixed_arrays(temp_2_digints, value));
	       end;
	    else
	       if other > 0 then
		  !!tmp.make(storage.count + 1);
		  from
		     i := storage.lower - 1;
		     calcul := other;
		  until
		     i = storage.upper
		  loop
		     i := i + 1;
		     calcul := storage.item(i) + calcul;
		     if calcul >= Base then
			tmp.put(calcul - Base, i);
			calcul := 1;
		     else
			tmp.put(calcul, i);
			calcul := 0;
		     end;
		  end;
		  if calcul = 0 then
		     tmp.remove_last;
		  else
		     tmp.put(calcul, tmp.upper);
		  end;
		     !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(tmp);
	       else
		  !!tmp.make(storage.count);
		  from
		     i := storage.lower - 1;
		     calcul := other;
		  until
		     i = storage.upper
		  loop
		     i := i + 1;
		     calcul := storage.item(i) + calcul;
		     if calcul < 0 then
			tmp.put(calcul + Base, i);
			calcul := -1;
		     else
			tmp.put(calcul, i);
			calcul := 0;
		     end;
		  end;
		  if tmp.item(tmp.upper) = 0 then
		     tmp.remove_last;
		  end;
		  if tmp.count = 1 then
		     !SMALL_INTEGER!Result.make(tmp.item(0));
		  else
		     !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(tmp);
		  end;
	       end;
	    end;
	 end;
      end;
      
feature {NUMBER} -- Multiplication
   
   infix "*" (other: NUMBER): NUMBER is
      do
	 Result := other.multiply_with_large_positive_integer(Current);
      end;
   
   multiply_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is
      do
	 !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(mult_2_fixed(value, other.value));
      end;
   
   multiply_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is
      do 
	 !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(mult_2_fixed(value, other.value));
      end;
   
   multiply_with_small_fraction (other: INTEGER_FRACTION ): NUMBER is
      do
	 Result := other.multiply_with_large_positive_integer(Current);
      end;
   
   multiply_with_large_fraction (other: NUMBER_FRACTION ): NUMBER is
      do
	 Result := other.multiply_with_large_positive_integer(Current);
      end; 
   
   infix "@*"(other : INTEGER): NUMBER is
      do
	 if (other = 0) then
	    Result := zero;
	 elseif other > 0 then
	    if (other >= Base) then 
	       temp_2_digints.put(other \\ Base, 0);
	       temp_2_digints.put(other // Base, 1);
	       !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(mult_2_fixed(value, temp_2_digints));
	    else
	       !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(mult_fixed_with_integer(value, other));
	    end;
	 elseif other < 0 then
	    if other <= -Base then
	       temp_2_digints.put((other \\ Base).abs, 0);
	       temp_2_digints.put((other // Base).abs, 1);
	       !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(mult_2_fixed(value, temp_2_digints));
	    else
	       !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(mult_fixed_with_integer(value, other.abs));
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
	 elseif (other = -1) then
	    Result := -Current;
	 else
	    if (other >= Base) then
	       temp_2_digints.put(other \\ Base, 0);
	       temp_2_digints.put(other // Base, 1);
	       divise_fixed_array(value, temp_2_digints);
	    elseif (other <= -Base) then
	       temp_2_digints.put((other \\ Base).abs, 0);
	       temp_2_digints.put((other // Base).abs, 1);
	       divise_fixed_array(value, temp_2_digints);
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
	       if (other >= Base) then
		  !LARGE_POSITIVE_INTEGER!den.make_smaller(other);
		  !NUMBER_FRACTION!Result.make_simply(Current, den, true);
	       elseif (other <= -Base) then
		  !LARGE_POSITIVE_INTEGER!den.make_smaller(other);
		  !NUMBER_FRACTION!Result.make_simply(Current, den, true);
	       else
		  !SMALL_INTEGER!den.make(other.abs);
		  !NUMBER_FRACTION!Result.make_simply(Current, den, (other < 0));
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
	 temp_1_digint.put(other.to_integer.abs,0); 
	 divise_fixed_array(temp_1_digint, value);
	 if (other.value < 0) then
	    Result := create_negative(temp_quotient);
	 else
	    Result := create_positive(temp_quotient);
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
	 if other >= Base then
	    temp_2_digints.put(other \\ Base, 0);
	    temp_2_digints.put(other // Base, 1);
	    divise_fixed_array(value, temp_2_digints);
	    Result := create_positive(temp_quotient);
	 elseif other <= -Base then
	    temp_2_digints.put(-(other \\ Base), 0);
	    temp_2_digints.put(-(other // Base), 1);
	    divise_fixed_array(value, temp_2_digints);
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
	 temp_1_digint.put(other.to_integer.abs,0);
	 divise_fixed_array(temp_1_digint, value);
	 if (other @< 0) then
	    Result := create_negative(temp_remainder);
	 else
	    Result := create_positive(temp_remainder);
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
	 if other >= Base then
	    temp_2_digints.put(other \\ Base, 0);
	    temp_2_digints.put(other // Base, 1);
	    divise_fixed_array(value, temp_2_digints);
	    Result := create_positive(temp_quotient);
	 elseif other <= -Base then
	    temp_2_digints.put((other \\ Base).abs, 0);
	    temp_2_digints.put((other // Base).abs, 1);
	    divise_fixed_array(value, temp_2_digints);
	    Result := create_negative(temp_quotient);
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
	 !NUMBER_FRACTION!Result.make_simply(num, Current, false);
      end;
      
   
feature -- comparisons with INTEGER
   
   infix "@=" (other: INTEGER): BOOLEAN is
      do
	 Result := is_integer_value and then (value.item(value.upper) * Base + value.item(value.lower) = other);
      end;
   
   infix "@<" (other: INTEGER): BOOLEAN is
      do
	 Result := is_integer_value and then ((value.item(1) * Base + value.item(0)) < other);
      end;
   
   infix "@>" (other: INTEGER): BOOLEAN is 
      do
	 Result := (not is_integer_value) or else ((value.item(1) * Base + value.item(0)) > other);
      end;
   
   infix "@>=" (other: INTEGER): BOOLEAN is 
      do
	 Result := (not is_integer_value) or else ((value.item(1) * Base + value.item(0)) >= other);
      end;
   
   infix "@<=" (other: INTEGER): BOOLEAN is 
      do
	 Result := is_integer_value and then ((value.item(1) * Base + value.item(0)) <= other);
      end;
   
feature -- comparisons with NUMBER
   
   infix "<" (other: NUMBER): BOOLEAN is
      do
	 Result := other.greater_with_large_positive_integer(Current);
      end;
   
feature -- comparisons with DOUBLE 
   
   infix "#=" (other: DOUBLE): BOOLEAN is
      do
	 if other <= Base then
	 else
	    Result := to_double = other;
	 end;
      end;
   
   infix "#<" (other: DOUBLE): BOOLEAN is
      do
	 if other <= Base then
	 else
	    Result := to_double < other;
	 end;
      end;
   
   infix "#<=" (other: DOUBLE): BOOLEAN is
      do
	 if other <= Base then
	 else
	    Result := to_double <= other;
	 end;
      end;
   
   infix "#>" (other: DOUBLE): BOOLEAN is
      do
	 if other <= Base then
	    Result := true 
	 else
	    Result := to_double > other;
	 end;
      end;
   
   infix "#>=" (other: DOUBLE): BOOLEAN is
      do
	 if other <= Base then
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
   
   greater_with_small_fraction (other: INTEGER_FRACTION): BOOLEAN is
      once
	 Result := true;
      end;   
   
   greater_with_large_fraction (other: NUMBER_FRACTION): BOOLEAN is
      do
	 Result := not other.greater_with_large_positive_integer(Current);
      end;   
   
   
end -- LARGE_POSITIVE_INTEGER




