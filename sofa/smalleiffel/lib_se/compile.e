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
class COMPILE
   --
   -- The `compile' command.
   --

inherit COMMAND_FLAGS;

creation make

feature {NONE}

   command_name: STRING is "compile";

   make is
      local
         argc, argi: INTEGER;
         arg, make_script_name, next_arg: STRING;
      do
         argc := argument_count;
         if argc < 1 then
            system_tools.bad_use_exit(command_name);
         end;
         search_for_verbose_flag;
         search_for_cc_flag(argc);
         system_tools.command_path_in(command,Command_compile_to_c);
         from
            argi := 1;
         until
            argi > argc
         loop
            arg := argument(argi);
            if is_flag_version(arg) then
               compile_to_c_pass_argument(arg);
               argi := argi + 1;
            elseif ("-c_code").is_equal(arg) then
               echo.w_put_string(
                  "Flag -c_code is now obsolete (this is the default since %
                  %-0.81).%NSee documentation of `compile' (flag -clean).%N");
               exec_clean_command := false;
               argi := argi + 1;
            elseif ("-clean").is_equal(arg) then
               exec_clean_command := true;
               argi := argi + 1;
            elseif one_arg_flags.has(arg) then
               compile_to_c_pass_argument(arg);
               argi := argi + 1;
               if argi <= argc then
                  arg := argument(argi);
                  compile_to_c_pass_argument(arg);
                  argi := argi + 1;
               end;
            elseif argi < argc then
               compile_to_c_pass_argument(arg);
               next_arg := argument(argi + 1);
               argi := system_tools.extra_arg(arg,argi,next_arg);
               if argument(argi - 1) = next_arg then
                  compile_to_c_pass_argument(next_arg);
               end;
            else
               compile_to_c_pass_argument(arg);
               argi := system_tools.extra_arg(arg,argi,Void);
            end;
         end;
         check_for_root_class;
         make_script_name := system_tools.remove_make_script;
         echo.call_system(command);
         system_tools.cygnus_bug(make_file,make_script_name);
         if not make_file.is_connected then
            echo.w_put_string(fz_01);
            echo.w_put_string(make_script_name);
            echo.w_put_string("%" not found. %
                                %Error(s) during `compile_to_c'.%N");
            die_with_code(exit_failure_code);
         end;
         echo.put_string("C compiling using %"");
         echo.put_string(make_script_name);
         echo.put_string("%" command file.%N");
         from
            make_file.read_line;
         until
            make_file.last_string.count = 0
         loop
            command.copy(make_file.last_string);
            echo.call_system(command);
            make_file.read_line;
         end;
         make_file.disconnect;
         if exec_clean_command then
            command.clear;
            system_tools.command_path_in(command,Command_clean);
            command.extend(' ');
            command.append(make_script_name);
            echo.call_system(command);
         else
            echo.put_string("C code not removed.%N");
         end;
         echo.put_string(fz_02);
      end;

   compile_to_c_pass_argument(arg: STRING) is
      do
         command.extend(' ');
         command.append(arg);
      end;

   exec_clean_command: BOOLEAN;
         -- True if command clean must be called.

   make_file: STD_FILE_READ is
      once
         !!Result.make;
      end;

   command: STRING is
      once
         !!Result.make(256);
      end;

   one_arg_flags: ARRAY[STRING] is
      once
         Result := <<"-o", Flag_cc, "-cecil">>;
      end;

end -- COMPILE

