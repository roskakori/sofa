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
class LARGE_NEGATIVE_INTEGER
--
-- To implement NUMBER (do not use this class, see NUMBER).
--
       
inherit LARGE_INTEGER;
   
creation make_from_fixed_array, make_smaller, make_from_large_product, make_from_product, make_big

feature

   is_positive: BOOLEAN is false;
   
   is_negative: BOOLEAN is true;
   
   is_integer_value:BOOLEAN is
      local
	 d_1_mi: INTEGER;
      do
	 if value.upper <= 1 then
	    d_1_mi := (Minimum_integer // Base).abs;
	    Result := (value.item(value.upper) < d_1_mi) or else ((value.item(value.upper) = d_1_mi) and then (value.item(value.lower) <= (Minimum_integer \\ Base).abs));
	 end;
      end;
   
   to_integer: INTEGER is
      do
	 Result := -storage.item(0) - storage.item(1) * Base;
      end;
   
   to_double: DOUBLE is
      do
	 Result := - fixed_array_to_double(value);
      end;
   
   prefix "-": NUMBER is
      do
	 !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(value);
      end;

	 
   infix "+" (other: NUMBER): NUMBER is
      do
	 Result := other.add_with_large_negative_integer(Current);
      end;
 
   infix "@+" (other: INTEGER): NUMBER is
      local
	 oth: NUMBER;
	 i, calcul:INTEGER;
	 tmp: FIXED_ARRAY[INTEGER];
	 transit: INTEGER;
      do
	 if other = 0 then
	    Result := Current;
	 else
	    if other >= Base then
	       -- Boostable
	       !LARGE_POSITIVE_INTEGER!oth.make_smaller(other);
	       Result := oth.add_with_large_negative_integer(Current);
	    elseif other <= -Base then
	       !LARGE_NEGATIVE_INTEGER!oth.make_smaller(other);
	       Result := oth.add_with_large_negative_integer(Current);
	    else
	       transit := -other;
	       if transit > 0 then
		  !!tmp.make(storage.count + 1);
		  from
		     i := storage.lower - 1;
		     calcul := transit;
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
		  !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(tmp);
	       else
		  !!tmp.make(storage.count);
		  from
		     i := storage.lower - 1;
		     calcul := transit;
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
		     !SMALL_INTEGER!Result.make(-tmp.item(0));
		  else
		     !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(tmp);
		  end;
	       end;
	    end;
	 end;
      end;

   infix "*" (other: NUMBER): NUMBER is
      do
	 Result := other.multiply_with_large_negative_integer(Current);
      end;
      
   infix "@*"(other : INTEGER): NUMBER is
      do
	 if (other = 0) then
	    Result := zero;
	 elseif (other > 0) then 
	    if (other >= Base) then 
	       temp_2_digints.put(other \\ Base, 0);
	       temp_2_digints.put(other // Base, 1);
	       !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(mult_2_fixed(value, temp_2_digints));
	    else
	       !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(mult_fixed_with_integer(value, other));
	    end;
	 elseif other < 0 then
	    if other <= -Base then
	       temp_2_digints.put((other \\ Base).abs, 0);
	       temp_2_digints.put((other // Base).abs, 1);
	       !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(mult_2_fixed(value, temp_2_digints));
	    else
	       !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(mult_fixed_with_integer(value, other.abs));
	    end;
	 end;
      end;
   
   infix "@/" (other: INTEGER): NUMBER is
      require
	 other /= 0;
      local      
	 d: ABSTRACT_INTEGER;
      do
	 if (other = 1) then
	    Result := Current;
	 elseif (other = -1) then
	    Result := -Current;
	 else
	    if other >= Base then
	       !LARGE_POSITIVE_INTEGER!d.make_smaller(other);
	    elseif other <= -Base then
	       !LARGE_NEGATIVE_INTEGER!d.make_smaller(other.abs);
	    else
	       !SMALL_INTEGER!d.make(other);
	    end;
	    Result := Current / d;
	 end;
      end;
   
   infix "//" (other: NUMBER): NUMBER is
      local
	 oth: ABSTRACT_INTEGER;
      do
	 oth ?= other;
	 Result := oth.integer_divide_large_negative_integer(Current);
      end;
   
   infix "@//" (other: INTEGER): NUMBER is
      do
	 if other >= Base then
	    temp_2_digints.put(other \\ Base, 0);
	    temp_2_digints.put(other // Base, 1);
	    divise_fixed_array(value, temp_2_digints);
	    Result := create_negative(temp_quotient);
	 elseif other <= -Base then
	    temp_2_digints.put(-(other \\ Base), 0);
	    temp_2_digints.put(-(other // Base), 1);
	    divise_fixed_array(value, temp_2_digints);
	    Result := create_positive(temp_quotient);
	 else	
	    temp_1_digint.put(other.abs,0);
	    divise_fixed_array(value, temp_1_digint);
	    if (other < 0) then
	       Result := create_positive(temp_quotient);
	    else
	       Result := create_negative(temp_quotient);
	    end;
	 end;
      end;
   
   infix "\\" (other: NUMBER): NUMBER is
      local
	 oth: ABSTRACT_INTEGER;
      do
	 oth ?= other;
	 Result := oth.remainder_of_divide_large_negative_integer(Current);
      end;
   
feature {NUMBER}
   
   add_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is
      do
	 Result := other.add_with_large_negative_integer(Current);
      end;
   
   add_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is
      do
	 !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(add_fixed_arrays(value, other.value));
      end;
   
   add_with_small_fraction(other: INTEGER_FRACTION): NUMBER is
      do
	 Result := other.add_with_large_negative_integer( Current );
      end;
   
   add_with_large_fraction(other: NUMBER_FRACTION): NUMBER is
      do
	 Result := other.add_with_large_negative_integer( Current );
      end;
 	    
   multiply_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is
      do
	Result := other.multiply_with_large_negative_integer( Current ); 
      end;
   
   multiply_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is
      do 
	!LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(mult_2_fixed(value, other.value));
      end;
   
   multiply_with_small_fraction (other: INTEGER_FRACTION): NUMBER is
      do
	 Result := other.multiply_with_large_negative_integer(Current);
      end;
   
   multiply_with_large_fraction (other: NUMBER_FRACTION): NUMBER is
      do
	 Result := other.multiply_with_large_negative_integer(Current);
      end;
   
   integer_divide_small_integer(other: SMALL_INTEGER): ABSTRACT_INTEGER is
      do
	 temp_1_digint.put(other.to_integer.abs,0); 
	 divise_fixed_array(temp_1_digint, value);
	 if (other.to_integer < 0) then
	    Result := create_positive(temp_quotient);
	 else
	    Result := create_negative(temp_quotient);
	 end;
      end; 
      
   integer_divide_large_positive_integer(other: LARGE_POSITIVE_INTEGER): ABSTRACT_INTEGER is
      do
	 divise_fixed_array(other.value, value);
	 Result := create_negative(temp_quotient);
      end;
   
   integer_divide_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): ABSTRACT_INTEGER is
      do 
	 divise_fixed_array(other.value, value);
	 Result := create_positive(temp_quotient);
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
	    temp_2_digints.put(-(other \\ Base), 0);
	    temp_2_digints.put(-(other // Base), 1);
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
	 num: SMALL_INTEGER;
	 den: LARGE_POSITIVE_INTEGER;
      do
	 den ?= abs;
	 num ?= one;
	 !NUMBER_FRACTION!Result.make_simply(num, den, true);
      end;
   
   
feature -- Comparisons with INTEGER
   
   infix "@=" (other: INTEGER): BOOLEAN is
      do
	 Result := is_integer_value and then (-value.item(value.upper) * Base - value.item(value.lower) = other);
      end;
   
   infix "@<" (other: INTEGER): BOOLEAN is
      do
	 Result := (not is_integer_value)  or else ((-value.item(1) * Base - value.item(0)) < other);
      end;
   
   infix "@>" (other: INTEGER): BOOLEAN is
      do
	 Result := is_integer_value and then ((-value.item(1) * Base - value.item(0)) > other);
      end; 
   
   infix "@<=" (other: INTEGER): BOOLEAN is
      do
	 Result := (not is_integer_value) or else ((-value.item(1) * Base - value.item(0)) <= other);
      end; 
   
   infix "@>=" (other: INTEGER): BOOLEAN is
      do
	 Result := is_integer_value and then ((-value.item(1) * Base - value.item(0)) >= other);
      end; 
   
feature -- Comparisons with NUMBER
   
      infix "<" (other: NUMBER): BOOLEAN is
      do
	 Result := other.greater_with_large_negative_integer(Current);
      end
   
feature -- Comparisons with DOUBLE
   
   infix "#=" (other: DOUBLE): BOOLEAN is
      do
	 if other >= -Base then
	 else
	    Result := to_double = other;
	 end;
      end;
   
   infix "#<" (other: DOUBLE): BOOLEAN is
      do
	 if other >= -Base then
	    Result := true 
	 else
	    Result := to_double < other;
	 end;
     end;
   
   infix "#<=" (other: DOUBLE): BOOLEAN is
      do
	 if other >= -Base then
	    Result := true
	 else
	    Result := to_double <= other;
	 end;
      end;
   
   infix "#>" (other: DOUBLE): BOOLEAN is
      do
	 if other >= -Base then
	 else
	    Result := to_double > other;
	 end;
      end;
   
   infix "#>=" (other: DOUBLE): BOOLEAN is
      do
	 if other > -Base then
	 else
	    Result := to_double >= other;
	 end;
      end;
   
feature{NUMBER}
   
   greater_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): BOOLEAN is 
      do
      end;
   
   greater_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): BOOLEAN is 
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
	       and then (value.item(i) < other.value.item(i));
	 else	    
	    Result := (value.upper < other.value.upper);  
	 end;
      end;

   greater_with_small_fraction(other: INTEGER_FRACTION): BOOLEAN is 
      do
      end;
   
   greater_with_large_fraction(other: NUMBER_FRACTION): BOOLEAN is 
      do
	    Result := not(other.greater_with_large_negative_integer(Current));
      end;
   

end -- LARGE_NEGATIVE_INTEGER
