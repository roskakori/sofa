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
expanded class DOUBLE
--
-- Note: An Eiffel DOUBLE is mapped as a C double or as a Java double.
--

inherit
   DOUBLE_REF
      redefine
         infix "+", infix "-", infix "*", infix "/", infix "^", prefix "+",
         prefix "-", divisible, infix "<", infix "<=", infix ">", infix ">=",
         fill_tagged_out_memory, out_in_tagged_out_memory, hash_code
      end;
   
feature {ANY}

   infix "+" (other: DOUBLE): DOUBLE is
      external "SmallEiffel"
      end;

   infix "-" (other: DOUBLE): DOUBLE is
      external "SmallEiffel"
      end;

   infix "*" (other: DOUBLE): DOUBLE is
      external "SmallEiffel"
      end;
   
   infix "/" (other: DOUBLE): DOUBLE is
      external "SmallEiffel"
      end;

   infix "^" (e: INTEGER): DOUBLE is
         -- Raise Current to `e'-th power (see also `pow').
      external "SmallEiffel" 
      end;

   prefix "+" : DOUBLE is
      do
         Result := Current
      end;

   prefix "-": DOUBLE is
      external "SmallEiffel"
      end;

   abs: DOUBLE is
      do
         if Current < 0.0 then
            Result := -Current;
         else
            Result := Current;
         end;
      end;
         
   infix "<" (other: DOUBLE): BOOLEAN is
      external "SmallEiffel"
      end;
   
   infix "<=" (other: DOUBLE): BOOLEAN is
      external "SmallEiffel"
      end;
   
   infix ">" (other: DOUBLE): BOOLEAN is
      external "SmallEiffel"
      end;
   
   infix ">=" (other: DOUBLE): BOOLEAN is
      external "SmallEiffel"
      end;
   
   divisible(other: DOUBLE): BOOLEAN is
      do
         Result := (other /= 0.0)
      end;
   
   double_floor: DOUBLE is
         -- Greatest integral value no greater than Current.
      external "SmallEiffel"
      end;

   floor: INTEGER is
         -- Greatest integral value no greater than Current.
      local
         d: DOUBLE;
      do
         d := double_floor;
         Result := d.truncated_to_integer;
      ensure 
         result_no_greater: Result <= Current;
	 close_enough: Current - Result < one
      end;

   double_ceiling: DOUBLE is
         -- Smallest integral value no smaller than Current.
      do
         Result := ceil;
      end;

   ceiling: INTEGER is
         -- Smallest integral value no smaller than Current.
      local
         d: DOUBLE;
      do
         d := double_ceiling;
         Result := d.truncated_to_integer;
      ensure
	 result_no_smaller: Result >= Current;
	 close_enough: Result - Current < one
      end;

   rounded: INTEGER is
         -- Rounded integral value.
      do
         if double_floor + 0.5 < Current then
            Result := double_ceiling.truncated_to_integer;
         else
            Result := double_floor.truncated_to_integer;
         end;
      end;
   
   truncated_to_integer: INTEGER is
         -- Integer part (same sign, largest absolute value
         -- no greater than Current).
      external "SmallEiffel"
      ensure
         Result.to_double <= Current
      end;
   
   to_real: REAL is
         -- Note: C conversion from "double" to "float".
         -- Thus, Result can be undefine (ANSI C).
      external "SmallEiffel"
      end;
   
   to_string: STRING is
         -- Convert the DOUBLE into a new allocated STRING. 
         -- As ANSI C, the default number of digit for the
         -- fractionnal part is 6.
         -- Note: see `append_in' to save memory.
      do
         !!Result.make(8);
         append_in(Result);
      end; 

   append_in(str: STRING) is
         -- Append the equivalent of `to_string' at the end of 
         -- `str'. Thus you can save memory because no other
         -- STRING is allocate for the job.
      require
         str /= Void
      do
         append_in_format(str,6);
      end; 
   
   to_string_format(f: INTEGER): STRING is
         -- Convert the DOUBLE into a new allocated STRING including 
         -- only `f' digits in fractionnal part. 
         -- Note: see `append_in_format' to save memory.
      require
         f >= 0
      do
         sprintf_double(sprintf_double_buffer,f);
         !!Result.from_external_copy(sprintf_double_buffer.to_pointer);
      end; 

   append_in_format(str: STRING; f: INTEGER) is
         -- Same as `append_in' but produce `f' digit of 
         -- the fractionnal part.
      require
         str /= Void;
         f >= 0
      local
         i: INTEGER;
      do
         from
            sprintf_double(sprintf_double_buffer,f);
            i := 0;
         until
            sprintf_double_buffer.item(i) = '%U'
         loop
            str.extend(sprintf_double_buffer.item(i));
            i := i + 1;
         end;
      end; 
   
feature -- Maths functions :

   sqrt: DOUBLE is
         -- Square root of `Current' (ANSI C `sqrt').
      require
         Current >= 0
      external "SmallEiffel"
      end;

   sin: DOUBLE is
         -- Sine of `Current' (ANSI C `sin').
      external "SmallEiffel"
      end;

   cos: DOUBLE is
         -- Cosine of `Current' (ANSI C `cos').
      external "SmallEiffel"
      end;

   tan: DOUBLE is
         -- Tangent of `Current' (ANSI C `tan').
      external "SmallEiffel"
      end;

   asin: DOUBLE is
         -- Arc Sine of `Current' (ANSI C `asin').
      external "SmallEiffel"
      end;

   acos: DOUBLE is
         -- Arc Cosine of `Current' (ANSI C `acos').
      external "SmallEiffel"
      end;

   atan: DOUBLE is
         -- Arc Tangent of `Current' (ANSI C `atan').
      external "SmallEiffel"
      end;

   atan2(x: DOUBLE): DOUBLE is
         -- Arc Tangent of `Current' / `x'  (ANSI C `atan2').
      external "SmallEiffel"
      end;

   sinh: DOUBLE is
         -- Hyperbolic Sine of `Current' (ANSI C `sinh').
      external "SmallEiffel"
      end;

   cosh: DOUBLE is
         -- Hyperbolic Cosine of `Current' (ANSI C `cosh').
      external "SmallEiffel"
      end;

   tanh: DOUBLE is
	 -- Hyperbolic Tangent of `Current' (ANSI C `tanh').
      external "SmallEiffel"
      end;

   exp: DOUBLE is
         -- Exponential of `Current' (ANSI C `exp').
      external "SmallEiffel"
      end;

   log: DOUBLE is
         -- Natural Logarithm of `Current' (ANSI C `log').
      external "SmallEiffel"
      end;

   log10: DOUBLE is
         -- Base-10 Logarithm of Current (ANSI C `log10').
      external "SmallEiffel"
      end;

   pow(e: DOUBLE): DOUBLE is
	 -- `Current' raised to the power of `e' (ANSI C `pow').
      external "SmallEiffel"
      end;

feature -- Object Printing :

   out_in_tagged_out_memory, fill_tagged_out_memory is
      do
         Current.append_in(tagged_out_memory);
      end;

feature -- Hashing :

   hash_code: INTEGER is
      do
         Result := truncated_to_integer;
	 if Result < 0 then
	    Result := - (Result + 1);
	 end;
      end;

feature {NONE}

   ceil: DOUBLE is 
      external "SmallEiffel"
      end;

   sprintf_double(native_array: NATIVE_ARRAY[CHARACTER]; f: INTEGER) is
         -- Put in the `native_array' a viewable version of Current with
         -- `f' digit of the fractionnal part. Assume the `native_array' is 
         -- large enougth.
      require
         f >= 0
      external "SmallEiffel"
      end;
   
   sprintf_double_buffer: NATIVE_ARRAY[CHARACTER] is
      once
         Result := Result.calloc(1024);
      end;

end -- DOUBLE

