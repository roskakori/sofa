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
expanded class  REAL
--
-- Note: An Eiffel REAL is mapped as a C float or as a Java float.
--

inherit
   REAL_REF
      redefine
         infix "+", infix "-", infix "*", infix "/", infix "^",
         prefix "+", prefix "-", divisible, infix "<", 
         infix "<=", infix ">", infix ">=", out_in_tagged_out_memory, 
         fill_tagged_out_memory, hash_code
      end;
   
feature {ANY}

   infix "+" (other: REAL): REAL is
      external "SmallEiffel"
      end;

   infix "-" (other: REAL): REAL is
      external "SmallEiffel"
      end;

   infix "*" (other: REAL): REAL is
      external "SmallEiffel"
      end;
   
   infix "/" (other: REAL): REAL is
      external "SmallEiffel"
      end;

   infix "^" (e: INTEGER): DOUBLE is
      do
         check
            Current = 0.0 implies e > 0;
         end;
         Result := to_double ^ e; 
      end;

   prefix "+" : REAL is
      do
         Result := Current
      end;

   prefix "-": REAL is
      external "SmallEiffel"
      end;

   abs: REAL is
      do
         if Current < 0.0 then
            Result := -Current;
         else
            Result := Current;
         end;
      end;
         
   infix "<" (other: REAL): BOOLEAN is
      external "SmallEiffel"
      end;
   
   infix "<=" (other: REAL): BOOLEAN is
      external "SmallEiffel"
      end;
   
   infix ">" (other: REAL): BOOLEAN is
      external "SmallEiffel"
      end;
   
   infix ">=" (other: REAL): BOOLEAN is
      external "SmallEiffel"
      end;
   
   divisible(other: REAL): BOOLEAN is
      do
         Result := (other /= 0.0)
      end;
   
   floor: INTEGER is
         -- Greatest integral value no greater than Current.
      do
         Result := to_double.floor;
      ensure 
         result_no_greater: Current >= Result;
         close_enough: Current - Result < one;
      end;
      
   ceiling: INTEGER is
         -- Smallest integral value no smaller than Current.
      do
         Result := to_double.ceiling;
      ensure
         result_no_smaller: Current <= Result;
         close_enough: Result.to_real - Current < one;
      end;

   rounded: INTEGER is
         -- Rounded integral value.
      do
         Result := to_double.rounded;
      end;

   truncated_to_integer: INTEGER is
         -- Integer part (same sign, largest absolute value
         -- no greater than Current).
      do
         Result := to_double.truncated_to_integer;
      ensure
         Result.to_real <= Current
      end;
   
   to_string: STRING is
         -- Convert the REAL into a new allocated STRING. 
         -- Note: see `append_in' to save memory.
      do
         Result := to_double.to_string;
      end; 

   append_in(str: STRING) is
         -- Append the equivalent of `to_string' at the end of 
         -- `str'. Thus you can save memory because no other
         -- STRING is allocate for the job.
      require
         str /= Void;
      do
         to_double.append_in(str);
      end; 
   
   to_string_format(d: INTEGER): STRING is
         -- Convert the REAL into a new allocated STRING including 
         -- only `d' digits in fractionnal part. 
         -- Note: see `append_in_format' to save memory.
      do
         Result := to_double.to_string_format(d);
      end; 

   append_in_format(str: STRING; f: INTEGER) is
         -- Same as `append_in' but produce only `f' digit of 
         -- the fractionnal part.
      require
         str /= Void;
         f >= 0
      do
         to_double.append_in_format(str,f);
      end; 
   
   to_double: DOUBLE is
      external "SmallEiffel"
      end;
   
feature -- Maths functions :

   sqrt: DOUBLE is
         -- Compute the square routine.
      require
         Current >= 0
      do
         Result := to_double.sqrt;
      end;
   
   sin: DOUBLE is
         -- Sinus (ANSI C sin).
      do
         Result := to_double.sin;
      end;

   cos: DOUBLE is
         -- Cosinus (ANSI C cos).
      do
         Result := to_double.cos;
      end;

   tan: DOUBLE is
         -- (ANSI C tan).
      do
         Result := to_double.tan;
      end;

   asin: DOUBLE is
         -- (ANSI C asin).
      do
         Result := to_double.asin;
      end;

   acos: DOUBLE is
         -- (ANSI C acos).
      do
         Result := to_double.acos;
      end;

   atan: DOUBLE is
         -- (ANSI C atan).
      do
         Result := to_double.atan;
      end;

   sinh: DOUBLE is
         -- (ANSI C sinh).
      do
         Result := to_double.sinh;
      end;

   cosh: DOUBLE is
         -- (ANSI C cosh).
      do
         Result := to_double.cosh;
      end;

   tanh: DOUBLE is
         -- (ANSI C tanh).
      do
         Result := to_double.tanh;
      end;

   exp: DOUBLE is
         -- (ANSI C exp).
      do
         Result := to_double.exp;
      end;

   log: DOUBLE is
         -- (ANSI C log).
      do
         Result := to_double.log;
      end;

   log10: DOUBLE is
         -- (ANSI C log10).
      do
         Result := to_double.log10;
      end;

feature -- Object Printing :

   out_in_tagged_out_memory, fill_tagged_out_memory is
      do
         Current.append_in(tagged_out_memory);
      end;

feature -- Hashing :

   hash_code: INTEGER is
      do
         Result := to_double.hash_code;
      end;

end --  REAL

