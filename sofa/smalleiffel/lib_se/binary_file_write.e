--          This file is part of SmallEiffel The GNU Eiffel Compiler.
--          Copyright (C) 1994-98 LORIA - UHP - CRIN - INRIA - FRANCE
--            Dominique COLNET and Suzanne COLLIN - colnet@loria.fr
--                       http://SmallEiffel.loria.fr
-- SmallEiffel is  free  software;  you can  redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the Free
-- Software  Foundation;  either  version  2, or (at your option)  any  later
-- version. SmallEiffel is distributed in the hope that it will be useful,but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- or  FITNESS FOR A PARTICULAR PURPOSE.   See the GNU General Public License
-- for  more  details.  You  should  have  received a copy of the GNU General
-- Public  License  along  with  SmallEiffel;  see the file COPYING.  If not,
-- write to the  Free Software Foundation, Inc., 59 Temple Place - Suite 330,
-- Boston, MA 02111-1307, USA.
--
class BINARY_FILE_WRITE

creation make

feature

   path: STRING;

feature {NONE}

   output_stream: POINTER;

feature

   make is
      do
      end;

feature

   connect_to(new_path: STRING) is
      require
         not is_connected;
         not new_path.is_empty
      do
         output_stream := bfw_open(new_path.count,new_path.to_external);
         if output_stream.is_not_null then
            path := new_path;
         end;
      end;

   is_connected: BOOLEAN is
      do
         Result := path /= Void;
      end;

   put_byte(byte: CHARACTER) is
      require
         is_connected
      local
         bool: BOOLEAN;
      do
         if bool then
            put_byte(byte)
         else
            c_inline_c("fputc(a1,C->_output_stream);");
         end;
      end;

   disconnect is
      require
         is_connected
      do
         fclose(output_stream);
         path := Void;
      end;

feature {NONE}

   fclose(stream_pointer : POINTER) is
      external "C_InlineWithoutCurrent"
      end;

   bfw_open(path_count: INTEGER; path_pointer: POINTER): POINTER is
      do
         c_inline_c("R=fopen(a2,%"wb%");");
      end;

end -- BINARY_FILE_WRITE

