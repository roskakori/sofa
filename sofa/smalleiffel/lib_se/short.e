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
class SHORT
   --
   -- The `short' command.
   --

inherit COMMAND_FLAGS;

creation make

feature {NONE}

   command_name: STRING is "short";

   format: STRING;

   parents: FIXED_ARRAY[BASE_CLASS] is
         -- From `run_control..root_class' up to ANY included.
      once
         !!Result.with_capacity(4);
      end;

   run_class: RUN_CLASS;

   rf_list: FIXED_ARRAY[RUN_FEATURE] is
      once
         !!Result.with_capacity(256);
      end;

   sort: BOOLEAN;

   short: BOOLEAN;

   make is
      local
         bc: BASE_CLASS;
         i: INTEGER;
         ccl: CREATION_CLAUSE_LIST;
      do
         small_eiffel.set_short_flag;
         if argument_count = 0 then
            fatal_bad_usage
         else
            automat;
            if run_control.root_class = Void then
               fatal_bad_usage
            end;
            bc := small_eiffel.load_class(run_control.root_class);
            parents.add_last(bc);
            if not short then
               bc.up_to_any_in(parents);
            end;
            if format = Void then
               format := "plain";
            end;
            -- Prepare data :
            compute_run_class(bc);
            run_class.runnable_class_invariant;
            -- Print the class interface :
            short_print.start(format,bc,run_class);
            ccl := bc.creation_clause_list;
            if ccl = Void or else not ccl.short then
               short_print.hook("hook102");
            end;
            compute_rf_list;
            if sort then
               short_print.hook_or("hook200","feature(s)%N");
               sort_rf_list;
               from
                  i := 0;
               until
                  i > rf_list.upper
               loop
                  short_print.a_run_feature(rf_list.item(i));
                  i := i + 1;
               end;
               short_print.hook("hook201");
            end;
            short_print.finish;
         end;
      end;

   automat is
      local
         arg: INTEGER;
         a: STRING;
      do
         from
            arg := 1;
         until
            arg > argument_count
         loop
            a := argument(arg);
            if ("-sort").is_equal(a) then
               sort := true;
            elseif ("-short").is_equal(a) then
               short := true;
            elseif is_flag_case_insensitive(a) then
            elseif is_flag_no_style_warning(a) then
            elseif is_flag_no_warning(a) then
            elseif is_flag_version(a) then
            elseif a.item(1) = '-' then
               a.remove_first(1);
               format := a;
            else
               if a.has_suffix(eiffel_suffix) then
                  a.remove_suffix(eiffel_suffix);
               end;
               if as_bit_n_ref.same_as(a) then
                  a := as_bit_n;
               end;
               run_control.compute_root_class(a);
            end;
            arg := arg + 1;
         end;
      end;

   compute_run_class(bc: BASE_CLASS) is
      local
         fgl: FORMAL_GENERIC_LIST;
         bcn: STRING;
         sp: POSITION;
         t, ct: TYPE;
         gl: ARRAY[TYPE];
         i: INTEGER;
         fga: FORMAL_GENERIC_ARG;
      do
         bcn := bc.name.to_string;
         sp := bc.name.start_position;
         fgl := bc.formal_generic_list;
         if as_any = bcn then
            !TYPE_ANY!ct.make(sp);
         elseif as_native_array = bcn then
            !TYPE_CHARACTER!t.make(sp);
            !TYPE_NATIVE_ARRAY!ct.make(sp,t);
         elseif as_array = bcn then
            !TYPE_ANY!t.make(sp);
            !TYPE_ARRAY!ct.make(sp,t);
         elseif as_integer = bcn then
            !TYPE_INTEGER!ct.make(sp);
         elseif as_real = bcn then
            !TYPE_REAL!ct.make(sp);
         elseif as_double = bcn then
            !TYPE_DOUBLE!ct.make(sp);
         elseif as_character = bcn then
            !TYPE_CHARACTER!ct.make(sp);
         elseif as_boolean = bcn then
            !TYPE_BOOLEAN!ct.make(sp);
         elseif as_pointer = bcn then
            !TYPE_POINTER!ct.make(sp);
         elseif as_string = bcn then
            !TYPE_STRING!ct.make(sp);
         elseif fgl /= Void then
            from
               i := 1;
               !!gl.with_capacity(fgl.count,1);
            until
               i > fgl.count
            loop
               fga := fgl.item(i);
               if fga.constraint = Void then
                  !TYPE_ANY!t.make(sp);
               else
                  t := fga.constraint;
               end;
               gl.add_last(t);
               i := i + 1;
            end;
            !TYPE_GENERIC!ct.make(bc.name,gl);
         else
            !TYPE_CLASS!ct.make(bc.name);
         end;
         run_class := ct.run_class;
      end;

   compute_rf_list is
      local
         i: INTEGER;
         bc: BASE_CLASS;
         rc: RUN_CLASS;
         fcl: FEATURE_CLAUSE_LIST;
      do
         from
            i := parents.upper;
            rc := run_class;
         until
            i < 0
         loop
            bc := parents.item(i);
            fcl := bc.feature_clause_list;
            if fcl /= Void then
               fcl.for_short(bc.name,sort,rf_list,rc);
            end;
            i := i - 1;
         end;
      end;

   sort_rf_list is
      local
         min, max, buble: INTEGER;
         moved: BOOLEAN;
      do
         from
            max := rf_list.upper;
            min := 0;
            moved := true;
         until
            not moved
         loop
            moved := false;
            if max - min > 0 then
               from
                  buble := min + 1;
               until
                  buble > max
               loop
                  if gt(buble - 1,buble) then
                     rf_list.swap(buble - 1,buble);
                     moved := true;
                  end;
                  buble := buble + 1;
               end;
               max := max - 1;
            end;
            if moved and then max - min > 0 then
               from
                  moved := false;
                  buble := max - 1;
               until
                  buble < min
               loop
                  if gt(buble,buble + 1) then
                     rf_list.swap(buble,buble + 1);
                     moved := true;
                  end;
                  buble := buble - 1;
               end;
               min := min + 1;
            end;
         end;
      end;

   gt(i,j: INTEGER): BOOLEAN is
      local
         n1, n2: STRING;
      do
         n1 := rf_list.item(i).name.to_key;
         n2 := rf_list.item(j).name.to_key;
         Result :=  n1 > n2;
      end;

   fatal_bad_usage is
      do
         system_tools.bad_use_exit(command_name);
      end;

end -- SHORT -- The command.

