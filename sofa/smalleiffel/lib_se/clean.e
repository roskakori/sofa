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
class CLEAN
   --
   -- The `clean' command.
   --

inherit COMMAND_FLAGS;

creation make

feature {NONE}

   command_name: STRING is
      do
         Result := Command_clean;
      end;

   make is
      local
         argc, argi: INTEGER;
         arg, make_suffix: STRING;
      do
         argc := argument_count;
         if argc < 1 then
            system_tools.bad_use_exit(command_name);
         end;
         search_for_verbose_flag;
         search_for_cc_flag(argc);
         from
            make_suffix := system_tools.make_suffix;
            argi := 1;
         until
            argi > argc
         loop
            arg := argument(argi);
            if is_flag_verbose(arg) then
               argi := argi + 1;
            elseif is_flag_version(arg) then
               argi := argi + 1;
            elseif arg.item(1) = '-' then
               unknown_flag_exit(arg);
            else
               if arg.has_suffix(eiffel_suffix) then
                  arg.remove_suffix(eiffel_suffix);
               elseif arg.has_suffix(make_suffix) then
                  arg.remove_suffix(make_suffix);
               end;
               run_control.compute_root_class(arg);
               try_to_remove(arg);
               arg.to_upper;
               try_to_remove(arg);
               arg.to_lower;
               try_to_remove(arg);
               arg := system_tools.remove_make_script;
               arg := run_control.root_class.twin;
               try_to_remove(arg);
               arg.to_lower;
               try_to_remove(arg);
               argi := argi + 1;
            end;
         end;
      end;

   try_to_remove(prefix_name: STRING) is
      require
         prefix_name.count > 0
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i = 0
         loop
            tmp_path.copy(prefix_name);
            i.append_in(tmp_path);
            tmp_path.extend('.');
            tmp_path.extend('c');
            if file_exists(tmp_path) then
               echo.file_removing(tmp_path);
               tmp_path.put('d',tmp_path.count);
               echo.file_removing(tmp_path);
               tmp_path.remove_last(2);
               tmp_path.append(system_tools.object_suffix);
               echo.file_removing(tmp_path);
               i := i + 1;
            else
               i := 0;
            end;
         end;
	 --
         tmp_path.copy(prefix_name);
         tmp_path.append(".h");
         echo.file_removing(tmp_path);
	 --
         tmp_path.copy(prefix_name);
         tmp_path.append(".c");
         echo.file_removing(tmp_path);
	 --
         tmp_path.copy(prefix_name);
         tmp_path.append(".d");
         echo.file_removing(tmp_path);
	 --
         tmp_path.copy(prefix_name);
         tmp_path.append(".id");
         echo.file_removing(tmp_path);
	 --
         tmp_path.copy(prefix_name);
         tmp_path.append("_external_cpp.h");
         echo.file_removing(tmp_path);
	 --
         tmp_path.copy(prefix_name);
         tmp_path.append("_external_cpp.cpp");
         echo.file_removing(tmp_path);
	 --
         tmp_path.copy(prefix_name);
         tmp_path.append("_external_cpp.o");
         echo.file_removing(tmp_path);
      end;

end -- CLEAN
