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
class RUN_REQUIRE
   --
   -- A RUN_REQUIRE is composed with all inherited E_REQUIRE.
   --

inherit GLOBALS;

creation {ASSERTION_COLLECTOR} make

feature {NONE}

   list: ARRAY[E_REQUIRE];
         -- From bottom to the top of the inheritance graph.
         -- Order is important because one at least must be true
         -- following bottom up order.

   make(first: E_REQUIRE) is
      do
         !!list.with_capacity(4,1);
         list.add_last(first);
      end;

feature

   short is
      local
         i: INTEGER;
      do
         from
            list.item(1).short("hook401","      require%N");
            i := 2;
         until
            i > list.upper
         loop
            list.item(i).short("hook402","      require else %N");
            i := i + 1;
         end;
         short_print.hook("hook403");
      end;

   use_current: BOOLEAN is
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            Result or else i > list.upper
         loop
            Result := list.item(i).use_current;
            i := i + 1;
         end;
      end;

   afd_check is
      local
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            i = 0
         loop
            list.item(i).afd_check;
            i := i - 1;
         end;
      end;

   compile_to_c is
      require
         run_control.require_check
      local
         i: INTEGER;
      do
         if list.upper = 1 then
            cpp.put_string("se_require_uppermost_flag=1;%N");
            list.first.compile_to_c;
         else
            cpp.put_string("se_require_uppermost_flag=0;%N%
                           %se_require_last_result=1;%N");
            list.first.compile_to_c;
            from
               i := 2;
            until
               i > list.upper
            loop
               if i = list.upper then
                  cpp.put_string("se_require_uppermost_flag=1;%N")
               end;
               cpp.put_string("if(!se_require_last_result){%N%
                              %se_require_last_result=1;%N")
               list.item(i).compile_to_c;
               cpp.put_string(fz_12)
               i := i + 1;
            end;
         end;
      end;

   compile_to_jvm is
      local
         i: INTEGER;
         ca: like code_attribute;
      do
         if run_control.require_check then
            ca := code_attribute;
            if list.upper = 1 then
               list.first.compile_to_jvm(true);
               ca.opcode_pop;
            else
               sucess.clear;
               from
                  i := 1;
               until
                  i > (list.upper - 1)
               loop
                  list.item(i).compile_to_jvm(false);
                  sucess.add_last(ca.opcode_ifne);
                  i := i + 1;
               end;
               list.item(i).compile_to_jvm(true);
               ca.opcode_pop;
               ca.resolve_with(sucess);
            end;
         end;
      end;

feature {ASSERTION_COLLECTOR}

   add(r: E_REQUIRE) is
      require
         r /= Void
      local
         i: INTEGER;
         r2: E_REQUIRE;
         bc, bc2: BASE_CLASS;
      do
         list.add_last(r);
         from
            bc := r.start_position.base_class;
            i := list.upper;
         until
            i = 1
         loop
            r2 := list.item(i - 1);
            bc2 := r2.start_position.base_class;
            if bc.is_subclass_of(bc2) then
               list.swap(i,i-1);
               i := i - 1;
            else
               i := 1;
            end;
         end;
      end;

feature {ONCE_ROUTINE_POOL}

   clear_run_feature is
      local
         i: INTEGER;
      do
         from
            i := list.upper;
         until
            i = 0
         loop
            list.item(i).clear_run_feature;
            i := i - 1;
         end;
      end;

feature {NONE}

   sucess: FIXED_ARRAY[INTEGER] is
         -- To reach the sucessful code.
      once
         !!Result.with_capacity(4);
      end;

invariant

   list.lower = 1;

   not list.is_empty;

end -- RUN_REQUIRE

