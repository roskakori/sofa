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
class STD_FILE_WRITE
--
-- Basic output facilities to write a named file on the disk.
--
-- Note : most features are common with STD_OUTPUT so you can 
--        test your program first on the screen and then, changing 
--        of instance (STD_OUTPUT/STD_FILE_WRITE), doing the same
--        on a file.
--
   
inherit OUTPUT_STREAM
   
creation 
   connect_to, make

feature
   
   path: STRING;
         -- Not Void when connected to the corresponding file
         -- on the disk.

feature {NONE}
   
   output_stream: POINTER;

feature 

   connect_to(new_path: STRING) is
      require
         not is_connected;
         not new_path.is_empty
      local
         p: POINTER;
      do
         p := new_path.to_external;
         output_stream := sfw_open(p);
         if output_stream.is_not_null then
            path := new_path;
         end;
      end;
   
feature

   disconnect is
      require
         is_connected
      do
         fclose(output_stream); 
         path := Void;
      end;
   
   make is
      do
      end;

feature

   is_connected: BOOLEAN is
      do
         Result := path /= Void;
      end;

   flush is
      do
         flush_stream(output_stream);
      end;

   put_character(c: CHARACTER) is
      do
         write_byte(output_stream,c);
      end;

feature {NONE}
   
   sfw_open(path_pointer: POINTER): POINTER is
      external "SmallEiffel"
      end;

   fclose(stream_pointer : POINTER) is
      external "C_InlineWithoutCurrent"
      end;

end -- STD_FILE_WRITE

