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
deferred class LARGE_INTEGER
--
-- To implement NUMBER (do not use this class, see NUMBER).
--
   
inherit ABSTRACT_INTEGER;   
   
feature 
   
   is_zero: BOOLEAN is false;
   
   is_one: BOOLEAN is false;
   
   is_equal(other : like Current): BOOLEAN is
	 -- compares 2 LARGE_INTEGERs. As they both have same sign
	 -- comparison is done with absolute values
      require
	 other /= Void;
      local
	 i : INTEGER;
      do
	 from
	    i := value.upper;
	    Result := i = other.value.upper;
	 until
	    not(Result) or else (i < 0)
	 loop
	    Result := (value @ i) = (other.value @ i);
	    i := i - 1;
	 end;
      end;
   
feature{NUMBER}
   
   value: FIXED_ARRAY[INTEGER] is
      do
	 Result := storage;
      end;   
   
   
   make_from_fixed_array(fa: FIXED_ARRAY[INTEGER]) is
      require
	 fa /= Void
      do
	 check
	    correct_fixed(fa)
	 end;
	 storage := fa;
      end;
   
   
   make_smaller(int: INTEGER) is
      do
	 !!storage.make(2);
	 storage.put(int,0);
	 storage.put(1,1);
      end;
   
   make_from_product(int: INTEGER) is
      do
	 !!storage.make(2);
	 storage.put(int,1);
      end;

   make_big is
      do
	 !!storage.make(3);
	 storage.put(1, 2);
      end;
   
   
feature{NONE}
   
   create_positive(fa: FIXED_ARRAY[INTEGER]): ABSTRACT_INTEGER is
	 -- creates a simplified positive ABSTRACT_INTEGER
	 -- from a correct FIXED_ARRAY or a one item FIXED
      require
	 fa /= Void;
	 internal_correct_fixed(fa);
      do
	 if (fa.upper > 0) then
	    !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(clone(fa));
	 elseif (fa.upper = 0) then
	    !SMALL_INTEGER!Result.make(fa.item(0));
	 else
	    Result ?= zero;
	 end;
      ensure
	 Result /= Void;
	 Result.is_abstract_integer;
      end; 
   
   create_negative(fa: FIXED_ARRAY[INTEGER]): ABSTRACT_INTEGER is
	 -- creates a simplified negative ABSTRACT_INTEGER
	 -- from a correct FIXED_ARRAY or a one item FIXED
      require
	 fa /= Void;
	 internal_correct_fixed(fa);
      do
	 if fa.upper > 0 then
	    !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(clone(fa));
	 elseif fa.upper = 0 then
	    !SMALL_INTEGER!Result.make(- (fa.item(0)));
	 else
	    Result ?= zero;
	 end;
      ensure
	 Result /= Void;
	 Result.is_abstract_integer;
      end; 
   
feature {NONE} -- Conversion tool
   
   fixed_array_to_double(fa: FIXED_ARRAY[INTEGER]): DOUBLE is
	 -- only a tool 
	 -- unsigned conversion
      require
	 fa /= Void;
	 correct_fixed(fa);
      local
	 i : INTEGER;
      do
	 from
	    i := fa.upper - 1;
	    Result := fa.item(fa.upper).to_double;
	 until
	    (i < 0) or else (Result > Maximum_double)
	 loop
	    Result := (Result * Double_base) + fa.item(i).to_double;
	    i := i - 1;
	 end;
	 if (Result = Maximum_double) and then (fa.item(0) /= 0) then
	    Result := Maximum_double * 2;
	 end;
      end
   
   
feature{NONE} -- Operations tools
   
   add_fixed_arrays(fa1, fa2: FIXED_ARRAY[INTEGER]) is
	 -- only a tool used by some features in positive 
	 -- and negative large integers
	 -- result is stored in temp
      require
	 fa1 /= Void;
	 fa2 /= Void and fa2 /= temp;
      local
	 smaller, larger: FIXED_ARRAY[INTEGER];
	 i, carry, partial_sum, 
	 initial_smaller_upper, initial_larger_upper: INTEGER;
      do
	 if fa1.upper >= fa2.upper then
	    smaller := fa2;
	    larger := fa1;
	 else
	    smaller := fa1;
	    larger := fa2;
	 end;
	 from
	    initial_smaller_upper := smaller.upper;
	    initial_larger_upper := larger.upper;
	    i := 0;
	    temp.resize(initial_larger_upper + 2);
	    carry := 0;
	 until
	    i > initial_smaller_upper
	 loop
	    partial_sum := smaller.item(i) + larger.item(i) + carry;
	    if partial_sum <0 then
	       carry := 1;
	       temp.put(partial_sum - Base, i);
	    else
	       carry := 0;
	       temp.put(partial_sum, i);
	    end;
	    i := i + 1;
	 end;
	 from
	 until
	    (i > initial_larger_upper)
	 loop
	    partial_sum := larger.item(i) + carry;
	    if partial_sum <0 then
	       carry := 1;
	       temp.put(partial_sum - Base, i);
	    else
	       carry := 0;
	       temp.put(partial_sum, i);
	    end;
	    i := i + 1;
	 end;
	 if (carry = 0) then
	    temp.resize(i);
	 else
	    temp.put(1,i);
	 end;
      ensure
	 temp.item(temp.upper) /= 0;
      end;
   
   difference_between_fixed_arrays(larger, smaller: FIXED_ARRAY[INTEGER]) is
	 -- only a tool used by some features in positive and negative
	 -- large integers
	 -- result is stored in temp
	 -- Warning : temp can be an empty array if result is zero
      require
	 smaller /= Void;
	 larger /= Void;
	 not fixed_array_greater_than(smaller, larger) -- smaller <= larger
      local
	 i, last_not_zero, carry, partial_sum, larger_upper: INTEGER;
	 not_zero: BOOLEAN;
      do
	 from
	    larger_upper := larger.upper;
	    i := 0;
	    temp.resize(larger_upper + 1);
	    carry := 0;
	    last_not_zero := -1;
	 until
	    i > smaller.upper
	 loop
	    partial_sum := larger.item(i) - smaller.item(i) - carry;
	    if (partial_sum < 0) then
	       carry := 1;
	       temp.put(partial_sum + Base , i);
	       not_zero := (partial_sum + Base ) /= 0;
	    else
	       carry := 0;
	       temp.put(partial_sum, i);
	       not_zero := partial_sum /= 0;
	    end;
	    if not_zero then
	       last_not_zero := i;
	    end;
	    i := i + 1;
	 end;
	 from
	 until
	    (i > larger_upper)
	 loop
	    partial_sum := larger.item(i) - carry;
	    if (partial_sum < 0) then
	       carry := 1;
	       temp.put(partial_sum + Base , i);
	       not_zero := (partial_sum + Base ) /= 0;
	    else
	       carry := 0;
	       temp.put(partial_sum, i);
	       not_zero := partial_sum /= 0;
	    end;
	    if not_zero then
	       last_not_zero := i;
	    end;
	    i := i + 1;
	 end;
	 temp.resize(last_not_zero + 1);
      ensure
	  internal_correct_fixed(temp);
      end;	    
   
   mult_fixed_with_integer(fa: FIXED_ARRAY[INTEGER]; int: INTEGER) is
	 -- result is stored in temp
      require
	 fa /= Void;
	 fa /= temp;
	 int /= 0;
      local
	 i : INTEGER;
      do
	 from
	    i := fa.upper - 1;
	    mult_2_integer(fa.item(fa.upper), int);
	    temp.copy(temp_2_digints);
	    if temp.item(1) = 0 then
	       temp.resize(1);
	    end;
	 until
	    i < 0
	 loop
	    shift(temp);
	    mult_2_integer(fa.item(i), int);
	    add_fixed_arrays(temp, temp_2_digints);
	    i := i - 1;
	 end;
      ensure
	 internal_correct_fixed(temp);
      end; 
   
   mult_2_fixed(fa1, fa2: FIXED_ARRAY[INTEGER]) is
	 -- result stored in temp_from_mult
      require
	 fa1 /= Void;
	 fa1 /= temp;
	 fa1 /= temp_from_mult;
	 fa2 /= Void;
	 fa2 /= temp;
	 fa2 /= temp_from_mult;
      local
	 i : INTEGER;
      do
	 from
	    mult_fixed_with_integer(fa1, fa2.item(fa2.upper));
	    temp_from_mult.copy(temp);
	    i := fa2.upper - 1;
	 until
	    i < 0
	 loop
	    shift(temp_from_mult);
	    if (fa2.item(i) /= 0) then
	       mult_fixed_with_integer(fa1, fa2.item(i));
	       add_fixed_arrays(temp, temp_from_mult);
	       temp_from_mult.copy(temp);
	    end;
	    i := i - 1;
	 end;
      ensure
	  internal_correct_fixed(temp_from_mult);
      end;
   
   -- constants for integer division
   
   fa_one: FIXED_ARRAY[INTEGER] is 
      once 
	 !!Result.make(0);
	 Result.add_last(1);
      ensure
	 Result /= Void and then (Result.item(0) = 1);
      end;
   
   divise_fixed_array(dividende, divisor : FIXED_ARRAY[INTEGER]) is
	 -- quotient is stored in temp_quotient, remainder in temp_remainder
      require
	 dividende /= Void;
	 internal_correct_fixed(dividende);
	 divisor /= Void;
	 internal_correct_fixed(divisor); 
	 divisor.upper >= 0;
      local
	 double_num, double_den, approx : DOUBLE;
	 n, i : INTEGER;
      do
	 if fixed_array_greater_than(divisor, dividende) then
	    temp_quotient.resize(0);
	    temp_remainder.copy(dividende);
	 elseif dividende.is_equal(divisor) then
	    temp_quotient.copy(fa_one);
	    temp_remainder.resize(0);
	 else
	    from
	       temp_remainder.copy(dividende);
	       temp_quotient.resize(0);
	    until
	       (temp_remainder.upper < 0) 
		  or else fixed_array_greater_than(divisor, temp_remainder)
	    loop
	       n := temp_remainder.upper - divisor.upper;
	       if (n = 0) then
		  double_num := temp_remainder.item(temp_remainder.upper);
		  double_den := divisor.item(divisor.upper);
		  if (divisor.upper > 0) then
		     double_num := (double_num * Double_base) 
			+ temp_remainder.item(temp_remainder.upper - 1);
		     double_den := (double_den * Double_base) 
			+ divisor.item(divisor.upper - 1);
		  end;
	       else
		  double_num := temp_remainder.item(temp_remainder.upper);
		  double_num := (double_num * Double_base) 
		     + temp_remainder.item(temp_remainder.upper - 1);
		  double_den := divisor.item(divisor.upper);
		  n := n - 1;
	       end;
	       approx := double_num / (double_den + 1);
	       if approx < 1 then
		  approx := 1.01;
	       end;
	       if (approx >= Double_base) then
		  temp_division.resize(2);
		  temp_division.put((approx / Double_base).truncated_to_integer, 1);
		  temp_division.put((approx - (Double_base * temp_division.item(1))).truncated_to_integer, 0);
	       else
		  temp_division.resize(1);
		  temp_division.put(approx.truncated_to_integer, 0);
	       end;
	       from
		  i := n - 1;
	       until
		  i < 0
	       loop
		  shift(temp_division);
		  i := i - 1;
	       end;
	       add_fixed_arrays(temp_division, temp_quotient);
	       temp_quotient.copy(temp);
	       mult_2_fixed(temp_division, divisor);
	       difference_between_fixed_arrays(temp_remainder, temp_from_mult);
	       temp_remainder.copy(temp);
	    end;
	 end;
      ensure
	 internal_correct_fixed(temp_remainder);
	 internal_correct_fixed(temp_quotient);
      end;
   
   shift(fa: FIXED_ARRAY[INTEGER]) is
      require
	 fa /= Void;
      local
	 i : INTEGER;
      do
	 from
	    i := fa.upper;
	    fa.resize(fa.upper + 2);
	 until
	    i < 0
	 loop
	    fa.put(fa.item(i), i + 1);
	    i := i - 1;
	 end
	 fa.put(0,0);
      end;
   
feature -- is_equal
   
   
feature{NONE} -- Comparison tools   
   
   fixed_array_greater_than(fa1, fa2: FIXED_ARRAY[INTEGER]): BOOLEAN is         
      require
	 fa1 /= Void;
	 internal_correct_fixed(fa1);
	 fa2 /= Void;
	 internal_correct_fixed(fa2);
      local
	 i : INTEGER;
      do
	 if (fa1.upper = fa2.upper) then
	    from
	       i := fa1.upper;
	    until
	       (i < 0) or else ( (fa1 @ i) /= (fa2 @ i) )
	    loop
	       i := i - 1;
	    end;
	    Result := (i >= 0) and then ((fa1 @ i) > (fa2 @ i));
	 else
	    Result := fa1.upper > fa2.upper;
	 end;
      end;
   
   
feature{NUMBER} -- validity check   
   
   internal_correct_fixed(fa: FIXED_ARRAY[INTEGER]): BOOLEAN is
      do
	 Result := correct_fixed(fa) 
		    or else ((fa.upper = 0) and then (fa.item(0) /= 0)) 
		    or else (fa.upper = -1);
      end;
   
   correct_fixed(fa: FIXED_ARRAY[INTEGER]): BOOLEAN is
      local
	 i : INTEGER;
      do
	 from
	    i := fa.upper;
	    Result := ((fa.upper >= 1) and then (fa.item(fa.upper) /= 0 ));
	 until
	    (i < 0) or else (not Result)
	 loop
	    Result := (fa.item(i) >= 0);
	    i := i - 1;
	 end;
      end;
    
feature {NONE}
   
   storage : FIXED_ARRAY[INTEGER];
   
   view: STRING is
	 -- for debugging only
	 -- print storage contents
      local
	 i : INTEGER
      do
	 !!Result.make(0) ;
	 from
	    i := storage.lower
	 variant
	    storage.upper - i
	 until
	    i > storage.upper
	 loop
	    Result.append( i.to_string ) ;
	    Result.append( " -> " ) ;
	    Result.append( storage.item(i).to_string ) ;
	    Result.append( "%N" ) ;
	    i := i + 1 ;
	 end
      end
   
invariant
   
   correct_fixed(storage);
   
end -- LARGE_INTEGER
