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
class CALL_INFIX_EQ
   --
   --   Infix operator : "=".
   --

inherit CALL_INFIX2;

creation make, with

feature

   operator: STRING is
      do
         Result := as_eq;
      end;

   is_static: BOOLEAN is
      do
         if target.is_void then
            Result := is_static_eq_void(arg1);
         elseif arg1.is_void then
            Result := is_static_eq_void(target);
         elseif target.is_static and then arg1.is_static then
            Result := true;
         end;
      end;

   static_value: INTEGER is
      do
         if target.is_void then
            Result := static_eq_void(arg1);
         elseif arg1.is_void then
            Result := static_eq_void(target);
         elseif target.is_static and then arg1.is_static then
            if target.static_value = arg1.static_value then
               Result := 1;
            end;
         end;
      end;

   compile_to_c is
      local
         tt, at: TYPE;
      do
         tt := target.result_type.run_type;
         at := arg1.result_type.run_type;
         if tt.is_expanded then
            if at.is_expanded then -- ------------- Expanded/Expanded :
               if tt.is_user_expanded then
                  cmp_user_expanded(true,tt);
               elseif tt.is_basic_eiffel_expanded then
                  cmp_basic_eiffel_expanded(true,at,tt);
               elseif tt.is_bit then
                  cmp_bit(true,tt);
               else -- NATIVE_ARRAY
                  cmp_basic_ref(true);
               end;
            else -- ------------------------------- Expanded/Reference :
               c2c_exp_ref(target,tt,arg1,at);
            end;
         elseif at.is_expanded then -- ----------- Reference/Expanded :
            c2c_exp_ref(arg1,at,target,tt);
         else -- ---------------------------- Reference/Reference :
            cmp_basic_ref(true);
         end;
      end;

feature {NONE}

   c2c_exp_ref(e: EXPRESSION; et: TYPE; r: EXPRESSION; rt: TYPE) is
      do
         if r.is_void then
            cpp.put_string(fz_17);
            e.compile_to_c;
         else
            cpp.put_string(fz_17);
            e.compile_to_c;
            cpp.put_string(fz_20);
            r.compile_to_c;
         end;
         cpp.put_string("),0)");
      end;

feature {NONE}

   is_static_eq_void(e: EXPRESSION): BOOLEAN is
      local
         rt: TYPE;
      do
         if e.is_current then
            Result := true;
         elseif e.is_manifest_string then
            Result := true;
         elseif e.is_manifest_array then
            Result := true;
         else
            rt := e.result_type.run_type;
            if rt.is_expanded then
               if e.can_be_dropped then
                  Result := true;
               end;
            elseif e.is_static then
               if e.static_value = 0 then
                  Result := true;
               end;
            end;
         end;
      end;

   static_eq_void(e: EXPRESSION): INTEGER is
      local
         rt: TYPE;
      do
         if e.is_current then
         elseif e.is_manifest_string then
         elseif e.is_manifest_array then
         else
            rt := e.result_type.run_type;
            if rt.is_expanded then
               if e.can_be_dropped then
                  Result := 0;
               end;
            elseif e.is_static then
               if e.static_value = 0 then
                  Result := 1;
               end;
            end;
         end;
      end;

feature

   compile_to_jvm is
      local
         space, point1, point2: INTEGER;
         rt: TYPE;
         rc: RUN_CLASS;
      do
         if target.is_void then
            jvm_void_cmp(arg1);
         elseif arg1.is_void then
            jvm_void_cmp(target);
         else
            rt := target.result_type.smallest_ancestor(arg1.result_type);
            space := target.compile_to_jvm_into(rt);
            space := arg1.compile_to_jvm_into(rt);
            if rt.is_user_expanded then
               rc := rt.run_class;
               jvm.std_is_equal(rc,rc.writable_attributes);
            else
               point1 := rt.jvm_if_x_eq;
               code_attribute.opcode_iconst_0;
               point2 := code_attribute.opcode_goto;
               code_attribute.resolve_u2_branch(point1);
               code_attribute.opcode_iconst_1;
               code_attribute.resolve_u2_branch(point2);
            end;
         end;
      end;

   jvm_branch_if_false: INTEGER is
      do
         Result := jvm_standard_branch_if_false;
      end;

   jvm_branch_if_true: INTEGER is
      do
         Result := jvm_standard_branch_if_true;
      end;

feature {NONE}

   jvm_void_cmp(e: EXPRESSION) is
      local
         rt: TYPE;
         point1, point2: INTEGER;
         space: INTEGER;
      do
         rt := e.result_type.run_type;
         if rt.is_expanded then
            e.compile_to_jvm;
            from
               space := rt.jvm_stack_space;
            until
               space = 0
            loop
               code_attribute.opcode_pop;
               space := space - 1;
            end;
            code_attribute.opcode_iconst_0;
         else
            e.compile_to_jvm;
            point1 := code_attribute.opcode_ifnull;
            code_attribute.opcode_iconst_0;
            point2 := code_attribute.opcode_goto;
            code_attribute.resolve_u2_branch(point1);
            code_attribute.opcode_iconst_1;
            code_attribute.resolve_u2_branch(point2);
         end;
      end;

invariant

   run_feature = Void;

end -- CALL_INFIX_EQ

