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
class CECIL_POOL
   --
   -- Unique global object in charge of CECIL calls.
   --

inherit GLOBALS;

feature {COMMAND_FLAGS}

   add_file(path: STRING) is
	 -- Add `path' as a new -cecil file to be considered.
      require
	 path /= Void
      local
	 cecil_file: CECIL_FILE;
      do
	 !!cecil_file.make(path);
	 if cecil_files = Void then
	    !!cecil_files.with_capacity(4);
	 end;
	 cecil_files.add_last(cecil_file);
      end;
   
feature {SMALL_EIFFEL}
   
   fill_up is
      local
	 i: INTEGER;
      do
	 if cecil_files /= Void then
	    from
	       i := cecil_files.upper;
	    until
	       i < cecil_files.lower
	    loop
	       cecil_files.item(i).parse;
	       i := i - 1;
	    end;
	 end;
      end;

   afd_check is
      local
	 i: INTEGER;
      do
	 if cecil_files /= Void then
	    from
	       i := cecil_files.upper;
	    until
	       i < cecil_files.lower
	    loop
	       cecil_files.item(i).afd_check;
	       i := i - 1;
	    end;
	 end;
      end;

feature {C_PRETTY_PRINTER}

   c_define_users is
      local
	 i: INTEGER;
      do
	 if cecil_files /= Void then
	    from
	       i := cecil_files.upper;
	    until
	       i < cecil_files.lower
	    loop
	       cecil_files.item(i).c_define_users;
	       i := i - 1;
	    end;
	 end;
      end;

feature {RUN_FEATURE}

   define_body_of(rf: RUN_FEATURE) is
      local
         rfct, rfrt: TYPE;
         cecil_target: CECIL_TARGET;
         cecil_arg_list: CECIL_ARG_LIST;
         running: ARRAY[RUN_CLASS];
      do
         rfct := rf.current_type;
         rfrt := rf.result_type;
         running := rfct.run_class.running;
         if running = Void then
            eh.add_type(rfct," not created (type is not alive).");
            eh.append(" Empty Cecil/Wrapper function ");
            eh.append(rfct.run_time_mark);
            eh.append(rf.name.to_key);
            eh.extend('.');
            eh.print_as_warning;
         else
            if run_control.no_check then
               cpp.put_string(
               "se_dump_stack ds={NULL,NULL,0,NULL,NULL};%N%
               %ds.caller=se_dst;%N%
               %se_dst=&ds;%N");
            end;
            if rfrt /= Void then
               buffer.clear;
               buffer.extend('{');
               rfrt.c_type_for_external_in(buffer);
               buffer.append(" R=");
               cpp.put_string(buffer);
            end;
            !!cecil_target.make(rf);
            if rf.arguments /= Void then
               !!cecil_arg_list.run_feature(rf);
            end;
            if rfct.is_expanded then
               cpp.push_direct(rf,cecil_target,cecil_arg_list);
               rf.mapping_c;
               cpp.pop;
            else
               cpp.push_cpc(rf,running,cecil_target,cecil_arg_list);
            end;
            if rfrt /= Void then
               cpp.put_string(fz_00);
            end;
            if run_control.no_check then
               cpp.put_string("se_dst=ds.caller;%N");
            end;
            if rfrt /= Void then
               cpp.put_string("return R;%N}%N");
            end;
         end;
         cpp.put_string(fz_12);
      end;

feature {CECIL_FILE}

   echo_for(rf: RUN_FEATURE) is
      do
	 if echo.verbose then
	    echo.put_character('%T');
	    echo.put_string(rf.current_type.run_time_mark);
	    echo.put_character('.');
	    echo.put_string(rf.name.to_string);
	    echo.put_character('%N');
	 end;
      end;

   c_define_for(c_name: STRING; rf: RUN_FEATURE) is
      require
         not c_name.is_empty;
         rf /= Void
      local
         rfct, rfrt: TYPE;
         rfargs: FORMAL_ARG_LIST;
      do
         rfct := rf.current_type;
         rfrt := rf.result_type;
         rfargs := rf.arguments;
	 echo_for(rf);
         -- (1) ------------------------- Define Cecil heading :
         buffer.clear;
         if rfrt /= Void then
            rfrt.c_type_for_external_in(buffer);
         else
            buffer.append(fz_void);
         end;
         buffer.extend(' ');
         buffer.append(c_name);
         buffer.extend('(');
         rfct.c_type_for_external_in(buffer);
         buffer.extend(' ');
         buffer.extend('C');
         if rfargs /= Void then
            buffer.extend(',');
            rfargs.external_prototype_in(buffer);
         end;
         buffer.extend(')');
         cpp.put_c_heading(buffer);
         cpp.swap_on_c;
         define_body_of(rf);
      end;

feature {NONE}

   cecil_files: FIXED_ARRAY[CECIL_FILE];
	 -- Non Void if some -cecil option is used.

   buffer: STRING is
	 -- To prepare C code.
      once
         !!Result.make(256);
      end;

   singleton_memory: CECIL_POOL is
      once
	 Result := Current;
      end;

invariant

   is_real_singleton: Current = singleton_memory

end -- CECIL_POOL

