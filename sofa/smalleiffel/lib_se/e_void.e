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
class E_VOID
   --
   -- Handling of the Eiffel `Void'.
   --

inherit EXPRESSION;

creation make

feature

   start_position: POSITION;

   is_void: BOOLEAN is true;

   is_writable: BOOLEAN is false;

   is_current: BOOLEAN is false;

   is_result: BOOLEAN is false;

   is_static: BOOLEAN is true;

   static_value: INTEGER is 0;

   to_integer_or_error: INTEGER is 0;

   is_pre_computable: BOOLEAN is true;

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   can_be_dropped: BOOLEAN is true;

   use_current: BOOLEAN is false;

   isa_dca_inline_argument: INTEGER is -1;

   c_simple: BOOLEAN is true;

   static_result_base_class: BASE_CLASS is
      do
      end;

   bracketed_pretty_print, pretty_print is
      do
         fmt.put_string(as_void);
      end;

   to_string, to_key: STRING is
      do
         Result := as_void;
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
         mapping_c_arg(formal_arg_type);
      end;

   assertion_check(tag: CHARACTER) is
      do
      end;

   afd_check is
      do
      end;

   mapping_c_target(target_type: TYPE) is
      do
      end;

   mapping_c_arg(formal_arg_type: TYPE) is
      do
         compile_to_c;
      end;

   short is
      do
         short_print.hook_or(as_void,as_void);
      end;

   short_target is
      do
         short;
         short_print.a_dot;
      end;

   collect_c_tmp is
      do
      end;

   compile_to_c is
      do
         cpp.put_string(fz_null);
      end;

   c_declare_for_old is
      do
      end;

   compile_to_c_old is
      do
      end;

   compile_to_jvm_old is
      do
      end;

   compile_target_to_jvm, compile_to_jvm is
      do
         code_attribute.opcode_aconst_null;
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

   result_type: TYPE_NONE is
      local
         unknown_position: POSITION;
      once
         !!Result.make(unknown_position);
      end;

   to_runnable(ct: TYPE): like Current is
      do
         Result := Current;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := true;
      end;

   print_as_target is
      do
      end;

   precedence: INTEGER is
      do
         Result := atomic_precedence;
      end;

   jvm_assign is
      do
      end;

feature {NONE}

   make(sp: like start_position) is
      require
         not sp.is_unknown
      do
         start_position := sp;
      ensure
         sp = start_position
      end;

end -- E_VOID

