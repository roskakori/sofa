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
deferred class COMMAND_FLAGS
   --
   -- Some useful tools to handle command flags (inherited by compile,
   -- compile_to_c, compile_to_jvm, finder, clean, short, pretty, etc.).
   --

inherit GLOBALS;

feature {NONE}

   Command_compile_to_c:    STRING is "compile_to_c";

   Command_clean:           STRING is "clean";

   command_name: STRING is
      deferred
      end;

   search_for_verbose_flag is
         -- To become verbose as soon as possible.
      local
         i: INTEGER;
      do
         from
            i := argument_count;
         until
            i = 0
         loop
            if is_flag_verbose(argument(i)) then
               echo.set_verbose;
               i := 0;
            else
               i := i - 1;
            end;
         end;
      end;

   search_for_cc_flag(argc: INTEGER) is
         -- To know about the C compiler as soon as possible.
      local
         i: INTEGER;
         c_compiler: STRING;
      do
         from
            i := 1;
         until
            i > argc
         loop
            if Flag_cc.is_equal(argument(i)) then
               if i < argc then
                  i := i + 1;
                  c_compiler := argument(i);
                  i := argc + 1;
               end;
            end;
            i := i + 1;
         end;
         system_tools.set_c_compiler(c_compiler);
      end;

   is_flag_case_insensitive(flag: STRING): BOOLEAN is
      do
         if ("-case_insensitive").is_equal(flag) then
            Result := true;
            eiffel_parser.set_case_insensitive;
         end;
      end;

   is_flag_no_style_warning(flag: STRING): BOOLEAN is
      do
         if ("-no_style_warning").is_equal(flag) then
            Result := true;
            eiffel_parser.set_no_style_warning;
         end;
      end;

   is_flag_no_warning(flag: STRING): BOOLEAN is
      do
         if ("-no_warning").is_equal(flag) then
            Result := true;
            eh.set_no_warning;
         end;
      end;

   is_flag_trace(flag: STRING): BOOLEAN is
      do
         if ("-trace").is_equal(flag) then
            Result := true;
            run_control.set_trace;
         end;
      end;

   is_flag_verbose(flag: STRING): BOOLEAN is
      do
         if ("-verbose").is_equal(flag) then
            Result := true;
         end;
      end;

   is_flag_version(flag: STRING): BOOLEAN is
      do
         if ("-version").is_equal(flag) then
            Result := true;
            std_output.put_string("Version of command %"");
            std_output.put_string(command_name);
            std_output.put_string("%" is:%N");
            std_output.put_string(small_eiffel.copyright);
            if argument_count = 1 then
               die_with_code(exit_success_code);
            end;
         end;
      end;

   is_flag_boost(flag: STRING): BOOLEAN is
      do
         if ("-boost").is_equal(flag) then
            Result := true;
            run_control.set_boost;
            check_for_level(flag);
         end;
      end;

   is_flag_no_check(flag: STRING): BOOLEAN is
      do
         if ("-no_check").is_equal(flag) then
            Result := true;
            run_control.set_no_check;
            check_for_level(flag);
         end;
      end;

   is_flag_require_check(flag: STRING): BOOLEAN is
      do
         if ("-require_check").is_equal(flag) then
            Result := true;
            run_control.set_require_check;
            check_for_level(flag);
         end;
      end;

   is_flag_ensure_check(flag: STRING): BOOLEAN is
      do
         if ("-ensure_check").is_equal(flag) then
            Result := true;
            run_control.set_ensure_check;
            check_for_level(flag);
         end;
      end;

   is_flag_invariant_check(flag: STRING): BOOLEAN is
      do
         if ("-invariant_check").is_equal(flag) then
            Result := true;
            run_control.set_invariant_check;
            check_for_level(flag);
         end;
      end;

   is_flag_loop_check(flag: STRING): BOOLEAN is
      do
         if ("-loop_check").is_equal(flag) then
            Result := true;
            run_control.set_loop_check;
            check_for_level(flag);
         end;
      end;

   is_flag_all_check(flag: STRING): BOOLEAN is
      do
         if ("-all_check").is_equal(flag) then
            Result := true;
            run_control.set_all_check;
            check_for_level(flag);
         end;
      end;

   is_flag_debug_check(flag: STRING): BOOLEAN is
      do
         if ("-debug_check").is_equal(flag) then
            Result := true;
            run_control.set_debug_check;
         end;
      end;

   is_flag_cecil(flag: STRING; argi, argc: INTEGER): BOOLEAN is
      do
         if ("-cecil").is_equal(flag) then
            Result := true;
            if argi < argc then
               cecil_pool.add_file(argument(argi + 1));
            else
               echo.w_put_string(command_name);
               echo.w_put_string(" : missing file name after -cecil flag.%N");
               die_with_code(exit_failure_code);
            end;
         end;
      end;

   is_flag_o(flag: STRING; argi, argc: INTEGER;
             code_printer: CODE_PRINTER): BOOLEAN is
      local
         output_name: STRING;
      do
         if ("-o").is_equal(flag) then
            Result := true;
            if argi < argc then
               output_name := argument(argi + 1);
               if output_name.has_suffix(eiffel_suffix) then
                  echo.w_put_string("Bad executable name: %"");
                  echo.w_put_string(output_name);
                  echo.w_put_string(
                  "%". Must not use Eiffel source file suffix %
                   %with option %"-o <executable_name>%".");
                  die_with_code(exit_failure_code);
               end;
               run_control.set_output_name(output_name);
            else
               echo.w_put_string(command_name);
               echo.w_put_string(" : missing output name after -o flag.%N");
               die_with_code(exit_failure_code);
            end;
         end;
      end;

   check_for_root_class is
      do
         if run_control.root_class = Void then
            echo.w_put_string(command_name);
            echo.w_put_string(": error: No <Root-Class> in command line.%N");
            die_with_code(exit_failure_code);
         end;
      end;

   level_flag: STRING;

   check_for_level(new_level_flag: STRING) is
      do
         if level_flag /= Void then
            if not level_flag.is_equal(new_level_flag) then
               echo.w_put_string(command_name);
               echo.w_put_string(": level is already set to ");
               echo.w_put_string(level_flag);
               echo.w_put_string(". Bad flag ");
               echo.w_put_string(new_level_flag);
               echo.w_put_string(fz_dot);
               die_with_code(exit_failure_code);
            end;
         else
            level_flag := new_level_flag;
         end;
      end;

   unknown_flag_exit(flag: STRING) is
      do
         echo.w_put_string(command_name);
         echo.w_put_string(" : unknown flag %"");
         echo.w_put_string(flag);
         echo.w_put_string("%".%N");
         die_with_code(exit_failure_code);
      end;

   Flag_cc: STRING is "-cc";

end -- COMMAND_FLAGS
