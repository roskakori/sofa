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
class PARSER_BUFFER

inherit GLOBALS;

creation make

feature

   path: STRING;
         -- When `is_ready', gives the `path' of the corresponding
         -- buffered file.

   count: INTEGER;
         -- Number of lines in the source file.

   is_ready: BOOLEAN is
      do
         Result := path /= Void;
      end;

feature {SMALL_EIFFEL,EIFFEL_PARSER}

   load_file(a_path: STRING) is
         -- Try to load `a_path' and set `is_ready' when corresponding
         -- file has been loaded.
      local
         i: INTEGER;
      do
         tmp_file_read.connect_to(a_path);
         if tmp_file_read.is_connected then
            path := string_aliaser.item(a_path);
            from
               if empty_line_at(0) /= Void then
                  -- unused line.
               end;
               i := 1;
               tmp_file_read.read_line_in(empty_line_at(i));
            until
               tmp_file_read.end_of_input
            loop
               i := i + 1;
               tmp_file_read.read_line_in(empty_line_at(i));
            end;
            if text.item(i).is_empty then
               count := i - 1;
            else
               count := i;
            end;
            tmp_file_read.disconnect;
	    if count <= 0 then
	       eh.append("File %"");
	       eh.append(path);
	       eh.append("%" seems to be empty.");
	       eh.print_as_fatal_error;
	    end;
         else
            path := Void;
         end;
      end;

   unset_is_ready is
      do
         path := Void;
      end;

feature {EIFFEL_PARSER}

   item(line: INTEGER): STRING is
      require
         is_ready;
         1 <= line;
         line <= count
      do
         Result := text.item(line);
      ensure
         Result /= Void
      end;

feature {NONE}

   make is
      do
      end;

   text: FIXED_ARRAY[STRING] is
         -- To store the complete file to parse. Each line
         -- is one STRING without the '%N' end-of-line mark.
      once
         !!Result.with_capacity(6000);
      end;

   empty_line_at(i: INTEGER): STRING is
      require
         i >= 0
      do
         if i <= text.upper then
            Result := text.item(i);
            Result.clear;
         else
            !!Result.make(medium_line_size);
            text.add_last(Result);
         end;
      ensure
         Result.is_empty;
         Result.capacity >= medium_line_size;
         text.item(i) = Result
      end;

   medium_line_size: INTEGER is 128;

end -- PARSER_BUFFER

