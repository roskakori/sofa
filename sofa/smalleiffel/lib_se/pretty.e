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
class PRETTY
   --
   -- The `pretty' command.
   --

inherit COMMAND_FLAGS;

creation make

feature {NONE}

   command_name: STRING is "pretty";

   make is
      do
         small_eiffel.set_pretty_flag;
         if argument_count < 1 then
            system_tools.bad_use_exit(command_name);
         else
            automat;
         end;
      end;

feature {NONE}

   state: INTEGER;

   style: STRING;

   class_names: ARRAY[STRING] is
      once
         !!Result.make(1,10);
         Result.clear;
      end;

   automat is
      local
         arg: INTEGER;
         a: STRING;
         -- state 0  : nothing done.
         -- state 1  : end.
         -- state 2  : error.
      do
         from
            arg := 1;
         until
            arg > argument_count or else state > 0
         loop
            a := argument(arg);
            if a.item(1) /= '-' then
               class_names.add_last(a);
            elseif is_flag_no_style_warning(a) then
            elseif is_flag_no_warning(a) then
            elseif is_flag_version(a) then
            elseif ("-default").is_equal(a) then
               if style /= Void then
                  error_style(a);
               else
                  fmt.set_default;
                  style := a;
               end;
            elseif ("-zen").is_equal(a) then
               if style /= Void then
                  error_style(a);
               else
                  fmt.set_zen;
                  style := a;
               end;
            elseif ("-end").is_equal(a) then
               if style /= Void then
                  error_style(a);
               else
                  fmt.set_end;
                  style := a;
               end;
            elseif ("-parano").is_equal(a) then
               if style /= Void then
                  error_style(a);
               else
                  fmt.set_parano;
                  style := a;
               end;
            else
               echo.w_put_string(fz_08);
               echo.w_put_string(a);
               echo.w_put_character('%N');
               state := 2;
            end;
            arg := arg + 1;
         end;
         if nb_errors > 0 then
            eh.append("No pretty printing done.");
            eh.print_as_error;
         else
            if class_names.is_empty then
               eh.append("No Class to Pretty Print.");
               eh.print_as_error;
            else
               pretty_print;
            end;
         end;
      end;

   error_style(style2: STRING) is
      do
         state := 2;
         eh.append("pretty: format style is already set to ");
         eh.append(style);
         eh.append(". Bad flag ");
         eh.append(style2);
         eh.append(fz_dot);
         eh.print_as_error;
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         from
            i := class_names.lower;
         until
            i > class_names.upper
         loop
            pretty_for(class_names.item(i));
            i := i + 1;
         end;
      end;

   pretty_for(name: STRING) is
      require
         name /= Void;
      local
         root_class: STRING;
         e_class: BASE_CLASS;
      do
         run_control.compute_root_class(name);
         root_class := run_control.root_class;
         e_class := small_eiffel.load_class(root_class);
         if e_class = Void then
            eh.append("No pretty printing done for %"");
            eh.append(name);
            fatal_error("%".");
         else
            path.copy(e_class.path);
            backup.copy(path);
            backup.remove_suffix(eiffel_suffix);
            backup.append(backup_suffix);
            if file_exists(backup) then
               eh.append("Old backup file %"");
               eh.append(backup);
               fatal_error("%" already exists.");
            end;
            rename_file(path,backup);
            if not file_exists(backup) then
               eh.append("Cannot rename %"");
               eh.append(path);
               fatal_error("%".");
            end;
            echo.sfw_connect(new_file,path);
            fmt.connect_to(new_file);
            e_class.pretty_print;
            new_file.disconnect;
            if not small_eiffel.re_load_class(e_class) then
               eh.append("Error during `pretty' printing.%N%
                         %Cannot parse output of pretty.%N%
                         %Backup %"");
               eh.append(backup);
               fatal_error("%" not removed.");
            end;
         end;
      end;

   path: STRING is
      once
         !!Result.make(256);
      end;

   backup: STRING is
      once
         !!Result.make(256);
      end;

   new_file: STD_FILE_WRITE is
      once
         !!Result.make;
      end;

end -- PRETTY
