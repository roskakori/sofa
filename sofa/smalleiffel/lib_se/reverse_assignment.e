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
class REVERSE_ASSIGNMENT
   --
   -- For instructions like :
   --                          foo ?= bar;
   --                          foo ?= bar + 1;
   --

inherit INSTRUCTION;

creation make

feature

   left_side: EXPRESSION;

   right_side: EXPRESSION;

   end_mark_comment: BOOLEAN is false;

   use_current: BOOLEAN is
      do
         if left_side.use_current then
            Result := true;
         else
            Result := right_side.use_current;
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         if small_eiffel.stupid_switch(left_side.result_type,r) then
            if small_eiffel.stupid_switch(right_side.result_type,r) then
               if left_side.stupid_switch(r) then
                  if right_side.stupid_switch(r) then
                     Result := true;
                  end;
               end;
            end;
         end;
      end;

   afd_check is
      do
         right_side.afd_check;
      end;

   collect_c_tmp is
      do
         right_side.collect_c_tmp;
      end;

   compile_to_c is
      local
         run: ARRAY[RUN_CLASS];
         i: INTEGER;
      do
         cpp.se_trace_ins(start_position);
         if right_type.run_type.is_expanded then
            eh.add_position(start_position);
            fatal_error("Right-hand side expanded Not Yet Implemented.");
         end;
         run := left_type.run_class.running;
         if run = Void then
            if not right_side.can_be_dropped then
               right_side.compile_to_c;
               cpp.put_string(fz_00);
            end;
            left_side.compile_to_c;
            cpp.put_string(fz_30);
         elseif right_side.is_current then
            if run.fast_has(right_side.result_type.run_class) then
               left_side.compile_to_c;
               cpp.put_string("=((void*)");
               right_side.compile_to_c;
               cpp.put_string(fz_14);
            else
               left_side.compile_to_c;
               cpp.put_string(fz_30);
            end;
         else
            left_side.compile_to_c;
            cpp.put_character('=');
            if right_side.is_current then
               cpp.put_string(fz_cast_t0_star);
            end;
            right_side.compile_to_c;
            cpp.put_string(";%Nif(NULL!=(");
            left_side.compile_to_c;
            cpp.put_string(")){%Nswitch(((T0*)");
            left_side.compile_to_c;
            cpp.put_string(")->");
            cpp.put_string("id){%N");
            from
               i := run.lower;
            until
               i > run.upper
            loop
               cpp.put_string("case ");
               cpp.put_integer(run.item(i).id);
               cpp.put_character(':');
               i := i + 1;
            end;
            cpp.put_string("%Nbreak;%Ndefault:%N");
            left_side.compile_to_c;
            cpp.put_string("=NULL;%N}%N}");
         end;
      end;

   compile_to_jvm is
      local
         run: ARRAY[RUN_CLASS];
         rc: RUN_CLASS;
         point1, i: INTEGER;
         ca: like code_attribute;
      do
         ca := code_attribute;
         if right_type.run_type.is_expanded then
            eh.add_position(start_position);
            fatal_error("Right-hand side expanded Not Yet Implemented.");
         end;
         run := left_type.run_class.running;
         if run = Void or else run.is_empty then
            right_side.compile_to_jvm;
            ca.opcode_pop;
            ca.opcode_aconst_null;
            left_side.jvm_assign;
         else
            right_side.compile_to_jvm;
            ca.opcode_dup;
            point1 := ca.opcode_ifnull;
            from
               ca.branches.clear;
               i := run.upper;
            until
               i = 0
            loop
               ca.opcode_dup;
               rc := run.item(i);
               rc.opcode_instanceof;
               ca.branches.add_last(ca.opcode_ifne);
               i := i - 1;
            end;
            ca.opcode_pop;
            ca.opcode_aconst_null;
            ca.resolve_u2_branch(point1);
            ca.resolve_branches;
            left_side.jvm_assign;
         end;
      end;

   is_pre_computable: BOOLEAN is false;

   start_position: POSITION is
      do
         Result := left_side.start_position;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         e: EXPRESSION;
      do
         if current_type = Void then
            current_type := ct;
            e := left_side.to_runnable(ct);
            if e = Void then
               error(left_side.start_position,fz_blhsoa);
            else
               left_side := e;
            end;
            if nb_errors = 0  then
               e := right_side.to_runnable(ct);
               if e = Void then
                  error(right_side.start_position,fz_brhsoa);
               else
                  right_side := e;
               end;
            end;
            if nb_errors = 0 and then
               right_type.run_type.is_a(left_type.run_type) then
               if not right_side.is_current and then
                  not left_type.is_like_current and then
		  not right_type.is_formal_generic and then
		  not left_type.is_formal_generic
                then
                  eh.add_type(right_type," is a ");
                  eh.add_type(left_type,". Simple assignment is allowed");
                  warning(start_position," (%"?=%" is not necessary).");
               end;
            end;
            eh.cancel;
            if not left_type.run_type.is_reference then
               eh.add_type(left_type.run_type," is not a reference Type.");
               error(start_position," Invalid reverse assignment (VJRV).");
            end;
            if nb_errors = 0 then
               Result := Current;
            end;
         else
            !!Result.make(left_side,right_side);
            Result := Result.to_runnable(ct);
         end;
      end;

   right_type: TYPE is
      do
         Result := right_side.result_type;
      ensure
         Result /= Void
      end;

   left_type: TYPE is
      do
         Result := left_side.result_type;
      ensure
         Result /= Void
      end;

   pretty_print is
      do
         pretty_print_assignment(left_side,"?=",right_side);
      end;

feature {NONE}

   current_type: TYPE;

   make(ls: like left_side; rs: like right_side) is
      require
         ls /= Void;
         rs /= Void
      do
         left_side := ls;
         right_side := rs;
      end;

invariant

   left_side.is_writable;

   right_side /= Void;

end -- REVERSE_ASSIGNMENT

