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
deferred class INPUT_STREAM
   --
   -- This abstract class is the superclass of all classes 
   -- representing an input stream of bytes. 
   --

feature -- State of the stream :

   is_connected: BOOLEAN is
         -- True when the corresponding stream is connected
         -- to some physical input device.
      deferred
      end;

   end_of_input: BOOLEAN is
         -- Has end-of-input been reached ?
         -- True when the last character has been read.
      require
         is_connected
      deferred
      end;

feature -- To read one character at a time :

   read_character is
         -- Read a character and assign it to `last_character'.
      require
         not end_of_input
      deferred
      ensure
         not push_back_flag
      end;

   last_character: CHARACTER is
         -- Last character read with `read_character'.
      require
         is_connected
      deferred
      end;
   
   push_back_flag: BOOLEAN;
         -- True in one char is already pushed back.

   unread_character is
         -- Un-read the last character read.
      require
         not push_back_flag
      deferred
      ensure
         push_back_flag
      end;

feature -- Skipping separators :

   skip_separators is
         -- Skip all separators (see `is_separator' of class CHARACTER) and 
         -- make the first non-separator available in `last_character'. This 
         -- non-separator character is pushed back into the stream (see 
         -- `unread_character') to be available one more time (the next 
         -- `read_character' will consider this non-separator). When 
         -- `end_of_input' occurs, this process is automatically stopped.
      do
         from  
         until
            end_of_input or else not last_character.is_separator
         loop
            read_character;
         end;
         if not end_of_input and then not push_back_flag then
            unread_character
         end
      end;
   
   skip_separators_using(separators:STRING) is
         -- Same job as `skip_separators' using the `separators' set.
      require 
         separators /= void
      do
         from 
         until
            end_of_input or else 
            not separators.has(last_character)
         loop
            read_character;
         end;
         if not end_of_input and then not push_back_flag then
            unread_character
         end
      end;

   skip_remainder_of_line is
         -- Skip all the remainder of the line including the end of 
         -- line character itself.
      local
         stop: BOOLEAN;
      do
         from until stop
         loop
            if end_of_input then
               stop := true;
            else
               inspect
                  last_character
               when '%N', '%R' then
                  read_character;
                  stop := true;
               else 
                  read_character;
               end;
            end;
         end;
      end;
   
feature -- To read one number at a time :
   
   read_integer is
         -- Read an integer according to the Eiffel syntax.
         -- Make result available in `last_integer'.
         -- Heading separators are automatically skipped using 
         -- `is_separator' of class CHARACTER.
         -- Trailing separators are not skipped.
      require
         not end_of_input
      local
         state: INTEGER;
         sign: BOOLEAN;
         -- state = 0 : waiting sign or first digit.
         -- state = 1 : sign read, waiting first digit.
         -- state = 2 : in the number.
         -- state = 3 : end state.
         -- state = 4 : error state.
      do
         from
         until
            state > 2
         loop
            read_character;
            inspect 
               state
            when 0 then
               if last_character.is_separator then
               elseif last_character.is_digit then
                  last_integer := last_character.value;
                  state := 2;
               elseif last_character = '-' then
                  sign := true;
                  state := 1;
               elseif last_character = '+' then
                  state := 1;
               else
                  state := 4;
               end;
            when 1 then
               if last_character.is_separator then
               elseif last_character.is_digit then
                  last_integer := last_character.value;
                  state := 2;
               else
                  state := 4;
               end;
            else -- 2
               if last_character.is_digit then
                  last_integer := (last_integer * 10) + last_character.value;
               else
                  state := 3;
               end;
            end;
            if end_of_input then
               inspect 
                  state
               when 0 .. 1 then
                  state := 4;
               when 2 .. 3 then
                  state := 3;
               else -- 4
               end;
            end;
         end;
         if not end_of_input then
            unread_character;
         end;
         debug
            if state = 4 then
               std_error.put_string("Error in INPUT_STREAM.read_integer.%N");
               crash;
            end;
         end;
         if sign then
            last_integer := - last_integer;
         end;
      end;
   
   last_integer: INTEGER; 
         -- Last integer read using `read_integer'.
   
   read_real is
         -- Read a REAL and make the result available in `last_real'
         -- and in `last_double'.
         -- The integral part is available in `last_integer'.
      require
         not end_of_input
      do
         read_double;
         last_real := last_double.to_real;
      end;
   
   last_real: REAL; 
         -- Last real read with `read_real'.
   
   read_double is
         -- Read a DOUBLE and make the result available in `last_double'. 
      require
         not end_of_input
      local
         state: INTEGER;
         sign: BOOLEAN;
         -- state = 0 : waiting sign or first digit.
         -- state = 1 : sign read, waiting first digit.
         -- state = 2 : in the integral part.
         -- state = 3 : in the fractional part.
         -- state = 4 : end state.
         -- state = 5 : error state.
      do
         from
            last_string.clear
         until
            state >= 4
         loop
            read_character;
            inspect 
               state
            when 0 then
               if last_character.is_separator then
               elseif last_character.is_digit then
                  last_string.add_last(last_character)
                  state := 2;
               elseif last_character = '-' then
                  sign := true;
                  state := 1;
               elseif last_character = '+' then
                  state := 1;
               elseif last_character = '.' then
                  last_string.add_last(last_character)
                  state := 3;
               else
                  state := 5;
               end;
            when 1 then
               if last_character.is_separator then
               elseif last_character.is_digit then
                  last_string.add_last(last_character)
                  state := 2;
               else
                  state := 5;
               end;
            when 2 then
               if last_character.is_digit then
                  last_string.add_last(last_character)
               elseif last_character = '.' then
                  last_string.add_last(last_character)
                  state := 3;
               else
                  state := 4;
               end;
            else -- 3 
               if last_character.is_digit then
                  last_string.add_last(last_character)
               else
                  state := 4;
               end;
            end;
            if end_of_input then
               inspect
                  state
               when 2 .. 4 then
                  state := 4;
               else
                  state := 5;
               end;
            end;
         end;
         if not end_of_input then
            unread_character;
         end;
         debug
            if state = 5 then
               std_error.put_string("Error in STD_FILE.read_double.%N");
               crash;
            end;
         end;
         if last_string.count > 0 then
            last_double := last_string.to_double
         else
            last_double := 0; -- NaN
         end
         if sign then
            last_double := - last_double;
         end;
      end;
   
   last_double: DOUBLE;
         -- Last double read with `read_double'.
   
feature -- To read one line or one word at a time :

   last_string: STRING is
         -- Access to the unique common buffer to get for example the result 
         -- computed by `read_line', `read_word', `newline', etc. This is a once 
         -- function (the same common buffer is used for all streams).
      once
         !!Result.make(1024);
      end;
   
   read_line is
         -- Read a complete line ended by '%N' or `end_of_input'. Make the 
         -- result available in `last_string' common buffer. The end of line 
         -- character (usually '%N') is not added in the `last_string' buffer.
      require
         not end_of_input
      do
         last_string.clear;
         read_line_in(last_string);
      end;

   read_word is
         -- Read a word using `is_separator' of class CHARACTER. Result is 
         -- available in the `last_string' common buffer. Heading separators are 
         -- automatically skipped. Trailing separators are not skipped 
         -- (`last_character' is left on the first one). If `end_of_input' is 
         -- encountered, Result can be the empty string.
      require
         not end_of_input
      do
         skip_separators;
         if not end_of_input then
            read_character;
         end
         from  
            last_string.clear;
         until
            end_of_input or else
            last_character.is_separator
         loop
            last_string.extend(last_character);
            read_character;
         end;
      end;

   newline is
         -- Consume input until newline ('%N') is found. Corresponding 
         -- STRING is stored in `last_string' common buffer.
      local
         stop: BOOLEAN;
      do
         from  
            last_string.clear;
            stop := end_of_input;
         until
            stop
         loop
            read_character;
            if end_of_input or else last_character = '%N' then
               stop := true;
            else
               last_string.extend(last_character);
            end;
         end;
      end;

   reach_and_skip(keyword: STRING) is
         -- Try to skip enough characters in order to reach the `keyword' 
         -- which is skipped too. If the `keyword' is not in the remainder of 
         -- this stream, the process is stopped as soon  as `end_of_input' 
         -- occurs. As for `skip_separators' the following character of the 
         -- `keyword' is available in `last_character' and not yet read.
      require
         not keyword.is_empty
      local
         stop: BOOLEAN;
         i: INTEGER;
         first: CHARACTER;
      do
         from
            last_string.clear;
            first := keyword.first;
         until
            end_of_input or else stop
         loop
            -- Reach the first character of the `keyword':
            from
               i := 2;
            until
               i > last_string.count or else last_string.item(i) = first
            loop
               i := i + 1;
            end
            if i <= last_string.count then    
               last_string.remove_first(i - 1);
            else
               last_string.clear;
               from
                  if not end_of_input then
                     read_character;
                  end
               until
                  end_of_input or else last_character = first
               loop
                  read_character
               end
               last_string.extend(last_character);
            end
            check
               not end_of_input implies last_string.item(1) = first;
               last_string.count <= keyword.count;
            end
            -- Now we need as many characters as in `keyword':
            from
            until
               end_of_input or else last_string.count = keyword.count
            loop
               read_character
               last_string.extend(last_character);
            end
            stop := last_string.is_equal(keyword);
         end
         if not end_of_input then
            read_character;
            unread_character;
         end;
      ensure
         not end_of_input implies last_string.is_equal(keyword)
      end

feature -- Other features :

   read_line_in(buffer: STRING) is
         -- Same jobs as `read_line' but storage is directly done in `buffer'.
         --
      require
         not end_of_input;
	 buffer /= Void
      deferred
      end;

   read_word_using(separators: STRING) is
         -- Same jobs as `read_word' using `separators'.
      require 
         not end_of_input;
         separators /= void
      do
         skip_separators_using(separators);
         if not end_of_input then
            read_character;
         end
         from  
            last_string.clear;
         until
            end_of_input or else
            separators.has(last_character)
         loop
            last_string.extend(last_character);
            read_character;
         end;
      end;

   read_tail_in(str: STRING) is
         -- Read all remaining character of the file in `str'.
      require
         str /= Void
      do
         from
         until
            end_of_input
         loop
            read_character;
            if not end_of_input then
               str.extend(last_character);
            end;
         end;
      ensure
         end_of_input
      end;

feature {NONE}

   eof_code: INTEGER is 
      external "SmallEiffel"
      end;

   read_byte(stream_pointer : POINTER): INTEGER is
      external "SmallEiffel"
      end;

end -- INPUT_STREAM
