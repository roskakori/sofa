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
class FINDER
   --
   -- The `finder' command.
   --

inherit COMMAND_FLAGS;

creation make

feature {NONE}

   command_name: STRING is "finder";

   make is
      local
         argc, argi: INTEGER;
         arg, class_name: STRING;
         file_name: STRING;
      do
         argc := argument_count;
         search_for_verbose_flag;
         from
            argi := 1;
         until
            argi > argc
         loop
            arg := argument(argi);
            if is_flag_version(arg) then
            elseif is_flag_verbose(arg) then
            elseif class_name /= Void then
               system_tools.bad_use_exit(command_name);
            else
               class_name := arg;
               file_name := small_eiffel.find_path_for(class_name);
               if file_name = Void then
                  std_output.put_string(class_name);
                  std_output.put_string(": not found.%N");
                  die_with_code(exit_failure_code);
               else
                  std_output.put_string(file_name);
                  std_output.put_character('%N');
               end;
            end;
            argi := argi + 1;
         end;
      end;

end -- FINDER

