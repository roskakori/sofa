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
class COMPILE_TO_C
   --
   -- The `compile_to_c' command.
   --

inherit COMMAND_FLAGS;

creation make

feature {NONE}

   command_name: STRING is
      do
         Result := Command_compile_to_c;
      end;

   make is
      local
         argc, argi: INTEGER;
         arg: STRING;
      do
         eiffel_parser.set_drop_comments;
         argc := argument_count;
         if argc < 1 then
            system_tools.bad_use_exit(command_name);
         end;
         search_for_verbose_flag;
         search_for_cc_flag(argc);
         from
            argi := 1;
         until
            argi > argc
         loop
            arg := argument(argi);
            if is_flag_case_insensitive(arg) then
               argi := argi + 1;
            elseif is_flag_no_style_warning(arg) then
               argi := argi + 1;
            elseif is_flag_no_warning(arg) then
               argi := argi + 1;
            elseif is_flag_version(arg) then
               argi := argi + 1;
            elseif is_flag_verbose(arg) then
               argi := argi + 1;
            elseif is_flag_boost(arg) then
               argi := argi + 1;
            elseif is_flag_no_check(arg) then
               argi := argi + 1;
            elseif is_flag_require_check(arg) then
               argi := argi + 1;
            elseif is_flag_ensure_check(arg) then
               argi := argi + 1;
            elseif is_flag_invariant_check(arg) then
               argi := argi + 1;
            elseif is_flag_loop_check(arg) then
               argi := argi + 1;
            elseif is_flag_all_check(arg) then
               argi := argi + 1;
            elseif is_flag_debug_check(arg) then
               argi := argi + 1;
            elseif is_flag_cecil(arg,argi,argc) then
               argi := argi + 2;
            elseif is_flag_o(arg,argi,argc,cpp) then
               argi := argi + 2;
            elseif ("-no_main").is_equal(arg) then
               cpp.set_no_main;
               argi := argi + 1;
            elseif ("-no_gc").is_equal(arg) then
               gc_handler.no_gc;
               argi := argi + 1;
            elseif ("-gc_info").is_equal(arg) then
               gc_handler.set_info_flag;
               argi := argi + 1;
            elseif ("-no_strip").is_equal(arg) then
               system_tools.set_no_strip;
               argi := argi + 1;
            elseif ("-no_split").is_equal(arg) then
               cpp.set_no_split;
               argi := argi + 1;
            elseif ("-trace").is_equal(arg) then
               run_control.set_trace;
               argi := argi + 1;
            elseif ("-wedit").is_equal(arg) then
               cpp.set_wedit(true);
               argi := argi + 1;
            elseif Flag_cc.is_equal(arg) then
               if argi < argc then
                  argi := argi + 2;
               else
                  echo.w_put_string(command_name);
                  echo.w_put_string(
                     " : missing compiler name after -cc flag.%N");
                  die_with_code(exit_failure_code);
               end;
            elseif argi < argc then
               argi := system_tools.extra_arg(arg,argi,argument(argi + 1));
            else
               argi := system_tools.extra_arg(arg,argi,Void);
            end;
         end;
         check_for_root_class;
         if run_control.trace then
            if cpp.wedit then
               echo.w_put_string(command_name);
               echo.w_put_string(" : cannot use -wedit with -trace flag.%N");
               die_with_code(exit_failure_code);
            end;
            if run_control.boost then
               echo.w_put_string(command_name);
               echo.w_put_string(" : cannot use -trace with -boost flag.%N");
               die_with_code(exit_failure_code);
            end;
         end;
         small_eiffel.compile_to_c;
         id_provider.disk_save;
         string_aliaser.echo_information;
      end;

end -- COMPILE_TO_C

