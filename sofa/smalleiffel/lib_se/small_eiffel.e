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
class SMALL_EIFFEL
   --
   -- Singleton object to handle general purpose information.
   -- This singleton is shared via the GLOBALS.`small_eiffel' once function.
   --

inherit GLOBALS;

creation make

feature

   copyright: STRING is
      "-- SmallEiffel The GNU Eiffel Compiler -- Release (- 0.76Beta#1)--%N%
      %-- Copyright (C), 1994-98 - LORIA - UHP - CRIN - INRIA - FRANCE --%N%
      %-- Dominique COLNET and Suzanne COLLIN -    colnet@loria.fr     --%N%
      %--                  http://SmallEiffel.loria.fr/                --%N";

feature {GC_HANDLER,C_PRETTY_PRINTER}

   root_procedure: RUN_FEATURE_3;

feature {NONE}

   make is
      do
      end;

feature

   loading_path: ARRAY[STRING] is
      once
         !!Result.with_capacity(32,1);
         system_tools.read_loading_path_in(Result);
      end;

   is_ready: BOOLEAN;
         -- True when type inference algorithm is done : all
         -- needed classes are loaded, `at_run_time' classes are
         -- known, falling down is done, ...

   get_class(str: STRING): BASE_CLASS is
      local
         class_name: CLASS_NAME;
      do
         if base_class_dictionary.has(str) then
            Result := base_class_dictionary.at(str);
         else
            !!class_name.unknown_position(str);
            Result := class_name.base_class;
         end;
      ensure
         Result /= Void
      end;

   base_class(class_name: CLASS_NAME): BASE_CLASS is
      require
         class_name /= Void;
      do
         if base_class_dictionary.has(class_name.to_string) then
            Result := base_class_dictionary.at(class_name.to_string);
         elseif eiffel_parser.is_running then
            fatal_error("Internal Error #1 in SMALL_EIFFEL.");
         else
            if parser_buffer_for(class_name.to_string) then
               Result := eiffel_parser.analyse_class(class_name);
               check
                  Result /= Void
                     implies
                  base_class_dictionary.has(class_name.to_string);
               end;
            end;
            if Result = Void then
               eh.add_position(class_name.start_position);
               fatal_error("Unable to load class.");
            end;
         end;
      end;

   load_class(name: STRING): BASE_CLASS is
         -- Try to load a class using it's `name' (ie. not the corresponding 
         -- file path).
      require
         name = string_aliaser.item(name);
         not eiffel_parser.is_running
      local
         class_name: CLASS_NAME;
      do
         check
            not name.has('.');
            not name.has('/');
            not name.has('\');
            not name.has(' ');
            not name.has(':');
         end;
         !!class_name.unknown_position(name);
         if parser_buffer_for(name) then
            Result := eiffel_parser.analyse_class(class_name);
            if Result = Void then
               fatal_error("Cannot load class.");
            end;
         else
            fatal_error("Cannot find class.");
         end;
      end;

   same_base_feature(up_rf: RUN_FEATURE; r: ARRAY[RUN_CLASS]): BOOLEAN is
         -- True when all `dynamic' features of `r' have excately the same 
         -- final name and refer exactely to the same `base_feature'.
      require
         is_ready and r.count > 1
      local
         i: INTEGER;
         f: E_FEATURE;
         dyn_rf: RUN_FEATURE;
         rc: RUN_CLASS;
      do
         from
            Result := true;
            i := r.upper;
            f := up_rf.base_feature;
         until
            not Result or else i = 0
         loop
            rc := r.item(i);
            dyn_rf := rc.dynamic(up_rf);
            if f = dyn_rf.base_feature then
               if dyn_rf.name.to_string /= up_rf.name.to_string then
                  Result := false;
               end;
            else
               Result := false;
            end;
            i := i - 1;
         end;
      end;

   stupid_switch(t: TYPE; r: ARRAY[RUN_CLASS]): BOOLEAN is
         -- True when `t' drives exactely to the same `t.run_type' for all `r'.
      require
         is_ready
      do
         if r = Void then
            Result := true;
         elseif r.count = 1 then
            Result := true;
         else
            Result := t.stupid_switch(r);
         end;
      end;

feature {PRETTY}

   re_load_class(e_class: BASE_CLASS): BOOLEAN is
      require
         e_class /= Void;
      local
         name: STRING;
         new_class: like e_class;
      do
         name := e_class.name.to_string;
         check
            base_class_dictionary.has(name);
         end;
         base_class_dictionary.remove(name);
         new_class := load_class(name);
         Result := new_class /= Void;
      end;

feature {BASE_CLASS}

   add_base_class(bc: BASE_CLASS) is
      require
         bc /= Void
      local
         name: STRING;
      do
         name := bc.name.to_string
         check
            not name.is_empty;
            not base_class_dictionary.has(name);
         end;
         base_class_dictionary.put(bc,name);
         incr_magic_count;
      ensure
         base_class_dictionary.has(bc.name.to_string);
      end;

feature {FINDER}

   find_path_for(arg: STRING): STRING is
      do
         if parser_buffer_for(arg) then
            Result := parser_buffer.path;
         end;
         parser_buffer.unset_is_ready;
      end;

feature {NONE}

   parser_buffer_path: STRING is
      once
         !!Result.make(256);
      end;

   parser_buffer_for(name: STRING): BOOLEAN is
         -- SmallEiffel algorithm for searching classes on the disk.
         -- When Result, `parser_buffer' is ready to be used.
      require
         name /= Void;
         not parser_buffer.is_ready
      local
         i: INTEGER;
      do
         tmp_tail.copy(name);
         tmp_tail.to_lower;
         if not tmp_tail.has_suffix(eiffel_suffix) then
            tmp_tail.append(eiffel_suffix);
         end;
         from
            i := loading_path.lower;
         until
            i > loading_path.upper or else Result
         loop
            parser_buffer_path.copy(loading_path.item(i));
            parser_buffer_path.append(tmp_tail);
            parser_buffer.load_file(parser_buffer_path);
            Result := parser_buffer.is_ready;
            i := i + 1;
         end;
         if not Result and then rename_dictionary.has(tmp_tail) then
            parser_buffer_path.copy(rename_dictionary.at(tmp_tail));
            parser_buffer.load_file(parser_buffer_path);
            if parser_buffer.is_ready then
               Result := true;
            else
               echo.w_put_string("Bad %"rename.se%" file.%NCannot open %"");
               echo.w_put_string(parser_buffer_path);
               echo.w_put_string(fz_03);
               die_with_code(exit_failure_code);
            end;
         end;
         if not Result then
            tmp_tail.copy(name);
            if not tmp_tail.has_suffix(eiffel_suffix) then
               tmp_tail.append(eiffel_suffix);
            end;
            from
               i := loading_path.lower;
            until
               i > loading_path.upper or else Result
            loop
               parser_buffer_path.copy(loading_path.item(i));
               parser_buffer_path.append(tmp_tail);
               parser_buffer.load_file(parser_buffer_path);
               Result := parser_buffer.is_ready;
               i := i + 1;
            end;
         end;
         if not Result then
            echo.w_put_string("Unable to find file for class %"");
            echo.w_put_string(name);
            echo.w_put_string("%". ");
            parser_buffer_path.clear;
            append_loading_path_in(parser_buffer_path);
            echo.w_put_string(parser_buffer_path);
         end;
      ensure
         Result implies parser_buffer.is_ready
      end;

   rename_dictionary: DICTIONARY[STRING,STRING] is
         -- Handling of "rename.se" files.
      local
         i: INTEGER;
         full_name, short_name: STRING;
      once
         from
            !!Result.make;
            i := 1;
         until
            i > loading_path.upper
         loop
            tmp_path.copy(loading_path.item(i));
            tmp_path.append("rename.se");
            echo.sfr_connect(tmp_file_read,tmp_path);
            if tmp_file_read.is_connected then
               from
               until
                  tmp_file_read.end_of_input
               loop
                  tmp_file_read.read_word;
                  full_name := tmp_file_read.last_string.twin;
                  tmp_file_read.read_word;
                  short_name := tmp_file_read.last_string.twin;
                  short_name.prepend(loading_path.item(i));
                  if Result.has(full_name) then
                     echo.w_put_string("Multiple entry for %"");
                     echo.w_put_string(full_name);
                     echo.w_put_string("%" in %"rename.se%" files.%N%
                                           %Clash for %N%"");
                     echo.w_put_string(short_name);
                     echo.w_put_string("%" and %N%"");
                     echo.w_put_string(Result.at(full_name));
                     echo.w_put_string(".%N");
                     die_with_code(exit_failure_code);
                  end;
                  Result.put(short_name,full_name)
                  tmp_file_read.skip_separators;
               end;
               tmp_file_read.disconnect;
            end;
            i := i + 1;
         end;
      end;

feature

   short_flag: BOOLEAN;
         -- True when command `short' is running.

   pretty_flag: BOOLEAN;
         -- True when command `pretty' is running.

feature {SHORT}

   set_short_flag is
      do
         short_flag := true;
      end;

feature {PRETTY}

   set_pretty_flag is
      do
         pretty_flag := true;
      end;

feature

   is_used(cn: STRING): BOOLEAN is
         -- Is the base class `cn' used (loaded) ?
      do
         Result := base_class_dictionary.has(cn);
      end;

   run_class(t: TYPE): RUN_CLASS is
      require
         t.run_type = t
      local
         run_string: STRING;
      do
         run_string := t.run_time_mark;
         if run_class_dictionary.has(run_string) then
            Result := run_class_dictionary.at(run_string);
         else
            !!Result.make(t);
            check
               run_class_dictionary.has(run_string);
            end;
         end;
      ensure
         Result /= Void
      end;

feature

   base_class_count: INTEGER is
         -- Total number of base class actually loaded.
      do
         Result := base_class_dictionary.count;
      end;

feature

   compile_to_c is
         -- Produce C code for `root_class'/`procedure'.
      local
         root_class, procedure: STRING;
         rc: RUN_CLASS;
         run_count: INTEGER;
         i: INTEGER;
         gc_flag: BOOLEAN;
      do
         root_class := run_control.root_class;
         procedure := run_control.root_procedure;
         get_started(root_class,procedure);
         if nb_errors = 0 then
            check
               root_procedure /= Void
            end;
            cpp.get_started;
            cpp.swap_on_h;
            gc_flag := not gc_handler.is_off;
            -- ---------------------------------------------------------
            cpp.put_string("%N/* --- Mangling Table Start ---%N");
            from
               i := 1;
            until
               i > run_class_dictionary.count
            loop
               rc := run_class_dictionary.item(i);
               if rc.at_run_time then
                  run_count := run_count + 1;
               end;
               rc.demangling;
               i := i + 1;
            end;
            cpp.put_string(" --- Mangling Table End --- */%N");
            -- ---------------------------------------------------------
            from
               cpp.put_comment_line("C Header Pass 1 :");
               i := 1;
            until
               i > run_class_dictionary.count
            loop
               rc := run_class_dictionary.item(i);
               rc.c_header_pass1;
               i := i + 1;
            end;
            -- ---------------------------------------------------------
            from
               cpp.put_comment_line("C Header Pass 2 :");
               i := 1;
            until
               i > run_class_dictionary.count
            loop
               rc := run_class_dictionary.item(i);
               rc.c_header_pass2;
               i := i + 1;
            end;
            -- ---------------------------------------------------------
            from
               cpp.put_comment_line("C Header Pass 3 :");
               i := 1;
            until
               i > run_class_dictionary.count
            loop
               rc := run_class_dictionary.item(i);
               rc.c_header_pass3;
               i := i + 1;
            end;
            -- ---------------------------------------------------------
            from
               cpp.put_comment_line("C Header Pass 4 :");
               i := 1;
            until
               i > run_class_dictionary.count
            loop
               rc := run_class_dictionary.item(i);
               rc.c_header_pass4;
               i := i + 1;
            end;
            -- Force definition of T9 and T7 :
            if not run_class_dictionary.has(as_native_array_character) then
               cpp.put_string("typedef char* T9;%N");
               if run_control.no_check then
                  cpp.put_c_function("void se_prinT9(T9*o)",
                                     "printf(%"NATIVE_ARRAY[STRING]#%%p\n%",*o);");
               end;
            end;
            manifest_string_pool.c_define1(string_at_run_time);
            cpp.customize_runtime(basic_sys_runtime);
            -- ---------------------------------------------------------
            if gc_flag then
               gc_handler.define1;
            end;
            -- ---------------------------------------------------------
            compile_routines;
            cpp.cecil_define;
            -- ---------------------------------------------------------
            cpp.define_main(root_procedure);
            manifest_string_pool.c_define2(string_at_run_time);
            compile_registered_for_c_define;
            address_of_pool.c_define;
            if gc_flag then
               gc_handler.define2;
            end;
            manifest_array_pool.c_define;
            switch_collection.c_define;
            cpp.define_used_basics;
            debug
               echo.put_string("Very Final magic_count : ");
               echo.put_integer(magic_count);
               echo.put_character('%N');
            end;
            cpp.write_make_file;
         else
            eh.append("Cannot produce C code.");
            eh.print_as_error;
         end;
      end;

   compile_to_jvm is
         -- Produce Java Byte Code for `root_class'/`procedure'.
      local
         root_class, procedure: STRING;
         rc: RUN_CLASS;
         run_count, i: INTEGER;
      do
         root_class := run_control.root_class;
         procedure := run_control.root_procedure;
         get_started(root_class,procedure);
         if nb_errors = 0 then
            jvm.prepare_output_directory;
            from
               i := 1;
            until
               i > run_class_dictionary.count
            loop
               rc := run_class_dictionary.item(i);
               if rc.at_run_time then
                  run_count := run_count + 1;
                  rc.compile_to_jvm;
               end;
               i := i + 1;
            end;
            echo.print_count("Used Type",run_count);
            jvm.write_jvm_root_class;
            jvm.write_main_class(root_procedure);
         else
            eh.append("Cannot produce Java Byte Code.");
            eh.print_as_error;
         end;
      end;

feature {NONE}

   base_class_dictionary: DICTIONARY[BASE_CLASS,STRING] is
         -- When looking for a BASE_CLASS using the name of
         -- base class (ie FOO[BAR] is stored at key "FOO").
      once
         !!Result.with_capacity(2048);
      end;

feature

   magic_count: INTEGER;
         -- Grow each time a new run class is added, each time a new
         -- class is loaded, each time a new feature is checked,
         -- each time ...
         -- Thus when `magic_count' stops growing, we are really
         -- ready to run :-).

feature {RUN_CLASS,RUN_FEATURE,ASSERTION_COLLECTOR,SWITCH_COLLECTION}

   incr_magic_count is
      do
         magic_count := magic_count + 1;
      end;

feature {BASE_CLASS,RUN_CLASS,GC_HANDLER}

   run_class_dictionary: DICTIONARY[RUN_CLASS,STRING] is
      once
         !!Result.with_capacity(2048);
      end;

feature {CALL_PROC_CALL}

   run_class_with(run_time_mark: STRING): RUN_CLASS is
      do
         if run_class_dictionary.has(run_time_mark) then
            Result := run_class_dictionary.at(run_time_mark);
         end;
      end;

feature {RUN_CLASS}

   is_tagged(rc: RUN_CLASS): BOOLEAN is
      require
         is_ready;
         rc.at_run_time;
         rc.current_type.is_reference;
         run_control.boost
      local
         i, up: INTEGER;
         r: ARRAY[RUN_CLASS];
         rcd: like run_class_dictionary;
         rc2: RUN_CLASS;
      do
         from
            i := 1;
            rcd := run_class_dictionary;
            up := rcd.count;
         until
            Result or else i > up
         loop
            rc2 := rcd.item(i);
            r := rc2.running;
            if r = Void then
            elseif r.fast_has(rc) then
               Result := r.count > 1;
            end;
            i := i + 1;
         end;
      end;

   memory_class_used: BASE_CLASS is
         -- The MEMORY class when used or Void when this class is not
         -- in the live code..
      do
         if base_class_dictionary.has(as_memory) then
            Result := base_class_dictionary.at(as_memory);
         end;
      end;

feature {NONE}

   get_started(root_class_name, procedure_name: STRING) is
         -- Get started to compile using creation `procedure_name'
         -- of base class `root_class_name'.
      require
         not root_class_name.is_empty;
         not procedure_name.is_empty
      local
         root_proc_name: SIMPLE_FEATURE_NAME;
         root: BASE_CLASS;
         root_proc: PROCEDURE;
         root_type: TYPE;
         magic: INTEGER;
      do
         echo.put_string(copyright);
         if run_control.no_check then
            run_control.set_generator_used;
            run_control.set_generating_type_used;
         end;
         echo.put_string("Parsing :%N");
         root := load_class(root_class_name);
         if root = Void then
            eh.append("Cannot load root class ");
            eh.append(root_class_name);
            eh.append(fz_dot);
            eh.print_as_error;
         else
            root_proc_name := root.root_procedure_name(procedure_name);
            root_proc := root.root_procedure(root_proc_name);
         end;
         if nb_errors = 0 then
            if root_proc.arguments /= Void then
               eh.add_position(root_proc.start_position);
               eh.append("Creation procedure ");
               eh.append(procedure_name);
               eh.append(" must not have arguments.");
               eh.print_as_error;
            end;
         end;
         if nb_errors = 0 then
            root_type := root.run_class.current_type;
         end;
         if nb_errors = 0 then
            root_procedure := root_proc.to_run_feature(root_type,root_proc_name);
         end;
         if nb_errors = 0 then
            echo.put_string("Starting Falling Down (");
            echo.put_integer(magic_count);
            echo.put_string(em1);
            from
               falling_down;
               cecil_pool.fill_up;
            until
               magic = magic_count or else nb_errors > 0
            loop
               magic := magic_count;
               falling_down;
            end;
            echo.put_string("End of Falling Down (");
            echo.put_integer(magic_count);
            echo.put_string(em1);
         end;
         if nb_errors = 0 then
            echo.put_string("Starting AFD Check (");
            echo.put_integer(magic_count);
            echo.put_string(em1);
            from
               afd_check;
            until
               magic = magic_count or else nb_errors > 0
            loop
               magic := magic_count;
               afd_check;
            end;
            check_for_deferred;
            check_generic_formal_arguments;
            switch_collection.afd;
            echo.put_string("Before conversion handling (");
            echo.put_integer(magic_count);
            echo.put_string(em1);
            conversion_handler.finish_falling_down;
            echo.put_string("After conversion handling (");
            echo.put_integer(magic_count);
            echo.put_string(em1);
            from
            until
               magic = magic_count or else nb_errors > 0
            loop
               magic := magic_count;
               falling_down;
            end;
            echo.put_string("End of AFD Check (");
            echo.put_integer(magic_count);
            echo.put_string(em1);
         end;
         if not eh.is_empty then
            eh.append("Internal Warning #1 (Error Handler Not Empty) : ");
            eh.print_as_warning;
         end;
         if nb_errors = 0 then
            is_ready := true;
            echo.print_count("Loaded Classe",base_class_dictionary.count);
         end;
      ensure
         nb_errors = 0 implies root_procedure /= Void
      end;

feature -- To add more Context for some `to_runnable' :

   top_rf: RUN_FEATURE is
      do
         Result := stack_rf.item(top);
      end;

   push(rf: RUN_FEATURE) is
      do
         top := top + 1;
         stack_rf.force(rf,top);
      end;

   pop is
      do
         check
            1 <= top;
         end;
         top := top - 1;
      ensure
         old(top) = top + 1
      end;

feature {NONE}

   stack_rf: ARRAY[RUN_FEATURE] is
      once
         !!Result.make(1,50);
      end;

   top: INTEGER;

feature {NONE}

   falling_down is
      local
         rc: RUN_CLASS;
         i: INTEGER;
      do
         if run_control.generator_used then
            type_string.set_at_run_time;
         end;
         manifest_string_pool.falling_down;
         address_of_pool.falling_down;
         from
            i := 1;
         until
            i > run_class_dictionary.count
         loop
            rc := run_class_dictionary.item(i);
            rc.falling_down;
            i := i + 1;
         end;
      end;

   afd_check is
      local
         rc: RUN_CLASS;
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > run_class_dictionary.count
         loop
            rc := run_class_dictionary.item(i);
            rc.afd_check;
            i := i + 1;
         end;
      end;

feature {RUN_FEATURE_9}

   afd_check_deferred(rf9: RUN_FEATURE_9) is
      do
         if not rf9_memory.fast_has(rf9) then
            rf9_memory.add_last(rf9);
         end;
      end;

feature {NONE}

   rf9_memory: FIXED_ARRAY[RUN_FEATURE_9] is
      once
         !!Result.with_capacity(1024);
      end;

   check_for_deferred is
      local
         i: INTEGER;
         rf9: RUN_FEATURE;
         rc: RUN_CLASS;
      do
         from
            i := rf9_memory.upper
            echo.print_count("Deferred Routine",i+1);
         until
            i < 0
         loop
            rf9 := rf9_memory.item(i);
            rc := rf9.current_type.run_class;
            if rc.at_run_time then
               eh.append(rf9.name.to_string);
               eh.append(" is a deferred feature in ");
               eh.append(rf9.current_type.written_mark);
               warning(rf9.start_position,fz_dot);
            end;
            i := i - 1;
         end;
      end;

   check_generic_formal_arguments is
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > base_class_dictionary.count
         loop
            base_class_dictionary.item(i).check_generic_formal_arguments;
            i := i + 1;
         end;
      end;

feature {ID_PROVIDER}

   id_extra_information(sfw: STD_FILE_WRITE; name: STRING) is
      local
         bc: BASE_CLASS;
         rc: RUN_CLASS;
         path: STRING;
     do
	if name = as_none then
	elseif run_class_dictionary.has(name) then
           rc := run_class_dictionary.at(name);
           bc := rc.base_class;
        elseif base_class_dictionary.has(name) then
           bc := base_class_dictionary.at(name);
        else
        end;
        if bc /= Void then
           sfw.put_string("class-path: %"");
           path := bc.path;
           sfw.put_string(path);
           sfw.put_character('%"');
           sfw.put_character(' ');
           bc.id_extra_information(sfw);
        end;
        if rc /= Void then
           rc.id_extra_information(sfw);
        end;
     end;

feature {C_PRETTY_PRINTER}

   define_extern_tables is
      require
         cpp.on_c
      local
         size: INTEGER;
      do
         size := id_provider.max_id + 1;
         cpp.macro_def("SE_MAXID",size);
         if run_control.generator_used then
            cpp.put_extern4(fz_t7_star,"g",size);
         end;
         if run_control.generating_type_used then
            cpp.put_extern4(fz_t7_star,"t",size);
         end;
         if run_control.no_check then
            cpp.put_extern4("char*","p",size);
            c_code.copy("void(*se_prinT[");
            size.append_in(c_code);
            c_code.append("])(void**)");
            cpp.put_extern1(c_code);
         end;
      end;

   initialize_path_table is
      require
         run_control.no_check;
         cpp.on_c;
      local
         i: INTEGER;
         bc: BASE_CLASS;
         rc: RUN_CLASS;
      do
         from
            -- *** Add the current path for Jacob Navia. ***
            cpp.put_string("p[0]=%"???%";%N");
            i := 1;
         until
            i > base_class_dictionary.count
         loop
            bc := base_class_dictionary.item(i);
            cpp.put_string("p[");
            cpp.put_integer(bc.id);
            cpp.put_string("]=");
            cpp.put_string_c(bc.path);
            cpp.put_string(fz_00);
            i := i + 1;
         end;
         from
            i := 1;
         until
            i > run_class_dictionary.count
         loop
            rc := run_class_dictionary.item(i);
            if rc.at_run_time then
               cpp.put_string("se_prinT[");
               cpp.put_integer(rc.id);
               cpp.put_string("]=((void(*)(void**))se_prinT");
               cpp.put_integer(rc.id);
               cpp.put_string(");%N");
               if rc.current_type.is_generic then
                  cpp.put_string("p[");
                  cpp.put_integer(rc.id);
                  cpp.put_string("]=p[");
                  cpp.put_integer(rc.base_class.id);
                  cpp.put_string("];%N");
               end;
            end;
            i := i + 1;
         end;
      ensure
         cpp.on_c;
      end;

   initialize_generator is
      require
         cpp.on_c
      local
         i: INTEGER;
         bc: BASE_CLASS;
         rc: RUN_CLASS;
      do
         from
            i := 1;
         until
            i > base_class_dictionary.count
         loop
            bc := base_class_dictionary.item(i);
            cpp.put_array1('g',bc.id);
            cpp.put_character('=');
            cpp.put_se_string_from_external_copy(bc.name.to_string);
            cpp.put_string(fz_00);
            i := i + 1;
         end;
         from
            i := 1;
         until
            i > run_class_dictionary.count
         loop
            rc := run_class_dictionary.item(i);
            if rc.at_run_time then
               bc := rc.base_class;
               if bc.name.to_string /= rc.current_type.run_time_mark then
                  cpp.put_array1('g',rc.id);
                  cpp.put_character('=');
                  cpp.put_array1('g',bc.id);
                  cpp.put_string(fz_00);
               end;
            end;
            i := i + 1;
         end;
      ensure
         cpp.on_c;
      end;

   initialize_generating_type is
      require
         cpp.on_c;
      local
         i: INTEGER;
         rc: RUN_CLASS;
         bc: BASE_CLASS;
         rtm: STRING;
      do
         from
            i := 1;
         until
            i > run_class_dictionary.count
         loop
            rc := run_class_dictionary.item(i);
            if rc.at_run_time then
               cpp.put_array1('t',rc.id);
               cpp.put_character('=');
               bc := rc.base_class;
               rtm := rc.current_type.run_time_mark
               if bc.name.to_string /= rtm then
                  cpp.put_se_string_from_external_copy(rtm);
               else
                  cpp.put_array1('g',rc.id);
               end;
               cpp.put_string(fz_00);
            end;
            i := i + 1;
         end;
      ensure
         cpp.on_c;
      end;

feature {NONE}

   compile_routines is
         -- Try to give the best order to the C output.
      local
         rc, rc_string: RUN_CLASS;
         ct: TYPE;
         deep, i: INTEGER;
         stop: BOOLEAN;
         bcn: STRING;
      do
         echo.put_string("Compiling/Sorting routines for ");
         echo.put_integer(run_class_dictionary.count);
         echo.put_string(" run classes :%N");
         cpp.swap_on_c;
         from
            i := 1;
         until
            i > run_class_dictionary.count
         loop
            rc := run_class_dictionary.item(i);
            ct := rc.current_type;
            if ct.is_basic_eiffel_expanded then
               rc.compile_to_c(0);
            elseif ct.is_string then
               rc_string := rc;
            end;
            i := i + 1;
         end;
         from
            i := 1;
         until
            i > run_class_dictionary.count
         loop
            rc := run_class_dictionary.item(i);
            ct := rc.current_type;
            if ct.is_bit then
               rc.compile_to_c(0);
            end;
            i := i + 1;
         end;
         from
            i := 1;
         until
            i > run_class_dictionary.count
         loop
            rc := run_class_dictionary.item(i);
            bcn := rc.base_class_name.to_string;
            if as_native_array = bcn then
               rc.compile_to_c(0);
            end;
            i := i + 1;
         end;
         if rc_string /= Void then
            rc_string.compile_to_c(0);
         end;
         from
            i := 1;
         until
            i > run_class_dictionary.count
         loop
            rc := run_class_dictionary.item(i);
            ct := rc.current_type;
            bcn := ct.base_class_name.to_string;
            if as_array = bcn or else as_fixed_array = bcn then
               rc.compile_to_c(0);
            end;
            i := i + 1;
         end;
         from
            i := 1;
         until
            i > run_class_dictionary.count
         loop
            rc := run_class_dictionary.item(i);
            ct := rc.current_type;
            if ct.is_generic then
               rc.compile_to_c(0);
            end;
            i := i + 1;
         end;
         from -- General sorting :
            deep := 6;
         until
            stop
         loop
            from
               stop := true;
               i := 1;
            until
               i > run_class_dictionary.count
            loop
               rc := run_class_dictionary.item(i);
               if not rc.compile_to_c_done then
                  stop := false;
                  rc.compile_to_c(deep);
               end;
               i := i + 1;
            end;
            deep := deep - 1;
         end;
      end;

feature {NONE}

   tmp_tail: STRING is
      once
         !!Result.make(128);
      end;

feature {NONE}

   em1: STRING is " items).%N";

feature {NONE}

   append_loading_path_in(str: STRING) is
      do
         system_tools.append_lp_in(str,loading_path);
      end;

feature {NONE}

   c_code: STRING is
      once
         !!Result.make(128);
      end;

feature {NONE}

   registered_for_c_define: FIXED_ARRAY[RUN_FEATURE_3] is
      once
         !!Result.with_capacity(512);
      end;

   compile_registered_for_c_define is
      local
         i: INTEGER;
      do
         from
            i := registered_for_c_define.upper;
         until
            i < 0
         loop
            registered_for_c_define.item(i).c_define;
            i := i - 1;
         end;
      end;

feature {RUN_FEATURE_3}

   register_for_c_define(rf: RUN_FEATURE_3) is
      require
         rf /= Void
      do
         registered_for_c_define.add_last(rf);
      end;

feature {RUN_FEATURE_8}
   
   register_sys_runtime_basic_of(name: STRING) is
         -- Add some SmallEiffel/sys/runtime/basic_* package as 
         -- an already used one in order to customize the runtime.
      require
         name.has_prefix("basic_")
      local
         package: STRING;
      do
         from
            package := "basic_....................";
            package.copy(name);
         until
            package.nb_occurrences('_') = 1
         loop
            package.remove_last(1);
         end;
         if not basic_sys_runtime.has(package) then
            package := package.twin;
            basic_sys_runtime.add_last(package);
         end;
      end;

feature {CONVERSION_HANDLER}

   reference_to_expanded(source_type: TYPE) is
      require
         source_type.is_reference
      local
         i: INTEGER;
         rc: RUN_CLASS;
         type: TYPE;
      do
         from
            i := 1;
         until
            i > run_class_dictionary.count
         loop
            rc := run_class_dictionary.item(i);
            type := rc.current_type;
            if type.is_expanded then
               if type.is_a(source_type) then
                  type := type.actual_reference(source_type);
                  rc := type.run_class;
                  if not rc.at_run_time then
                     rc.set_at_run_time;
                     source_type.run_class.falling_down;
                  end;
               else
                  eh.cancel;
               end;
            end;
            i := i + 1;
         end;
      end;

feature {NONE}

   basic_sys_runtime: FIXED_ARRAY[STRING] is
         -- Actually used packages of SmallEiffel/sys/runtime.
         -- For example: basic_directory, basic_time, basic_*, etc.
      once
         !!Result.with_capacity(12);
      end;
   
   string_at_run_time: BOOLEAN is
      require
         is_ready
      local
         rc: RUN_CLASS;
      do
         if run_class_dictionary.has(as_string) then
            rc := run_class_dictionary.at(as_string);
            Result := rc.at_run_time;
         end;
      end;

   singleton_memory: SMALL_EIFFEL is
      once
         Result := Current;
      end;

invariant

   is_real_singleton: Current = singleton_memory

end -- SMALL_EIFFEL
