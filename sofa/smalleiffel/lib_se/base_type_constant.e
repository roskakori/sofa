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
deferred class BASE_TYPE_CONSTANT
   --
   -- Common root of : BOOLEAN_CONSTANT, CHARACTER_CONSTANT, 
   -- INTEGER_CONSTANT and REAL_CONSTANT.
   --

inherit EXPRESSION;

feature

   start_position: POSITION;

   is_writable: BOOLEAN is false;

   is_current: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   is_result: BOOLEAN is false;

   is_void: BOOLEAN is false;

   use_current: BOOLEAN is false;

   can_be_dropped: BOOLEAN is true;

   frozen afd_check is
      do
      end;

   frozen is_pre_computable: BOOLEAN is
      do
         Result := is_static;
      end;

   frozen c_declare_for_old is
      do
      end;

   frozen compile_to_c_old is
      do
      end;

   frozen collect_c_tmp is
      do
      end;

   frozen compile_to_jvm_old is
      do
      end;

   frozen to_runnable(ct: TYPE): like Current is
      local
         t: TYPE;
      do
         Result := Current;
         t := result_type.to_runnable(ct);
         check
            t = result_type
         end;
      end;

   frozen stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := true;
      end;

   frozen assertion_check(tag: CHARACTER) is
      do
      end;

   frozen isa_dca_inline_argument: INTEGER is
      do
         if is_static then
            Result := -1;
         end;
      end;

   frozen dca_inline_argument(formal_arg_type: TYPE) is
      do
         mapping_c_arg(formal_arg_type);
      end;

   frozen mapping_c_target(target_type: TYPE) is
      do
         compile_to_c;
      end;

   frozen mapping_c_arg(formal_arg_type: TYPE) is
      do
         compile_to_c;
      end;

   frozen bracketed_pretty_print, frozen pretty_print is
      do
         fmt.put_string(to_string);
      end;

   frozen print_as_target is
      do
         fmt.put_character('(');
         pretty_print;
         fmt.put_character(')');
         fmt.put_character('.');
      end;

   frozen short is
      do
         short_print.a_base_type_constant(to_string);
      end;

   frozen short_target is
      do
         bracketed_short;
         short_print.a_dot;
      end;

   frozen precedence: INTEGER is
      do
         Result := atomic_precedence;
      end;

   frozen base_class_name: CLASS_NAME is
      do
         Result := result_type.base_class_name;
      end;

   frozen jvm_assign is
      do
      end;

feature {BASE_TYPE_CONSTANT}

   frozen set_current_type(ct: TYPE) is
      do
         current_type := ct;
      ensure
         current_type = ct;
      end;

feature {NONE}

   to_string: STRING is
      deferred
      end;

end -- BASE_TYPE_CONSTANT

