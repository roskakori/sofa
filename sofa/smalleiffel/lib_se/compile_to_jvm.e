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
class COMPILE_TO_JVM
   --
   -- The `compile_to_jvm' command.
   --

inherit COMMAND_FLAGS;

creation make

feature {NONE}

   command_name: STRING is "compile_to_jvm";

   make is
      local
         argc, argi: INTEGER;
         arg, output_name: STRING;
      do
         eiffel_parser.set_drop_comments;
         argc := argument_count;
         if argc < 1 then
            system_tools.bad_use_exit(command_name);
         end;
         search_for_verbose_flag;
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
            elseif is_flag_trace(arg) then
               argi := argi + 1;
            elseif is_flag_cecil(arg,argi,argc) then
               argi := argi + 2;
            elseif is_flag_o(arg,argi,argc,jvm) then
               argi := argi + 2;
            elseif arg.item(1) /= '-' then
               run_control.compute_root_class(arg);
               argi := argi + 1;
               if argi <= argc then
                  arg := argument(argi);
                  if arg.item(1) /= '-' then
                     run_control.set_root_procedure(arg);
                     argi := argi + 1;
                  end;
               end;
            else
               unknown_flag_exit(arg);
            end;
         end;
         if run_control.trace then
            if run_control.boost then
               run_control.set_no_check
            end;
         end;
         check_for_root_class;
	 if run_control.output_name = Void then
	    output_name := run_control.root_class.twin;
	    output_name.to_lower;
	    run_control.set_output_name(output_name);
	 end;
         small_eiffel.compile_to_jvm;
         string_aliaser.echo_information;
      end;

end -- COMPILE_TO_JVM
