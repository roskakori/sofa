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
class REAL_CONSTANT
   --
   -- For Manifest Constant REAL.
   --

inherit BASE_TYPE_CONSTANT;

creation make

feature

   c_simple: BOOLEAN is true;

   is_static: BOOLEAN is false;

   to_string: STRING;
         -- Cleanly written view of the constant (ANSI C compatible).

   to_integer_or_error: INTEGER is
      do
	 to_integer_error;
      end;

   static_result_base_class: BASE_CLASS is
      do
         Result := small_eiffel.get_class(as_real);
      end;

   static_value: INTEGER is
      do
      end;

   compile_to_c is
      do
         cpp.put_string(to_string);
      end;

   compile_target_to_jvm, compile_to_jvm is
      do
         code_attribute.opcode_push_as_float(to_string);
      end;

   jvm_branch_if_false: INTEGER is
      do
      end;

   jvm_branch_if_true: INTEGER is
      do
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         if dest.is_real then
            code_attribute.opcode_push_as_float(to_string);
            Result := 1;
         elseif dest.is_double then
            code_attribute.opcode_push_as_double(to_string);
            Result := 2;
         else
            Result := standard_compile_to_jvm_into(dest);
         end;
      end;

   result_type: TYPE_REAL is
      local
         unknown_position: POSITION;
      once
         !!Result.make(unknown_position);
      end;

feature {EIFFEL_PARSER}

   unary_minus is
      do
         to_string.add_first('-');
      end;

feature {NONE}

   make(sp: like start_position; ts: like to_string) is
      require
         not sp.is_unknown;
         ts /= Void
      do
         start_position := sp;
         to_string := ts;
      ensure
         start_position = sp;
         to_string = ts
      end;

end -- REAL_CONSTANT

