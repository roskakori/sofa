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
class E_OLD
   --
   -- To store instruction "old ..." usable in an ensure clause.
   --

inherit EXPRESSION;

creation make

feature

   expression: EXPRESSION;

   is_current: BOOLEAN is false;

   is_writable: BOOLEAN is false;

   is_static: BOOLEAN is false;

   is_pre_computable: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   is_result: BOOLEAN is false;

   is_void: BOOLEAN is false;

   can_be_dropped: BOOLEAN is false;

   c_simple: BOOLEAN is false;

   isa_dca_inline_argument: INTEGER is 0;

   static_result_base_class: BASE_CLASS is
      do
         Result := expression.static_result_base_class;
      end;

   static_value: INTEGER is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   result_type: TYPE is
      do
         Result := expression.result_type;
      end;

   assertion_check(tag: CHARACTER) is
      do
         if vaol_check_memory.item = Void then
            vaol_check_memory.set_item(Current);
         else
            eh.add_position(vaol_check_memory.item.start_position);
            eh.append("Must not use old inside some old %
                       %expression (VAOL.2).");
            eh.print_as_fatal_error;
         end;
         expression.assertion_check(tag);
         vaol_check_memory.clear;
      end;

   afd_check is
      do
         expression.afd_check;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         exp: like expression;
      do
         if current_type = Void then
            current_type := ct;
            exp := expression.to_runnable(ct);
            if exp = Void then
               error(start_position,"Bad old expression.");
            else
               expression := exp;
            end;
            Result := Current;
         else
            !!Result.make(expression);
            Result := Result.to_runnable(ct);
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := true;
      end;

   start_position: POSITION is
      do
         Result := expression.start_position;
      end;

   pretty_print is
      do
         fmt.put_string("old ");
         fmt.level_incr;
         expression.pretty_print;
         fmt.level_decr;
      end;

   print_as_target is
      do
         fmt.put_character('(');
         pretty_print;
         fmt.put_character(')');
         fmt.put_character('.');
      end;

   bracketed_pretty_print is
      do
         fmt.put_character('(');
         pretty_print;
         fmt.put_character(')');
      end;

   short is
      do
         short_print.hook_or("old","old ");
         expression.short;
      end;

   short_target is
      do
         bracketed_short;
         short_print.a_dot;
      end;

   precedence: INTEGER is
      do
         Result := 11;
      end;

   mapping_c_target(target_type: TYPE) is
      do
         compile_to_c;
      end;

   mapping_c_arg(formal_arg_type: TYPE) is
      do
         compile_to_c;
      end;

   c_declare_for_old is
      local
         t: TYPE;
         name: STRING;
         p: POSITION;
      do
         name := local_c_name;
         t := result_type.run_type;
         tmp_string.clear;
         t.c_type_for_argument_in(tmp_string);
         tmp_string.extend(' ');
         tmp_string.append(name);
         tmp_string.extend('=');
         t.c_initialize_in(tmp_string);
         tmp_string.append(fz_00);
         cpp.put_string(tmp_string);
         if run_control.no_check then
            c_frame_descriptor_locals.append("(void**)&");
            c_frame_descriptor_locals.append(name);
            c_frame_descriptor_locals.extend(',');
            c_frame_descriptor_local_count.increment;
            p := start_position;
            c_frame_descriptor_format.append("old l");
            p.line.append_in(c_frame_descriptor_format);
            c_frame_descriptor_format.extend('c');
            p.column.append_in(c_frame_descriptor_format);
            c_frame_descriptor_format.append(p.base_class_name.to_string);
            t.c_frame_descriptor;
         end;
      end;

   compile_to_c_old is
      local
         t: TYPE;
      do
         t := result_type.run_type;
         tmp_string.copy(local_c_name);
         tmp_string.extend('=');
         cpp.put_string(tmp_string);
         expression.mapping_c_arg(t);
         cpp.put_string(fz_00);
      end;

   collect_c_tmp is
      do
      end;

   compile_to_c is
      do
         cpp.put_string(local_c_name);
      end;

   compile_to_jvm_old is
      local
         e: like expression;
         rt: TYPE;
      do
         e := expression;
         rt := e.result_type.run_type;
         id := code_attribute.extra_local(rt);
         e.compile_to_jvm;
         rt.jvm_write_local(id);
      end;

   compile_to_jvm is
      do
         expression.result_type.jvm_push_local(id);
      end;

   compile_target_to_jvm is
      do
         standard_compile_target_to_jvm;
      end;

   jvm_branch_if_false: INTEGER is
      do
         Result := jvm_standard_branch_if_false;
      end;

   jvm_branch_if_true: INTEGER is
      do
         Result := jvm_standard_branch_if_true;
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := standard_compile_to_jvm_into(dest);
      end;

   jvm_assign is
      do
      end;

   use_current: BOOLEAN is
      do
         Result := expression.use_current;
      end;

feature {NONE}

   current_type: TYPE;

   local_c_name_memory: STRING;
         -- The C name for the local variable.

   id: INTEGER;
         -- Used in Java byte code to gives a number to the
         -- the extra local variable.

   make(exp: like expression) is
      require
         exp /= Void
      do
         expression := exp;
      ensure
         expression = exp;
      end;

   local_c_name: STRING is
      do
         if local_c_name_memory = Void then
            tmp_string.clear;
            tmp_string.extend('o');
            start_position.base_class.id.append_in(tmp_string);
            tmp_string.extend('_');
            start_position.line.append_in(tmp_string);
            tmp_string.extend('_');
            start_position.column.append_in(tmp_string);
            local_c_name_memory := tmp_string.twin;
         end;
         Result := local_c_name_memory;
      end;

   tmp_string: STRING is
      once
         !!Result.make(12);
      end;

   vaol_check_memory: MEMO[E_OLD] is
      once
         !!Result;
      end;

invariant

   expression /= Void;

end -- E_OLD

