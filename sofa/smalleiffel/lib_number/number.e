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
deferred class  NUMBER
   --
   -- This abstract definition of a NUMBER is intended to be the unique 
   -- view of the client (do not use sub-classes names at all in the 
   -- client code). In order to create NUMBERs without using concrete 
   -- class name, the client code can inherit NUMBER_TOOLS (see directory 
   -- ${SmallEiffel}/lib_show/number for example.
   --
   
inherit
   HASHABLE
      undefine
	 is_equal
      redefine
	 fill_tagged_out_memory, out_in_tagged_out_memory
      end;      

feature -- Binary operators for two NUMBERs :
   
   infix "+" (other: NUMBER): NUMBER is
	 -- Sum of `Current' and `other'.
      require
	 other /= Void
      deferred
      ensure
	 Result /= Void
      end;

   infix "-" (other: NUMBER): NUMBER is
	 -- Difference of `Current' and `other'.
      require
	 other /= Void
      do
	 Result := Current + (- other);
      ensure
	 Result /= Void
      end;
   
   infix "*" (other: NUMBER): NUMBER is
	 -- Product of 'Current' and 'other'.
      require
	 other /= Void
      deferred
      ensure
	 Result /= Void
      end;

   infix "/" (other: NUMBER): NUMBER is
	 -- Quotient of `Current' and `other'.
      require
	 not (other @= 0)
	 divisible(other);
      do
	 Result := Current * other.inverse;
      ensure
	 Result /= Void
      end;

   infix "//" (other: NUMBER): NUMBER is
	 -- Divide Current by `other' (Integer division).
      require
	 is_abstract_integer;
	 other.is_abstract_integer;
	 divisible (other);
      deferred
      ensure
	 Result.is_abstract_integer;
      end;
   
   infix "\\" (other: NUMBER): NUMBER is
	 -- Remainder of division of Current by `other'.
      require
	 is_abstract_integer;
	 other.is_abstract_integer;
	 divisible (other);
      deferred
      ensure
	 Result.is_abstract_integer;
      end;
   
   infix "^" (exp: NUMBER): NUMBER is
	 -- 'Current' raised to 'exp'-th power.
      require
	 exp.is_abstract_integer;
	 exp.is_positive;
	 not (is_zero and then exp.is_zero);
      local
	 e: NUMBER;
	 factor: NUMBER;
      do
	 Result := one;
	 factor := Current;
	 from
	    e := exp;
	 until
	    e.is_zero
	 loop
	    if (e @\\ 2) @= 1 then
	       Result := Result * factor;
	    end;
	    e := e @// 2;
	    factor := factor * factor;
	 end;
      ensure
	 Result /= Void;
	 exp.is_zero implies Result.is_one;
      end;
   
   infix "<" (other: NUMBER): BOOLEAN is
	 -- Is `Current' strictly less than `other'?
      require
	 other_exists: other /= Void;
      deferred
      ensure
	 asymmetric: Result implies not (other <= Current);  
      end;
   
   infix "<=" (other: NUMBER): BOOLEAN is
	 -- Is `Current' less or equal than `other'?
      require
	 other_exists: other /= Void;
      do
	 Result := not (other < Current);
      ensure
	 definition: Result = (Current < other) or same_as(other);
      end;
   
   infix ">" (other: NUMBER): BOOLEAN is
	 -- Is `Current' strictly greater than `other'?
      require
	 other_exists: other /= Void;
      do
	 Result := (other < Current);
      ensure
	 definition: Result = (other < Current);
      end;
   
   infix ">=" (other: NUMBER): BOOLEAN is
	 -- Is `Current' greater or equal than `other'?
      require
	 other_exists: other /= Void;
      do
	 Result := not (Current < other);
      ensure
	 definition: Result = (other <= Current);
      end;
   
   gcd(other: NUMBER): ABSTRACT_INTEGER is
	 -- Great Common Divisor of `Current' and `other'.
      require
	 other.is_abstract_integer;	 
	 is_abstract_integer;
	 is_positive;
	 other.is_positive;
      do
	 if other.is_zero then 
	    Result ?= Current;
	    check
	       Result /= Void;
	    end;
	 else
	    Result := other.gcd(Current \\ other);
	 end;    
      end;   
      
feature -- Unary operators for two NUMBERs :

   frozen prefix "+" : NUMBER is
	 -- Unary plus of 'Current'.
      do
	 Result := Current;
      ensure
	 Result = Current
      end;
   
   prefix "-" : NUMBER is
	 -- Negative of 'Current'.
      deferred
      ensure
	 Result /= Void
      end;

feature -- To know more about a NUMBER :
   
   in_range(lower, upper: NUMBER): BOOLEAN is
	 -- Return true if `Current' is in range [`lower'..`upper']
      do
	 Result := (Current >= lower) and then (Current <= upper);
      ensure
	 Result = (Current >= lower and Current <= upper);
      end;
   
   compare(other: NUMBER): INTEGER is
	 -- Compare `Current' with `other'.
	 -- `<'  <==> `Result < 0'
	 -- `>'  <==> `Result > 0'
	 -- Otherwise `Result = 0'.
      require
	 other /= Void;
      do
	 if (Current < other) then
	    Result := -1;
	 elseif (other < Current) then
	    Result := 1;
	 end;
      ensure
	 (Result < 0) = (Current < other);
	 (Result = 0) = not (Current < other or Current > other);
	 (Result > 0) = (Current > other);
      end;
   
   min(other: NUMBER): NUMBER is 
	 -- Minimum of `Current' and `other'.
      require
	 other /= Void;
      do
	 if Current < other then
	    Result := Current;
	 else
	    Result := other;
	 end;
      ensure
	 Result <= Current and then Result <= other;
	 compare(Result) = 0 or else other.compare(Result) = 0;
      end;
   
   max(other: NUMBER): NUMBER is 
	 -- Maximum of `Current' and `other'.
      require
	 other /= Void;
      do
	 if (other < Current) then
	    Result := Current;
	 else
	    Result := other;
	 end;
      ensure
	 (Result >= Current) and then (Result >= other);
	 compare(Result) = 0 or else other.compare(Result) = 0;
      end;
   
   is_zero: BOOLEAN is
         -- Is it 0 ?
      deferred
      ensure
	 Result = (Current @= 0)
      end;
   
   is_one: BOOLEAN is
         -- Is it 1 ?
      deferred
      ensure
	 Result = (Current @= 1)
      end;   
   
   is_positive: BOOLEAN is
	 -- Is `Current' greater or equal zero ?
      deferred
      ensure
	 Result = (Current @>= 0)
      end;
   
   is_negative: BOOLEAN is
	 -- Is `Current' < 0 ?
      deferred
      ensure
	 Result = (Current @< 0)
      end;
   
   is_odd, odd: BOOLEAN is
	 -- Is `odd' ?
      require
	 is_abstract_integer
      do
	 Result := (Current @\\ 2).is_one;
      end;
   
   is_even, even: BOOLEAN is
	 -- Is `even' ?
      require
	 is_abstract_integer
      do
	 Result := (Current @\\ 2).is_zero;
      end;
   
   frozen same_as(other: NUMBER): BOOLEAN is
	 -- Is it the same NUMBER as `other' ?
	 --
	 -- Note: because `is_equal' uses type like Current for 
	 -- `other', this is impossible to use directely `is_equal'.
      require
	 other /= Void
      local
	 x: like Current;
      do
	 x ?= other;
	 Result := (x /= Void) and then x.is_equal(Current);
      ensure
	 Result implies other.is_equal(Current)
      end;
   
   frozen is_abstract_integer: BOOLEAN is
      local
	 abstract_integer: ABSTRACT_INTEGER;
      do
	 abstract_integer ?= Current;
	 Result := abstract_integer /= Void;
      end;
   
   frozen is_abstract_fraction: BOOLEAN is
      local
	 abstract_fraction : ABSTRACT_FRACTION;
      do
	 abstract_fraction ?= Current;
	 Result := abstract_fraction /= Void;
      end;
   
   frozen is_integer: BOOLEAN is
	 -- Does `Current' value fit on an INTEGER ?
      local
	 abstract_integer: ABSTRACT_INTEGER;
      do
	 abstract_integer ?= Current;
	 if abstract_integer /= Void then
	    Result := abstract_integer.is_integer_value;
	 end;
       ensure
	 Result implies is_abstract_integer;
      end;   
   
   frozen is_double: BOOLEAN is
      do
	 if Current #>= Minimum_double then
	    Result := Current #<= Maximum_double;
	 end;
      end;
   
feature -- Conversions and printing :
   
   to_integer: INTEGER is
      require
	 is_integer
      deferred
      end;
   
   to_double: DOUBLE is
      require
	 is_double
      deferred
      end;
   
   to_string: STRING is
	 -- Convert the NUMBER into a new allocated STRING. 
	 -- Note: see `append_in' to save memory.
      do
	 Result := "This is a local STRING buffer ....";
	 Result.clear;
	 append_in(Result);
	 Result := Result.twin;
      end;

   frozen digit: CHARACTER is
	 -- Gives the corresponding CHARACTER for range 0..9.
      require
	 to_integer.in_range(0,9)
      do
	 Result := to_integer.digit;
      ensure
	 ("0123456789").has(Result);
	 Current @= Result.value;
      end;

   append_in(str: STRING) is
	 -- Append the equivalent of `to_string' at the end of 
	 -- `str'. Thus you can save memory because no other
	 -- STRING is allocate for the job.
      require
	 str /= Void;
      deferred
      end; 

feature -- To mimic NUMERIC :
   
   divisible(other: NUMBER): BOOLEAN is
	 -- Is `other' a valid divisor for `Current' ?
      require
	 other /= Void
      do
	 Result := not other.is_zero;
      end;
   
   one: NUMBER is
	 -- The neutral element of multiplication.
      once
	 !SMALL_INTEGER!Result.make(1);
      ensure
	 neutral_element: -- Result is the neutral element of 
	 -- multiplication.
      end;
   
   zero: NUMBER is
	 -- The neutral element of addition.
      once
	 !SMALL_INTEGER!Result.make(0);
      ensure
	 neutral_element: -- Result is the neutral element of 
	 -- addition.
      end;
   
   frozen sign: INTEGER is
      do
	 if is_positive then
	    Result := 1;
	 elseif is_negative then
	    Result := - 1;
	 end;
      end;
   
   sqrt: DOUBLE is
	 -- Compute the square routine.
      require
	 is_double
      do
	 Result := to_double.sqrt;
      end;
   
   frozen log: DOUBLE is
      require
	 is_double
      do
	 Result := to_double.log;
      end;
   
   abs: NUMBER is
      do
	 if is_negative then
	    Result := -Current;
	 else
	    Result := Current;
	 end;
      end;
      
feature -- To mix NUMBER and INTEGER :
   
   infix "@+" (other: INTEGER): NUMBER is
	 -- Sum of `Current' and `other'.
      deferred
      ensure
	 Result /= Void
      end;
   
   infix "@-" (other: INTEGER): NUMBER is
	 -- Difference of `Current' and `other'.
      do
	 if other = Minimum_integer then
	    Result := (Current @+ 1);
	    Result := Result @+ Maximum_integer;
	 else
	    Result := Current @+ (- other);
	 end;
      ensure
	 Result /= Void
      end;
   
   infix "@*" (other: INTEGER): NUMBER is
      require
	 other /= Void
      deferred
      ensure
	 Result /= Void
      end;
   
   infix "@/" (other: INTEGER): NUMBER is
	 -- Quotient of `Current` and `other`.
      require
	 other /= 0;
      deferred
      ensure
	 Result /= Void
      end; 
   
   infix "@//" (other: INTEGER): NUMBER is
	 -- Divide Current by `other' (Integer division).
      require
	 is_abstract_integer;
	 other /= 0;
      deferred
      ensure
	 Result.is_abstract_integer;
      end;
   
   
   infix "@\\" (other: INTEGER): NUMBER is
	 -- Remainder of division of Current by `other'.
      require
	 is_abstract_integer;
	 other /= 0;
      deferred
      ensure
	 Result.is_abstract_integer;
      end;
   
   infix "@^" (exp: INTEGER): NUMBER is
      require
	 (exp > 0) or else not is_zero
      local
	 int : INTEGER;
	 other : NUMBER;
      do
	 int := exp.abs;
	 inspect int
	 when 0 then
	    !SMALL_INTEGER!Result.make(1);
	 when 1 then
	    Result := Current;
	 else
	    from
	       int := int - 1;
	       other := Current;
	       Result := Current;
	    until
	       int < 2
	    loop
	       if int.odd then
		  Result := Result * other;
	       end;
	       other := other * other; -- methode sqrt : ^2
	       int := int // 2;
	    end;
	    Result := Result * other;
	 end;
	 if (exp < 0) then
	    Result := Result.inverse; 
	 end;
      ensure
	 Result /= Void;
	 Result /= Current implies (exp /= 1 or else not is_zero);
      end;
   
   infix "@=" (other: INTEGER): BOOLEAN is
	 -- Is Current equal `other' ?
      deferred
      end;
   
   infix "@<" (other: INTEGER): BOOLEAN is
	 -- Is 'Current' strictly less than 'other'?
      deferred
      ensure
	 Result = not (Current @>= other);
      end;
   
   infix "@<=" (other: INTEGER): BOOLEAN is
	 -- Is 'Current' less or equal 'other'?
      deferred
      ensure
	 Result = not (Current @> other);
      end;
   
   infix "@>" (other: INTEGER): BOOLEAN is
	 -- Is 'Current' strictly greater than 'other'?
      deferred
      ensure
	 Result = not (Current @<= other);
      end;
   
   infix "@>=" (other: INTEGER): BOOLEAN is
	 -- Is 'Current' greater or equal than 'other'?
      deferred
      ensure
	 Result = not (Current @< other);
      end;
   
feature -- To mix NUMBER and DOUBLE :

   infix "#=" (other: DOUBLE): BOOLEAN is
	 -- Is Current equal `other` ?
      deferred
      end;
   
   infix "#<" (other: DOUBLE): BOOLEAN is
	 -- Is 'Current' strictly less than 'other'?
      deferred
      ensure
	 Result implies not (Current #>= other);
      end;
   
   infix "#<=" (other: DOUBLE): BOOLEAN is
	 -- Is `Current` less or equal `other`?
      deferred
      ensure
	 Result = not (Current #> other);
      end;
   
   infix "#>" (other: DOUBLE): BOOLEAN is
	 -- Is 'Current' strictly greater than 'other'?
      deferred
      ensure
	 Result = not (Current #<= other);
      end;   
   
   infix "#>=" (other: DOUBLE): BOOLEAN is
	 -- Is `Current` greater or equal than `other`?
      deferred
      ensure
	 Result = not (Current #< other);
      end;
   
feature -- Misc :
   
   out_in_tagged_out_memory, fill_tagged_out_memory is
      do
	 append_in(tagged_out_memory);
      end;   
   
   hash_code: INTEGER is
      do
	 if is_double then
	    Result := to_double.hash_code;
	 else
	    not_yet_implemented;
	 end;
      end;
   
   inverse: NUMBER is
      require
	 divisible(Current)
      deferred
      ensure
	 Result /= Void
      end;   
   
   factorial: NUMBER is
      require
	 is_abstract_integer;
	 is_positive
      local
	 n: NUMBER;
      do
	 if is_zero then
	    !SMALL_INTEGER!Result.make(1);
	 else
	    from
	       Result := Current;
	       n := Current @- 1;
	    until
	       n @= 0 	       
	    loop
	       Result := n * Result;
	       n := n @- 1;
	    end;
	 end;
      ensure
	 Result.is_abstract_integer;
	 Result.is_positive
      end;
   
feature {NUMBER} -- Implementation :
   
   nb_c(int: INTEGER): INTEGER is
      -- Return the number of chiffers in int.
      local
	 i: INTEGER;
      do
	 from
	    i := int;
	    Result := 1;
	 until
	    i < 10
	 loop
	    i := i // 10;
	    Result := Result + 1;
	 end;
      end;
   
   frozen is_small_integer: BOOLEAN is
	 -- Does `Current' value fit on an INTEGER ?
      do
	 if is_abstract_integer then
	    if Current @<= (Base - 1) then
	       Result := Current @>= (- (Base - 1));
	    end;
	 end;
      ensure
	 Result implies is_abstract_integer;
      end;   
   
   frozen add_with_small_integer(other: SMALL_INTEGER): NUMBER is
      require
	 other /= Void
      do
	 Result := Current @+ other.to_integer;
      ensure
	 Result /= Void
      end;
   
   add_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is
      require
	 other /= Void
      deferred
      ensure
	 Result /= Void
      end;
   
   add_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is
      require
	 other /= Void
      deferred
      ensure
	 Result /= Void
      end;
   
   add_with_small_fraction(other: INTEGER_FRACTION): NUMBER is
      require
	 other /= Void
      deferred
      ensure
	 Result /= Void
      end;
   
   add_with_large_fraction(other: NUMBER_FRACTION): NUMBER is
      require
	 other /= Void
      deferred
      ensure
	 Result /= Void
      end;
   
   multiply_with_small_integer(other: SMALL_INTEGER): NUMBER is
      require
	 other /= Void
      do
	 Result := Current @* other.to_integer;
      ensure
	 Result /= Void
      end;
   
   multiply_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): NUMBER is
      require
	 other /= Void
      deferred
      ensure
	 Result /= Void
      end;
   
   multiply_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): NUMBER is
      require
	 other /= Void
      deferred
      ensure
	 Result /= Void
      end;
   
   multiply_with_small_fraction(other: INTEGER_FRACTION): NUMBER is
      require
	 other /= Void
      deferred
      ensure
	 Result /= Void
      end;
   
   multiply_with_large_fraction(other: NUMBER_FRACTION): NUMBER is
      require
	 other /= Void
      deferred
      ensure
	 Result /= Void
      end;
   
   greater_with_small_integer(other: SMALL_INTEGER): BOOLEAN is
      require
	 other /= Void;
      do
	 Result := Current @> other.to_integer;
      end;
   
   greater_with_large_positive_integer(other: LARGE_POSITIVE_INTEGER): BOOLEAN is
      require
	 other /= Void;
      deferred
      end;
   
   greater_with_large_negative_integer(other: LARGE_NEGATIVE_INTEGER): BOOLEAN is
      require
	 other /= Void;
      deferred
      end;
   
   greater_with_small_fraction(other: INTEGER_FRACTION): BOOLEAN is
      require
	 other /= Void;
      deferred
      end;
   
   greater_with_large_fraction(other: NUMBER_FRACTION): BOOLEAN is
      require
	 other /= Void;
      deferred
      end;
   
   to_string_format(s: INTEGER): STRING is
	 -- Same as `to_string' but the result is on `s' character and the 
	 -- number is right aligned. 
	 -- Note: see `append_in_format' to save memory.
      require
	 to_string.count <= s;
      do
	 from  
	    tmp_string.clear;
	    append_in(tmp_string);
	 until
	    tmp_string.count >= s
	 loop
	    tmp_string.add_first(' ');
	 end;
	 Result := tmp_string.twin;
      ensure
	 Result.count = s;
      end; 
   
   append_in_format(str: STRING; s: INTEGER) is
	 -- Append the equivalent of `to_string_format' at the end of 
	 -- `str'. Thus you can save memory because no other
	 -- STRING is allocate for the job.
      do
	 from
	    tmp_string.clear;
	    append_in(tmp_string);
	 until
	    tmp_string.count >= s
	 loop
	    tmp_string.add_first(' ');
	 end;
	 str.append(tmp_string);
      ensure
	 str.count >= (old str.count) + s;
      end;
   
feature {NONE}   
   
   max_double: NUMBER is
      local
	 nt: NUMBER_TOOLS;
      once
	 !!nt;
	 Result := nt.from_string(Maximum_double.to_string);
      end;
   
   min_double: NUMBER is
      once
	 Result := -max_double @- 1;
      end;
   
   greater_large_negative_integer: LARGE_NEGATIVE_INTEGER is
      once
	 !LARGE_NEGATIVE_INTEGER!Result.make_smaller(0);
      end;
   
   Base : INTEGER is
	 -- The Base is the grater number which is like 10^x and 
	 -- which is inferior to the Maximu_integer value.
	 --
	 -- So if Maximum_number is 2147483647 :
	 -- The Base is :           1000000000.
	 -- A number has a value between 0-9 so a number in a
	 -- item of a FIXED_ARRAY[INTEGER] must be a succession 
	 -- of 9 so the value of the greater item is 999999999.
         -- And the Base is the greater value of a item + 1.
      once
	 Result := 10 ^ (nb_c(Maximum_integer) - 1);
      end; -- Base
   
   Half_base: INTEGER is
	 -- It's the value of the greater number like 10^x which is
	 -- inferior to Base.sqrt
	 -- For the multiplication, we can make multiplication without 
	 -- depassement of capacity.
      once
	    Result := 10^(Base.sqrt.log10.truncated_to_integer);
      end;
   
   Half_base_2: INTEGER is
      once
	 Result := Half_base ^ 2;
      end;
   
   Rest_base: INTEGER is
      once
	 Result := Base // (Half_base ^ 2);
      end;
   
   Double_base: DOUBLE is
	 -- It's the double value of the Base.
	 -- The conversion integer to double of the Base value.
	 -- This value is necessary to the division.
      once
	 Result := Base.to_double;
      end
   
   Log_base: DOUBLE is
      once
	 Result := Base.log;
      end;
   
   Base_is_impair: BOOLEAN is
      once
	 Result := (Rest_base = 10);
      end;
   
   -- This global variable is necessary to have a good memory gestion
   
   temp_2_digints: FIXED_ARRAY[INTEGER] is
	 -- Global variable to put an integer in a large_integer
      once
	 !!Result.make(2);
      end;
   
   temp_1_digint: FIXED_ARRAY[INTEGER] is
	 -- Global varaible to put an integer in a small_integer
	 -- for few operations
      once
	 !!Result.make(1);
      end;
   
   temp_from_mult: FIXED_ARRAY[INTEGER] is
	 -- Global variable
      once
	 !!Result.make(0);
      end;
   
   temp_after_mult: FIXED_ARRAY[INTEGER] is
	 -- Global variable
      once
	 !!Result.make(0);
      end;
   
   temp_quotient: FIXED_ARRAY[INTEGER] is
	 -- Global variable
      once
	 !!Result.make(0);
      end;
   
   temp_remainder: FIXED_ARRAY[INTEGER] is
	 -- Global variable
      once
	 !!Result.make(0);
      end;
   
   temp_division: FIXED_ARRAY[INTEGER] is
	 -- Global variable
      once
	 !!Result.make(0);
      end;
   
end -- NUMBER
