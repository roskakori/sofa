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
deferred class CALL_INFIX
   --
   -- For all sort of infix operators (root of all CALL_INFIX_*).
   --

inherit CALL_1 redefine feature_name, print_as_target end;

feature

   feature_name: INFIX_NAME;

feature

   left_brackets: BOOLEAN is
      deferred
      end;

   right_brackets: BOOLEAN is
      do
         Result := not left_brackets;
      end;

   operator: STRING is
      deferred
      ensure
         Result.count >= 1
      end;

feature

   frozen short is
      do
         if target.precedence = atomic_precedence then
            target.short;
            short_print_feature_name;
            if arg1.precedence = atomic_precedence then
               arg1.short;
            elseif precedence >= arg1.precedence then
               arg1.bracketed_short;
            else
               arg1.short;
            end;
         elseif target.precedence < precedence then
            target.bracketed_short;
            short_print_feature_name;
            arg1.short;
         else
            target.short;
            short_print_feature_name;
            arg1.short;
         end;
      end;

   frozen short_target is
      do
         bracketed_short;
         short_print.a_dot;
      end;

   frozen print_as_target is
      do
         fmt.put_character('(');
         pretty_print;
         fmt.put_character(')');
         fmt.put_character('.');
      end;

   frozen bracketed_pretty_print is
      do
         fmt.put_character('(');
         pretty_print;
         fmt.put_character(')');
      end;

feature

   frozen pretty_print is
      do
         if target.precedence = atomic_precedence then
            target.pretty_print;
         elseif precedence > target.precedence then
            target.bracketed_pretty_print;
         elseif precedence < target.precedence then
            target.pretty_print;
         elseif left_brackets then
            target.bracketed_pretty_print;
         else
            target.pretty_print;
         end;
         print_op;
         if arg1.precedence = atomic_precedence then
            arg1.pretty_print;
         elseif precedence > arg1.precedence then
            arg1.bracketed_pretty_print;
         elseif precedence < arg1.precedence then
            arg1.pretty_print;
         elseif right_brackets then
            arg1.bracketed_pretty_print;
         else
            arg1.pretty_print;
         end;
      end;

feature {NONE}

   frozen print_op is
      do
         fmt.put_character(' ');
         feature_name.pretty_print;
         fmt.put_character(' ');
      end;

feature {NONE}

   frozen short_print_feature_name is
      do
         short_print.a_infix_name("Binfix"," ","Ainfix"," ",feature_name);
      end;

   frozen c2c_cast_op(cast, op: STRING) is
      do
         cpp.put_character('(');
         cpp.put_character('(');
         cpp.put_character('(');
         cpp.put_string(cast);
         cpp.put_character(')');
         cpp.put_character('(');
         target.compile_to_c;
         cpp.put_character(')');
         cpp.put_character(')');
         cpp.put_string(op);
         cpp.put_character('(');
         cpp.put_character('(');
         cpp.put_string(cast);
         cpp.put_character(')');
         cpp.put_character('(');
         arg1.compile_to_c;
         cpp.put_character(')');
         cpp.put_character(')');
         cpp.put_character(')');
      end;

end -- CALL_INFIX

