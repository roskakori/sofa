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
deferred class TIME_IN_SOME_LANGUAGE
--
-- The polymophic format class for BASIC_TIME.
--

inherit ANY redefine out_in_tagged_out_memory end;

feature

   basic_time: BASIC_TIME;

   set_basic_time(bt: BASIC_TIME) is
      do
         basic_time := bt;
      ensure
         basic_time = bt
      end;

   short_mode: BOOLEAN;
         -- Is the formatting mode set to the short (abbreviated) 
         -- mode ?

   set_short_mode(value: BOOLEAN) is
      do
         short_mode := value;
      ensure 
         short_mode = value
      end;

   day_in(buffer: STRING) is
         -- According to the current `short_mode', append in the `buffer' 
         -- the name of the day.
      deferred
      end;

   month_in(buffer: STRING) is
         -- According to the current `short_mode', append in the `buffer' 
         -- the name of the day.
      deferred
      end;

   frozen to_string: STRING is
      do
         to_string_buffer.clear;
         append_in(to_string_buffer);
         Result := to_string_buffer.twin;
      end;
   
   append_in(buffer: STRING) is
      deferred
      end;

   frozen out_in_tagged_out_memory is
      do
         append_in(tagged_out_memory);
      end;

feature {NONE}

   to_string_buffer: STRING is
      once
	 !!Result.make(128);
      end;

end
