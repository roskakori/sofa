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
class STD_FILE_READ_WRITE
   --
   -- Originally written by Emmanuel CECCHET --
   --
inherit 
   INPUT_STREAM;
   OUTPUT_STREAM;
   
creation connect_to
   
feature 
   
   path: STRING;

   last_character: CHARACTER;

feature {NONE}

   stream: POINTER;
   
feature

   connect_to(new_path: STRING) is
      local
         s, p: POINTER;
         sfw: STD_FILE_WRITE;
      do
         if not file_exists(new_path) then
            !!sfw.connect_to(new_path);
            sfw.disconnect;
         end;
         check
            file_exists(new_path)
         end;
         p := new_path.to_external;
         c_inline_c("_s=fopen(_p,%"r+%");");
         if s.is_not_null then
            stream := s;
            path := new_path;
         end;
      end;

feature

   disconnect is
      require
         is_connected
      do
         fclose(stream);
         path := Void;
      end;

   read_character is
      do
         flush_stream(stream);
         last_character := read_byte(stream).to_character;
         push_back_flag := false;
      end;

   put_character(c: CHARACTER) is
      do
         flush_stream(stream);
         write_byte(stream,c);
      end;
   
   unread_character is
      local
         p: POINTER;
         c: CHARACTER;
      do
         p := stream;
         c := last_character;
         c_inline_c("ungetc(_c,_p);");
         push_back_flag := true;
      end;

   end_of_input: BOOLEAN is
      do
         flush_stream(stream);
         Result := feof(stream)
      end;

   is_connected: BOOLEAN is
      do
         Result := path /= Void;
      end;

   read_line_in(str: STRING) is
      do
         read_character;
         if last_character /= '%N' then
            from  
               str.extend(last_character);
            until
               end_of_input or else last_character = '%N'
            loop
               read_character;
               str.extend(last_character);
            end;
         end;
      end;

feature {NONE}

   fclose(stream_pointer : POINTER) is
      external "C_InlineWithoutCurrent"
      end;

   feof(stream_ptr: POINTER): BOOLEAN is
      external "SmallEiffel"
      end;

end -- STD_FILE_READ_WRITE

