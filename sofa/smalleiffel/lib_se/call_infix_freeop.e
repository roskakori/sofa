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
class CALL_INFIX_FREEOP
   --
   --   Infix free operator : "@...", "#...", "|...", "&..."
   --

inherit CALL_INFIX1;

creation make, with

feature

   precedence: INTEGER is 10;

   left_brackets: BOOLEAN is false;

   isa_dca_inline_argument: INTEGER is 0;

feature {NONE}

   make(lp: like target; in: like feature_name; rp: like arg1) is
      require
         lp /= Void;
         in.is_freeop;
         rp /= Void
      do
         target := lp;
         feature_name := in;
         !!arguments.make_1(rp);
      ensure
         target = lp;
         feature_name = in;
         arguments.first = rp
      end;

feature

   operator: STRING is
      do
         Result := feature_name.to_string;
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   is_static: BOOLEAN is
      do
         Result := call_is_static;
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

invariant

   feature_name.is_freeop

end -- CALL_INFIX_FREEOP

