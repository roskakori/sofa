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
expanded class INTEGER
--
-- Note: An Eiffel INTEGER is mapped as a C int or as a Java int.
--

inherit
   INTEGER_REF
      redefine
         infix "+", infix "-", infix "*", infix "/", infix "\\", 
         infix "//", infix "^", infix "<", infix "<=", infix ">",
         infix ">=", prefix "-", prefix "+", hash_code, 
         out_in_tagged_out_memory, fill_tagged_out_memory
      end;

feature 
   
   infix "+" (other: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   infix "-" (other: INTEGER): INTEGER is
      external "SmallEiffel"
      end;

   infix "*" (other: INTEGER): INTEGER is
      external "SmallEiffel"
      end;

   infix "/" (other: INTEGER): DOUBLE is
      external "SmallEiffel"
      end;

   infix "//" (other: INTEGER): INTEGER is
      external "SmallEiffel"
      end;

   infix "\\" (other: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   infix "^" (exp: INTEGER): INTEGER is
      do
         if exp = 0 then
            Result := 1;
         elseif exp \\ 2 = 0 then
            Result := (Current * Current) ^ (exp // 2);
         else
            Result := Current * (Current ^ (exp - 1));
         end;
      end;
   
   abs: INTEGER is
         -- Absolute value of `Current'.
      do
         if Current < 0 then
            Result := -Current;
         else
            Result := Current;
         end;
      end;
         
   infix "<" (other: INTEGER): BOOLEAN is
         -- Is 'Current' strictly less than 'other'?
      external "SmallEiffel"
      end;

   infix "<=" (other: INTEGER): BOOLEAN is
         -- Is 'Current' less or equal 'other'?
      external "SmallEiffel"
      end;

   infix ">" (other: INTEGER): BOOLEAN is
         -- Is 'Current' strictly greater than 'other'?
      external "SmallEiffel"
      end;

   infix ">=" (other: INTEGER): BOOLEAN is
         -- Is 'Current' greater or equal than 'other'?
      external "SmallEiffel"
      end;

   prefix "+": INTEGER is
      do
         Result := Current
      end;

   prefix "-": INTEGER is
      external "SmallEiffel"
      end;
   
   odd: BOOLEAN is
         -- Is odd ?
      do
         Result := (Current \\ 2) = 1;
      end;

   even: BOOLEAN is
         -- Is even ?
      do
         Result := (Current \\ 2) = 0;
      end;

   sqrt: DOUBLE is
         -- Compute the square routine.
      do
         Result := to_double.sqrt;
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

   gcd(other: INTEGER): INTEGER is
         -- Great Common Divisor of `Current' and `other'.
      require
         Current >= 0;
         other >= 0;
      do
         if other = 0 then 
            Result := Current
         else
            Result := other.gcd(Current \\ other);
         end;    
      ensure
         Result = other.gcd(Current);
      end;
   
feature -- Conversions :
   
   to_real: REAL is
      do
         Result := Current;
      end;
   
   to_double: DOUBLE is
      do
         Result := Current;
      end;
   
   to_string: STRING is
         -- Convert the decimal view of `Current' into a new allocated STRING.
         -- For example, if `Current' is -1 the new STRING is "-1".
         -- Note: see also `append_in' to save memory.
      do
	 tmp_string.clear;
         append_in(tmp_string);
         Result := tmp_string.twin;
      end; 

   to_boolean: BOOLEAN is
         -- Return false for 0, otherwise true.
      do
         Result := Current /= 0;
      ensure 
         Result = (Current /= 0)
      end;

   to_number: NUMBER is
      local
	 number_tools: NUMBER_TOOLS;
      do
	 Result := number_tools.from_integer(Current);
      ensure
	 Result @= Current
      end;

   to_bit: BIT Integer_bits is
         -- Portable BIT_N conversion.
      external "SmallEiffel"
      end;

   append_in(buffer: STRING) is
         -- Append in the `buffer' the equivalent of `to_string'. No new STRING 
         -- creation during the process.
      require
         buffer /= Void
      local
         val, i: INTEGER;
      do
         if Current = 0 then
            buffer.extend('0');
         else
            if Current > 0 then
               from
                  i := buffer.count + 1;
                  val := Current;
               until
                  val = 0
               loop
                  buffer.extend((val \\ 10).digit);
                  val := val // 10;
               end;
            else
               buffer.extend('-');
               from
                  i := buffer.count + 1;
                  val := Current;
               until
                  val = 0
               loop
                  buffer.extend((-(val \\ 10)).digit);
                  val := val // 10;
               end;
            end;
            from  
               val := buffer.count;
            until
               i >= val
            loop
               buffer.swap(i,val);
               val := val - 1;
               i := i + 1;
            end;
         end;
      end; 
   
   to_string_format(s: INTEGER): STRING is
         -- Same as `to_string' but the result is on `s' character and the 
         -- number is right aligned. 
         -- Note: see `append_in_format' to save memory.
      require
         to_string.count <= s
      local
	 i: INTEGER;
      do
	 tmp_string.clear;
	 append_in(tmp_string);
         from
	    !!Result.make(tmp_string.count.max(s));
	    i := s - tmp_string.count;
         until
	    i <= 0
         loop
            Result.extend(' ');
	    i := i - 1;
	 end;
         Result.append(tmp_string);
      ensure
         Result.count = s
      end; 

   append_in_format(str: STRING; s: INTEGER) is
         -- Append the equivalent of `to_string_format' at the end of 
         -- `str'. Thus you can save memory because no other
         -- STRING is allocate for the job.
      require
	 to_string.count <= s
      local
	 i: INTEGER;
      do
	 tmp_string.clear;
	 append_in(tmp_string);
         from
	    i := s - tmp_string.count;
         until
            i <= 0
         loop
            str.extend(' ');
	    i := i - 1;
         end;
         str.append(tmp_string);
      ensure
         str.count >= (old str.count) + s
      end;
   
   decimal_digit, digit: CHARACTER is
         -- Gives the corresponding CHARACTER for range 0..9.
      require
         in_range(0,9)
      do
         Result := (Current + ('0').code).to_character;
      ensure
         ("0123456789").has(Result);
         Result.value = Current
      end;
      
   hexadecimal_digit: CHARACTER is
         -- Gives the corresponding CHARACTER for range 0..15.
      require
         in_range(0,15)
      do
         if Current <= 9 then
            Result := digit;
         else
            Result := (('A').code + (Current - 10)).to_character;
         end;
      ensure
         ("0123456789ABCDEF").has(Result)
      end;

   to_character: CHARACTER is
         -- Return the coresponding ASCII character.
      require
         Current >= 0;
      external "SmallEiffel"
      end;
   
   to_octal: INTEGER is
         -- Gives coresponding octal value.
      do
         if Current = 0 then
         elseif Current < 0 then
            Result := -((-Current).to_octal);
         else
            from  
               tmp_string.clear;
               Result := Current;
            until
               Result = 0
            loop
               tmp_string.extend((Result \\ 8).digit);
               Result := Result // 8;
            end;
            tmp_string.reverse;
            Result := tmp_string.to_integer;
         end;
      end;
   
   to_hexadecimal: STRING is
         -- Convert the hexadecimal view of `Current' into a new allocated 
         -- STRING. For example, if `Current' is -1 the new STRING is "FFFF" 
         -- on a 32 bit machine.
         -- Note: see also `to_hexadecimal_in' to save memory.
      do
         tmp_string.clear;
         to_hexadecimal_in(tmp_string);
         Result := tmp_string.twin;
      ensure
         Result.count = Integer_bits / 4
      end;

   to_hexadecimal_in(buffer: STRING) is
         -- Append in `buffer' the equivalent of `to_hexadecimal'. No new STRING 
         -- creation during the process.
      local
         one_digit, times, index: INTEGER;
         value: BIT Integer_bits;
      do
         from
            value := to_bit;
            times := Integer_bits // 4;
            index := buffer.count + times;
            buffer.extend_multiple(' ',times);
         until
            times = 0
         loop
            one_digit := (value and 1111B).to_integer;
            buffer.put(one_digit.hexadecimal_digit,index);
            index := index - 1;
            value := value @>> 4;
            times := times - 1;
         end;
      ensure
         buffer.count = old buffer.count + Integer_bits / 4
      end;
      
feature -- Object Printing :

   out_in_tagged_out_memory, fill_tagged_out_memory is
      do
         Current.append_in(tagged_out_memory);
      end;

feature -- Hashing :
   
   hash_code: INTEGER is
      do
         if Current < 0 then
            Result := -(Current + 1);
         else
            Result := Current;
         end
      end;

feature {NONE}
   
   tmp_string: STRING is 
      once
         !!Result.make(128);
      end;
         
end -- INTEGER

