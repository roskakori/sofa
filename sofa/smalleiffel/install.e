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
class INSTALL
   --
   -- The portable `install' command to install SmallEiffel. The installation is 
   -- done from scratch. Unless "-no_compile" is specified,  all commands are
   -- recompiled from scratch (the compiler itself is bootstrapped).
   --

inherit COMMAND_FLAGS rename system_tools as dev_null end;

creation make

feature {NONE}

   command_name: STRING is "install";

   interactive: BOOLEAN;
	 -- No automatic compiler selection or system name selection.

   no_compile: BOOLEAN;
         -- Compile binaries ? (Useful, if precompile binaries are already
         -- included with a distribution)

   compiler: STRING;
         -- Name of C compiler

   system_se_path: STRING;
	 -- The "system.se" file path is the very first information this 
	 -- install program tries to compute. For example, on Windows, the 
	 -- value may be "C:SmallEiffel\sys\system.se". This file is intended 
	 -- to contains the `system_name' value on its very first line.

   set_system_se_path is
      local
	 string: STRING;
      do
	 echo.put_string("Checking %"SmallEiffel%" environment variable:%N");
	 system_se_path := get_environment_variable(fz_se);
	 if system_se_path = Void or else system_se_path.count = 0 then
	    string := fz_se.twin;
	    string.to_upper;
	    system_se_path := get_environment_variable(string);
	 end;
	 if system_se_path = Void or else system_se_path.count = 0 then
	    fatal_problem_description_start;
	    echo.put_string(
	    "Environment variable %"SmallEiffel%" is not set.%N%
	    %Please, set this variable with the absolute path of %N%
	    %the %"SmallEiffel/sys/system.se%" file.%N%
	    %A file %"system.se%" must exists in the sub-directory %"sys%"%
	    % of the%NSmallEiffel directory.%N");
	    fatal_problem_description_end;
	 end;
	 if not system_se_path.has_suffix("system.se") then
	    fatal_problem_description_start;
	    echo.put_string(
	    "Value of the Environment variable %"SmallEiffel%"%Nis %"");
	    echo.put_string(system_se_path);
	    echo.put_string("%".%N");
	    echo.put_string(
	    "Please, set this variable with the absolute path of%N%
	    %the %"SmallEiffel/sys/system.se%" file.%N%
	    %For example, on Linux, the value is%N%
	    %often %"/usr/lib/SmallEiffel/sys/system.se%".%N%
	    %On Windows, %"C:\SmallEiffel\sys\system.se%" is a correct %
	    %value%Nwhen the SmallEiffel directory is at toplevel of the C %
	    %hard disk.%N");
	    fatal_problem_description_end;
	 end;
	 if not file_exists(system_se_path) then
	    fatal_problem_description_start;
	    echo.put_string(
	    "Value of the Environment variable %"SmallEiffel%" value%Nis %"");
	    echo.put_string(system_se_path);
	    echo.put_string(
	    "%".%N%
	    %There is no readable file %"");
	    echo.put_string(system_se_path);
	    echo.put_string(
	    "%".%N%
	    %Check this absolute path as well as read permission.%N");
	    fatal_problem_description_end;
	 end;
	 echo.put_string(
	 "Value of the Environment variable %"SmallEiffel%" is correctly %
	 %set%Nto some existing file%Npath (%"");
	 echo.put_string(system_se_path);
	 echo.put_string("%").%N");
      end;

   installation_path: STRING;
	 -- Using the `system_se_path', the `installation_path' of SmallEiffel is 
	 -- computed. For example, on Windows, a correct value may be 
	 -- "C:\SmallEiffel\".

   set_installation_path is
      local
	 string: STRING;
      do
	 echo.put_string("Checking that the SmallEiffel directory exists:%N");
	 string := system_se_path.twin;
	 basic_directory.compute_parent_directory_of(string);
	 if basic_directory.last_entry.is_empty then
	    fatal_problem_description_start;
	    echo.put_string("Unable to compute parent directory %Nof %"");
	    echo.put_string(system_se_path);
	    echo.put_string("%".%N");
	    fatal_problem_description_end;
	 end;
	 string := basic_directory.last_entry.twin;
	 basic_directory.compute_parent_directory_of(string);
	 if basic_directory.last_entry.is_empty then
	    fatal_problem_description_start;
	    echo.put_string("Unable to compute parent directory %Nof %"");
	    echo.put_string(string);
	    echo.put_string("%".%N");
	    fatal_problem_description_end;
	 end;
	 installation_path := basic_directory.last_entry.twin;
	 echo.put_string("SmallEiffel directory path is %"");
	 echo.put_string(installation_path);
	 echo.put_string("%".%N");
      end;

   system_name: STRING;
	 -- The `system_name' is one element of SYSTEM_TOOLS `system_list' 
	 -- ("UNIX", "Windows", "Amiga", etc.).

   set_system_name is
      do
	 echo.put_string("System name detection:%N");
	 if interactive then
	    system_name := choice_in("System name selection",
				     system_tools.system_list);
	 elseif file_exists("s:startup-sequence") then
	    -- This check has to be performed BEFORE the Unix check
	    -- ("/bin/ls"), because the latter might be true if the user
	    -- installed GeekGadgets and one of those perverted patches
	    -- to handle Unix-style paths !
	    echo.put_string("System seems to be an Amiga.%N");
	    system_name := "Amiga";
	 elseif file_exists("/boot/beos/system/Tracker") then
	    echo.put_string("System seems to be BeOS.%N");
	    system_name := "BeOS";
	 elseif file_exists("/bin/ls") then
	    echo.put_string("System seems to be UNIX.%N");
	    system_name := "UNIX";
	 else
	    basic_directory.connect_to("C:\");
	    if basic_directory.is_connected then
	       system_name := "Windows";
	       basic_directory.disconnect;
	    else
	       system_name := choice_in("System name selection",
					system_tools.system_list);
	    end;
	 end;
	 echo.put_string("System is %"");
	 echo.put_string(system_name);
	 echo.put_string("%".%NTry to update file %"");
	 echo.put_string(system_se_path);
	 echo.put_string("%".%N");
	 echo.sfw_connect(sfw,system_se_path);
	 sfw_check_is_connected(system_se_path);
	 sfw.put_string(system_name);
	 sfw.put_character('%N');
	 sfw.disconnect;
	 echo.put_string("Update of %"");
	 echo.put_string(system_se_path);
	 echo.put_string("%" done.%N")
	 system_tools.make;
	 if not system_name.is_equal(system_tools.system_name) then
	    fatal_problem_description_start;
	    echo.put_string("Unkown SYSTEM_TOOLS.system_name %"");
	    echo.put_string(system_name);
	    echo.put_string("%".%N");
	    fatal_problem_description_end;
	 end;
      end;

   write_default_loadpath_se_file is
	 -- Write the appropriate "C:\SmallEiffel\sys\loadpath.se" file.
      local
	 path, directory: STRING;
	 list: ARRAY[STRING];
	 i: INTEGER;
      do
	 echo.put_string("Writing default loadpath.se file:%N");
	 path := installation_path.twin;
	 basic_directory.compute_subdirectory_with(path,"sys");
	 if basic_directory.last_entry.is_empty then
	    fatal_problem_description_start;
	    echo.put_string("Unable to compute subdirectory %"sys%" of %"");
	    echo.put_string(path);
	    echo.put_string("%".%N");
	    fatal_problem_description_end;
	 end;
	 path.copy(basic_directory.last_entry);
	 basic_directory.compute_file_path_with(path,"loadpath.");
	 path.copy(basic_directory.last_entry);
	 path.append(system_name);
	 echo.sfw_connect(sfw,path);
	 sfw_check_is_connected(path);
	 echo.put_string("--- Written data ---%N");
	 -- The current working directory is the very first item:
	 if ("UNIX").is_equal(system_name) then
	    directory := "./%N";
	 elseif ("DOS").is_equal(system_name) then
	    directory := ".\%N";
	 elseif ("Windows").is_equal(system_name) then
	    directory := ".\%N";
	 elseif ("BeOS").is_equal(system_name) then
	    directory := "./%N";
	 elseif ("Macintosh").is_equal(system_name) then
	    directory := ":%N";
	 elseif ("VMS").is_equal(system_name) then
	    -- Don't know the correct notation for VMS, please, if you are 
	    -- a VMS user, mail this information to "colnet@loria.fr".
	    directory := Void;
	 elseif ("OS2").is_equal(system_name) then
	    -- Don't know the correct notation for OS2, please, if you are 
	    -- a VMS user, mail this information to "colnet@loria.fr".
	    directory := Void;
	 elseif ("Amiga").is_equal(system_name) then
	    directory := "%N";
	 end;
	 if directory /= Void then
	    echo.put_string(directory);
	    sfw.put_string(directory);
	 end;
	 -- After the current working directory, here is the default order 
	 -- for searching Eiffel source files :
	 list := <<
		   "lib_std", 
		   "lib_iterator",
		   "lib_random", 
		   "lib_number",
		   "lib_show",
		   "lib_se"
		   >>;
	 from
	    i := 1;
	 until
	    i > list.upper
	 loop
	    directory := installation_path.twin;
	    basic_directory.compute_subdirectory_with(directory,list.item(i));
	    directory.copy(basic_directory.last_entry);
	    if i < list.upper then
	       directory.extend('%N');
	    end;
	    echo.put_string(directory);
	    sfw.put_string(directory);
	    i := i + 1;
	 end;
	 echo.put_string("%N--- Written data ---%N");
	 sfw.disconnect;
	 echo.put_string("Update of %"");
	 echo.put_string(path);
	 echo.put_string("%" done.%NThe default loadpath is updated.%N");
      end;

   compiler_se_path: STRING;
	 -- The path name of the file which is used to save the 
	 -- `c_compiler_name' with its default options. For example, 
	 -- on Windows, the value may be "C:SmallEiffel\sys\compiler.se"

   set_compiler_se_path is
      local
	 path: STRING
      do
	 path := installation_path.twin;
	 basic_directory.compute_subdirectory_with(path,"sys");
	 path := basic_directory.last_entry.twin;
	 basic_directory.compute_file_path_with(path,"compiler.se");
	 compiler_se_path := basic_directory.last_entry.twin;
      end;

   garbage_collector_file_path: STRING;
	 -- The garbage collector path file. For example, on Windows, a 
	 -- correct value may be "C:\SmallEiffel\sys\gc".

   set_garbage_collector_file_path is
      local
	 path: STRING;
      do
	 echo.put_string("Computing GC file path:%N");
	 path := installation_path.twin;
	 basic_directory.compute_subdirectory_with(path,"sys");
	 if basic_directory.last_entry.is_empty then
	    fatal_problem_description_start;
	    echo.put_string("Unable to compute directory path with %"");
	    echo.put_string(path);
	    echo.put_string("%" and %"sys%".%N");
	    fatal_problem_description_end;
	 end;
	 path := basic_directory.last_entry.twin;
	 basic_directory.compute_file_path_with(path,"gc");
	 path := basic_directory.last_entry.twin;
	 garbage_collector_file_path := path;
	 echo.put_string("GC file path is %"");
	 echo.put_string(garbage_collector_file_path);
	 echo.put_string("%" and %"sys%".%N");
      end;

   garbage_collector: STRING;
	 -- The content of the first word of file `garbage_collector_file_path'
	 -- (the specific code for the GC).

   garbage_collector_selection is
      local
	 cmd: STRING;
      do
	 echo.put_string("Garbage collector selection:%N");
	 if system_name.is_equal("UNIX") then
	    cmd := system_se_path.twin;
	    cmd.remove_suffix("sys/system.se");
	    cmd.append("misc/GC.SH");
	    echo.put_string("Launching script %"");
	    echo.put_string(cmd);
	    echo.put_string("%".%N");
	    system(cmd);
	 elseif system_name.is_equal("Amiga") then
	    garbage_collector := "m68k-amigaos.c";
	 elseif system_name.is_equal("Windows") then
	    garbage_collector := "windows.c";
	 elseif system_name.is_equal("BeOS") then
	    garbage_collector := "BeOS_x86.c";
	 elseif system_name.is_equal("DOS") then
	    garbage_collector := "windows.c";
	 elseif system_name.is_equal("Macintosh") then
	    garbage_collector := "MacintoshPPC.c";
	 elseif system_name.is_equal("OS2") then
	    garbage_collector := "windows.c";
	 elseif system_name.is_equal("VMS") then
	    garbage_collector := "generic.c";
	 end;
	 if garbage_collector = Void then
	    echo.sfr_connect(sfr,garbage_collector_file_path);
	    garbage_collector := echo.read_word_in(sfr);
	    sfr.disconnect;
	    echo.put_string("Selected GC for %"");
	    echo.put_string(garbage_collector);
	    echo.put_string("%".%N");
	 else
	    echo.put_string("Selected GC for %"");
	    echo.put_string(garbage_collector);
	    echo.put_string("%".%N");
	    echo.sfw_connect(sfw,garbage_collector_file_path);
	    sfw_check_is_connected(garbage_collector_file_path);
	    sfw.put_string(garbage_collector);
	    sfw.put_character('%N');
	    sfw.disconnect;
	 end;
      end;

   c_compiler_name: STRING;
	 -- The `c_compiler_name' is one element of SYSTEM_TOOLS `compiler_list' 
	 -- ("gcc", "lcc-win32", "cc", etc.).

   c_compiler_linker_options: STRING is "";
	 -- Default extra options for the C compiler/linker. 

   set_c_compiler_name is
      do
	 echo.put_string("C compiler selection:%N");
	 if not interactive and compiler = Void then
	    if system_name.is_equal("UNIX") then
	       compiler := "gcc";
	       if ("linux.c").is_equal(garbage_collector) then
		  c_compiler_linker_options.copy("-pipe");
	       end;
	    end;
	 end;
	 if compiler = Void then
	    compiler := choice_in("C compiler selection",
				  system_tools.compiler_list);
	 end;
	 echo.put_string("Selected C compiler is %"");
	 echo.put_string(compiler);
	 echo.put_string("%".%N");
	 c_compiler_name := compiler;
	 echo.put_string("Try to update %"");
	 echo.put_string(compiler_se_path);
	 echo.put_string("%".%N");
	 echo.sfw_connect(sfw,compiler_se_path);
	 sfw_check_is_connected(compiler_se_path);
	 sfw.put_string(c_compiler_name);
	 if interactive then
	    interactive_c_compiler_linker_options;
	 end;
	 if not c_compiler_linker_options.is_empty then
	    sfw.put_character(' ');
	    sfw.put_string(c_compiler_linker_options);
	 end;
	 sfw.put_character('%N');
	 sfw.disconnect;
	 echo.put_string("Update of %"");
	 echo.put_string(compiler_se_path);
	 echo.put_string("%" done.%N");
	 echo.put_string(
	 "Hint: It is possible to change some default option(s) for the C %
	 %compiler%Njust after the compiler name in the very first line of %
	 %the%Nfile %"");
	 echo.put_string(compiler_se_path);
	 echo.put_string(
	 "%".%NFor example, the very first line can be %"gcc -pipe -O3%".%N%
	 %If you are no an expert of C compilation, do not add options.%N");
	 system_tools.set_c_compiler(Void);
	 system_tools.install_extra_options;
      end;

   interactive_c_compiler_linker_options is
	 -- To set `c_compiler_linker_options' interactively.
      require
	 interactive
      do
	 std_output.put_string(
	 "-----%NIt is possible to add some default option(s) to be passed%N%
	 %to the C compiler/linker.%N");
	 if ("gcc").is_equal(c_compiler_name) then
	    std_output.put_string(
	    "With gcc the -pipe option is recommended (unfortunately%N%
            %this is not supported for all platforms).%N%
            %The -pipe option is supported on all Linux platforms.%N")
	 end;
	 std_output.put_string(
	 "Enter now one single line for extra option(s) or an empty line:%N");
	 std_input.read_line;
	 c_compiler_linker_options.copy(std_input.last_string);
      end;

   bin_path: STRING;
	 -- The path where binary files are to be placed. For example, 
	 -- on Windows, the value may be "C:SmallEiffel\bin\"

   set_bin_path is
      do
	 bin_path := installation_path.twin;
	 basic_directory.compute_subdirectory_with(bin_path,"bin");
	 bin_path := basic_directory.last_entry.twin;
	 -- Because WinZip may not create an empty directory :
	 basic_directory.connect_to(bin_path);
	 if basic_directory.is_connected then
	    basic_directory.disconnect;
	 elseif basic_directory.create_new_directory(bin_path) then
	    echo.put_string("Directory %"");
	    echo.put_string(bin_path);
	    echo.put_string("%" created.%N");
	 else
	    echo.put_string("Directory %"");
	    echo.put_string(bin_path);
	    echo.put_string("%" not found.%N");
	 end;
      end;
   
   bin_c_path: STRING;
	 -- The path where source files are to be found. For example, 
	 -- on Windows, the value may be "C:SmallEiffel\bin_c\"

   set_bin_c_path is
      do
	 bin_c_path := installation_path.twin;
	 basic_directory.compute_subdirectory_with(bin_c_path,"bin_c");
	 bin_c_path := basic_directory.last_entry.twin;
      end;

   bin_path_in_system_env_path: BOOLEAN;
	 -- True if we find in the `bin_path' in the system PATH environment 
	 -- variable.

   compute_bin_path_in_system_env_path is
      local
	 se_bin, content: STRING;
      do
	 se_bin := bin_path.twin;
	 if ("UNIX").is_equal(system_name) then
	    content := get_environment_variable("PATH");
	    if content /= Void then
	       from
		  if se_bin.last = '/' then
		     se_bin.remove_last(1);
		  end;
		  content := content.twin;
	       variant
		  content.count
	       until
		  content.count = 0
	       loop
		  if content.has_prefix(se_bin) then
		     content.remove_first(se_bin.count);
		     if content.count = 0 then
			bin_path_in_system_env_path := true;
		     elseif content.first = ':' then
			content.clear;
			bin_path_in_system_env_path := true;
		     elseif content.first = '/' then
			content.remove_first(1);
			if content.count = 0 then
			   bin_path_in_system_env_path := true;
			elseif content.first = ':' then
			   content.clear;
			   bin_path_in_system_env_path := true;
			end;
		     end;
		  else
		     content.remove_first(1);
		  end;
	       end;
	    end;
	 elseif ("Windows").is_equal(system_name) then
	    content := get_environment_variable("PATH");
	    if content /= Void then
	       from
		  if se_bin.last = '\' then
		     se_bin.remove_last(1);
		  end;
		  se_bin.to_lower;
		  content := content.twin;
		  content.to_lower;
	       variant
		  content.count
	       until
		  content.count = 0
	       loop
		  if content.has_prefix(se_bin) then
		     content.remove_first(se_bin.count);
		     if content.count = 0 then
			bin_path_in_system_env_path := true;
		     elseif content.first = ';' then
			content.clear;
			bin_path_in_system_env_path := true;
		     elseif content.first = '\' then
			content.remove_first(1);
			if content.count = 0 then
			   bin_path_in_system_env_path := true;
			elseif content.first = ';' then
			   content.clear;
			   bin_path_in_system_env_path := true;
			end;
		     end;
		  else
		     content.remove_first(1);
		  end;
	       end;
	    end;
	 end;
      end;

   gathered_information_summary is
      do
	 std_output.put_string("---%N%
			       %Summary of gathered information :%N%
			       %   installation_path = %"");
	 std_output.put_string(installation_path);
	 std_output.put_string("%"%N   system_name = %"");
	 std_output.put_string(system_name);
	 std_output.put_string("%"%N   c_compiler_name = %"");
	 std_output.put_string(c_compiler_name);
	 std_output.put_string("%"%N");
	 if not c_compiler_linker_options.is_empty then
	    std_output.put_string("   c_compiler_linker_options = %"");
	    std_output.put_string(c_compiler_linker_options);
	    std_output.put_string("%"%N");
	 end;
	 std_output.put_string("   garbage_collector = %"");
	 std_output.put_string(garbage_collector);
	 std_output.put_string("%"%N");
	 if interactive then
	    std_output.put_string(
               "Type <Enter> to continue installation.%N%
	       %Type <Enter> now ");
	    std_output.flush;
	    std_input.read_character;
	 end;
	 std_output.put_string("---%NSmallEiffel's bootstrap started ...%N");
      end;

   move_executable_for(name: STRING) is
	 -- Move the executable for command `name' from `bin_c_path' 
	 -- to in `bin_path'.
      local
	 executable, old_path, new_path: STRING;
      do
	 executable := name.twin;
	 system_tools.add_x_suffix(executable);
	 basic_directory.compute_file_path_with(bin_c_path,executable);
	 old_path := basic_directory.last_entry.twin;
	 basic_directory.compute_file_path_with(bin_path,executable);
	 new_path := basic_directory.last_entry.twin;
	 if not file_exists(old_path) then
	    fatal_problem_description_start;
	    echo.put_string("Unable to find executable %"");
	    echo.put_string(old_path);
	    echo.put_string("%".%N");
	    fatal_problem_description_end;
	 end;
	 echo.file_renaming(old_path,new_path);
      end;

   split_mode_c_compile(name: STRING) is
	 -- Assume the current working directory is `bin_c_path', compile some
	 -- command `name' produced without the "-no_split" flag.
      local
	 c_name: STRING;
	 max: INTEGER;
      do
	 echo.put_string("C compiling %"");
	 echo.put_string(name);
	 echo.put_string("*.c%" files.%N");
	 run_control.set_output_name(name);
	 basic_directory.connect_to_current_working_directory;
	 if not basic_directory.is_connected then
	    fatal_problem_description_start;
	    echo.put_string("Unable to open current working directory.%N");
	    fatal_problem_description_end;
	 end;
	 from
	    basic_directory.read_entry;
	 until
	    basic_directory.end_of_input
	 loop
	    c_name := basic_directory.last_entry.twin;
	    if not c_name.has_prefix(name) then
	    elseif not c_name.has_suffix(".c") then
	    else
	       max := max + 1;
	       system_tools.split_mode_c_compiler_command(command,c_name);
	       std_output.put_string(command);
	       std_output.put_string("%N");
	       echo.call_system(command);
	    end;
	    basic_directory.read_entry;
	 end;
	 basic_directory.disconnect;
	 system_tools.split_mode_linker_command(command,name,max);
	 std_output.put_string(command);
	 std_output.put_string("%N");
	 echo.call_system(command);
	 move_executable_for(name);
      end;

   call_compile_to_c(options, name: STRING) is
      do
	 if bin_path_in_system_env_path then
	    command.copy("compile_to_c");
	 else
	    basic_directory.compute_file_path_with(bin_path,"compile_to_c");
	    command.copy(basic_directory.last_entry);
	 end;
	 system_tools.add_x_suffix(command);
	 command.extend(' ');
	 command.append(options);
	 command.append(" -o ");
	 command.append(name);
	 command.extend(' ');
	 command.append(name);
	 std_output.put_string(command);
	 std_output.put_string("%N");
	 echo.call_system(command);
      end;

   prepare_bin_c_directory is
	 -- Assume the current working directory is `bin_c_path',
	 -- prepare all C source files.
      local
	 i: INTEGER;
	 item: STRING;
      do
	 from
	    i := 1;
	 until
	    i > no_split_command_list.count
	 loop
	    item := no_split_command_list.item(i);
	    if ("lcc-win32").is_equal(c_compiler_name) then
	       echo.put_string(
               "Because of the very slow malloc of %"lcc-win32%",%N%
               %the -no_gc flag is not used.%N");
	       call_compile_to_c("-boost -no_split",item);
	    else
	       call_compile_to_c("-boost -no_gc -no_split",item);
	    end;
	    i := i + 1;
	 end;
	 from
	    i := 1;
	 until
	    i > splitted_command_list.count
	 loop
	    item := splitted_command_list.item(i);
	    if ("lcc-win32").is_equal(c_compiler_name) then
	       echo.put_string(
	       "Because of the very slow malloc of %"lcc-win32%" -no_gc flag is not used.%N");
	       call_compile_to_c("-boost",item);
	    else
	       call_compile_to_c("-boost -no_gc",item);
	    end;
	    i := i + 1;
	 end;
      end;

   no_split_mode_c_compile(name: STRING) is
	 -- Assume the current working directory is `bin_c_path', compile some
	 -- command `name' produced with the "-no_split" flag.
      local
	 c_name: STRING;
      do
	 c_name := name.twin;
	 c_name.append(".c");
	 run_control.set_output_name(name);
	 system_tools.no_split_mode_command(command,c_name);
	 std_output.put_string(command);
	 std_output.put_character('%N');
	 echo.call_system(command);
	 move_executable_for(name);
      end;

   no_split_command_list: ARRAY[STRING] is
	 -- Small commands which can be compiled with the -no_split flag.
      once
	 Result := <<
		     "clean",
		     "compile",
		     "finder",
		     "print_jvm_class"
		     >>;
      end;

   splitted_command_list: ARRAY[STRING] is
	 -- Small commands which can be compiled with the -no_split flag.
      once
	 Result := <<
		     "compile_to_c",
		     "short",
		     "pretty"
		     "compile_to_jvm",
		     >>;
      end;

   c_compile_no_split_command_list is
	 -- Apply `no_split_mode_c_compile' for all names of `no_split_command_list'.
      local
	 item: STRING;
	 i: INTEGER;
      do
	 from
	    i := 1;
	 until
	    i > no_split_command_list.count
	 loop
	    item := no_split_command_list.item(i);
	    no_split_mode_c_compile(item);
	    i := i + 1;
	 end;
      end;

   c_compile_splitted_command_list is
	 -- Apply `splitted_mode_c_compile' for all names of `splitted_command_list'.
      local
	 item: STRING;
	 i: INTEGER;
      do
	 from
	    i := 1;
	 until
	    i > splitted_command_list.count
	 loop
	    item := splitted_command_list.item(i);
	    split_mode_c_compile(item);
	    i := i + 1;
	 end;
      end;

   fatal_problem_description_start is
      do
	 echo.set_verbose;
	 echo.put_string(
	 "*** Fatal problem during installation of SmallEiffel.%N%
	 %    Read carefully the following information before starting%N%
	 %    again the `install' -debug command.%N%
	 %***************************************************************%N");
      end;

   fatal_problem_description_end is
      do
	 echo.put_string(
	 "***************************************************************%N%
	 %Fix the previously described problem and launch again `install'.%N");
	 restore_current_working_directory;
	 die_with_code(exit_failure_code);
      end;

   sfw_check_is_connected(path: STRING) is
      do
	 if not sfw.is_connected then
	    fatal_problem_description_start;
	    echo.put_string("Cannot write file %"");
	    echo.put_string(path);
	    echo.put_string("%".%NCheck write permissions.");
	    fatal_problem_description_end;
	 end;
      end;

   choice_in(title: STRING; names: ARRAY[STRING]): STRING is
	 -- Force some item to be selected interactively.
      local
	 i: INTEGER;
	 w, n: STRING;
      do
	 from
	 until
	    Result /= Void
	 loop
	    std_output.put_string(title);
	    std_output.put_string(":%N  ");
	    from
	       i := 1;
	    until
	       i > names.upper
	    loop
	       std_output.put_string(names.item(i));
	       i := i + 1;
	       if i <= names.upper then
		  std_output.put_string(", ");
	       end;
	    end;
	    std_output.put_string("%N? ");
	    std_output.flush;
	    std_input.read_word;
	    from
	       i := names.lower;
	       w := std_input.last_string.twin;
	       w.to_lower;
	    until
	       i > names.upper
	    loop
	       n := names.item(i).twin;
	       n.to_lower;
	       if w.is_equal(n) then
		  Result := names.item(i);
		  i := names.upper;
	       elseif n.has_prefix(w) then
		  if Result /= Void then
		     Result := Void;
		  else
		     Result := names.item(i);
		  end;
	       end;
	       i := i + 1;
	    end;
	    if Result = Void then
	       std_output.put_string("%"");
	       std_output.put_string(w);
	       std_output.put_string("%" is not a valid choice.%N");
	    end;
	 end;
	 std_output.put_string("selected: ");
	 std_output.put_string(Result);
	 std_output.put_string("%N");
      ensure
	 Result /= Void;
	 names.fast_has(Result)
      end;

   echo_usage_exit is
      do
	 echo.set_verbose;
	 echo.put_string("usage : ");
	 echo.put_string(command_name);
         echo.put_string(" [-interactive] [-no_compile] [-compiler <name>] [-debug]%N");
	 restore_current_working_directory;
	 die_with_code(exit_failure_code);
      end;

   basic_directory: BASIC_DIRECTORY;
   
   system_tools: SYSTEM_TOOLS is
      once
	 !!Result.install;
      end;

   sfr: STD_FILE_READ is
      once
	 !!Result.make;
      end;

   sfw: STD_FILE_WRITE is
      once
	 !!Result.make;
      end;

   cwd: STRING;
	 -- Used to save the initial current working directory (it 
	 -- must be restored before exit using `restore_current_working_directory'
	 -- because we are not always under UNIX.

   restore_current_working_directory is
      do
	 if cwd /= Void then
	    basic_directory.change_current_working_directory(cwd);
	 end;
      end;

   command: STRING is
      once
	 !!Result.make(512);
      end;

   call_clean(name: STRING) is
      do
	 if bin_path_in_system_env_path then
	    command.copy("clean");
	 else
	    basic_directory.compute_file_path_with(bin_path,"clean");
	    command.copy(basic_directory.last_entry);
	 end;
	 system_tools.add_x_suffix(command);
	 command.extend(' ');
	 command.append(name);
	 std_output.put_string(command);
	 std_output.put_string("%N");
	 echo.call_system(command);
      end;

   clean_bin_c_path is
	 -- Assume the current working directory is `bin_c_path', compile some
      local
	 i: INTEGER;
	 item: STRING;
      do
	 from
	    i := 1;
	 until
	    i > no_split_command_list.count
	 loop
	    item := no_split_command_list.item(i);
	    call_clean(item);
	    i := i + 1;
	 end;
	 from
	    i := 1;
	 until
	    i > splitted_command_list.count
	 loop
	    item := splitted_command_list.item(i);
	    if not item.is_equal("compile_to_c") then
	       call_clean(item);
	    end;
	    i := i + 1;
	 end;
	 -- To remove some C compiler specific files :
	 basic_directory.connect_to_current_working_directory;
	 if basic_directory.is_connected then
	    from
	       basic_directory.read_entry
	    until
	       basic_directory.end_of_input
	    loop
	       item := basic_directory.last_entry.twin;       
	       if item.has_prefix("compile_to_c") then
		  inspect
		      item.last
		  when 'h', 'c', 'H', 'C' then
		  else
		     echo.file_removing(item);
		  end;
	       else
		  echo.file_removing(item);
	       end;
	       basic_directory.read_entry
	    end;
	    basic_directory.disconnect;
	 end;
	 if ("lcc-win32").is_equal(c_compiler_name) then
	    echo.put_string("In order to reset %"compile_to_c%" -no_gc in %"");
	    echo.put_string(bin_c_path);
	    echo.put_string("%".%N");
	    call_clean("compile_to_c");
	    call_compile_to_c("-boost -no_gc","compile_to_c");
	    echo.remove_file("compile_to_c.bat");
	 end;
      end;

   make is
      local
	 i: INTEGER;
	 arg: STRING;
      do
	 from
	    i := 1;
	 until
	    i > argument_count
	 loop
	    arg := argument(i);
	    if ("-debug").is_equal(arg) then
	       echo.set_verbose;
	    elseif ("-interactive").is_equal(arg) then
	       interactive := true;
	    elseif ("-no_compile").is_equal(arg) then
	       no_compile := true;
	    elseif ("-compiler").is_equal(arg) then
	       if i < argument_count then
		  i := i + 1;
		  compiler := argument(i);
	       else
		  std_output.put_string("compiler name must be specified %
					%after %"-compiler%"%N");
		  echo_usage_exit;
               end;
            else
   	       echo_usage_exit;
            end;
	    i := i + 1;
	 end;
	 std_output.put_string("Install of SmallEiffel started.%N");
	 echo.put_string("Version of command %"");
	 echo.put_string(command_name);
	 echo.put_string("%" is:%N");
	 echo.put_string(small_eiffel.copyright);
	 set_system_se_path;
	 set_installation_path;
	 set_system_name;
	 write_default_loadpath_se_file;
	 set_compiler_se_path;
	 basic_directory.connect_to_current_working_directory;
	 cwd := basic_directory.last_entry.twin;
	 if basic_directory.is_connected then
	    basic_directory.disconnect;
	 end;
	 set_garbage_collector_file_path;
	 garbage_collector_selection;
	 set_c_compiler_name;
	 set_bin_path;
	 set_bin_c_path;
	 basic_directory.change_current_working_directory(bin_c_path);
	 if basic_directory.last_entry.is_empty then
	    fatal_problem_description_start;
	    echo.put_string(
	       "Unable to change current working directory %Nto %"");
	    echo.put_string(bin_c_path);
	    echo.put_string("%".%N");
	    fatal_problem_description_end;
	 end;
	 compute_bin_path_in_system_env_path;
	 gathered_information_summary;
         if not no_compile then
   	    std_output.put_string("C Compiling in %"");
   	    std_output.put_string(basic_directory.last_entry);
   	    std_output.put_string("%".%N");
   	    split_mode_c_compile("compile_to_c");
   	    prepare_bin_c_directory;
   	    c_compile_no_split_command_list;
   	    c_compile_splitted_command_list;
   	    clean_bin_c_path;
         end
	 restore_current_working_directory;
	 if not bin_path_in_system_env_path then
	    std_output.put_string("Do not forget to add %"");
	    std_output.put_string(bin_path);
	    std_output.put_string("%" in %Nyour system path variable.%N");
	 end;
	 std_output.put_string("SmallEiffel installation done.%N");
	 if system_name.is_equal("Windows") then
	    std_output.put_string("Type <Enter> to continue.%N");
	    std_input.read_character;
	 end;
      end;

end -- INSTALL
