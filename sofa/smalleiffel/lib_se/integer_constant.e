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
class INTEGER_CONSTANT
   --
   -- For Manifest Constant of class INTEGER.
   --

inherit BASE_TYPE_CONSTANT;

creation make

feature

   value: INTEGER;

   is_static: BOOLEAN is true;

   to_integer_or_error: INTEGER is
      do
	 Result := value;
      end;

   static_result_base_class: BASE_CLASS is
      do
         Result := small_eiffel.get_class(as_integer);
      end;

   static_value: INTEGER is
      do
         Result := value;
      end;

   compile_to_c is
      do
         cpp.put_integer(value);
      end;

   compile_target_to_jvm, compile_to_jvm is
      do
         code_attribute.opcode_push_integer(value);
      end;

   jvm_branch_if_false: INTEGER is
      do
      end;

   jvm_branch_if_true: INTEGER is
      do
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := standard_compile_to_jvm_into(dest);
      end;

   c_simple: BOOLEAN is
      do
         Result := true;
      end;

   to_string: STRING is
         -- *** SHOULD ADD PRINTING MODE WITH/WITHOUT UNDESCORE.
      do
         Result := value.to_string;
      end;

   make(a_value: INTEGER; sp: like start_position) is
      do
         value := a_value;
         start_position := sp;
      ensure
         value = a_value;
      end;

   result_type: TYPE_INTEGER is
      local
         unknown_position: POSITION;
      once
         !!Result.make(unknown_position);
      end;

feature {TMP_FEATURE}

   to_real_constant: REAL_CONSTANT is
      do
         !!Result.make(start_position,value.to_string);
      end;

feature {EIFFEL_PARSER}

   unary_minus is
      do
         value := - value;
      end;

feature {CST_ATT_UNIQUE}

   set_value(v: INTEGER) is
      do
         value := v;
      ensure
         value = v;
      end;

end -- INTEGER_CONSTANT


