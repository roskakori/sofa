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
expanded class NUMBER_TOOLS
--
-- This clas provides abstract creation functions for NUMBERs.
-- 
-- One may inherit this class in order to use NUMBERs.
-- 

feature

   is_number(s: STRING): BOOLEAN is
	 -- Is `s' the view of some NUMBER ?
      require
	 not s.is_empty
      local
	 i, state: INTEGER;
	 c: CHARACTER;
      do
	 from
	    i := 1;
	    c := s.item(i);
	 until
	    state > 6 or else i > s.count
	 loop
	    inspect
	       state
	    when 0 then	 
	       -- Waiting optional sign or first digit :
	       inspect
		  c
	       when ' ', '%T' then
	       when '+', '-' then
		  state := 1;
	       when '0' .. '9' then
		  state := 2;
	       else
		  state := 8;
	       end;
	    when 1 then
	       	 -- Waiting first digit (sign read) :
	       inspect
		  c
	       when ' ', '%T' then
	       when '0' .. '9' then
		  state := 2;
	       else
		  state := 8;
	       end;
	    when 2 then
	       -- Inside integer or numerator :
	       inspect
		  c
	       when ' ', '%T' then
		  state := 3;
	       when '0' .. '9' then
	       when '/' then
		  state := 4;
	       else
		  state := 8;
	       end;
	    when 3 then
	       -- Waiting end of integer or / of fraction :
	       inspect
		  c
	       when ' ', '%T' then
	       when '/' then
		  state := 4;
	       else
		  state := 8;
	       end;
	    when 4 then
	       -- Inside a fraction after / :
	       inspect
		  c
	       when ' ', '%T' then
	       when '0' .. '9' then
		  state := 5;
	       else
		  state := 8;
	       end;
	    when 5 then
	       -- Inside denominator :
	       inspect
		  c
	       when ' ', '%T' then
		  state := 6;
	       when '0' .. '9' then
	       else
		  state := 8;
	       end;
	    when 6 then
	       -- After denominator :
	       inspect
		  c
	       when ' ', '%T' then
	       else
		  state := 8;
	       end;
	    end;
	    -- state = 7 : end.
	    -- state = 8 : error.
	    i := i + 1;
	    if i <= s.count then
	       c := s.item(i);
	    end;
	 end;
	 -- Setting `Result' :
	 inspect
	    state
	 when 2, 3, 5, 6, 7 then
	    Result := true;
	 else
	 end;
      end;


   from_integer(n: INTEGER): NUMBER is
	 -- Uses value `n' to create a new NUMBER.
      do
	 if (n = Minimum_integer)  then
	    !LARGE_NEGATIVE_INTEGER!Result.make_smaller(0);
         else
	    !SMALL_INTEGER!Result.make(n);
	 end;
      ensure
	 Result.to_integer = n
      end;
   
   from_string(s: STRING): NUMBER is
	 -- Uses contents of `s' to create a new NUMBER.
      require
	 is_number(s)
      local
	 i: INTEGER;
	 num, den: ABSTRACT_INTEGER;
	 nb_is_negative: BOOLEAN;
	 length, first, last, base: INTEGER;
	 power: ABSTRACT_INTEGER;      
      do
	 i := s.index_of('/');
	 if (i = s.count + 1) then	    
	    nb_is_negative := false;
	    if s.first.is_equal('-') then
	       nb_is_negative := true;
	       s.remove_first(1);
	    elseif s.first.is_equal('+') then
	       s.remove_first(1);
	    end;
	    from
	       length := i.Maximum_integer.to_string.count - 1;
	       !SMALL_INTEGER!Result.make(0);	    
	       last := s.count;
	       power ?= Result.one;
	       check
		  power /= Void;
	       end;
	       base := 10^length;
	    until
	       last <= 0
	    loop
	       first := last - length;
	       if first < 0 then
		  first := 0;
	       end;
	       Result := Result + ( power @* s.substring(first+1, last).to_integer );
	       power ?= power @* base;  
	       check
		  power /= Void;
	       end;
	       last := first;
	    end;
	    if nb_is_negative then
	       Result := -Result;
	    end;	 
	 else	 
	    num ?= from_string( s.substring(1, i - 1) );	    
	    den ?= from_string( s.substring(i +1, s.count ) );
	    check
	       num /= Void;
	       den /= Void;
	    end;
	    if (num \\ den).same_as( num.zero ) then 
	       Result := num / den;
	    else
	       if num.is_integer and then den.is_integer then
		  !SMALL_FRACTION!Result.make_from_integer(num.to_integer, den.to_integer);
	       else
		  nb_is_negative := num.is_negative xor den.is_negative;
		  num ?= num.abs;
		  den ?= den.abs;
		  check
		     num /= Void;
		     den /= Void;
		  end;
		  !LARGE_FRACTION!Result.make(num, den, nb_is_negative);
	       end;
	    end;
	 end;
      ensure
	 Result /= Void
      end; 
   
   from_input_stream(input: INPUT_STREAM ): NUMBER is
	 -- Create a number from a file or standard input
      require
	 input.is_connected
      local
	 string: STRING;
      do
	 if not( input.end_of_input ) then
	    !!string.make(0);
	    input.read_line_in( string );
	    Result := from_string( string );
	 end;
      end;

end -- NUMBER_TOOLS








