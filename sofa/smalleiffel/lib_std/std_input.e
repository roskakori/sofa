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
class STD_INPUT
--
-- To use the standard input file. As for UNIX, the default standard 
-- input is the keyboard.
--
-- Notes : - the predefined `std_input' should be use to have only 
--         one instance of the class STD_INPUT. 
--         - to do reading or writing at the same time on the screen, 
--         see STD_INPUT_OUTPUT,
--         - to handle cursor of the screen, see CURSES.
--
   
inherit INPUT_STREAM;
   
creation make

feature {NONE}

   memory: INTEGER;
         -- Memory of the last available user's value.

feature

   is_connected: BOOLEAN is true;

feature 
   
   make is
      do
      end;
   
feature

   read_character is
      do
         if push_back_flag then
            push_back_flag := false;
         else
            memory := read_byte(stdin);
         end;
      end;

   unread_character is
      do
         push_back_flag := true;
      end;

   last_character: CHARACTER is
      do
         Result := memory.to_character;
      end;

   end_of_input: BOOLEAN is
      do
         if not push_back_flag then
            Result := memory = eof_code;
         end;
      end;

   read_line_in(str: STRING) is
      local
         mem: INTEGER;
      do
         read_character;
         if last_character /= '%N' then
            from  
               str.extend(memory.to_character);
               mem := read_byte(stdin);
            until
               mem = eof_code or else mem = ('%N').code
            loop
               str.extend(mem.to_character);
               mem := read_byte(stdin);
            end;
            memory := mem;
         end;
      end;

feature {NONE} 
   
   stdin: POINTER is
      external "SmallEiffel"
      end;

end -- STD_INPUT
