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
class NUMBER_FRACTION
--
-- To implement NUMBER (do not use this class, see NUMBER).
--
       
inherit ABSTRACT_FRACTION;
   
creation make, make_simply
   
feature {NUMBER}
   
   is_negative: BOOLEAN;

   numerator: ABSTRACT_INTEGER; 
    
   denominator: ABSTRACT_INTEGER; 
   
feature {NUMBER}
   
   make (n, d: ABSTRACT_INTEGER; s: BOOLEAN) is 
	 -- create a simplified large_fraction
      require
	 n.is_positive; 
	 d.is_positive;
	 not ((n \\ d) @= 0);  
      local
	 gcd_frac,num,den: ABSTRACT_INTEGER;
      do
	 gcd_frac := n.gcd(d);
 	 num ?= n // gcd_frac; 
	 den ?= d // gcd_frac; 	 
	 numerator := num;
	 denominator := den; 
	 is_negative := s;
      end;  

   make_simply (n, d: ABSTRACT_INTEGER; s: BOOLEAN)  is 
	 -- create a large_fraction without simplify it
      require
	 n.is_positive; 
	 d.is_positive;
	 not ((n \\ d) @= 0);  
      do
	 numerator := n;
	 denominator := d; 
	 is_negative := s;
      end; 

feature

   infix "#<"(other: DOUBLE): BOOLEAN is  
      do   
	 if (Current <= max_double) and then (min_double <= Current) then
	    Result := to_double < other;
	 else 
	    Result := max_double > Current;
	 end;
      end;  
   
   is_positive: BOOLEAN is
      do
	 Result := not is_negative;
      end;
   
   append_in(string : STRING) is  
      do   
	 if is_negative then
	    string.extend('-');
	 end;
	 numerator.append_in(string); 
	 string.extend('/'); 
	 denominator.append_in(string); 
      end;  
 
   is_equal(other: like Current): BOOLEAN is  
      do
	 if is_negative then
	    if other.is_negative then
	       Result := (denominator.is_equal(other.denominator) and then 
			  numerator.is_equal(other.numerator));
	    end;
	 elseif other.is_positive then
	    Result := (denominator.is_equal(other.denominator) and then 
		       numerator.is_equal(other.numerator));
	 end;
      end;  
   
feature {NUMBER} -- To convert a NUMBER_FRACTION  
   
   to_double: DOUBLE is 
      require 
	 numerator.is_double;
	 denominator.is_double;
      do	    
	 Result := numerator.to_double / denominator.to_double;
	 if is_negative then
	    Result := - Result;
	 end;
      end;
   
feature {NUMBER} -- Opposite    
 
   prefix "-": NUMBER is  
	 -- Opposite of 'Current'.  
      do
	 !NUMBER_FRACTION!Result.make_simply(numerator,denominator,not is_negative);
      end;  
   
   
feature {NUMBER} -- Addition 
 
   infix "+"(other: NUMBER): NUMBER is  
      -- Sum of 'Current' and 'other'.  
      do
	 Result := other.add_with_large_fraction(Current); 
      end;  
   
   
   add_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is  
      local
	 num : ABSTRACT_INTEGER;
      do   
	 if (is_negative) then
	    num ?= (other * denominator) + (-numerator);
	    check
	       num /= Void;
	    end;
	 else
	    num ?= (other * denominator) + numerator;
	    check
	       num /= Void;
	    end;	    
	 end;
	 Result := from_two_abstract_integer(num,denominator);
      end;  
    
   add_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is  
      local
	 num: ABSTRACT_INTEGER;
      do   
	 if is_negative then
	    num ?= (other * denominator) + (-numerator);
	    check
	       num /= Void;
	    end;
	 else
	    num ?= (other * denominator) + numerator;
	    check
	       num /= Void;
	    end;	    
	 end;
	 Result := from_two_abstract_integer(num,denominator);	 
      end;  
   
   add_with_small_fraction(other: INTEGER_FRACTION): NUMBER is  
      do
	 Result := other.add_with_large_fraction(Current);
      end;  
   
   
   add_with_large_fraction(other: NUMBER_FRACTION): NUMBER is  
      local
	 new_num, new_den: ABSTRACT_INTEGER;
      do
	 new_den ?= denominator * other.denominator;
	 if is_negative and then other.is_negative then
	    new_num ?= (-(numerator) * other.denominator) + (-(other.numerator) * denominator);
	 elseif is_negative then
	    new_num ?= (-(numerator) * other.denominator) + (other.numerator * denominator);
	 elseif other.is_negative then
	    new_num ?= (numerator * other.denominator) + (-(other.numerator) * denominator);
	 else
	    new_num ?= (numerator * other.denominator) + (other.numerator * denominator);
	 end;
	 check
	    new_num /= Void;
	    new_den /= Void;
	 end;
	 Result := from_two_abstract_integer(new_num,new_den);
      end; 
   
   infix "@+"(other: INTEGER): NUMBER is  
      -- Sum of 'Current' and 'other'.  
      local
	 tmp: SMALL_INTEGER;
      do
	 !SMALL_INTEGER!tmp.make(other);
	 Result := add_with_small_integer(tmp);
      end;  
 
 
feature {NUMBER} -- Multiplication  
   
   infix "*" (other: NUMBER): NUMBER is
      do
	 Result := other.multiply_with_large_fraction(Current);
      end;
   
   multiply_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is  
      local
	 num: ABSTRACT_INTEGER;      
      do   
	 num ?= numerator.multiply_with_large_positive_integer(other);
	 check
	    num /= Void;
	 end;	 
	 if is_negative then
	    num ?= -num;
	    Result := from_two_abstract_integer(num,denominator);
	 else
	    Result := from_two_abstract_integer(num,denominator);	    
	 end;
      end;  
    
   multiply_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is  
      local
	 num: ABSTRACT_INTEGER;
      do   
	 num ?= numerator.multiply_with_large_negative_integer(other);
	 check
	    num /= Void;
	 end;
	 if is_negative then
	    num ?= -num;
	    Result := from_two_abstract_integer(num, denominator);
	 else
	    Result := from_two_abstract_integer(num, denominator);
	 end;
      end;  
    
   multiply_with_small_fraction(other: INTEGER_FRACTION): NUMBER is  
      do   
	Result := other.multiply_with_large_fraction(Current); 
      end;  
   
   multiply_with_large_fraction (other: NUMBER_FRACTION) : NUMBER is
      local
	 prod1, prod2: ABSTRACT_INTEGER;
      do
	 if (is_negative and then other.is_negative) or else (is_positive and then other.is_positive) then
	    prod1 ?= numerator * other.numerator;	
	 elseif is_negative then
	    prod1 ?= -numerator * other.numerator;
	 else
	    prod1 ?= numerator * -other.numerator;
	 end;
	 prod2 ?= denominator * other.denominator;	
	 check
	    prod1 /= Void;
	    prod2 /= Void;
	 end;
	 Result := from_two_abstract_integer(prod1,prod2);
      end;
   
   infix "@*"(other: INTEGER): NUMBER is  
      local  
	 tmp: SMALL_INTEGER; 
      do 
	 if numerator.is_one then
	    if is_negative then
	       Result := from_integer_and_abstract_integer(-other,denominator);
	    else
	       Result := from_integer_and_abstract_integer(other,denominator);
	    end;
	 else
	    !SMALL_INTEGER!tmp.make(other); 
	    Result := multiply_with_small_integer(tmp); 
	 end;  
      end;  
      
   infix "@/"(other: INTEGER): NUMBER is  
      do 
	 if other = 1 then
	    Result := Current;
	 else
	    Result := Current * from_two_integer(1,other);
	 end;
      end; 
   
   
feature {NUMBER} -- Inverse   
   
   inverse: NUMBER is  
      do   
	 if numerator.is_one then
	    Result := denominator;
	 elseif (-numerator).is_one then
	    Result := -denominator;
	 else
	    !NUMBER_FRACTION!Result.make_simply(denominator, numerator, is_negative);
	 end;
      end;  
   
   
feature -- Comparisons with INTEGER
   
   infix "@<"(other: INTEGER): BOOLEAN is
      do
	 Result := numerator < (denominator @* other);
      end;
   
   infix "@>"(other: INTEGER): BOOLEAN is
      do
	 Result := numerator > (denominator @* other);
      end;
   
    infix "@<="(other: INTEGER): BOOLEAN is
      do
	 Result := numerator <= (denominator @* other);
      end;
   
    infix "@>="(other: INTEGER): BOOLEAN is
      do
	 Result := numerator >= (denominator @* other);
      
      end;
   
feature -- Comparisons with NUMBER 
   
   infix "<"(other: NUMBER): BOOLEAN is  
      do   
	 Result := other.greater_with_large_fraction(Current); 
      end;  
   
feature -- Comparisons with DOUBLE
   
   infix "#=" (other: DOUBLE): BOOLEAN is
      do
	 if (Current <= max_double) and then (min_double <= Current) then
	    Result := to_double = other;
	 end;
      end;
   
   infix "#<=" (other: DOUBLE): BOOLEAN is
      do
      end
	 
	 
   infix "#>=" (other: DOUBLE): BOOLEAN is    
      do
      end

   infix "#>" (other: DOUBLE): BOOLEAN is    
      do
      end
   
   
feature{NUMBER}
   
  greater_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): BOOLEAN is  
      do
	 if is_negative then
	    Result := denominator.multiply_with_large_positive_integer(other) < -numerator;
	 else
	    Result := denominator.multiply_with_large_positive_integer(other) < numerator;
	 end;
      end;
    
   greater_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): BOOLEAN is
      do
	 if is_negative then
	    Result := denominator.multiply_with_large_negative_integer(other) < -numerator;
	 else
	    Result := denominator.multiply_with_large_negative_integer(other) < numerator;
	 end;
      end;
    
   greater_with_small_fraction(other: INTEGER_FRACTION): BOOLEAN is  
      do   
	 if is_negative then
	    Result := other.small_numerator * denominator < -numerator * other.small_denominator;
	 else
	    Result := other.small_numerator * denominator < numerator * other.small_denominator;
	 end;
      end;  
   
   greater_with_large_fraction(other: NUMBER_FRACTION): BOOLEAN is  
      do   
	 if is_negative and then other.is_negative then
	    Result := numerator * other.denominator < other.numerator * denominator;
	 elseif is_negative then
	    Result := other.numerator * denominator < -numerator * other.denominator;
	 elseif other.is_negative then
	    Result := -other.numerator * denominator < numerator * other.denominator;
	 else
	    Result := other.numerator * denominator < numerator * other.denominator;
	 end;
      end;     
    
invariant  
    
   not (numerator.is_small_integer and denominator.is_small_integer);

end -- NUMBER_FRACTION






