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
class GC_HANDLER
   --
   -- GARBAGE_COLLECTOR_HANDLER
   --

inherit GLOBALS;

creation make

feature

   is_off: BOOLEAN;
         -- True when the Garbage Collector is not produced.

   info_flag: BOOLEAN;
         -- True when Garbage Collector Information need to be printed.

feature {NONE}

   make is
      do
      end;

feature {COMPILE_TO_C}

   no_gc is
      do
         is_off := true;
         info_flag := false;
      ensure
         is_off;
         not info_flag
      end;

   set_info_flag is
      do
         is_off := false;
         info_flag := true;
      ensure
         not is_off;
         info_flag
      end;

feature {NONE}

   compute_ceils is
      local
         fsoc_count_ceil, rsoc_count_ceil, i: INTEGER;
         rcd: DICTIONARY[RUN_CLASS,STRING];
         rc: RUN_CLASS;
         kb_count: INTEGER;
      do
         rcd := small_eiffel.run_class_dictionary;
         from
            i := 1;
         until
            i > rcd.count
         loop
            rc := rcd.item(i);
            if rc.at_run_time then
               if rc.current_type.is_native_array then
                  rsoc_count_ceil := rsoc_count_ceil + 1;
               else
                  fsoc_count_ceil := fsoc_count_ceil + 1;
               end;
            end;
            i := i + 1;
         end;
         fsoc_count_ceil := 4 * fsoc_count_ceil;
         kb_count := fsoc_count_ceil * (fsoc_size // 1024);
         if kb_count < 256 then
            fsoc_count_ceil := 256 // (fsoc_size // 1024);
         end;
         rsoc_count_ceil := 3 * rsoc_count_ceil;
         kb_count := rsoc_count_ceil * (rsoc_size // 1024);
         if kb_count < 256 then
            rsoc_count_ceil := 256 // (rsoc_size // 1024);
         end;
         cpp.put_extern6("unsigned int fsoc_count_ceil",fsoc_count_ceil);
         cpp.put_extern6("unsigned int rsoc_count_ceil",rsoc_count_ceil);
      end;

feature {TYPE}

   memory_dispose(code: STRING; o: STRING; run_class: RUN_CLASS) is
         -- Append in `code' the extra C code for MEMORY.dispose if
         -- any.
      require
         not run_class.current_type.is_expanded;
         not run_class.current_type.is_native_array
      local
         rf3: RUN_FEATURE_3;
         no_check: BOOLEAN;
      do
         rf3 := run_class.get_memory_dispose;
         if rf3 /= Void then
            code.append("if((");
            code.append(o);
            code.append("->header.flag)==FSOH_UNMARKED){");
            no_check := run_control.no_check;
            if no_check then
               code.append(
               "%N{se_frame_descriptor gcd={%"Garbage Collector at work.\n%
                %dispose called (during sweep phase)%",0,0,%"%",1};%N%
                %se_dump_stack ds = {NULL,NULL,0,NULL,NULL};%N%
                %ds.fd=&gcd;%N%
                %ds.caller=se_dst;%N%
                %se_dst=&ds;/*link*/%N");
            end;
            code.extend('r');
            run_class.id.append_in(code);
            rf3.name.mapping_c_in(code);
            code.extend('(');
            if no_check then
               code.append("&ds,");
            end;
            if no_check or else rf3.use_current then
               code.extend('(');
               run_class.current_type.c_type_for_target_in(code);
               code.extend(')');
               code.append(o);
            end;
            code.append(fz_14);
            if no_check then
               code.append("se_dst=ds.caller;/*unlink*/%N}");
            end;
            code.extend('}');
         end;
      end;

feature {SMALL_EIFFEL}

   define1 is
      require
         not is_off
      do
         echo.put_string("Adding Garbage Collector.%N");
         cpp.macro_def("FSOC_SIZE",fsoc_size);
         cpp.macro_def("RSOC_SIZE",rsoc_size);
         cpp.sys_runtime_h(fz_gc_lib);
         compute_ceils;
         cpp.sys_runtime_c(fz_gc_lib);
         --
         cpp.swap_on_h;
         cpp.put_extern2("unsigned int gc_start_count",'0');
      end;

   define2 is
      require
         not is_off
      local
         i: INTEGER;
         rc: RUN_CLASS;
         rcd: DICTIONARY[RUN_CLASS,STRING];
         root_type: TYPE;
      do
         rcd := small_eiffel.run_class_dictionary;
         root_type := small_eiffel.root_procedure.current_type;
         manifest_string_pool.define_manifest_string_mark;
         body.clear;
         once_routine_pool.gc_mark_in(body);
         cpp.put_c_function("void once_function_mark(void)",body);
         system_tools.put_mark_stack_and_registers;
         define_gc_start(root_type,rcd);
         cpp.swap_on_h;
         from
            i := 1;
         until
            i > rcd.count
         loop
            rc := rcd.item(i);
            rc.gc_define1;
            i := i + 1;
         end;
         cpp.swap_on_c;
         from
            i := 1;
         until
            i > rcd.count
         loop
            rc := rcd.item(i);
            rc.gc_define2;
            i := i + 1;
         end;
         from
            i := run_class_list.upper;
         until
            i < 0
         loop
            switch_for(run_class_list.item(i));
            i := i - 1;
         end;
         if info_flag then
            define_gc_info(rcd);
         end;
      ensure
         small_eiffel.magic_count = old small_eiffel.magic_count
      end;

feature {RUN_CLASS}

   falling_down(run_class: RUN_CLASS) is
      local
         rf3: RUN_FEATURE_3;
      do
         if not is_off then
            rf3 := run_class.get_memory_dispose;
            if rf3 /= Void then
               dispose_flag := true;
            end;
         end;
      end;


feature {C_PRETTY_PRINTER}

   initialize_runtime is
      do
         if not is_off then
            cpp.put_string(
               "gcmt=((mch**)malloc((gcmt_max+1)*sizeof(void*)));%N%
               %stack_bottom=((void**)(&argc));%N");
         end;
      end;

feature {CREATION_CALL,C_PRETTY_PRINTER,TYPE_BIT_REF}

   allocation(rc: RUN_CLASS) is
         -- Basic allocation of in new temporary `n' local.
      require
         rc.at_run_time;
         rc.current_type.is_reference;
         cpp.on_c
      do
         body.clear;
         body.extend('T');
         rc.id.append_in(body);
         body.extend('*');
         cpp.put_string(body);
         allocation_of("n",rc);
      end;

feature {C_PRETTY_PRINTER,CONVERSION_HANDLER}

   allocation_of(var: STRING; rc: RUN_CLASS) is
         -- Basic allocation in C variable `var' of object of `rc'.
      require
         var /= Void;
         rc.at_run_time;
         rc.current_type.is_reference;
         cpp.on_c
      do
	 body.clear;
	 basic_allocation(var,body,rc);
         cpp.put_string(body);
      end;

feature {RUN_CLASS}

   basic_allocation(destination, c_code_buffer: STRING; rc: RUN_CLASS) is
         -- Basic allocation of a newly created object of class `rc'.
	 -- Only the default basic initialization is done. 
	 -- The generated C code added in the `c_code_buffer' assign the 
	 -- `destination' C variable wich is supposed to be declared with the 
	 -- correct C type for class `rc'.
      require
         destination /= Void;
         rc.at_run_time;
         rc.current_type.is_reference;
      local
         ct: TYPE;
         id: INTEGER;
      do
         ct := rc.current_type;
         id := rc.id;
         c_code_buffer.append(destination);
         c_code_buffer.extend('=');
         if is_off then
	    c_code_buffer.append("((T");
	    id.append_in(c_code_buffer);
            if ct.need_c_struct then
               c_code_buffer.append("*)malloc(sizeof(*");
               c_code_buffer.append(destination);
               c_code_buffer.append("))/*");
               rc.c_sizeof.append_in(c_code_buffer);
	       c_code_buffer.append("*/);%N*");
               c_code_buffer.append(destination);
               c_code_buffer.append("=M");
               id.append_in(c_code_buffer);
            else
               -- Object has no attributes :
               c_code_buffer.append("*)malloc(1))");
            end;
         elseif destination = fz_eiffel_root_object then
	    c_code_buffer.append("((T");
	    id.append_in(c_code_buffer);
            c_code_buffer.append(
               "*)malloc(sizeof(double)+sizeof(*eiffel_root_object)));%N%
	       %*eiffel_root_object=M");
            id.append_in(c_code_buffer);
         else
            c_code_buffer.append(fz_new);
            id.append_in(c_code_buffer);
            c_code_buffer.append(fz_c_no_args_function);
         end;
         c_code_buffer.append(fz_00);
      end;

feature {MANIFEST_STRING_POOL}

   new_manifest_string_in(c_code: STRING; string_at_run_time: BOOLEAN) is
      do
         if is_off or else not string_at_run_time then
            c_code.append("((T7*)malloc(sizeof(T7)));%N");
         else
            c_code.append("((T7*)malloc(sizeof(gc7)));%N%
                          %((gc7*)s)->header.flag=FSOH_MARKED;%N");
         end;
         if string_at_run_time and then type_string.run_class.is_tagged then
            c_code.append("s->id=7;%N");
         end;
      end;

   new_native9_in(c_code: STRING; string_at_run_time: BOOLEAN) is
      do
         if is_off or else not string_at_run_time then
            c_code.append(as_malloc);
         else
            c_code.append(fz_new);
            c_code.extend('9');
         end;
      end;

feature

   mark_for(c_code: STRING; entity: STRING; rc: RUN_CLASS) is
         -- Add `c_code' to mark `entity' of class `rc'.
      require
         not is_off;
         rc.current_type.need_gc_mark_function
      local
         ct: TYPE;
         r: ARRAY[RUN_CLASS];
      do
         r := rc.running;
         if r /= Void then
            ct := rc.current_type;
            if ct.is_reference or else ct.is_native_array then
               c_code.append("if(NULL!=");
               c_code.append(entity);
               c_code.extend(')');
            end;
            if r.count > 1 then
               cpp.incr_switch_count;
               if not run_class_list.fast_has(rc) then
                  run_class_list.add_last(rc);
               end;
               c_code.extend('X');
               ct.gc_mark_in(c_code);
            else
               cpp.incr_direct_call_count;
	       ct := r.first.current_type;
	       ct.gc_mark_in(c_code);
            end;
            c_code.extend('(');
	    if ct.is_reference then
	       c_code.extend('(');
	       if r.count > 1 then
		  c_code.append("T0*");
	       else
		  ct.c_type_for_target_in(c_code);
	       end;
	       c_code.extend(')');
	    elseif ct.is_user_expanded then
	       c_code.extend('&');
            end;
            c_code.extend('(');
            c_code.append(entity);
            c_code.append(fz_16);
         end;
      end;

feature {C_PRETTY_PRINTER}

   gc_info_before_exit is
      require
         cpp.on_c
      do
         if is_off then
         elseif info_flag then
            cpp.put_string(
            "fprintf(SE_GCINFO,%"==== Last GC before exit ====\n%");%N%
	    %gc_start();%N");
         end;
         if not is_off and then dispose_flag then
            cpp.put_string("gc_dispose_before_exit();%N");
         end;
      end;

feature {NONE}

   run_class_list: FIXED_ARRAY[RUN_CLASS] is
      once
         !!Result.with_capacity(32);
      end;

   switch_for(rc: RUN_CLASS) is
      local
         ct: TYPE;
         r: ARRAY[RUN_CLASS];
      do
         header.clear;
         header.append(fz_void);
         header.extend(' ');
         header.extend('X');
         ct := rc.current_type;
         ct.gc_mark_in(header);
         header.extend('(');
         header.append(fz_t0_star);
         header.extend('o');
         header.extend(')');
         body.clear;
         r := rc.running;
         sort_running(r);
         body.append("{int i=o->id;%N");
         c_dicho(r,1,r.upper);
         body.extend('}');
         cpp.put_c_function(header,body);
      end;

   c_dicho(r: ARRAY[RUN_CLASS]; bi, bs: INTEGER) is
         -- Produce dichotomic inspection code for Current id.
      require
         bi <= bs
      local
         m: INTEGER;
         rc: RUN_CLASS;
      do
         if bi = bs then
            rc := r.item(bi);
            rc.current_type.gc_mark_in(body);
            body.extend('(');
            body.extend('(');
            body.extend('T');
            rc.id.append_in(body);
            body.extend('*');
            body.extend(')');
            body.extend('o');
            body.extend(')');
            body.append(fz_00);
         else
            m := (bi + bs) // 2;
            rc := r.item(m);
            body.append("if (i <= ");
            rc.id.append_in(body);
            body.append(") {%N");
            c_dicho(r,bi,m);
            body.append("} else {%N");
            c_dicho(r,m + 1,bs);
            body.extend('}');
         end;
      end;

  just_before_mark(rcd: DICTIONARY[RUN_CLASS,STRING]) is
      require
         not is_off
      local
         i: INTEGER;
         rc: RUN_CLASS;
      do
         from
            i := 1;
         until
            i > rcd.count
         loop
            rc := rcd.item(i);
            rc.just_before_gc_mark_in(body);
            i := i + 1;
         end;
      end;

   define_gc_info(rcd: DICTIONARY[RUN_CLASS,STRING]) is
      require
         info_flag
      local
         i: INTEGER;
         rc: RUN_CLASS;
      do
         header.clear;
         header.append(fz_void);
         header.extend(' ');
         header.append(fz_gc_info);
         header.append(fz_c_void_args);
         body.clear;
         body.append("fprintf(SE_GCINFO,%"--------------------\n%");%N");
         from
            i := 1;
         until
            i > rcd.count
         loop
            rc := rcd.item(i);
            rc.gc_info_in(body);
            i := i + 1;
         end;
         body.append(
           "fprintf(SE_GCINFO,%"Stack size = %%d\n%",gc_stack_size());%N%
           %fprintf(SE_GCINFO,%"GC Main Table:\n%");%N%
           %fprintf(SE_GCINFO,%" gcmt_used = %%d\n%",gcmt_used);%N%
           %fprintf(SE_GCINFO,%" gcmt_max = %%d\n%",gcmt_max);%N%
           %fprintf(SE_GCINFO,%"Fixed Size Chunk(s):\n%");%N%
           %fprintf(SE_GCINFO,%" fsocfl = %%d\n%",fsocfl_count());%N%
           %fprintf(SE_GCINFO,%" fsoc_count = %%d\n%",fsoc_count);%N%
           %fprintf(SE_GCINFO,%" fsoc_count_ceil = %%d\n%",fsoc_count_ceil);%N%
           %fprintf(SE_GCINFO,%"Native Array(s):\n%");%N%
           %fprintf(SE_GCINFO,%" rsoc_count = %%d\n%",rsoc_count);%N%
           %fprintf(SE_GCINFO,%" rsoc_count_ceil = %%d\n%",rsoc_count_ceil);%N%
           %rsocfl_info();%N%
           %fprintf(SE_GCINFO,%"GC called %%d time(s)\n%",gc_start_count);%N%
           %fprintf(SE_GCINFO,%"--------------------\n%");%N");
         cpp.put_c_function(header,body);
      end;

   define_gc_start(root_type: TYPE; rcd: DICTIONARY[RUN_CLASS,STRING]) is
      do
         body.clear;
         body.append("if(gc_is_off)return;%N%
                   %if(garbage_delayed())return;%N");
         if info_flag then
            body.append("fprintf(SE_GCINFO,%"==== Before  GC ====\n%");%N%
                        %gc_info();%N");
         end
         body.append(
            "gcmt_tail_addr=(((char*)(gcmt[gcmt_used-1]))+%
            %(gcmt[gcmt_used-1])->size);%N%
            %((gc");
         root_type.id.append_in(body);
         body.append("*)eiffel_root_object)->header.flag=FSOH_UNMARKED;%N");
         just_before_mark(rcd);
         body.append(fz_gc_mark);
         root_type.id.append_in(body);
         body.append("(eiffel_root_object);%N%
                     %manifest_string_mark1();%N%
                     %once_function_mark();%N");
         if run_control.generator_used then
            body.append("{int i=SE_MAXID-1;%N%
                        %while(i>=0){%N%
                        %if(g[i]!=NULL)gc_mark9((g[i])->_storage);%N%
                        %i--;}%N}%N");
         end;
         if run_control.generating_type_used then
            body.append("{int i=SE_MAXID-1;%N%
                        %while(i>=0){%N%
                        %if(t[i]!=NULL)gc_mark9((t[i])->_storage);%N%
                        %i--;}%N}%N");
         end;
         body.append("mark_stack_and_registers();%N%
                     %gc_sweep();%N%
                     %gc_start_count++;%N");
         if info_flag then
            body.append("gc_info();");
         end
         cpp.put_c_function("void gc_start(void)",body);
      end;

   header: STRING is
      once
         !!Result.make(64);
      end;

   body: STRING is
      once
         !!Result.make(512);
      end

   fsoc_size: INTEGER is 8192; -- Fixed Size Objects Chunks Size.

   rsoc_size: INTEGER is 32768; -- ReSizable Objects Chunks Size.

   dispose_flag: BOOLEAN;

invariant

   info_flag implies not is_off

end -- GC_HANDLER

