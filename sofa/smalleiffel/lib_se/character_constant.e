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
class CHARACTER_CONSTANT
--
-- For Manifest Constant CHARACTER.
--

inherit BASE_TYPE_CONSTANT;

creation make

feature

   value: CHARACTER;

feature

   pretty_print_mode: INTEGER;

   std_pretty_print: INTEGER is 0;

   percent_pretty_print: INTEGER is 1;

   ascii_pretty_print: INTEGER is 2;

   c_simple: BOOLEAN is true;

   is_static: BOOLEAN is true;

feature {NONE}

   make(sp: like start_position; v: like value;
        pm: like pretty_print_mode) is
      require
         not sp.is_unknown
      do
         start_position := sp;
         value := v;
         set_pretty_print_mode(pm);
      ensure
         start_position = sp;
         value = v;
         pretty_print_mode = pm;
      end;

feature

   static_result_base_class: BASE_CLASS is
      do
         Result := small_eiffel.get_class(as_character);
      end;

   static_value, to_integer_or_error: INTEGER is
      do
         Result := value.code;
      end;

   compile_to_c is
      do
         cpp.put_string("((T3)%'");
         if value.is_letter or else value.is_digit then
            cpp.put_character(value);
         elseif value = '%N' then
            cpp.put_character('\');
            cpp.put_character('n');
         else
            cpp.put_character('\');
            cpp.put_integer(value.code.to_octal);
         end;
         cpp.put_string("%')");
      end;

   compile_to_jvm, compile_target_to_jvm is
      do
         code_attribute.opcode_push_integer(value.code);
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

   set_pretty_print_mode(pm: like pretty_print_mode) is
      require
         pm = std_pretty_print or else
         pm = percent_pretty_print or else
         pm = ascii_pretty_print
      do
         pretty_print_mode := pm;
      ensure
         pretty_print_mode = pm;
      end;

   to_string: STRING is
      do
         !!Result.make(0);
         Result.extend('%'');
         inspect
            pretty_print_mode
         when std_pretty_print then
            Result.extend(value);
         when percent_pretty_print then
            character_coding(value,Result);
         when ascii_pretty_print then
            Result.extend('%%');
            Result.extend('/');
            value.code.append_in(Result);
            Result.extend('/');
         end;
         Result.extend('%'');
      end;

   result_type: TYPE_CHARACTER is
      local
         unknown_position: POSITION;
      once
         !!Result.make(unknown_position);
      end;

end -- CHARACTER_CONSTANT

