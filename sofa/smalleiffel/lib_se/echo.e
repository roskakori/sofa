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
class ECHO
   --
   -- Unique Global Object in charge of ECHOing some information
   -- messages during compilation for example.
   -- This object is used to implement the flag "-verbose".
   --
   --

inherit GLOBALS;

creation make

feature

   verbose: BOOLEAN;
         -- Is `echo' verbose (default is false).

feature

   make is
      do
      end;

feature  -- To echo some additional information (echo is only done
         -- when `verbose' is true).

   put_string(msg: STRING) is
      do
         if verbose then
            std_output.put_string(msg);
            std_output.flush;
         end;
      end;

   put_character(c: CHARACTER) is
      do
         if verbose then
            std_output.put_character(c);
            std_output.flush;
         end;
      end;

   put_new_line is
      do
         if verbose then
            std_output.put_new_line;
         end;
      end;

   put_integer(i: INTEGER) is
      do
         if verbose then
            std_output.put_integer(i);
            std_output.flush;
         end;
      end;

   put_double_format(d: DOUBLE; f: INTEGER) is
      do
         if verbose then
            std_output.put_double_format(d,f);
            std_output.flush;
         end;
      end;

   file_removing(path: STRING) is
         -- If `path' is an existing file, echo a message on `std_output'
         -- while removing the file. Otherwise, do nothing.
      require
         path /= Void
      do
         if file_exists(path) then
            put_string("Removing %"");
            put_string(path);
            put_string(fz_b0);
            remove_file(path);
         end;
      ensure
         may_fail: true or not file_exists(path)
      end;

   file_renaming(old_path, new_path: STRING) is
      require
         old_path /= Void;
         new_path /= Void
      do
         put_string("Renaming %"");
         put_string(old_path);
         put_string("%" as %"");
         put_string(new_path);
         put_string(fz_b0);
         rename_file(old_path,new_path);
      end;

   sfw_connect(sfw: STD_FILE_WRITE; path: STRING) is
      require
         not sfw.is_connected;
         path /= Void
      do
         sfw.connect_to(path);
         if sfw.is_connected then
            put_string("Writing %"");
            put_string(path);
            put_string("%" file.%N");
         else
            w_put_string("Cannot write file %"");
            w_put_string(path);
            w_put_string(fz_b0);
            die_with_code(exit_failure_code);
         end;
      ensure
         sfw.is_connected
      end;

   sfr_connect(sfr: STD_FILE_READ; path: STRING) is
      require
         not sfr.is_connected;
         path /= Void
      do
         put_string("Trying to read file %"");
         put_string(path);
         put_string(fz_b0);
         sfr.connect_to(path);
      end;

   sfr_connect_or_exit(sfr: STD_FILE_READ; path: STRING) is
      require
         not sfr.is_connected;
         path /= Void
      do
         sfr_connect(sfr,path);
         if not sfr.is_connected then
            w_put_string(fz_01);
            w_put_string(path);
            w_put_string("%" not found.%N");
            die_with_code(exit_failure_code);
         end;
      ensure
         sfr.is_connected
      end;

   read_word_in(sfr: STD_FILE_READ): STRING is
      require
         sfr.is_connected
      do
         put_string("Reading one word in %"");
         put_string(sfr.path);
         put_string(fz_b0);
         if sfr.end_of_input then
            w_put_string("Unexpected end_of_input while reading %"");
            w_put_string(sfr.path);
            w_put_string(fz_b0);
            die_with_code(exit_failure_code);
         else
            sfr.read_word;
            Result := sfr.last_string.twin;
         end;
      ensure
         sfr.is_connected
      end;

   call_system(cmd: STRING) is
      require
         cmd.count > 0
      local
         i: INTEGER;
         cmd2: STRING;
      do
         if cmd.last = '%N' then
            cmd.remove_last(1);
            call_system(cmd);
         elseif cmd.has('%N') then
            i := cmd.index_of('%N');
            cmd2 := cmd.substring(i + 1, cmd.count);
            cmd.remove_last(cmd.count - i + 1);
            call_system(cmd);
            call_system(cmd2);
         else
            put_string("System call %"");
            put_string(cmd);
            put_string(fz_b0);
            system(cmd);
         end;
      end;

   print_count(msg: STRING; count: INTEGER) is
      require
         count >= 0;
      do
         if verbose then
            if count > 0 then
               put_string("Total ");
               put_string(msg);
               if count > 1 then
                  put_character('s');
               end;
               put_string(": ");
               put_integer(count);
               put_string(fz_b6);
            else
               put_string("No ");
               put_string(msg);
               put_string(fz_b6);
            end;
         end;
      end;

feature  -- To echo some warning or some problem (echo is done whathever
         -- the value of `verbose').

   w_put_string(msg: STRING) is
      do
         std_error.put_string(msg);
         std_error.flush;
      end;

   w_put_character(c: CHARACTER) is
      do
         std_error.put_character(c);
         std_error.flush;
      end;

   w_put_integer(i: INTEGER) is
      do
         std_error.put_integer(i);
         std_error.flush;
      end;

feature {COMMAND_FLAGS}

   set_verbose is
      do
         verbose := true;
      end;

end -- ECHO
