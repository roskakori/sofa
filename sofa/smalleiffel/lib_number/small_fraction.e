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
class SMALL_FRACTION
--
-- To implement NUMBER (do not use this class, see NUMBER).
--
          
inherit ABSTRACT_FRACTION;
   
creation make, make_from_integer
   
feature 
   
   is_positive: BOOLEAN is
      do
	 Result := numerator >= 0;
      end;

   is_negative: BOOLEAN is
      do
	 Result := numerator < 0;
      end;

   is_equal(other: like Current): BOOLEAN is  
      do   
	 Result := standard_is_equal(other);
      end;  

   to_double: DOUBLE is
      do
	 Result := numerator / denominator;
      end;   
      
   prefix "-": NUMBER is  
      do   
	 !SMALL_FRACTION!Result.make(-numerator,denominator); 
      end;   
   
   infix "+"(other: NUMBER): NUMBER is  
      do   
	 Result := other.add_with_small_fraction(Current); 
      end;  

   infix "@+"(other: INTEGER): NUMBER is
	 -- Sum of 'Current' and 'other'.  
      local
	 sum : ABSTRACT_INTEGER;
      do   	 
	 sum ?= small_numerator + (small_denominator @* other);
	 check
	    sum /= Void;
	 end;
	 Result := from_abstract_integer_and_integer(sum,denominator);
      end;  
 
   infix "*"(other: NUMBER): NUMBER is
      do
	 Result := other.multiply_with_small_fraction(Current);
      end;
   
   infix "@*"(other: INTEGER): NUMBER is  
      local  
	 tmp: ABSTRACT_INTEGER;
      do 
	 if (other = 1) then
	    Result := Current;
	 elseif (other = -1) then
	    Result := -Current;
	 else
	    tmp ?= small_numerator @* other;
	    check
	       tmp /= Void;
	    end;
	    Result := from_abstract_integer_and_integer(tmp,denominator);
	 end;
      end;  
   
   infix "@/"(other: INTEGER): NUMBER is  
      do 	 
	 if (other = 1) then	    
	    Result := Current;
	 elseif (other = -1) then
	    Result := -Current;
	 else
	    Result := Current * from_two_integer(1,other);
	 end; 
      end;
   
   inverse: NUMBER is  
      do   
	 if (numerator = 1) then  
	    Result := small_denominator; 
	 elseif (numerator = -1) then
	    Result := - small_denominator;
	 else  
	    !SMALL_FRACTION!Result.make(denominator,numerator); 
	 end;  
      end;  

   infix "@<"(other: INTEGER): BOOLEAN is  
      do
	 Result := to_double < other.to_double
      end;      
   
   infix "@>"(other: INTEGER): BOOLEAN is
      do
 	 Result := to_double > other.to_double     
      end;
   
   infix "@<="(other: INTEGER): BOOLEAN is
      do
 	 Result := to_double <= other.to_double     
      end;   
   
   infix "@>="(other: INTEGER): BOOLEAN is
      do
 	 Result := to_double >= other.to_double     
      end;   
   
   infix "<"(other: NUMBER): BOOLEAN is  
      do   
	 Result := other.greater_with_small_fraction(Current); 
      end;  

   infix "#=" (other: DOUBLE): BOOLEAN is
      do
	 Result := (numerator / denominator) = other
      end;
	 
   
   infix "#>"(other: DOUBLE): BOOLEAN is
      do
	 Result := to_double > other 
      end;
	 
   infix "#>="(other: DOUBLE): BOOLEAN is
      do
	 Result := to_double >= other
      end;
   
   infix "#<"(other: DOUBLE): BOOLEAN is
      do
	 Result := to_double < other
      end;
   
   infix "#<="(other: DOUBLE): BOOLEAN is
      do
	 Result := to_double <= other
      end;
	 
   append_in(string : STRING) is  
      do   
	 numerator.append_in(string); 
	 string.append("/"); 
	 denominator.append_in(string); 
      end;  

feature {NUMBER}
   
   numerator: INTEGER; 
    
   denominator: INTEGER; 

   small_numerator: SMALL_INTEGER is
      do
	 !SMALL_INTEGER!Result.make(numerator);
      end;
   
   small_denominator: SMALL_INTEGER is
      do
	 !SMALL_INTEGER!Result.make(denominator);
      end;

   add_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is  
      local
	 sum: ABSTRACT_INTEGER;
      do   
	 sum ?= (other @* denominator) @+ numerator;
	 check
	    sum /= Void;
	 end;	 
	 Result := from_abstract_integer_and_integer(sum,denominator);
      end;
   
   add_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is  
      local
	 sum: ABSTRACT_INTEGER;
      do   
	 sum ?= (other @* denominator) @+ numerator;
	 check
	    sum /= Void;
	 end;
	 Result := from_abstract_integer_and_integer(sum,denominator);
      end;
      
   add_with_small_fraction(other: SMALL_FRACTION): NUMBER is  
      local  
	 sum, prod: ABSTRACT_INTEGER;
	 num1, num2, den1, den2: SMALL_INTEGER;
      do
	 num1 := small_numerator;
	 den1 := small_denominator;
	 num2 := other.small_numerator;
	 den2 := other.small_denominator;	 
	 sum ?= (num1 * den2) + (num2 * den1);
	 prod ?= den1 * den2;
	 check
	    sum /= Void;
	    prod /= Void;
	 end;
	 Result := from_two_abstract_integer(sum,prod);
      end;  
   
   add_with_large_fraction (other: LARGE_FRACTION) : NUMBER is 
      local
	 new_num, new_den: ABSTRACT_INTEGER;
      do
	 if (other.is_negative) then
	    new_num ?= (-(other.denominator) @* numerator) + (-(other.numerator) @* denominator);
	 else
	    new_num ?= (other.denominator @* numerator) + (other.numerator @* denominator);
	 end;
	 new_den ?= other.denominator @* denominator;
	 check
	    new_num /= Void;
	    new_den /= Void;
	 end;
	 Result := from_two_abstract_integer(new_num,new_den);
      end;

   
   multiply_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is  
      local
	 num: ABSTRACT_INTEGER;
      do   
	 num ?= other @* numerator;
	 check
	    num /= Void;
	 end;
	 Result := from_abstract_integer_and_integer(num,denominator);
      end;  
   
   multiply_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is  
      local
	 num: ABSTRACT_INTEGER;
      do   
	 num ?= other @* numerator;
	 check
	    num /= Void;
	 end;
	 Result := from_abstract_integer_and_integer(num,denominator);
      end;  
   
   multiply_with_small_fraction(other: SMALL_FRACTION): NUMBER is
      local
	 num, den: ABSTRACT_INTEGER;
      do
	 num ?= small_numerator * other.small_numerator;
	 den ?= small_denominator * other.small_denominator;
	 check
	    num /= Void;
	    den /= Void;
	 end;
	 Result := from_two_abstract_integer(num,den);
      end;  

   multiply_with_large_fraction(other: LARGE_FRACTION): NUMBER is
      local
	 new_num, new_den: ABSTRACT_INTEGER;
      do
	 if other.is_negative then
	    new_num ?= -(other.numerator) @* numerator;
	 else
	    new_num ?= (other.numerator @* numerator);
	 end;
	 new_den ?= other.denominator @* denominator;
	 check
	    new_num /= Void;
	    new_den /= Void;
	 end;	 
	 Result := from_two_abstract_integer(new_num,new_den);
      end;

   greater_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): BOOLEAN is 
      do
      end;
    
   greater_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): BOOLEAN is 
      once
	 Result := true; 
      end;

   greater_with_small_fraction(other: SMALL_FRACTION): BOOLEAN is  
      do   
	 Result := to_double > other.to_double; 
      end;  
   
   greater_with_large_fraction(other: LARGE_FRACTION): BOOLEAN is  
      do   
	 Result := other.greater_with_small_fraction(Current);
      end;  
    
feature {NONE}

   make(n, d: INTEGER) is  
      do
	 if d < 0 then  
	    numerator := - n; 
	    denominator := - d; 
	 else  
	    numerator := n; 
	    denominator := d; 
	 end;  
      end;  
   
   make_from_integer(n, d: INTEGER) is
      require 
	 (n \\ d) /= 0
      local 
	 pgcd : INTEGER;
      do
	 pgcd := n.abs.gcd(d.abs);
	 make(n // pgcd,d // pgcd);
      end;   
   
invariant
   
   numerator /= Minimum_integer;

   denominator > 1;

end -- SMALL_FRACTION
