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
class CALL_INFIX_NEQ
   --
   --   Infix operator : "/=".
   --

inherit CALL_INFIX2;

creation make, with

feature

   operator: STRING is
      do
         Result := as_neq;
      end;

   is_static: BOOLEAN is
      do
         if target.is_void then
            Result := is_static_neq_void(arg1);
         elseif arg1.is_void then
            Result := is_static_neq_void(target);
         elseif target.is_static and then arg1.is_static then
            Result := true;
         end;
      end;

   static_value: INTEGER is
      do
         if target.is_void then
            Result := static_neq_void(arg1);
         elseif arg1.is_void then
            Result := static_neq_void(target);
         elseif target.is_static and then arg1.is_static then
            if target.static_value /= arg1.static_value then
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
                  cmp_user_expanded(false,tt);
               elseif tt.is_basic_eiffel_expanded then
                  cmp_basic_eiffel_expanded(false,at,tt);
               elseif tt.is_bit then
                  cmp_bit(false,tt);
               else -- NATIVE_ARRAY
                  cmp_basic_ref(false);
               end;
            else -- ------------------------------- Expanded/Reference :
               c2c_exp_ref(target,tt,arg1,at);
            end;
         elseif at.is_expanded then -- ----------- Reference/Expanded :
            c2c_exp_ref(arg1,at,target,tt);
         else -- ---------------------------- Reference/Reference :
            cmp_basic_ref(false);
         end;
      end;

feature {NONE}

   c2c_exp_ref(e: EXPRESSION; et: TYPE; r: EXPRESSION; rt: TYPE) is
      do
         if r.is_void then
            cpp.put_string(fz_17);
            r.compile_to_c;
         else
            cpp.put_string(fz_17);
            e.compile_to_c;
            cpp.put_string(fz_20);
            r.compile_to_c;
         end;
         cpp.put_string("),1)");
      end;

feature {NONE}

   is_static_neq_void(e: EXPRESSION): BOOLEAN is
      local
         rt: TYPE;
      do
         if e.is_current or else
            e.is_manifest_string or else
            e.is_manifest_array
          then
            Result := true;
         else
            rt := e.result_type.run_type;
            if rt.is_expanded then
               Result := true;
            elseif e.is_static then
               Result := true;
            end;
         end;
      end;

   static_neq_void(e: EXPRESSION): INTEGER is
      local
         rt: TYPE;
      do
         if e.is_current or else
           e.is_manifest_string or else
           e.is_manifest_array
          then
            Result := 1;
         else
            rt := e.result_type.run_type;
            if rt.is_expanded then
               Result := 1;
            elseif e.is_static then
               if e.static_value /= 0 then
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
         ca: like code_attribute;
      do
         if target.is_void then
            jvm_void_cmp(arg1);
         elseif arg1.is_void then
            jvm_void_cmp(target);
         else
            ca := code_attribute;
            rt := target.result_type.smallest_ancestor(arg1.result_type);
            space := target.compile_to_jvm_into(rt);
            space := arg1.compile_to_jvm_into(rt);
            if rt.is_user_expanded then
               rc := rt.run_class;
               jvm_standard_is_neq_aux(rc,rc.writable_attributes);
            else
               point1 := rt.jvm_if_x_eq;
               ca.opcode_iconst_1;
               point2 := ca.opcode_goto;
               ca.resolve_u2_branch(point1);
               ca.opcode_iconst_0;
               ca.resolve_u2_branch(point2);
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
         ca: like code_attribute;
      do
         ca := code_attribute;
         rt := e.result_type.run_type;
         if rt.is_expanded then
            e.compile_to_jvm;
            from
               space := rt.jvm_stack_space;
            until
               space = 0
            loop
               ca.opcode_pop;
               space := space - 1;
            end;
            ca.opcode_iconst_1;
         else
            e.compile_to_jvm;
            point1 := ca.opcode_ifnonnull;
            ca.opcode_iconst_0;
            point2 := ca.opcode_goto;
            ca.resolve_u2_branch(point1);
            ca.opcode_iconst_1;
            ca.resolve_u2_branch(point2);
         end;
      end;

feature {NONE}

   jvm_standard_is_neq_aux(rc: RUN_CLASS; wa: ARRAY[RUN_FEATURE_2]) is
      require
         rc.current_type.is_user_expanded
      local
         ca: like code_attribute;
         rf2: RUN_FEATURE_2;
         point1, point2, idx, space, i: INTEGER;
      do
         ca := code_attribute;
         if wa = Void then
            ca.opcode_pop;
            ca.opcode_pop;
            ca.opcode_iconst_0;
         else
            ca.branches.clear;
            ca.opcode_dup;
            rc.opcode_instanceof;
            ca.branches.add_last(ca.opcode_ifeq);
            from
               i := wa.upper;
            until
               i = 0
            loop
               rf2 := wa.item(i);
               idx := constant_pool.idx_fieldref(rf2);
               space := rf2.result_type.jvm_stack_space - 1;
               if i > 1 then
                  ca.opcode_dup2;
               end;
               ca.opcode_getfield(idx,space);
               if space = 0 then
                  ca.opcode_swap;
               else
                  ca.opcode_dup2_x1;
                  ca.opcode_pop2;
               end;
               ca.opcode_getfield(idx,space);
               if i > 1 then
                  ca.branches.add_last(rf2.result_type.jvm_if_x_ne);
               else
                  point1 := rf2.result_type.jvm_if_x_ne;
               end;
               i := i - 1;
            end;
            ca.opcode_iconst_0;
            point2 := ca.opcode_goto;
            ca.resolve_branches;
            ca.opcode_pop;
            ca.opcode_pop;
            ca.resolve_u2_branch(point1);
            ca.opcode_iconst_1;
            ca.resolve_u2_branch(point2);
         end;
      end;

invariant

   run_feature = Void;

end -- CALL_INFIX_NEQ

