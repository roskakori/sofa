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
class CALL_INFIX_INT_REM
   --
   --   Infix operator : "\\".
   --

inherit CALL_INFIX1;

creation make, with

feature

   precedence: INTEGER is 8;

   left_brackets: BOOLEAN is false;

feature {NONE}

   make(lp: like target; operator_position: POSITION; rp: like arg1) is
      require
         lp /= Void;
         not operator_position.is_unknown
         rp /= Void
      do
         target := lp;
         !!feature_name.make(operator,operator_position);
         !!arguments.make_1(rp);
      ensure
         target = lp;
         start_position = operator_position;
         arguments.first = rp
      end;

feature

   operator: STRING is
      do
         Result := as_backslash_backslash;
      end;

   isa_dca_inline_argument: INTEGER is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   is_static: BOOLEAN is
      do
         if result_type.is_integer then
            if target.is_static and then arg1.is_static then
               Result := true;
               static_value_mem := target.static_value \\ arg1.static_value;
            end;
         end;
      end;

   compile_to_c is
      do
         call_proc_call_c2c;
      end;

   compile_to_jvm is
      do
         call_proc_call_c2jvm;
      end;

   jvm_branch_if_false: INTEGER is
      do
         Result := jvm_standard_branch_if_false;
      end;

   jvm_branch_if_true: INTEGER is
      do
         Result := jvm_standard_branch_if_true;
      end;

end -- CALL_INFIX_INT_REM


