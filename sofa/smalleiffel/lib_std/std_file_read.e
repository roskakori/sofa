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
class STD_FILE_READ 
--
-- Basic input facilities to read a named file on the disc.
--
-- Note : most features are common with STD_INPUT so you can 
-- test your program on the screen first and then, just changing
-- of instance (STD_INPUT/STD_FILE_READ), doing the same in a file.
--
   
inherit INPUT_STREAM;
   
creation 
   connect_to, make

feature
   
   path: STRING;
         -- Not Void when connected to the corresponding file 
         -- on the disk.
   
   is_connected: BOOLEAN is
      do
         Result := path /= Void;
      end;
   
   make is
      do
      end;
   
   connect_to(new_path: STRING) is
      require
         not is_connected;
         not new_path.is_empty
      local
         p: POINTER;
      do
         p := new_path.to_external;
         input_stream := sfr_open(p);
         if input_stream.is_not_null then
            push_back_flag := false;
            memory := (' ').code;
            path := new_path;
         end;
      end;

   disconnect is
      require
         is_connected
      do
         fclose(input_stream); 
         path := Void;
      end;
   
   read_character is
      do
         if push_back_flag then
            push_back_flag := false;
         else
            memory := read_byte(input_stream);
         end;
      end;

   last_character: CHARACTER is
      do
         Result := memory.to_character;
      end;

   unread_character is
      do
         push_back_flag := true;
      end;

   end_of_input: BOOLEAN is
      do
         if not push_back_flag then
            Result := memory = eof_code;
         end;
      end;

   read_line_in(buffer: STRING) is
      do
         from  
            read_character;
         until
            memory = eof_code 
               or else 
            memory = ('%N').code
               or else
            memory = ('%R').code
         loop
            buffer.extend(memory.to_character);
            read_character;
         end;
         if memory = ('%R').code then
            read_character;
            if memory /= ('%N').code then
               push_back_flag := true;
            end;
         end;
      end;

feature {FILE_TOOLS}

   same_as(other: like Current): BOOLEAN is
      require
         is_connected;
         other.is_connected
      local
         is1, is2: like input_stream;
         c1, c2: INTEGER;
      do
         from
            is1 := input_stream;
            is2 := other.input_stream;
         until
            c1 /= c2 or else c1 = eof_code
         loop
            c1 := read_byte(is1);
            c2 := read_byte(is2);
         end
         Result :=  c1 = c2;
         disconnect;
         other.disconnect;
      ensure
         not is_connected;
         not other.is_connected
      end;

feature {INPUT_STREAM}
   
   input_stream: POINTER;

feature {NONE}

   sfr_open(path_pointer: POINTER): POINTER is
      external "SmallEiffel"
      end;

   fclose(stream_pointer : POINTER) is
      external "C_InlineWithoutCurrent"
      end;

   memory: INTEGER;
         -- Memory of the last available user's value.

end -- STD_FILE_READ 

