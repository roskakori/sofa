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
class EXPRESSION_WITH_COMMENT
   --
   -- To store one expression with a following comment.
   --

inherit EXPRESSION;

creation make

feature

   expression : EXPRESSION;

   comment : COMMENT;

   static_result_base_class: BASE_CLASS is
      do
         Result := expression.static_result_base_class;
      end;

   is_writable: BOOLEAN is
      do
         Result := expression.is_writable;
      end;

   is_manifest_array: BOOLEAN is
      do
         Result := expression.is_manifest_array;
      end;

   is_manifest_string: BOOLEAN is
      do
         Result := expression.is_manifest_string;
      end;

   is_void: BOOLEAN is
      do
         Result := expression.is_void;
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

   mapping_c_target(target_type: TYPE) is
      do
         expression.mapping_c_target(target_type);
      end;

   mapping_c_arg(formal_arg_type: TYPE) is
      do
         expression.mapping_c_arg(formal_arg_type);
      end;

   afd_check is
      do
         expression.afd_check;
      end;

   collect_c_tmp is
      do
          expression.collect_c_tmp;
      end;

   compile_to_c is
      do
         expression.compile_to_c;
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
      do
         expression.compile_to_jvm;
      end;

   compile_target_to_jvm is
      do
         expression.compile_target_to_jvm
      end;

   jvm_branch_if_false: INTEGER is
      do
         Result := expression.jvm_branch_if_false;
      end;

   jvm_branch_if_true: INTEGER is
      do
         Result := expression.jvm_branch_if_true;
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := expression.compile_to_jvm_into(dest);
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

   to_runnable(ct: TYPE): like Current is
      local
         e: EXPRESSION;
      do
         e := expression.to_runnable(ct);
         if expression = e then
            Result := Current;
         else
            !!Result.make(e,comment);
         end;
      end;

   start_position: POSITION is
      do
         Result := expression.start_position;
      end;

   bracketed_pretty_print, pretty_print is
      do
         expression.pretty_print;
         comment.pretty_print;
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

   result_type: TYPE is
      do
         Result := expression.result_type;
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

   make(e: like expression; c: like comment) is
      require
         e /= Void;
         really_a_comment: c.count > 0
      do
         expression := e;
         comment := c;
      ensure
         expression = e;
         comment = c
      end;

end -- EXPRESSION_WITH_COMMENT

