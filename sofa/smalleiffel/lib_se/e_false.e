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
class E_FALSE
   --
   -- When using explicit constant `false'.
   --

inherit BOOLEAN_CONSTANT;

creation make

feature

   to_integer_or_error: INTEGER is 0;

   value: BOOLEAN is false;

   is_static: BOOLEAN is true;

   static_value: INTEGER is 0;

feature

   to_string: STRING is
      do
         Result := fz_false;
      end;

   compile_to_c is
      do
         cpp.put_character('0');
      end;

   compile_target_to_jvm, compile_to_jvm is
      do
         code_attribute.opcode_iconst_0;
      end;

   jvm_branch_if_false: INTEGER is
      do
         Result := code_attribute.opcode_goto;
      end;

   jvm_branch_if_true: INTEGER is
      do
         code_attribute.opcode_iconst_0;
         Result := code_attribute.opcode_ifeq;
      end;

end -- E_FALSE

