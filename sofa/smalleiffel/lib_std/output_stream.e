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
deferred class OUTPUT_STREAM
   --
   -- This abstract class is the superclass of all classes representing 
   -- an output stream of bytes. 
   --

feature -- State of the stream :

   is_connected: BOOLEAN is
      deferred
      end;

feature -- To write one character at a time :

   put_character(c: CHARACTER) is
      require
         is_connected
      deferred
      end;

feature 

   put_string(s: STRING) is
         -- Output `s' to current output device.
      require
         is_connected;
         s /= Void
      local
         i: INTEGER;
      do
         from  
            i := 1;
         until
            i > s.count
         loop
            put_character(s.item(i));
            i := i + 1;
         end;
      end;
   
   putstring(s: STRING) is
      obsolete "Please use ELKS 95 `put_string' instead."
      do
         put_string(s);
      end;

feature -- To write a number :

   put_integer(i: INTEGER) is
         -- Output `i' to current output device.
      require
         is_connected
      do
         tmp_string.clear;
         i.append_in(tmp_string);
         put_string(tmp_string);
      end;
   
   put_integer_format(i, s: INTEGER) is
         -- Output `i' to current output device using at most
         -- `s' character.
      require
         is_connected
      do
         tmp_string.clear;
         i.append_in_format(tmp_string,s);
         put_string(tmp_string);
      end;
   
   put_real(r: REAL) is
         -- Output `r' to current output device.
      require
         is_connected
      do
         tmp_string.clear;
         r.append_in(tmp_string);
         put_string(tmp_string);
      end;
   
   put_real_format(r: REAL; f: INTEGER) is
         -- Output `r' with only `f' digit for the fractionnal part.
         -- Examples: 
         --    put_real(3.519,2) print "3.51".
      require
         is_connected;
         f >= 0;
      do
         tmp_string.clear;
         r.append_in_format(tmp_string,f);
         put_string(tmp_string);
      end;
   
   put_double(d: DOUBLE) is
         -- Output `d' to current output device.
      require
         is_connected
      do
         tmp_string.clear;
         d.append_in(tmp_string);
         put_string(tmp_string);
      end;
   
   put_double_format(d: DOUBLE; f: INTEGER) is
         -- Output `d' with only `f' digit for the fractionnal part.
         -- Examples: 
         --    put_double(3.519,2) print "3.51". 
      require
         is_connected;
         f >= 0
      do
         tmp_string.clear;
         d.append_in_format(tmp_string,f);
         put_string(tmp_string);
      end;

   put_number(number: NUMBER) is
         -- 
      require
         number /= Void
      do
         tmp_string.clear;
         number.append_in(tmp_string);
         put_string(tmp_string);
      end;

feature -- Other features :   

   put_boolean(b: BOOLEAN) is
         -- Output `b' to current output device according
         -- to the Eiffel format.
      require
         is_connected
      do
         if b then
            put_string("true");
         else
            put_string("false");
         end;
      end;
   
   put_pointer(p: POINTER) is
         -- Output a viewable version of `p'.
      require
         is_connected
      do
         tmp_string.clear;
         p.append_in(tmp_string);
         put_string(tmp_string);
      end;

   put_new_line is
         -- Output a newline character.
      require
         is_connected
      do
         put_character('%N');
      end;
   
   put_spaces(nb: INTEGER) is
      -- Output `nb' spaces character.
      require
         nb >= 0
      local
         count : INTEGER;
      do
         from  
         until
            count >= nb
         loop
            put_character(' ');
            count := count + 1;
         end;
      end; 
   
   append_file(file_name: STRING) is
      require
         is_connected;
         file_exists(file_name);
      local
         c: CHARACTER;
      do
         tmp_file_read.connect_to(file_name);
         from  
            tmp_file_read.read_character;
         until
            tmp_file_read.end_of_input
         loop
            c := tmp_file_read.last_character;
            put_character(c);
            tmp_file_read.read_character;
         end;
         tmp_file_read.disconnect;
      end;

   flush is
      deferred
      end;

feature {NONE}

   write_byte(stream_pointer: POINTER; byte: CHARACTER) is
         -- Low level buffered output.
      external "SmallEiffel"
      end;

   flush_stream(stream_pointer: POINTER) is
      external "SmallEiffel"
      end;

   tmp_file_read: STD_FILE_READ is
      once
         !!Result.make;
      end;
   
   tmp_string: STRING is
      once
         !!Result.make(512);
      end;
   
end -- OUTPUT_STREAM

