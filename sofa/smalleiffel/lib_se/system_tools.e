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
class SYSTEM_TOOLS
   --
   -- Singleton object to handle system dependant information.
   -- This singleton is shared via the GLOBALS.`system_tools' once function.
   --
   -- Only this object is supposed to handle contents of the `SmallEiffel'
   -- system environment variable.
   --
   -- You may also want to customize this class in order to support a
   -- new operating system (please let us know).
   --

inherit GLOBALS;

creation make, install

feature {NONE}

   -- Currently handled system list :
   unix_system:        STRING is "UNIX";
   windows_system:     STRING is "Windows";
   beos_system:        STRING is "BeOS";
   macintosh_system:   STRING is "Macintosh";
   amiga_system:       STRING is "Amiga";
   dos_system:         STRING is "DOS";
   os2_system:         STRING is "OS2";
   vms_system:         STRING is "VMS";
   elate_system:       STRING is "Elate";

   -- Currently handled C compiler list :
   gcc:                STRING is "gcc";
   gpp:                STRING is "g++";
   lcc_win32:          STRING is "lcc-win32";
   cc:                 STRING is "cc";
   wcl386:             STRING is "wcl386";
   bcc32:              STRING is "bcc32";
   bcc32i:             STRING is "bcc32i"; -- Is this one really used ?
   cl:                 STRING is "cl";
   sas_c:              STRING is "sc";
   dice:               STRING is "dice";
   vbcc:               STRING is "vbcc";
   ccc:                STRING is "ccc";
   vpcc:               STRING is "vpcc";

feature {INSTALL}

   system_list: ARRAY[STRING] is
      once
         Result := << 
		     unix_system,
		     windows_system
		     beos_system,
		     macintosh_system,
		     amiga_system,
		     dos_system,
		     os2_system,
		     vms_system,
		     elate_system
		     >>;
      end;

   compiler_list: ARRAY[STRING] is
      once
	 Result := <<
		     gcc,
		     lcc_win32,
		     cc, 
		     wcl386, 
		     bcc32, 
		     bcc32i,
		     cl,
		     sas_c,
		     dice,
		     vbcc,
		     ccc,
		     vpcc
		     >>;
      end;

   add_x_suffix(cmd: STRING) is
      local
         suffix: STRING;
      do
         suffix := x_suffix;
         if not cmd.has_suffix(suffix) then
            cmd.append(suffix);
         end;
      end;

   make is
      local
         system_se_path: STRING;
         i: INTEGER;
      do
         system_se_path := get_environment_variable(fz_se);
         if system_se_path = Void then
            system_se_path := fz_se.twin;
            system_se_path.to_upper;
            system_se_path := get_environment_variable(system_se_path);
            if system_se_path = Void then
               echo.put_string(
                  "System environment variable %"SmallEiffel%" not set.%N%
                  %Trying default value: %"");
               system_se_path := "/usr/lib/SmallEiffel/sys/system.se";
               echo.put_string(system_se_path);
               echo.put_string(fz_03);
            end;
         else
            echo.put_string("SmallEiffel=%"");
            echo.put_string(system_se_path);
            echo.put_string(fz_b0);
         end;
         if system_se_path.has_suffix(fz_system_se) then
            echo.sfr_connect(tmp_file_read,system_se_path);
         else
            echo.put_string(
               "You should update the value of the %"SmallEiffel%" %
               %system environment variable.%N%
               %Since release -0.79, the %"SmallEiffel%" system %
               %environment variable must be the absolute path of %
               %the %"system.se%" file.%N%
               %For example %"/usr/lib/SmallEiffel/sys/system.se%" %
               %under Unix like system.%N");
            if system_se_path.has('/') then
               echo.put_string("Hope this is a Unix like system.%N");
               tmp_path.copy(system_se_path);
               tmp_path.extend_unless('/');
               tmp_path.append(fz_sys);
               tmp_path.extend('/');
               tmp_path.append(fz_system_se);
               echo.sfr_connect(tmp_file_read,tmp_path);
            end;
            if not tmp_file_read.is_connected then
               if system_se_path.has('\') then
                  echo.put_string("Hope this is a Windows like system.%N");
                  tmp_path.copy(system_se_path);
                  tmp_path.extend_unless('\');
                  tmp_path.append(fz_sys);
                  tmp_path.extend('\');
                  tmp_path.append(fz_system_se);
                  echo.sfr_connect(tmp_file_read,tmp_path);
               end;
            end;
            if not tmp_file_read.is_connected then
               if system_se_path.has(':') then
                  echo.put_string("Hope this is a Macintosh like system.%N");
                  tmp_path.copy(system_se_path);
                  tmp_path.extend_unless(':');
                  tmp_path.append(fz_sys);
                  tmp_path.extend(':');
                  tmp_path.append(fz_system_se);
                  echo.sfr_connect(tmp_file_read,tmp_path);
               end;
            end;
            if not tmp_file_read.is_connected then
               if system_se_path.has(']') then
                  echo.put_string("Hope this is a VMS system.%N");
                  tmp_path.copy(system_se_path);
                  tmp_path.extend_unless(']');
                  tmp_path.remove_last(1);
                  tmp_path.extend('.');
                  tmp_path.append(fz_sys);
                  tmp_path.extend(']');
                  tmp_path.append(fz_system_se);
                  echo.sfr_connect(tmp_file_read,tmp_path);
               end;
            end;
            if not tmp_file_read.is_connected then
               echo.put_string("Last chance.%N");
               tmp_path.copy(system_se_path);
               tmp_path.append(fz_system_se);
               echo.sfr_connect(tmp_file_read,tmp_path);
            end;
         end;
         if not tmp_file_read.is_connected then
            echo.w_put_string(
               "Unable to find file %"system.se%".%N%
               %Please, set the environment variable %"SmallEiffel%" %
               %with the appropriate absolute path to this file.%N%
               %Example for Unix: %"/usr/lib/SmallEiffel/sys/system.se%"%N%
               %Example for DOS/Windows: %"C:\SmallEiffel\sys\system.se%"%N");
            die_with_code(exit_failure_code);
         end;
         tmp_file_read.read_line;
         system_name := tmp_file_read.last_string;
         i := system_list.index_of(system_name);
         if i > system_list.upper then
            echo.w_put_string("Unknown system name in file%N%"");
            echo.w_put_string(tmp_file_read.path);
            echo.w_put_string("%".%NCurrently handled system names :%N");
            from
               i := 1;
            until
               i > system_list.upper
            loop
               echo.w_put_string(system_list.item(i));
               echo.w_put_character('%N');
               i := i + 1;
            end;
            die_with_code(exit_failure_code);
         else
            system_name := system_list.item(i);
            echo.put_string("System is %"");
            echo.put_string(system_name);
            echo.put_string(fz_b0);
         end;
         sys_directory := tmp_file_read.path.twin;
         sys_directory.remove_suffix(fz_system_se);
         tmp_file_read.disconnect;
         bin_directory := sys_directory.twin;
         parent_directory(bin_directory);
         add_directory(bin_directory,fz_bin);
      end;

   system_name: STRING;

   install_extra_options is
         -- Add some extra options during `install' time.
      do
         check
            c_compiler /= Void
	    -- This ought to be in a require clause, but
	    -- `c_compiler' has access restrictions
	 end
         if c_compiler = gcc then
            if not c_compiler_options.has('O') then
               append_token(c_compiler_options,"-O2");
            end;
         elseif c_compiler = lcc_win32 then
            if not c_compiler_options.has('O') then
               append_token(c_compiler_options,"-O");
            end;
	 elseif c_compiler = sas_c then
	    if not Scoptions_exists then
	       append_token(c_compiler_options,"Optimize OptimizerTime");
	    end;
	 elseif c_compiler = dice then
	 elseif c_compiler = vbcc then
	 elseif c_compiler = ccc then
	    if not c_compiler_options.has('O') then
	       append_token(c_compiler_options,"-O2");
	    end;
         elseif c_compiler = vpcc then
	    if not c_compiler_options.has('O') then
	       append_token(c_compiler_options,"-O2");
	    end;
         end;
      end;

feature {NONE}

   sys_directory: STRING;
         -- The SmallEiffel/sys directory computed with the value of
         -- the environment variable `SmallEiffel'.
         -- For example, under UNIX: "/usr/lib/SmallEiffel/sys/"

   bin_directory: STRING;
         -- For example, under UNIX: "/usr/lib/SmallEiffel/bin/"

   install is
      do
      end;

feature {COMPILE}

   command_path_in(command, command_name: STRING) is
         -- Append in `command' the correct path for `command_name'.
      do
         if windows_system /= system_name then
            command.append(bin_directory);
         end;
         command.append(command_name);
         command.append(x_suffix);
      end;

   cygnus_bug(make_file: STD_FILE_READ; make_script_name: STRING) is
         -- Because of a bug in cygnus on windows 95/NT.
      local
         time_out: INTEGER;
      do
         make_file.connect_to(make_script_name);
         if c_compiler = gcc then
            if system_name = windows_system then
               time_out := 2000;
            elseif system_name = dos_system then
               time_out := 2000;
            end;
         end;
         from
            time_out := 2000;
         until
            time_out = 0 or else make_file.is_connected
         loop
            make_file.connect_to(make_script_name);
            time_out := time_out - 1;
         end;

      end;

feature {COMPILE,CLEAN}

   remove_make_script: STRING is
         -- Compute the corresponding make file script name and remove
         -- the old one if any.
      do
         Result := path_h;
         Result.remove_suffix(h_suffix);
         if c_compiler = sas_c then
            Result.append(lnk_suffix);
            echo.file_removing(Result);
            Result.remove_suffix(lnk_suffix);
         end;
         Result.append(make_suffix);
         echo.file_removing(Result);
      end;

feature {SMALL_EIFFEL}

   read_loading_path_in(lp: ARRAY[STRING]) is
      do
         loading_path_add(lp,fz_loadpath_se,1);
         tmp_path.copy(sys_directory);
         tmp_path.append("loadpath.");
         tmp_path.append(system_name);
         loading_path_add(lp,tmp_path,1);
      end;

   append_lp_in(str: STRING; lp: ARRAY[STRING]) is
      local
         i: INTEGER;
         sed: STRING;
      do
         str.append("%NLoading path is:%N[%N");
         from
            i := lp.lower;
         until
            i > lp.upper
         loop
            str.extend(' ');
            str.extend('%"');
            str.append(lp.item(i));
            str.extend('%"');
            str.extend('%N');
            i := i + 1;
         end;
         str.append("]%NEnvironment Variable %"SmallEiffel%" is:%N");
         sed := get_environment_variable(fz_se);
         if sed = Void then
            str.append("not set.%N");
         else
            str.append(" %"");
            str.append(sed);
            str.append("%".%N");
         end;
      end;

feature {GC_HANDLER}

   put_mark_stack_and_registers is
         -- Add customized assembly code to mark registers.
      local
         architecture: STRING;
      do
         tmp_path.copy(sys_directory);
         tmp_path.append(fz_gc);
         echo.sfr_connect_or_exit(tmp_file_read,tmp_path);
         architecture := echo.read_word_in(tmp_file_read);
         tmp_file_read.disconnect;
         if as_none.is_equal(architecture) then
            eh.append(
               "Assembly Code for Garbage Collector not selected in %"");
            eh.append(tmp_path);
            eh.append(
               "%". Default generic (hazardous) C code is provided. %
	        % Have a look in the SmallEiffel FAQ.");
            eh.print_as_warning;
            architecture := "generic.c";
         end;
         tmp_path.copy(sys_directory);
         add_directory(tmp_path,fz_gc_lib);
         tmp_path.append(architecture);
         echo.sfr_connect_or_exit(tmp_file_read,tmp_path);
         cpp.put_c_file(tmp_file_read);
      end;

feature {SHORT_PRINT}

   format_directory(format: STRING): STRING is
      require
         format /= Void
      do
         !!Result.make(sys_directory.count + 10);
         Result.copy(sys_directory);
         parent_directory(Result);
         add_directory(Result,"short");
         add_directory(Result,format);
      end;

feature

   bad_use_exit(command_name: STRING) is
      require
         command_name /= Void
      do
         echo.w_put_string("Bad use of command `");
         echo.w_put_string(command_name);
         echo.w_put_string("'.%N");
         tmp_path.copy(sys_directory);
         parent_directory(tmp_path);
         add_directory(tmp_path,"man");
         tmp_path.append(command_name);
         tmp_path.append(help_suffix);
         echo.w_put_string("See documentation in file:%N   ");
         echo.w_put_string(tmp_path);
         echo.w_put_character('%N');
         die_with_code(exit_failure_code);
      end;

   is_c_plus_plus_file_path(path: STRING): BOOLEAN is
	 -- True when there `path' has one of the following 
	 -- suffix: ".cpp", ".cc", or ".C".
      do
	 if path.has_suffix(c_plus_plus_suffix) then
	    Result := true;
	 elseif path.has_suffix(".cc") then
	    Result := true;
	 elseif path.has_suffix(".C") then
	    Result := true;
	 end;
      end;

feature {JVM}

   class_file_path(path, directory, class_file_name: STRING) is
         -- Prepare `path' using `directory' and `class_file_name'.
      do
         path.clear;
         if vms_system = system_name then
            if directory.first /= '[' then
               path.extend('[');
            end;
         end;
         path.append(directory);
         if slash_separator then
            path.extend_unless('/');
         elseif backslash_separator then
            path.extend_unless('\');
         elseif macintosh_system = system_name then
            path.extend_unless(':');
         elseif amiga_system = system_name then
            path.extend_unless('/');
         elseif vms_system = system_name then
            path.extend_unless(']');
         end;
         path.append(class_file_name);
         path.append(class_suffix);
      end;

feature

   make_suffix: STRING is
      -- Suffix for make file produced by `compile_to_c'.
      once
         if dos_system = system_name then
            Result := ".BAT";
         elseif windows_system = system_name then
            Result := ".bat";
         elseif vms_system = system_name then
            Result := ".COM";
         elseif os2_system = system_name then
            Result := ".CMD";
         elseif elate_system = system_name then
            Result := ".scf";
         else
            Result := ".make";
         end;
      end;

   x_suffix: STRING is
         -- Executable files suffix.
      once
         if dos_system = system_name then
            Result := exe_suffix;
            Result.to_upper;
         elseif vms_system = system_name then
            Result := exe_suffix;
            Result.to_upper;
         elseif os2_system = system_name then
            Result := exe_suffix;
         elseif windows_system = system_name then
            Result := exe_suffix;
         elseif elate_system = system_name then
            Result := ".00";
         else
            Result := "";
         end;
      ensure
         Result /= Void
      end;

   object_suffix: STRING is
         -- Of object File produced by the C Compiler.
      once
         if c_compiler = gcc then
            Result := o_suffix;
         elseif c_compiler = lcc_win32 then
            Result := obj_suffix;
         elseif c_compiler = cc then
            if system_name = vms_system then
               Result := obj_suffix;
               Result.to_upper;
            else
               Result := o_suffix;
            end;
         elseif c_compiler = wcl386 then
            Result := obj_suffix;
         elseif c_compiler = bcc32 then
            Result := obj_suffix;
         elseif c_compiler = bcc32i then
            Result := obj_suffix;
         elseif c_compiler = cl then
            Result := obj_suffix;
         elseif c_compiler = sas_c then
            Result := o_suffix;
	 elseif c_compiler = dice then
	    Result := o_suffix;
	 elseif c_compiler = vbcc then
	    Result := o_suffix;
	 elseif c_compiler = ccc then
	    Result := o_suffix;
	 elseif c_compiler = vpcc then
	    Result := o_suffix;
         end;
      end;

feature {NATIVE_SMALL_EIFFEL}

   add_lib_math is
      once
         if beos_system = system_name then
         elseif c_compiler = gcc then
            add_external_lib(libm);
         elseif c_compiler = bcc32 then
            add_external_lib(libm);
         elseif c_compiler = bcc32i then
            add_external_lib(libm);
         elseif c_compiler = cl then
         elseif c_compiler = sas_c then
	    -- math library is included automatically if
	    -- "Math=..." was specified (as it is in
	    -- default `sas_c_compiler_options')
	 elseif c_compiler = dice then
	    add_external_lib(libm);
	 elseif c_compiler = vbcc then
	    if amiga_system = system_name then
	       add_external_lib("-lmieee");
	    else
	       add_external_lib(libm);
	    end;
	 elseif c_compiler = ccc then
	    add_external_lib(libcpml);
         elseif c_compiler = vpcc then
         end;
      end;

feature {COMPILE,COMPILE_TO_C}

   extra_arg(arg: STRING; argi: INTEGER; next_arg: STRING): INTEGER is
      require
         arg /= Void;
         argi >= 1
      do
         if arg.item(1) /= '-' then
            if arg.has_suffix(object_suffix) then
               append_token(external_object_files,arg);
               Result := argi + 1;
            elseif arg.has_suffix(c_suffix) then
               append_token(external_c_files,arg);
               Result := argi + 1;
            elseif is_c_plus_plus_file_path(arg) then
               append_token(external_c_plus_plus_files,arg);
               Result := argi + 1;
            elseif arg.has_suffix(".a") then
               add_external_lib(arg);
               Result := argi + 1;
            elseif arg.has_suffix(".lib") then
               add_external_lib(arg);
               Result := argi + 1;
            elseif arg.has_suffix(".res") then 
               -- For lcc-win32 resource files :
               add_external_lib(arg);
               Result := argi + 1;
            elseif run_control.root_class = Void then
               run_control.compute_root_class(arg);
               Result := argi + 1;
               if next_arg /= Void then
                  if next_arg.item(1) /= '-' then
                     if next_arg.has_suffix(object_suffix) then
                     elseif next_arg.has_suffix(c_suffix) then
                     elseif is_c_plus_plus_file_path(next_arg) then
                     else
                        run_control.set_root_procedure(next_arg);
                        Result := argi + 2;
                     end;
                  end;
               end;
            else
               append_token(c_compiler_options,arg);
               Result := argi + 1;
            end;
         elseif arg.has_prefix("-l") then
            add_external_lib(arg);
            Result := argi + 1;
         elseif arg.has_prefix("-L") then
            append_token(external_lib_path,arg);
            if ("-L").is_equal(arg) then
               if next_arg /= Void then
                  append_token(external_lib_path,next_arg);
                  Result := argi + 2;
               end;
            else
               Result := argi + 1;
            end;
         elseif ("-subsystem").is_equal(arg) then
            append_token(linker_options,arg);
            if next_arg /= Void then
               append_token(linker_options,next_arg);
               Result := argi + 2;
            else
               Result := argi + 1;
            end;
         elseif ("-include").is_equal(arg) then
            if next_arg /= Void then
	       append_token(c_compiler_options,arg);
               append_token(c_compiler_options,next_arg);
               Result := argi + 2;
            else
               Result := argi + 1;
            end;
         else
            append_token(c_compiler_options,arg);
            Result := argi + 1;
         end;
      ensure
         Result > old argi
      end;

feature {COMPILE,COMPILE_TO_C,CLEAN,INSTALL}

   set_c_compiler(cc_arg: STRING) is
         -- If `cc_arg' is not Void, used `cc_arg' as the C compiler. Otherwise, 
         -- read the selected one in the "SmallEiffel/sys/compiler.se" file.
      local
         i: INTEGER;
         sd: STRING;
         c: CHARACTER;
      do
         if cc_arg /= Void then
            i := compiler_list.index_of(cc_arg);
            if i > compiler_list.upper then
               echo.w_put_string("compile_to_c: ");
               echo.w_put_string(cc_arg);
               echo.w_put_string(
               " : unknown compiler name after -cc flag.%N");
               show_compiler_list_then_exit;
            end;
            c_compiler := compiler_list.item(i);
         else
            sd := sys_directory;
            tmp_path.copy(sd);
            tmp_path.append("compiler.se");
            echo.sfr_connect_or_exit(tmp_file_read,tmp_path);
            c_compiler := echo.read_word_in(tmp_file_read);
            i := compiler_list.index_of(c_compiler);
            if i > compiler_list.upper then
               echo.w_put_string("Unknown compiler name in file%N%"");
               echo.w_put_string(tmp_file_read.path);
               echo.w_put_string("%".%N");
               show_compiler_list_then_exit;
            end;
            c_compiler := compiler_list.item(i);
            if not tmp_file_read.end_of_input then
               from
                  c := tmp_file_read.last_character;
               until
                  c = '%N' or else c ='%R'
               loop
                  c_compiler_options.extend(c);
                  tmp_file_read.read_character;
                  if not tmp_file_read.end_of_input then
                     c := tmp_file_read.last_character;
                  end;
               end;
            end;
            tmp_file_read.disconnect;
            from
            until c_compiler_options.is_empty or else
               not c_compiler_options.first.is_separator
            loop
               c_compiler_options.remove_first(1);
            end;
            -- Setting default `c_compiler_options' only when there is no C 
            -- compiler option after the name of the compiler we have just 
            -- read in file "compiler.se". This allow the advanced user to 
	    -- tune exactly the C compiler according to its needs.
            if c_compiler_options.is_empty then
               if gcc = c_compiler then
                  c_compiler_options.copy("-O2");
               elseif lcc_win32 = c_compiler then
                  c_compiler_options.copy("-O");
               elseif cc = c_compiler then
                  c_compiler_options.copy("-O");
               elseif wcl386 = c_compiler then
               elseif bcc32 = c_compiler then
                  c_compiler_options.copy("-5 -w-aus -w-par -w-rvl -O2 -O-v");
               elseif bcc32i = c_compiler then
                  c_compiler_options.copy("-5 -w-aus -w-par -w-rvl -O2");
               elseif cl = c_compiler then
                  c_compiler_options.copy("-O2 -nologo -D%"WIN32%"");
               elseif sas_c = c_compiler then
		  c_compiler_options.clear;
		  linker_options.copy("Link");
		  if not Scoptions_exists then
		     append_token(linker_options, "SmallCode SmallData");
		  end;
	       elseif dice = c_compiler then
		  c_compiler_options.copy("-mD -mC");
	       elseif vbcc = c_compiler then
		  if amiga_system = system_name then
		     c_compiler_options.copy("-DAMIGA");
		  end;
	       elseif ccc = c_compiler then
		  c_compiler_options.copy("-O2");
               elseif vpcc = c_compiler then
                  c_compiler_options.copy("-O2");
               else
                  check false end;
               end;
            end;
         end;
      ensure
         compiler_list.fast_has(c_compiler)
      end;
   
feature {COMPILE_TO_C}

   set_no_strip is
      do
         no_strip := true;
      end;

feature {C_PRETTY_PRINTER}

   put_c_main_function_type(out_c: STD_FILE_WRITE) is
      do
         if vms_system = system_name then
            out_c.put_string(fz_void);
         else
            out_c.put_string(fz_int);
         end;
      end;

   put_c_main_function_exit(out_c: STD_FILE_WRITE) is
      do
         out_c.put_string("}%Nexit(0);%N");
         if vms_system = system_name then
            out_c.put_string("return;}%N");
         else
            out_c.put_string("return 0;}%N");
         end;
      end;

   sys_runtime(name: STRING; suffix: CHARACTER) is
         -- Prepare `tmp_file_read' to access the corresponding file
         -- in the SmallEiffel/sys/runtime directory.
      require
         name /= Void;
         suffix = 'c' or suffix = 'h'
      do
         tmp_path.copy(sys_directory);
         add_directory(tmp_path,fz_runtime);
         tmp_path.append(name);
         tmp_path.extend('.');
         tmp_path.extend(suffix);
         echo.sfr_connect_or_exit(tmp_file_read,tmp_path);
      ensure
         tmp_file_read.is_connected
      end;

   path_h: STRING is
         -- Create a new STRING which is the name of the
         -- main *.h file.
      do
         Result := run_control.root_class.twin;
         Result.to_lower;
         if dos_system = system_name then
            from
            until
               Result.count <= 4
            loop
               Result.remove_last(1);
            end;
         end;
         Result.append(h_suffix);
      end;

   strip_executable(cmd: STRING): BOOLEAN is
      local
         output_name: STRING;
      do
         cmd.clear;
         if not no_strip then
            output_name := run_control.output_name;
            if unix_system = system_name then
               Result := true;
               cmd.append("strip ");
               if output_name = Void then
                  cmd.append("a.out");
               else
                  cmd.append(output_name);
               end;
            elseif os2_system = system_name then
               Result := true;
               cmd.append("emxbind -qs ");
               if output_name = Void then
                  cmd.append("a.exe");
               else
                  cmd.append(output_name);
               end;
            end;
         end;
      end;

   add_c_plus_plus_file(f: STRING) is
      require
         is_c_plus_plus_file_path(f) 
      do
         append_token(external_c_plus_plus_files,f);
      end;

   is_linking_mandatory: BOOLEAN is
	 -- Is is mandatory to link again this executable even when 
	 -- nothing has changed in the generated C code ? 
      do
	 Result := not external_object_files.is_empty;
	 if not Result then
	    Result := not external_c_files.is_empty;
	 end;
	 if not Result then
	    Result := not external_c_plus_plus_files.is_empty;
	 end;
      end;

   add_lib_basic_gui is
      once
	 add_external_lib_path("-L/usr/X11R6/lib");
	 add_external_lib("-lX11");
      end;

feature {C_PRETTY_PRINTER,INSTALL}

   split_mode_c_compiler_command(cmd, c_file_name: STRING) is
         -- Where c_file_name is the name of one slice.
      do
         cmd.clear;
         if c_compiler = gcc then
 	    if is_c_plus_plus_file_path(c_file_name) then
	       cmd.append(gpp);
 	    else
	       cmd.append(gcc);
 	    end
            append_token(cmd,c_compiler_options);
            append_token(cmd,c_flag);
            append_token(cmd,c_file_name);
         elseif c_compiler = lcc_win32 then
            cmd.append(lcc);
            append_token(cmd,c_compiler_options);
            append_token(cmd,c_file_name);
         elseif c_compiler = cc then
            cmd.append(cc);
            append_token(cmd,c_compiler_options);
            append_token(cmd,c_flag);
            append_token(cmd,c_file_name);
         elseif c_compiler = wcl386 then
            cmd.append("wcc386");
            append_token(cmd,c_compiler_options);
            append_token(cmd,c_file_name);
         elseif c_compiler = bcc32 then
            cmd.append(bcc32);
            append_token(cmd,c_compiler_options);
            append_token(cmd,c_flag);
            append_token(cmd,c_file_name);
         elseif c_compiler = bcc32i then
            cmd.append(bcc32i);
            append_token(cmd,c_compiler_options);
            append_token(cmd,c_flag);
            append_token(cmd,c_file_name);
         elseif c_compiler = cl then
            cmd.append(cl);
            append_token(cmd,c_compiler_options);
            append_token(cmd,c_flag);
            append_token(cmd,c_file_name);
         elseif c_compiler = sas_c then
            cmd.append(sas_c);
	    append_token(cmd,sas_c_compiler_options(true));
	    append_token(cmd,c_compiler_options);
	    append_token(cmd,c_file_name);
	 elseif c_compiler = dice then
	    cmd.append(dcc);
	    append_token(cmd,c_compiler_options);
	    append_token(cmd,c_flag);
	    append_token(cmd,c_file_name);
	 elseif c_compiler = vbcc then
	    cmd.append(vc);
            append_token(cmd,c_compiler_options);
	    append_token(cmd,c_flag);
            append_token(cmd,c_file_name);
	 elseif c_compiler = ccc then
            cmd.append(ccc);
            append_token(cmd,c_compiler_options);
            append_token(cmd,c_flag);
            append_token(cmd,c_file_name);
         elseif c_compiler = vpcc then
            cmd.append(vpcc);
            append_token(cmd,c_compiler_options);
            append_token(cmd,c_flag);
            append_token(cmd,c_file_name);
         end;
      end;

   split_mode_linker_command(cmd, c_name: STRING; max: INTEGER) is
         -- Where `c_name' is only the prefix name (ie. "compile_to_c").
      do
         cmd.clear;
         if c_compiler = gcc then
 	    if external_c_plus_plus_files.is_empty then
	       cmd.append(gcc);
	    else
	       cmd.append(gpp);
	    end
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            add_objects(cmd,c_name,max);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
         elseif c_compiler = lcc_win32 then
            external_c_files_for_lcc_win32(cmd);
            cmd.append(lcclnk);
            if not no_strip then
               append_token(cmd,s_flag);
            end;
            append_token(cmd,linker_options);
            add_output_name(cmd);
            add_objects(cmd,c_name,max);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
         elseif c_compiler = cc then
            cmd.append(cc);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            add_objects(cmd,c_name,max);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
         elseif c_compiler = wcl386 then
            cmd.append("wlink");
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            add_objects(cmd,c_name,max);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
         elseif c_compiler = bcc32 then
            cmd.append(bcc32);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            add_objects(cmd,c_name,max);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
            add_lib_math;
         elseif c_compiler = bcc32i then
            cmd.append(bcc32i);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            add_objects(cmd,c_name,max);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
            add_lib_math;
         elseif c_compiler = cl then
            cmd.append(cl);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            add_objects(cmd,c_name,max);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
            add_lib_math;
         elseif c_compiler = sas_c then
            cmd.append(sas_c);
	    append_token(cmd,sas_c_compiler_options(true));
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,c_name);
            cmd.append("#1#2#3#4#5#6#7#8#9#?.o");
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
            add_output_name(cmd);
            if not no_strip then
               cmd.append(" StripDebug");
            end;
	 elseif c_compiler = dice then
	    cmd.append(dcc);
	    append_token(cmd,c_compiler_options);
	    append_token(cmd,linker_options);
	    append_token(cmd,external_lib_path);
	    add_output_name(cmd);
	    add_objects(cmd,c_name,max);
	    append_token(cmd,external_c_files);
	    append_token(cmd,external_c_plus_plus_files);
	    append_token(cmd,external_object_files);
	    append_token(cmd,external_lib);
	    if no_strip then
	       -- no typo; "-s" means "include symbol table",
	       -- not "strip debug information"
	       append_token(cmd,"-s -d1");
	    end;
	    add_lib_math;
	 elseif c_compiler = vbcc then
	    cmd.append(vc);
	    append_token(cmd,c_compiler_options);
	    append_token(cmd,linker_options);
	    append_token(cmd,external_lib_path);
	    add_output_name(cmd);
	    add_lib_math;
	    add_objects(cmd,c_name,max);
	    append_token(cmd,external_c_files);
	    append_token(cmd,external_c_plus_plus_files);
	    append_token(cmd,external_object_files);
	    append_token(cmd,external_lib);
         elseif c_compiler = ccc then
            cmd.append(ccc);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            add_objects(cmd,c_name,max);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
         elseif c_compiler = vpcc then
            cmd.append(vpcc);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            add_objects(cmd,c_name,max);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
         end;
      end;

   no_split_mode_command(cmd, c_file_name: STRING) is
      require
         c_file_name.has_suffix(".c")
      do
         cmd.clear;
         if c_compiler = gcc then
	    if external_c_plus_plus_files.is_empty then
	       cmd.append(gcc);
	    else
	       cmd.append(gpp);
	    end
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            append_token(cmd,c_file_name);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
         elseif c_compiler = lcc_win32 then
            cmd.append(lcc);
            append_token(cmd,c_compiler_options);
            append_token(cmd,c_file_name);
            cmd.extend('%N');
            external_c_files_for_lcc_win32(cmd);
            cmd.append(lcclnk);
            if not no_strip then
               append_token(cmd,s_flag);
            end;
            append_token(cmd,linker_options);
            add_output_name(cmd);
            c_file_name.remove_suffix(c_suffix);
            c_file_name.append(object_suffix);
            append_token(cmd,c_file_name);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
         elseif c_compiler = cc then
            cmd.append(cc);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            append_token(cmd,c_file_name);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
         elseif c_compiler = wcl386 then
            cmd.append(wcl386);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            append_token(cmd,c_file_name);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
         elseif c_compiler = bcc32 then
            cmd.append(bcc32);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            append_token(cmd,c_file_name);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
            add_lib_math;
         elseif c_compiler = bcc32i then
            cmd.append(bcc32i);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            append_token(cmd,c_file_name);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
            add_lib_math;
         elseif c_compiler = cl then
            cmd.append(cl);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            append_token(cmd,c_file_name);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
            add_lib_math;
         elseif c_compiler = sas_c then
            cmd.append(sas_c);
	    append_token(cmd,sas_c_compiler_options(false));
            append_token(cmd,c_compiler_options);
	    append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            append_token(cmd,c_file_name);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
	    add_lib_math;
            add_output_name(cmd);
	 elseif c_compiler = dice then
	    cmd.append(dcc);
	    append_token(cmd,c_compiler_options);
	    append_token(cmd,linker_options);
	    append_token(cmd,external_lib_path);
	    add_output_name(cmd);
	    append_token(cmd,c_file_name);
	    append_token(cmd,external_c_files);
	    append_token(cmd,external_c_plus_plus_files);
	    append_token(cmd,external_object_files);
	    append_token(cmd,external_lib);
	    add_lib_math;
	    if no_strip then
	       append_token(cmd,"-s");
	    end;
	 elseif c_compiler = vbcc then
	    cmd.append(vc);
	    append_token(cmd,c_compiler_options);
	    append_token(cmd,linker_options);
	    append_token(cmd,external_lib_path);
	    add_output_name(cmd);
	    add_lib_math;
	    append_token(cmd,c_file_name);
	    append_token(cmd,external_c_files);
	    append_token(cmd,external_c_plus_plus_files);
	    append_token(cmd,external_object_files);
	    append_token(cmd,external_lib);
	 elseif c_compiler = ccc then
	    cmd.append(ccc);
	    append_token(cmd,c_compiler_options);
	    append_token(cmd,linker_options);
	    append_token(cmd,external_lib_path);
	    add_output_name(cmd);
	    append_token(cmd,c_file_name);
	    append_token(cmd,external_c_files);
	    append_token(cmd,external_c_plus_plus_files);
	    append_token(cmd,external_object_files);
	    append_token(cmd,external_lib);
         elseif c_compiler = vpcc then
            cmd.append(vpcc);
            append_token(cmd,c_compiler_options);
            append_token(cmd,linker_options);
            append_token(cmd,external_lib_path);
            add_output_name(cmd);
            append_token(cmd,c_file_name);
            append_token(cmd,external_c_files);
            append_token(cmd,external_c_plus_plus_files);
            append_token(cmd,external_object_files);
            append_token(cmd,external_lib);
	 end;
      end;

feature {NONE} -- SAS/c support functions:

   Scoptions_exists: BOOLEAN is
	 -- Is there a file "SCOPTIONS" in the current directory?
      once
	 Result := file_tools.is_readable("SCOPTIONS")
      end;
   
   sas_c_compiler_options(split: BOOLEAN): STRING is
	 -- C compiler options or "" if no SCOPTIONS exists.
	 -- If `split' is True, "Data=Far" is used, otherwise
	 -- "Data=Auto".
      do
	 if Scoptions_exists then
	    Result := ""
	 else
	    !!Result.make(0)
	    Result.append("Math=IEEE Parameters=Both Code=Far");
	    -- cause bloat, but avoid linker errors
	    if split then
	       Result.append(" Data=Far");
	    else
	       Result.append(" Data=Auto");
	    end
	    Result.append(" Ignore=93,194,304");
	    -- ignore the following warnings:
	    --  93: no reference to identifier X
	    -- 194: too much local data for NEAR reference,
	    --      some changed to FAR (only with Data=Auto)
	    -- 304: dead assignment eliminated
	    Result.append(" NoVersion NoIcons");
	    -- avoid cluttering the display with messages and
	    -- the current directory with icon files
	 end
      end;
   
feature {NONE}

   c_compiler: STRING;
         -- One item of `compiler_list'.

   c_compiler_options: STRING is "";
         -- C compiler options including extra include path,
         -- optimization flags, etc.

   external_object_files: STRING is "";
         -- External object files.

   external_c_files: STRING is "";
         -- External C files.

   external_lib_path: STRING is "";
         -- External libraries path to be added at link time.

   external_lib: STRING is "";
         -- External libraries to be added at link time.

   linker_options: STRING is "";
         -- Those options are only to be passed to the linker.

   external_c_plus_plus_files: STRING is "";
         -- External C++ files.

   append_token(line, token: STRING) is
      do
         if not token.is_empty then
            if token.first /= ' ' then
               if not line.is_empty then
                  line.extend_unless(' ');
               end;
            end;
            line.append(token);
         end;
      end;
   
   backslash_separator: BOOLEAN is
      do
         if windows_system = system_name then
            Result := true;
         elseif dos_system = system_name then
            Result := true;
         elseif os2_system = system_name then
            Result := true;
         end;
      end;

   loading_path_add(lp: ARRAY[STRING]; path: STRING; level: INTEGER) is
      local
         file: STD_FILE_READ;
         line: STRING;
      do
         if level > 5 or else lp.count > 1024 then
            echo.w_put_string(
               "Eiffel source loading path too long or infinite %
               %loadpath.se includes.%N");
            !!line.make(1024);
            append_lp_in(line,lp);
            echo.w_put_string(line);
            die_with_code(exit_failure_code);
         end;
         !!file.make;
         echo.sfr_connect(file,path);
         if file.is_connected then
            from
               echo.put_string("Append contents of  %"");
               echo.put_string(path);
               echo.put_string("%" to loading path.%N");
            until
               file.end_of_input
            loop
               file.read_line;
               line := file.last_string.twin;
               environment_variable_substitution(path,line);
               if line.has_suffix(fz_loadpath_se) then
                  loading_path_add(lp,line,level + 1);
               elseif line.is_empty then
                  if not file.end_of_input then
                     lp.add_last(line);
                  end;
               else
                  lp.add_last(line);
               end;
            end;
            file.disconnect;
         end;
      end;

   external_c_files_for_lcc_win32(cmd: STRING) is
         -- Because lcc_win32 does not accept *.c file while 
         -- linking as other C compiler do :-(
      local
         c_files: ARRAY[STRING];
         c_file: STRING;
         i: INTEGER;
      do
         if not external_c_files.is_empty then
            c_files := external_c_files.split;
            external_c_files.clear;
            if c_files /= Void then
               from
                  i := c_files.lower;
               until
                  i > c_files.upper
               loop
                  c_file := c_files.item(i);
                  cmd.append(lcc);
                  append_token(cmd,c_compiler_options);
                  append_token(cmd,c_file);
                  cmd.extend('%N');
                  c_file.remove_suffix(c_suffix);
                  c_file.append(object_suffix);
                  append_token(external_object_files,c_file);
                  i := i + 1;
               end;
            end;
         end;
      end;

   add_directory(path, dir: STRING) is
      require
         path.count > 0;
         dir.count > 0
      local
         last: CHARACTER;
      do
         if slash_separator then
            path.extend_unless('/');
            path.append(dir);
            path.extend_unless('/');
         elseif backslash_separator then
            path.extend_unless('\');
            path.append(dir);
            path.extend_unless('\');
         elseif macintosh_system = system_name then
            path.extend_unless(':');
            path.append(dir);
            path.extend_unless(':');
         elseif amiga_system = system_name then
            last := path.last;
            if last /= '/' and then last /= ':' then
               path.extend_unless('/');
            end;
            path.append(dir);
            path.extend_unless('/');
         elseif vms_system = system_name then
            path.extend_unless(']');
            path.remove_last(1);
            path.extend_unless('.');
            path.append(dir);
            path.extend_unless(']');
         else
            check
               false
            end;
         end;
      end;

   parent_directory(path: STRING) is
         -- Remove the last sub-directory of `path' (assume `path' is a
         -- combination of more than one directory).
      require
         path.count > 0
      do
         if slash_separator then
            from
               path.remove_last(1);
            until
               path.is_empty or else path.last = '/'
            loop
               path.remove_last(1);
            end;
         elseif backslash_separator then
            from
               path.remove_last(1);
            until
               path.is_empty or else path.last = '\'
            loop
               path.remove_last(1);
            end;
         elseif macintosh_system = system_name then
            from
               path.remove_last(1);
            until
               path.is_empty or else path.last = ':'
            loop
               path.remove_last(1);
            end;
         elseif amiga_system = system_name then
            from
               path.remove_last(1);
            until
               path.is_empty or else ("/:").has(path.last)
            loop
               path.remove_last(1);
            end;
         elseif vms_system = system_name then
            from
               path.remove_last(1);
            until
               path.is_empty or else path.last = '.'
            loop
               path.remove_last(1);
            end;
            path.remove_last(1);
            path.extend(']');
         else
            check
               false
            end;
         end;
      ensure
         path.count > 0;
         path.count < (old path.count)
      end;

feature {ID_PROVIDER}

   id_file_path: STRING is
      once
         Result := path_h;
         Result.remove_suffix(h_suffix);
         Result.append(".id");
      end;

feature {NONE}

   environment_variable_substitution(path, line: STRING) is
         -- If any, substitute some environment variable by it's value.
         -- The only one accepted notation is :
         --                                        ${...}
      local
         i, state, mem1, mem2: INTEGER;
         c: CHARACTER;
         value, variable: STRING;
      do
         from
            i := 1;
         until
            i > line.count
         loop
            c := line.item(i);
            inspect
               state
            when 0 then -- Initial state.
               if c = '$' then
                  state := 1;
                  mem1 := i;
               end;
            when 1 then -- "$" read.
               if c = '{' then
                  state := 2;
                  !!variable.make(8);
               else
                  state := 0;
               end;
            when 2 then -- "${" read.
               if c = '}' then
                  state := 3;
                  mem2 := i;
               else
                  variable.extend(c);
               end;
            else -- First correct variable found.
            end;
            i := i + 1;
         end;
         if state = 3 then
            value := get_environment_variable(variable);
            if value = Void then
               echo.w_put_string("Environment variable ${");
               echo.w_put_string(variable);
               echo.w_put_string("} of %"");
               echo.w_put_string(path);
               echo.w_put_string("%" is not set.%N");
            else
               variable.copy(line);
               line.head(mem1 - 1);
               line.append(value);
               variable.remove_first(mem2);
               line.append(variable);
               environment_variable_substitution(path,line)
            end;
         end;
      end;

   slash_separator: BOOLEAN is
      do
         if unix_system = system_name then
            Result := true;
         elseif beos_system = system_name then
            Result := true;
         elseif elate_system = system_name then
            Result := true;
         end;
      end;

   show_compiler_list_then_exit is
      local
         i: INTEGER;
      do
         echo.w_put_string("Currently handled compiler names:%N");
         from
            i := 1;
         until
            i > compiler_list.upper
         loop
            echo.w_put_string(compiler_list.item(i));
            echo.w_put_character('%N');
            i := i + 1;
         end;
         die_with_code(exit_failure_code);
      end;

   add_output_name(cmd: STRING) is
      local
         output_name: STRING;
      do
         output_name := run_control.output_name;
         if output_name = Void then
            output_name := run_control.root_class.twin;
            output_name.to_lower;
            if c_compiler = lcc_win32 then
               append_token(cmd,o_flag);
               append_token(cmd,output_name);
               add_x_suffix(cmd);
            elseif c_compiler = bcc32 then
               append_token(cmd,e_flag);
               cmd.append(output_name);
               add_x_suffix(cmd);
            elseif c_compiler = bcc32i then
               append_token(cmd,e_flag);
               cmd.append(output_name);
               add_x_suffix(cmd);
            elseif c_compiler = wcl386 then
               append_token(cmd,o_flag);
               cmd.append(output_name);
               add_x_suffix(cmd);
            elseif c_compiler = sas_c then
               output_name := run_control.root_class.twin;
               output_name.to_lower;
               cmd.append(fz_to_);
               cmd.append(output_name);
	    elseif c_compiler = dice then
	       append_token(cmd,o_flag);
	       cmd.append(output_name);
	    elseif c_compiler = vbcc then
	       append_token(cmd,o_flag);
	       cmd.append(output_name);
	    elseif c_compiler = vpcc then
	       append_token(cmd,o_flag);
	       cmd.append(output_name);
            end;
         elseif c_compiler = gcc then
            append_token(cmd,o_flag);
            append_token(cmd,output_name);
            add_x_suffix(cmd);
         elseif c_compiler = lcc_win32 then
            append_token(cmd,o_flag);
            append_token(cmd,output_name);
            add_x_suffix(cmd);
         elseif c_compiler = cc then
            append_token(cmd,o_flag);
            append_token(cmd,output_name);
            add_x_suffix(cmd);
         elseif c_compiler = wcl386 then
            append_token(cmd,o_flag);
            append_token(cmd,output_name);
            add_x_suffix(cmd);
         elseif c_compiler = bcc32 then
            append_token(cmd,e_flag);
            cmd.append(output_name);
            add_x_suffix(cmd);
         elseif c_compiler = bcc32i then
            append_token(cmd,e_flag);
            cmd.append(output_name);
            add_x_suffix(cmd);
         elseif c_compiler = cl then
            append_token(cmd,o_flag);
            cmd.append(output_name);
            add_x_suffix(cmd);
         elseif c_compiler = sas_c then
            cmd.append(fz_to_);
            append_token(cmd,output_name);
	 elseif c_compiler = dice then
	    append_token(cmd,o_flag);
	    append_token(cmd,output_name);
	    add_x_suffix(cmd);
	 elseif c_compiler = vbcc then
	    append_token(cmd,o_flag);
	    append_token(cmd,output_name);
	    add_x_suffix(cmd);
         elseif c_compiler = ccc then
            append_token(cmd,o_flag);
            append_token(cmd,output_name);
            add_x_suffix(cmd);
         elseif c_compiler = vpcc then
            append_token(cmd,o_flag);
            append_token(cmd,output_name);
            add_x_suffix(cmd);
         end;
      end;

   no_strip: BOOLEAN;

   add_objects(cmd, c_name: STRING; max: INTEGER) is
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > max
         loop
            append_token(cmd,c_name);
            i.append_in(cmd);
            cmd.append(object_suffix);
            i := i + 1;
         end;
      end;

   add_external_lib(lib: STRING) is
      require
	 not lib.is_empty
      do
	 if not external_lib.has_string(lib) then
	    append_token(external_lib,lib);
	 end;
      end;

   add_external_lib_path(path: STRING) is
      require
	 not path.is_empty
      do
	 if not external_lib_path.has_string(path) then
	    append_token(external_lib_path,path);
	 end;
      end;

   exe_suffix: STRING is ".exe";

   o_suffix: STRING is ".o";

   obj_suffix: STRING is ".obj";

   c_flag: STRING is "-c";

   o_flag: STRING is "-o";

   e_flag: STRING is "-e";

   s_flag: STRING is "-s";

   lcc: STRING is "lcc";

   vc: STRING is "vc";

   dcc: STRING is "dcc";

   lcclnk: STRING is "lcclnk";

   lnk_suffix: STRING is ".lnk";

   libm: STRING is "-lm";

   libcpml: STRING is "-lcpml";

   fz_to_: STRING is " To ";

   fz_loadpath_se: STRING is "loadpath.se";

   singleton_memory: SYSTEM_TOOLS is
      once
         Result := Current;
      end;

invariant

   is_real_singleton: Current = singleton_memory

end -- SYSTEM_TOOLS
