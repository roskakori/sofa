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
class MANIFEST_ARRAY
   --
   -- Like :  << foo , bar >>
   --

inherit EXPRESSION;

creation make

feature

   start_position: POSITION;
         -- Of first character '<'.

   list: ARRAY[EXPRESSION];
         -- Void or elements in the array.

   result_type: TYPE_ARRAY;
         -- Computed according to the actual `list'.

   is_manifest_array: BOOLEAN is true;

   is_current: BOOLEAN is false;

   is_writable: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   is_result: BOOLEAN is false;

   is_void: BOOLEAN is false;

   is_static: BOOLEAN is false;

   precedence: INTEGER is 2;

   can_be_dropped: BOOLEAN is false;

   c_simple: BOOLEAN is false;

   isa_dca_inline_argument: INTEGER is 0;

   static_result_base_class: BASE_CLASS is
      do
         Result := small_eiffel.get_class(as_array);
      end;

   static_value: INTEGER is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   is_pre_computable: BOOLEAN is
      local
         i: INTEGER;
         e: EXPRESSION;
      do
         if list = Void then
            Result := true;
         elseif result_type.generic_list.item(1).is_string then
            from
               Result := true;
               i := list.upper;
            until
               not Result or else i = 0
            loop
               e := list.item(i);
               Result := e.is_pre_computable;
               i := i - 1;
            end;
         end;
      end;

   assertion_check(tag: CHARACTER) is
      local
         i: INTEGER;
         e: EXPRESSION;
      do
         if list /= Void then
            from
               i := list.upper;
            until
               i = 0
            loop
               e := list.item(i);
               e.assertion_check(tag);
               i := i - 1;
            end;
         end;
      end;

   afd_check is
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := list.upper;
            until
               i = 0
            loop
               list.item(i).afd_check;
               i := i - 1;
            end;
         end;
      end;

   frozen mapping_c_target(target_type: TYPE) is
      do
         cpp.put_string(fz_b7);
         cpp.put_integer(target_type.id);
         cpp.put_string(fz_b8);
         compile_to_c;
         cpp.put_character(')');
      end;

   frozen mapping_c_arg(formal_arg_type: TYPE) is
      do
         compile_to_c;
      end;

   collect_c_tmp is
      do
      end;

   compile_to_c is
      local
         i: INTEGER;
         formal_type, actual_type: TYPE;
         adr: BOOLEAN;
         e: EXPRESSION;
      do
         manifest_array_pool.c_call(result_type);
         formal_type := result_type.generic_list.item(1).run_type;
         cpp.put_character('(');
         if list = Void then
            cpp.put_character('0');
         else
            adr := formal_type.is_user_expanded;
            cpp.put_integer(list.upper);
            from
               i := 1;
            until
               i > list.upper
            loop
               cpp.put_string(fz_b9);
               if adr then
                  cpp.put_character('&');
               end;
               e := list.item(i);
               actual_type := e.result_type.run_type;
               e.compile_to_c;
               i := i + 1;
            end;
         end;
         cpp.put_character(')');
      end;

   c_declare_for_old is
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := list.upper;
            until
               i = 0
            loop
               list.item(i).c_declare_for_old;
               i := i - 1;
            end;
         end;
      end;

   compile_to_c_old is
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := list.upper;
            until
               i = 0
            loop
               list.item(i).compile_to_c_old;
               i := i - 1;
            end;
         end;
      end;

   compile_to_jvm_old is
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := list.upper;
            until
               i = 0
            loop
               list.item(i).compile_to_jvm_old;
               i := i - 1;
            end;
         end;
      end;

   compile_target_to_jvm, compile_to_jvm is
      local
         rt, elt_type: TYPE;
         i, idx, space: INTEGER;
         rc: RUN_CLASS;
         idx_rc: INTEGER;
         cp: like constant_pool;
         ca: like code_attribute;
      do
         cp := constant_pool;
         ca := code_attribute;
         rt := result_type.run_type;
         rc := rt.run_class;
         elt_type := rt.generic_list.item(1).run_type;
         idx_rc := rc.jvm_constant_pool_index;
         rc.jvm_basic_new;
         -- Set lower :
         idx := cp.idx_fieldref4(idx_rc,as_lower,fz_i);
         ca.opcode_dup;
         ca.opcode_iconst_1;
         ca.opcode_putfield(idx,-2);
         -- Set upper :
         idx := cp.idx_fieldref4(idx_rc,as_upper,fz_i);
         ca.opcode_dup;
         if list = Void then
            ca.opcode_iconst_0;
         else
            ca.opcode_push_integer(list.count);
         end;
         ca.opcode_putfield(idx,-2);
         -- Set capacity :
         idx := cp.idx_fieldref4(idx_rc,as_capacity,fz_i);
         ca.opcode_dup;
         if list = Void then
            ca.opcode_iconst_0;
         else
            ca.opcode_push_integer(list.count);
         end;
         ca.opcode_putfield(idx,-2);
         -- Set storage :
         idx := cp.idx_fieldref4(idx_rc,as_storage,sd(elt_type));
         ca.opcode_dup;
         if list = Void then
            ca.opcode_aconst_null;
         else
            ca.opcode_push_integer(list.count);
            elt_type.jvm_xnewarray;
            from
               i := 1;
            until
               i > list.upper
            loop
               ca.opcode_dup;
               ca.opcode_push_integer(i - 1);
               space := list.item(i).compile_to_jvm_into(elt_type);
               elt_type.jvm_xastore;
               i := i + 1;
            end;
         end;
         ca.opcode_putfield(idx,-2);
      end;

   jvm_branch_if_false: INTEGER is
      do
      end;

   jvm_branch_if_true: INTEGER is
      do
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := 1;
         compile_to_jvm;
      end;

   use_current: BOOLEAN is
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := list.upper;
            until
               i = 0 or else Result
            loop
               Result := list.item(i).use_current;
               i := i - 1;
            end;
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      local
         i: INTEGER;
      do
         Result := true;
         if list /= Void then
            from
               i := list.upper;
            until
               not Result or else i = 0
            loop
               Result := list.item(i).stupid_switch(r);
               i := i - 1;
            end;
         end;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         i: INTEGER;
         e: EXPRESSION;
         elt: TYPE;
      do
         if current_type = Void then
            current_type := ct;
            if list = Void then
               elt := type_any;
            else
               from
                  i := list.upper;
               until
                  i = 0
               loop
                  e := list.item(i).to_runnable(ct);
                  if e = Void then
                     eh.add_position(start_position);
                     error(list.item(i).start_position,
                           "Bad expression in manifest array.");
                     i := 0;
                  else
                     list.put(e,i);
                     if elt = Void then
                        elt := e.result_type;
                     else
                        elt := elt.smallest_ancestor(e.result_type);
                     end;
                     i := i - 1;
                  end;
               end;
            end;
            if nb_errors = 0 then
               elt := elt.run_type;
               !!result_type.make(start_position,elt);
               result_type.run_class.set_at_run_time;
               result_type.load_basic_features;
               Result := Current;
               if list /= Void then
                  from
                     i := list.upper;
                  until
                     i = 0
                  loop
                     e := list.item(i);
                     e := conversion_handler.implicit_cast(e,elt);
                     list.put(e,i);
                     i := i - 1;
                  end;
               end;
               manifest_array_pool.register(result_type);
            end;
         elseif list = Void then
            Result := Current;
         else
            !!Result.make(start_position,list.twin);
            Result := Result.to_runnable(ct);
         end;
      end;

   bracketed_pretty_print is
      do
         fmt.put_character('(');
         pretty_print;
         fmt.put_character(')');
      end;

   pretty_print is
      local
         i: INTEGER;
      do
         fmt.put_string(fz_c_shift_left);
         fmt.level_incr;
         if list /= Void then
            from
               i := 1;
            until
               i > list.upper
            loop
               list.item(i).pretty_print;
               i := i + 1;
               if i <= list.upper then
                  fmt.put_character(',');
               end;
            end;
         end;
         fmt.put_string(fz_c_shift_right);
         fmt.level_decr;
      end;

   print_as_target is
      do
         fmt.put_character('(');
         pretty_print;
         fmt.put_character(')');
         fmt.put_character('.');
      end;

   short is
      local
         i: INTEGER;
      do
         short_print.hook_or("op_ma",fz_c_shift_left);
         if list /= Void then
            from
               i := 1;
            until
               i > list.upper
            loop
               list.item(i).short;
               i := i + 1;
               if i <= list.upper then
                  short_print.hook_or("ma_sep",",");
               end;
            end;
         end;
         short_print.hook_or("cl_ma",fz_c_shift_right);
      end;

   short_target is
      do
         bracketed_short;
         short_print.a_dot;
      end;

   jvm_assign is
      do
      end;

feature {NONE}

   current_type: TYPE;

   make(sp: like start_position; l: like list) is
      require
         not sp.is_unknown;
         l /= Void implies not l.is_empty and l.lower =1;
      do
         start_position := sp;
         list := l;
      ensure
         start_position = sp;
         list = l;
      end;

   sd(elt_type: TYPE): STRING is
         -- The JVM descriptor for `storage'.
      do
         tmp_string.clear;
         tmp_string.extend('[');
         elt_type.jvm_descriptor_in(tmp_string);
         Result := tmp_string;
      end;

   tmp_string: STRING is
      once
         !!Result.make(16);
      end;

invariant

   not start_position.is_unknown;

   list /= Void implies not list.is_empty and list.lower = 1;

end -- MANIFEST_ARRAY

