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
class IMPLICIT_CAST
   --
   -- To memorize an implicit legal cast from one type to another. 
   -- This invisible expression is used for all kinds of implicit 
   -- conversions :
   --   from INTEGER to REAL
   --   from INTEGER to DOUBLE,
   --   from REAL to DOUBLE,
   --   from INTEGER to INTEGER_REF,
   --   ...
   --   from some expanded type to some comaptible reference type
   --   or conversely.
   --

inherit EXPRESSION;

creation {CONVERSION_HANDLER} make

feature {NONE}

   expression : EXPRESSION;
         -- The wrapped `expression' with it's `source_type'.

   source_type, destination_type: TYPE;

   make(e: like expression; dt: like destination_type) is
      require
         e.result_type.run_time_mark /= dt.run_time_mark
      do
         expression := e;
         source_type := e.result_type;
         destination_type := dt;
         conversion_handler.notify(expression,source_type,destination_type);
      ensure
         expression = e;
         source_type = e.result_type;
         destination_type = dt
      end;

feature

   is_manifest_array: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   to_integer_or_error: INTEGER is
      do
	 to_integer_error;
      end;

   result_type: TYPE is
      do
         Result := destination_type;
      end;

   is_void: BOOLEAN is
      do 
         Result := expression.is_void;
      end;

   static_result_base_class: BASE_CLASS is
      do
         Result := result_type.base_class;
      end;

   is_writable: BOOLEAN is
      do
         Result := expression.is_writable;
      end;

   is_result: BOOLEAN is
      do
         Result := expression.is_result;
      end;

   is_current: BOOLEAN is
      do
         Result := expression.is_current;
      end;

   assertion_check(tag: CHARACTER) is
      do
         expression.assertion_check(tag);
      end;

   is_static: BOOLEAN is
      do
         Result := expression.is_static;
      end;

   static_value: INTEGER is
      do
         Result := expression.static_value;
      end;

   is_pre_computable: BOOLEAN is
      do
         Result := expression.is_pre_computable;
      end;

   isa_dca_inline_argument: INTEGER is
      do
         Result := expression.isa_dca_inline_argument;
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
         expression.dca_inline_argument(formal_arg_type);
      end;

   compile_to_c is
      do
         c_wrapper_opening;
         expression.compile_to_c;
         c_wrapper_closing;
      end;

   mapping_c_target(target_type: TYPE) is
      do
         c_wrapper_opening;
         expression.mapping_c_target(source_type);
         c_wrapper_closing;
      end;

   mapping_c_arg(formal_arg_type: TYPE) is
      do
         c_wrapper_opening;
         expression.mapping_c_arg(source_type);
         c_wrapper_closing;
      end;

   afd_check is
      do
         expression.afd_check;
      end;

   collect_c_tmp is
      do
          expression.collect_c_tmp;
      end;

   c_declare_for_old is
      do
         expression.c_declare_for_old;
      end;

   compile_to_c_old is
      do
         expression.compile_to_c_old;
      end;

   compile_to_jvm_old is
      do
         expression.compile_to_jvm_old;
      end;

   compile_to_jvm is
      local
         space: INTEGER;
      do
         expression.compile_to_jvm;
         space := source_type.jvm_convert_to(destination_type);
      end;

   compile_target_to_jvm is
      local
         space: INTEGER;
      do
         expression.compile_target_to_jvm
         space := source_type.jvm_convert_to(destination_type);
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         compile_to_jvm;
         Result := destination_type.jvm_convert_to(dest);
      end;

   jvm_branch_if_false: INTEGER is
      do
         Result := expression.jvm_branch_if_false;
      end;

   jvm_branch_if_true: INTEGER is
      do
         Result := expression.jvm_branch_if_true;
      end;

   use_current: BOOLEAN is
      do
         Result := expression.use_current;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := expression.stupid_switch(r);
      end;

   c_simple: BOOLEAN is
      do
         Result := expression.c_simple;
      end;

   can_be_dropped: BOOLEAN is
      do
         Result := expression.can_be_dropped;
      end;

   to_runnable(ct: TYPE): EXPRESSION is
      do
         Result := expression.to_runnable(ct);
      end;

   start_position: POSITION is
      do
         Result := expression.start_position;
      end;

   bracketed_pretty_print, pretty_print is
      do
         expression.pretty_print;
      end;

   print_as_target is
      do
         expression.print_as_target;
      end;

   short is
      do
         expression.short;
      end;

   short_target is
      do
         expression.short_target;
      end;

   precedence: INTEGER is
      do
         Result := expression.precedence;
      end;

   jvm_assign is
      do
         expression.jvm_assign;
      end;

feature {NONE}

   c_wrapper_opening is
      do
         conversion_handler.c_function_call(source_type,destination_type);
      end;

   c_wrapper_closing is
      do
         cpp.put_character(')');
      end;

end -- IMPLICIT_CAST
