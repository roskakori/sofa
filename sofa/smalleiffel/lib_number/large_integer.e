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
   
   append_in(str:STRING) is
      local
	 i:INTEGER;
	 s: STRING;
      do
	 if is_negative then
	    str.extend('-');
	 end;
	 str.append(storage.item(storage.upper).to_string);	 
	 from
	    i := storage.upper;
	 until
	    i = storage.lower
	 loop
	    i := i - 1;
	    s := storage.item(i).to_string
	    str.extend_multiple('0', (Base.log10.truncated_to_integer - s.count));
	    str.append(storage.item(i).to_string);
	 end;
      end;
	    
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
      -- Creation of a large_integer with a too important integer
      do
	 !!storage.make(2);
	 storage.put((int \\ Base).abs,0);
	 storage.put((int // Base).abs,1);
      end;
   
   make_from_large_product(int, other: INTEGER) is
      -- Creation of a large_integer with the multiplication of 2 integer
      do
	 temp_2_digints.put((other \\ Base).abs, 0);
	 temp_2_digints.put((other // Base).abs, 1);
	 storage := mult_fixed_with_integer(temp_2_digints,int.abs);
      end;
   
   
   make_from_product(int, other: INTEGER) is
      local
	 v11, v12, v13, v21, v22, v23: INTEGER;
	 ret: INTEGER;
	 d1, d2, d3: INTEGER;
      do
	 !!storage.make(2);
	 d1 := int.abs;
	 d2 := other.abs;
	 v11 := d1 // (Half_base_2);
	 v13 := d1 \\ (Half_base_2);
	 v12 := v13 // Half_base;
	 v13 := v13 \\ Half_base;
	 v21 := d2 // (Half_base_2);
	 v23 := d2 \\ (Half_base_2);
	 v22 := v23 // Half_base;
	 v23 := v23 \\ Half_base;
	 
	 if Base_is_impair then
	    d1 :=v23 * v12 + v13 * v22;
	    d2 := d1 // Half_base;
	    d1 := (d1 - (d2 * Half_base)) * Half_base + v23 * v13;
	    if d1 >= 2 * Half_base_2 then
	       d1 := d1 - (2 * (Half_base_2));
	       ret := 2;
	    else
	       if d1 >= Half_base_2 then
		  d1 := d1 - (Half_base_2);
		  ret := 1;
	       else
		  ret := 0;
	       end;
	    end;
	    d2 := ret + d2 + (v23 * v11) + (v13 * v21) + (v12 * v22) + ((v11 * v22) \\ Half_base) * Half_base + ((v21 * v12) \\ Half_base) * Half_base;
	    d3 := (v11 * v22) // Half_base + (v21 * v12) // Half_base + v11 * v21;
	    ret := d2 // Rest_base;
	    storage.put(d1 + (d2 - (ret * Rest_base)) * (Half_base_2), 0);
	    storage.put(d3 * (Half_base_2 // Rest_base) + ret, 1);
	 else
	    ret := v13 * v23;
	    v11 := v12 * v23;
	    v21 := v22 * v13;
	    d1 := ret // Half_base + v11 \\ Half_base + v21 \\ Half_base;
	    d2 := d1 \\ Half_base;
	    storage.put((d1 - (d2 * Half_base)) * Half_base + ret \\ Half_base, 0);
	    storage.put(d2 + v11 // Half_base + v21 // Half_base + (v12 * v22), 1);
	 end;
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
   
   create_positive_directly(fa: FIXED_ARRAY[INTEGER]): ABSTRACT_INTEGER is
	 -- creates a simplified positive ABSTRACT_INTEGER
	 -- from a correct FIXED_ARRAY or a one item FIXED
      require
	 fa /= Void;
	 internal_correct_fixed(fa);
      do
	 if (fa.upper > 0) then
	    !LARGE_POSITIVE_INTEGER!Result.make_from_fixed_array(fa);
	 elseif (fa.upper = 0) then
	    !SMALL_INTEGER!Result.make(fa.item(0));
	 else
	    Result ?= zero;
	 end;
      ensure
	 Result /= Void;
	 Result.is_abstract_integer;
      end; 
   
   create_negative_directly(fa: FIXED_ARRAY[INTEGER]): ABSTRACT_INTEGER is
	 -- creates a simplified negative ABSTRACT_INTEGER
	 -- from a correct FIXED_ARRAY or a one item FIXED
      require
	 fa /= Void;
	 internal_correct_fixed(fa);
      do
	 if fa.upper > 0 then
	    !LARGE_NEGATIVE_INTEGER!Result.make_from_fixed_array(fa);
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
   
      add_fixed_array_with_integer_in_himself_from(fa1: INTEGER; fa2: FIXED_ARRAY[INTEGER]; n: INTEGER) is
	 -- only a tool used by some features in positive 
	 -- and negative large integers
	 -- result is stored in fa2
	 -- Make the addition between fa2 and fa1 which is shifted by 
	 -- n and return the result in fa2 to have a 
	 -- good memory gestion.
      require
	 fa2 /= Void;
      local
	 i, carry, partial_sum, 
	 initial_larger_upper: INTEGER;
      do
	 initial_larger_upper := fa2.upper;
	 partial_sum := fa2.item(n) + fa1;
	 if partial_sum >= Base or else partial_sum < 0 then
	    carry := 1;
	    fa2.put(partial_sum - Base, n);
	 else
	    carry := 0;
	    fa2.put(partial_sum, n);
	 end;
	 from
	    i := n + 1;
	 until
	    (i > initial_larger_upper)
	 loop
	    partial_sum := fa2.item(i) + carry;
	    if partial_sum >= Base or else partial_sum < 0 then
	       carry := 1;
	       fa2.put(partial_sum - Base, i);
	    else
	       carry := 0;
	       fa2.put(partial_sum, i);
	    end;
	    i := i + 1;
	 end;
	 if (carry /= 0) then
	    fa2.add_last(carry);
	 end;
      ensure
	 fa2.item(fa2.upper) /= 0;
      end;
   
   add_fixed_arrays(fa1, fa2: FIXED_ARRAY[INTEGER]): FIXED_ARRAY[INTEGER] is
	 -- only a tool used by some features in positive 
	 -- and negative large integers
	 -- Give a FIXED_ARRAY[INTEGER] for the creation of an 
	 -- large_integer after an addition.
      require
	 fa1 /= Void;
	 fa2 /= Void;
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
	    !!Result.make(larger.count + 1);
	    i := 0;
	    carry := 0;
	 until
	    i > initial_smaller_upper
	 loop
            partial_sum := larger.item(i) + smaller.item(i) + carry;
            if partial_sum >= Base or else partial_sum < 0 then
               carry := 1;
               Result.put(partial_sum - Base, i);
            else
               carry := 0;
               Result.put(partial_sum, i);
            end;
	    i := i + 1;
	 end;
	 from
	 until
	    (i > initial_larger_upper)
	 loop
            partial_sum := larger.item(i) + carry;
            if partial_sum >= Base or else partial_sum < 0 then
               carry := 1;
               Result.put(partial_sum - Base, i);
            else
               carry := 0;
               Result.put(partial_sum, i);
            end;
	    i := i + 1;
	 end;
	 if (carry = 0) then
	    Result.remove_last;
	 else
	    Result.put(carry,i);
	 end;
      ensure
	 Result.item(Result.upper) /= 0;
      end;
   
      add_fixed_arrays_in_himself(fa1, fa2: FIXED_ARRAY[INTEGER]) is
	 -- only a tool used by some features in positive 
	 -- and negative large integers
	 -- result is stored in fa2
	 -- Make the addition and return the result in fa2 to have a 
	 -- good memory gestion.
      require
	 fa1 /= Void;
	 fa2 /= Void;
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
	    carry := 0;
	 until
	    i > initial_smaller_upper
	 loop
            partial_sum := larger.item(i) + smaller.item(i) + carry;
            if partial_sum >= Base or else partial_sum < 0 then
               carry := 1;
               fa2.put(partial_sum - Base, i);
            else
               carry := 0;
               fa2.put(partial_sum, i);
            end;
	    i := i + 1;
	 end;
	 from
	 until
	    (i > initial_larger_upper)
	 loop
            partial_sum := larger.item(i) + carry;
            if partial_sum >= Base or else partial_sum < 0 then
               carry := 1;
               fa2.put(partial_sum - Base, i);
            else
               carry := 0;
               fa2.put(partial_sum, i);
            end;
	    i := i + 1;
	 end;
	 if (carry /= 0) then
	    fa2.add_last(carry);
	 end;
      ensure
	 fa2.item(fa2.upper) /= 0;
      end;
   
      add_fixed_arrays_in_himself_from(fa1, fa2: FIXED_ARRAY[INTEGER]; n: INTEGER) is
	 -- only a tool used by some features in positive 
	 -- and negative large integers
	 -- result is stored in fa2
	 -- Make the addition between fa2 and fa1 which is shifted by 
	 -- n and return the result in fa2 to have a 
	 -- good memory gestion.
      require
	 fa1 /= Void;
	 fa2 /= Void;
      local
	 i, carry, partial_sum, 
	 initial_smaller_upper, initial_larger_upper: INTEGER;
      do
	 from
	    initial_smaller_upper := fa1.upper + n;
	    initial_larger_upper := fa2.upper;
	    i := n;
	    carry := 0;
	 until
	    i > initial_smaller_upper
	 loop
	    partial_sum := fa2.item(i) + fa1.item(i - n) + carry;
	    if partial_sum >= Base or else partial_sum < 0 then
	       carry := 1;
	       fa2.put(partial_sum - Base, i);
	    else
	       carry := 0;
	       fa2.put(partial_sum, i);
	    end;
	    i := i + 1;
	 end;
	 from
	 until
	    (i > initial_larger_upper)
	 loop
	    partial_sum := fa2.item(i) + carry;
	    if partial_sum >= Base or else partial_sum < 0 then
	       carry := 1;
	       fa2.put(partial_sum - Base, i);
	    else
	       carry := 0;
	       fa2.put(partial_sum, i);
	    end;
	    i := i + 1;
	 end;
	 if (carry /= 0) then
	    fa2.add_last(carry);
	 end;
      ensure
	 fa2.item(fa2.upper) /= 0;
      end;
   
   difference_between_fixed_arrays(larger, smaller: FIXED_ARRAY[INTEGER]):FIXED_ARRAY[INTEGER] is
	 -- only a tool used by some features in positive and negative
	 -- large integers
	 -- Warning : temp can be an empty array if result is zero
	 -- Give a FIXED_ARRAY[INTEGER] for the creation of an 
	 -- large_integer after an subtraction.
      require
	 smaller /= Void;
	 larger /= Void;
	 not fixed_array_greater_than(smaller, larger) -- smaller <= larger
      local
	 i, last_not_zero, carry, partial_sum, larger_upper, smaller_upper: INTEGER;
      do
	 from
	    larger_upper := larger.upper;
	    smaller_upper := smaller.upper;
	    i := 0;
	    !!Result.make(larger.count);
	    carry := 0;
	    last_not_zero := -1;
	 until
	    i > smaller_upper
	 loop
	    partial_sum := larger.item(i) - smaller.item(i) - carry;
	    if (partial_sum < 0) then
	       carry := 1;
	       Result.put(partial_sum + Base , i);
	       if (partial_sum + Base ) /= 0 then
		  last_not_zero := i;
	       end;
	    else
	       carry := 0;
	       Result.put(partial_sum, i);
	       if partial_sum /= 0 then
		  last_not_zero := i;
	       end;
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
	       Result.put(partial_sum + Base , i);
	       if (partial_sum + Base ) /= 0 then
		  last_not_zero := i;
	       end;
	    else
	       carry := 0;
	       Result.put(partial_sum, i);
	       if partial_sum /= 0 then
		  last_not_zero := i;
	       end;
	    end;
	    i := i + 1;
	 end;
	 Result.resize(last_not_zero + 1);
      ensure
	  internal_correct_fixed(Result);
      end;	    
   
   difference_between_fixed_arrays_in_himself(larger, smaller: FIXED_ARRAY[INTEGER]) is
	 -- only a tool used by some features in positive and negative
	 -- large integers
	 -- Warning : temp can be an empty array if result is zero
	 -- result is stored in larger
	 -- Make the subtraction and return the result in larger to have a 
	 -- good memory gestion.
	 -- Use this function if you know that larger is greater than 
	 -- smaller.
      require
	 smaller /= Void;
	 larger /= Void;
	 not fixed_array_greater_than(smaller, larger) -- smaller <= larger
      local
	 i, last_not_zero, carry, partial_sum, larger_upper,smaller_upper: INTEGER;
      do
	 from
	    larger_upper := larger.upper;
	    smaller_upper := smaller.upper;
	    i := 0;
	    carry := 0;
	    last_not_zero := -1;
	 until
	    i > smaller_upper
	 loop
	    partial_sum := larger.item(i) - smaller.item(i) - carry;
	    if (partial_sum < 0) then
	       carry := 1;
	       larger.put(partial_sum + Base , i);
	       if (partial_sum + Base ) /= 0 then
		  last_not_zero := i;
	       end;
	    else
	       carry := 0;
	       larger.put(partial_sum, i);
	       if partial_sum /= 0 then
		  last_not_zero := i;
	       end;
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
	       larger.put(partial_sum + Base , i);
	       if (partial_sum + Base ) /= 0 then
		  last_not_zero := i;
	       end;
	    else
	       carry := 0;
	       larger.put(partial_sum, i);
	       if partial_sum /= 0 then
		  last_not_zero := i;
	       end;
	    end;
	    i := i + 1;
	 end;
	 larger.resize(last_not_zero + 1);
      ensure
	 internal_correct_fixed(larger);
      end;

   difference_between_fixed_arrays_in_himself_from(larger, smaller: FIXED_ARRAY[INTEGER]; n: INTEGER) is
	 -- only a tool used by some features in positive and negative
	 -- large integers
	 -- Warning : temp can be an empty array if result is zero
	 -- result is stored in larger
	 -- Make the subtraction between larger and smaller which is 
	 -- shifted by n and return the result in larger to have a 
	 -- good memory gestion.
	 -- Use this function if you know that larger is greater than 
	 -- smaller.
      require
	 smaller /= Void;
	 larger /= Void;
	 not fixed_array_greater_than(smaller, larger) -- smaller <= larger
      local
	 a, i, last_not_zero, carry, partial_sum, larger_upper,smaller_upper: INTEGER;
      do
	 from
	    larger_upper := larger.upper;
	    smaller_upper := smaller.upper;
	    i := n;
	    a := 0;
	    carry := 0;
	    last_not_zero := n - 1;
	 until
	    a > smaller_upper
	 loop
	    partial_sum := larger.item(i) - smaller.item(a) - carry;
	    if (partial_sum < 0) then
	       carry := 1;
	       larger.put(partial_sum + Base , i);
	       if (partial_sum + Base ) /= 0 then
		  last_not_zero := i;
	       end;
	    else
	       carry := 0;
	       larger.put(partial_sum, i);
	       if partial_sum /= 0 then
		  last_not_zero := i;
	       end;
	    end;
	    i := i + 1;
	    a := a + 1;
	 end;
	 from
	 until
	    (i > larger_upper)
	 loop
	    partial_sum := larger.item(i) - carry;
	    if (partial_sum < 0) then
	       carry := 1;
	       larger.put(partial_sum + Base , i);
	       if (partial_sum + Base ) /= 0 then
		  last_not_zero := i;
	       end;
	    else
	       carry := 0;
	       larger.put(partial_sum, i);
	       if partial_sum /= 0 then
		  last_not_zero := i;
	       end;
	    end;
	    i := i + 1;
	 end;
	 larger.resize(last_not_zero + 1);
      ensure
	 internal_correct_fixed(larger);
      end;

   mult_fixed_with_integer(fa: FIXED_ARRAY[INTEGER]; int: INTEGER): FIXED_ARRAY[INTEGER] is
	 -- only a tool used by some features in positive and negative
	 -- large integers
	 -- Warning : temp can be an empty array if result is zero
	 -- Give a FIXED_ARRAY[INTEGER] for the creation of an 
	 -- large_integer after an multiplication between a 
	 -- large_integer and a small_integer.
      require
	 fa /= Void;
	 int /= 0;
      local
	 v11, v12, v13, v21, v22, v23: INTEGER;
	 ret, retenue: INTEGER;
	 d1, d2, d3: INTEGER;
	 i, bsup : INTEGER;
      do
	 !!Result.make(((nb_c(fa.item(fa.upper)) + 9 * (fa.count - 1) + nb_c(int)) / 9).ceiling);
	 from
	    v11 := int // (Half_base_2);
	    v13 := int \\ (Half_base_2);
	    v12 := v13 // Half_base;
	    v13 := v13 \\ Half_base;
	    i := Result.lower - 1
	    retenue := 0;
	    bsup := fa.upper
	 until
	    i = Result.upper
	 loop
	    i := i + 1;
	    if (i <= bsup) then
	       v21 := fa.item(i) // (Half_base_2);
	       v23 := fa.item(i) \\ (Half_base_2);
	       v22 := v23 // Half_base;
	       v23 := v23 \\ Half_base;
	       if Rest_base = 10 then
		  d1 := v23 * v12 + v13 * v22;
		  d2 := d1 // Half_base;
		  d1 := (d1 - (d2 * Half_base)) * Half_base + v23 * v13;
		  if d1 >= 2 * Half_base_2 then
		     d1 := d1 - (2 * (Half_base_2));
		     ret := 2;
		  else
		     if d1 >= Half_base_2 then
			d1 := d1 - (Half_base_2);
			ret := 1;
		     else
			ret := 0;
		     end;
		  end;
		  d2 := ret + d2 + (v23 * v11) + (v13 * v21) + (v12 * v22) + ((v11 * v22) \\ Half_base) * Half_base + ((v21 * v12) \\ Half_base) * Half_base;
		  d3 := (v11 * v22) // Half_base + (v21 * v12) // Half_base + v11 * v21;
		  ret := d2 // Rest_base;
		  d1 := d1 + (d2 - (ret * Rest_base)) * (Half_base_2);
		  d2 := d3 * (Half_base_2 // Rest_base) + ret;
	       else
		  ret := v13 * v23;
		  v11 := v12 * v23;
		  v21 := v22 * v13;
		  d1 := ret // Half_base + v11 \\ Half_base + v21 \\ Half_base;
		  d2 := d1 \\ Half_base;
		  d1 := (d1 - (d2 * Half_base)) * Half_base + ret \\ Half_base;
		  d2 := d2 + v11 // Half_base + v21 // Half_base + (v12 * v22);
	       end;
	       d3 := d1 + retenue
	       if d3 >= Base or else d3 < 0 then
		  retenue := d2 + 1;
		  Result.put(d3 - Base, i);
	       else
		  retenue := d2;
		  Result.put(d3, i);
	       end;
	    else
	       if retenue >= Base or else retenue < 0 then
		  Result.put(retenue - Base, i);
	       else
		  Result.put(retenue, i);
	       end;
	    end;
	 end;
	 if Result.item(Result.upper) = 0 then
	    Result.remove_last;
	 end;
      ensure
	 internal_correct_fixed(Result);
      end; 
   
   mult_fixed_with_integer_in_temp(fa: FIXED_ARRAY[INTEGER]; int: INTEGER) is
	 -- only a tool used by some features in positive and negative
	 -- large integers
	 -- Warning : temp can be an empty array if result is zero
	 -- Give a FIXED_ARRAY[INTEGER] for the creation of an 
	 -- large_integer after an multiplication between a 
	 -- large_integer and a small_integer.
      require
	 fa /= Void;
	 int /= 0;
      local
	 v11, v12, v13, v21, v22, v23: INTEGER;
	 ret, retenue: INTEGER;
	 d1, d2, d3: INTEGER;
	 i, bsup : INTEGER;
      do
	 temp_after_mult.resize(((nb_c(fa.item(fa.upper)) + nb_c(int) + 9 * (fa.count - 1)) / 9).ceiling);
	 from
	    v11 := int // (Half_base_2);
	    v13 := int \\ (Half_base_2);
	    v12 := v13 // Half_base;
	    v13 := v13 \\ Half_base;
	    i := temp_after_mult.lower - 1
	    retenue := 0;
	    bsup := fa.upper
	 until
	    i = temp_after_mult.upper
	 loop
	    i := i + 1;
	    if (i <= bsup) then
	       v21 := fa.item(i) // (Half_base_2);
	       v23 := fa.item(i) \\ (Half_base_2);
	       v22 := v23 // Half_base;
	       v23 := v23 \\ Half_base;
	       if Rest_base = 10 then
		  d1 := v23 * v12 + v13 * v22;
		  d2 := d1 // Half_base;
		  d1 := (d1 - (d2 * Half_base)) * Half_base + v23 * v13;
		  if d1 >= 2 * Half_base_2 then
		     d1 := d1 - (2 * (Half_base_2));
		     ret := 2;
		  else
		     if d1 >= Half_base_2 then
			d1 := d1 - (Half_base_2);
			ret := 1;
		     else
			ret := 0;
		     end;
		  end;
		  d2 := ret + d2 + (v23 * v11) + (v13 * v21) + (v12 * v22) + ((v11 * v22) \\ Half_base) * Half_base + ((v21 * v12) \\ Half_base) * Half_base;
		  d3 := (v11 * v22) // Half_base + (v21 * v12) // Half_base + v11 * v21;
		  ret := d2 // Rest_base;
		  d1 := d1 + (d2 - (ret * Rest_base)) * (Half_base_2);
		  d2 := d3 * (Half_base_2 // Rest_base) + ret;
	       else
		  ret := v13 * v23;
		  v11 := v12 * v23;
		  v21 := v22 * v13;
		  d1 := ret // Half_base + v11 \\ Half_base + v21 \\ Half_base;
		  d2 := d1 \\ Half_base;
		  d1 := (d1 - (d2 * Half_base)) * Half_base + ret \\ Half_base;
		  d2 := d2 + v11 // Half_base + v21 // Half_base + (v12 * v22);
	       end;
	       d3 := d1 + retenue
	       if d3 >= Base or else d3 < 0 then
		  retenue := d2 + 1;
		  temp_after_mult.put(d3 - Base, i);
	       else
		  retenue := d2;
		  temp_after_mult.put(d3, i);
	       end;
	    else
	       if retenue >= Base or else retenue < 0 then
		  temp_after_mult.put(retenue - Base, i);
	       else
		  temp_after_mult.put(retenue, i);
	       end;
	    end;
	 end;
	 if temp_after_mult.item(temp_after_mult.upper) = 0 then
	    temp_after_mult.remove_last;
	 end;
      ensure
	 internal_correct_fixed(temp_after_mult);
      end; 
   
   mult_fixed_with_integer_in(fa1: FIXED_ARRAY[INTEGER]; int: INTEGER; fa2: FIXED_ARRAY[INTEGER]) is
	 -- only a tool used by some features in positive and negative
	 -- large integers
	 -- Warning : temp can be an empty array if result is zero
	 -- result is stored in fa2
	 -- Make after the multiplication between a large_integer and 
	 -- a small_integer i shift and return the result in fa2 to have a 
	 -- good memory gestion.
	 -- Use this function if you know that larger is greater than 
	 -- smaller.
      require
	 fa1 /= Void;
	 fa2 /= Void;
	 int > 0;
      local
	 v11, v12, v13, v21, v22, v23: INTEGER;
	 ret, retenue: INTEGER;
	 d1, d2, d3: INTEGER;
	 i, bsup : INTEGER;
      do
	 fa2.resize(((fa1.item(fa1.upper).log10.truncated_to_integer + int.log10.truncated_to_integer + 9 * (fa1.count - 1) + 2) / 9).ceiling);
	 from
	    v11 := int // (Half_base_2);
	    v13 := int \\ (Half_base_2);
	    v12 := v13 // Half_base;
	    v13 := v13 \\ Half_base;
	    i := fa2.lower - 1
	    retenue := 0;
	    bsup := fa1.upper
	 until
	    i = fa2.upper
	 loop
	    i := i + 1;
	    if (i <= bsup) then
	       v21 := fa1.item(i) // (Half_base_2);
	       v23 := fa1.item(i) \\ (Half_base_2);
	       v22 := v23 // Half_base;
	       v23 := v23 \\ Half_base;
	       
	       if Rest_base = 10 then
		  d1 := v23 * v12 + v13 * v22;
		  d2 := d1 // Half_base;
		  d1 := (d1 - (d2 * Half_base)) * Half_base + v23 * v13;
		  if d1 >= 2 * Half_base_2 then
		     d1 := d1 - (2 * (Half_base_2));
		     ret := 2;
		  else
		     if d1 >= Half_base_2 then
			d1 := d1 - Half_base_2;
			ret := 1;
		     else
			ret := 0;
		     end;
		  end;
		  d2 := ret + d2 + (v23 * v11) + (v13 * v21) + (v12 * v22) + ((v11 * v22) \\ Half_base) * Half_base + ((v21 * v12) \\ Half_base) * Half_base;
		  d3 := (v11 * v22) // Half_base + (v21 * v12) // Half_base + v11 * v21;
		  ret := d2 // Rest_base;
		  d1 := d1 + (d2 - (ret * Rest_base)) * (Half_base_2);
		  d2 := d3 * (Half_base_2 // Rest_base) + ret;
	       else
		  ret := v13 * v23;
		  v11 := v12 * v23;
		  v21 := v22 * v13;
		  d1 := ret // Half_base + v11 \\ Half_base + v21 \\ Half_base;
		  d2 := d1 \\ Half_base;
		  d1 := (d1 - (d2 * Half_base)) * Half_base + ret \\ Half_base;
		  d2 := d2 + v11 // Half_base + v21 // Half_base + (v12 * v22);
	       end;
	       d3 := d1 + retenue
	       if d3 >= Base or else d3 < 0 then
		  retenue := d2 + 1;
		  fa2.put(d3 - Base, i);
	       else
		  retenue := d2;
		  fa2.put(d3, i);
	       end;
	    else
	       if retenue >= Base or else retenue < 0 then
		  fa2.put(retenue - Base, i);
	       else
		  fa2.put(retenue, i);
	       end;
	    end;
	 end;
	 if fa2.item(fa2.upper) = 0 then
	    fa2.remove_last;
	 end;
      ensure
	 internal_correct_fixed(fa2);
      end; 
   
   mult_2_fixed(fa1, fa2: FIXED_ARRAY[INTEGER]): FIXED_ARRAY[INTEGER] is
	 -- only a tool used by some features in positive and negative
	 -- large integers
	 -- Warning : temp can be an empty array if result is zero
	 -- Give a FIXED_ARRAY[INTEGER] for the creation of an 
	 -- large_integer after the multiplication of 2 large_integer.
      require
	 fa1 /= Void;
	 fa2 /= Void;
      local
	 i : INTEGER;
      do
	 !!Result.make(((fa1.item(fa1.upper).log10.truncated_to_integer + 9 * (fa1.count - 1) + fa2.item(fa2.upper).log10.truncated_to_integer + 9 * (fa2.count - 1) + 2) / 9).ceiling);
	 from
	    mult_fixed_with_integer_in(fa1, fa2.item(fa2.upper), Result);
	    i := fa2.upper - 1;
	 until
	    i < 0
	 loop
	    shift(Result);
	    if (fa2.item(i) /= 0) then
	       mult_fixed_with_integer_in(fa1, fa2.item(i), temp_from_mult);
	       add_fixed_arrays_in_himself(temp_from_mult, Result);
	    end;
	    i := i - 1;
	 end;
      ensure
	  internal_correct_fixed(Result);
      end;
   
   mult_2_fixed_in_temp(fa1, fa2: FIXED_ARRAY[INTEGER]) is
	 -- only a tool used by some features in positive and negative
	 -- large integers
	 -- Warning : temp can be an empty array if result is zero
	 -- Result is stored in temp_after_mult
	 -- Make the multiplication between 2 large_integer and the 
	 -- result is stored in tmp_from_div to have a good memory gestion
      require
	 fa1 /= Void;
	 fa2 /= Void;
      local
	 i : INTEGER;
      do
	 from
	    mult_fixed_with_integer_in(fa1, fa2.item(fa2.upper), temp_after_mult);
	    i := fa2.upper - 1;
	 until
	    i < 0
	 loop
	    shift(temp_after_mult);
	    if (fa2.item(i) /= 0) then
	       mult_fixed_with_integer_in(fa1, fa2.item(i), temp_from_mult);
	       add_fixed_arrays_in_himself(temp_from_mult, temp_after_mult);
	    end;
	    i := i - 1;
	 end;
      ensure
	  internal_correct_fixed(temp_after_mult);
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
	 -- Make the division between 2 abstract_integer.
	 -- quotient is stored in temp_quotient.
	 -- remainder is stored in temp_remainder.
      require
	 dividende /= Void;
	 internal_correct_fixed(dividende);
	 divisor /= Void;
	 internal_correct_fixed(divisor); 
	 divisor.upper >= 0;
      local
	 double_num, double_den, approx : DOUBLE;
	 n, val: INTEGER;
	 t, td: BOOLEAN;
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
	       t := true;
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
		  temp_2_digints.put((approx / Double_base).truncated_to_integer, 1);
		  temp_2_digints.put((approx - (Double_base * temp_2_digints.item(1))).truncated_to_integer, 0);
		  td := false;
		  if t then
		     t := false;
		     temp_quotient.resize(2 + n);
		  end;
	       else
		  val := approx.truncated_to_integer;
		  td := true;
		  if t then
		     t := false;
		     temp_quotient.resize(1 + n);
		  end;
	       end;
	       if td then
		  add_fixed_array_with_integer_in_himself_from(val, temp_quotient, n);
		  mult_fixed_with_integer_in_temp(divisor, val)
	       else
		  add_fixed_arrays_in_himself_from(temp_2_digints, temp_quotient, n);
		  mult_2_fixed_in_temp(temp_2_digints, divisor);
	       end;
	       difference_between_fixed_arrays_in_himself_from(temp_remainder, temp_after_mult, n);
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
