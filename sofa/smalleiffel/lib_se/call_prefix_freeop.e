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
class CALL_PREFIX_FREEOP
   --
   --   Prefix free operator : "@...", "#...", "|...", "&..."
   --

inherit CALL_PREFIX;

creation make, with

feature

   precedence: INTEGER is 11;

feature {NONE}

   make(t: like target; pn: like feature_name)is
      require
         t /= Void;
         pn.is_freeop
      do
         target := t;
         feature_name := pn;
      ensure
         target = t;
         feature_name = pn
      end;

feature

   operator: STRING is
      do
         Result := feature_name.to_string;
      end;

   isa_dca_inline_argument: INTEGER is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   is_static: BOOLEAN is
      local
         running: ARRAY[RUN_CLASS];
         rf: like run_feature;
      do
         running := run_feature.run_class.running;
         if running /= Void and then running.count = 1 then
            rf := running.first.dynamic(run_feature);
            if rf.is_static then
               Result := true;
            end;
         end;
      end;

   static_value: INTEGER is
      local
         running: ARRAY[RUN_CLASS];
         rf: like run_feature;
      do
         running := run_feature.run_class.running;
         if running /= Void and then running.count = 1 then
            rf := running.first.dynamic(run_feature);
            if rf.is_static then
               Result := rf.static_value_mem;
            end;
         end;
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

end -- CALL_PREFIX_FREEOP


