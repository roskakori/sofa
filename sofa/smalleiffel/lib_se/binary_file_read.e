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
class BINARY_FILE_READ

creation connect_to

feature

   path: STRING;

   last_byte: INTEGER;

feature {NONE}

   input_stream: POINTER;

   eof_code: INTEGER is
      external "SmallEiffel"
      end;

feature

   connect_to(new_path: STRING) is
      require
         not is_connected;
         not new_path.is_empty
      do
         input_stream := bfr_open(new_path.count,new_path.to_external);
         if input_stream.is_not_null then
            path := new_path;
         end;
      end;

   is_connected: BOOLEAN is
      do
         Result := path /= Void;
      end;

   end_of_input: BOOLEAN is
         -- Has end-of-input been reached ?
         -- True when the last character has been read.
      require
         is_connected
      do
         Result := last_byte = eof_code;
      end;

   read_byte is
      require
         is_connected;
         not end_of_input
      do
         last_byte := fgetc(input_stream);
      end;

   disconnect is
      require
         is_connected
      do
         c_inline_c("fclose(C->_input_stream);");
         path := Void;
      end;

feature {NONE}

   fgetc(stream_pointer: POINTER): INTEGER is
      external "C_InlineWithoutCurrent"
      end;

   bfr_open(path_count: INTEGER; path_pointer: POINTER): POINTER is
      do
         c_inline_c("R=fopen(a2,%"rb%");");
      end;

end -- BINARY_FILE_READ

