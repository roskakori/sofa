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
class ASSIGNMENT
   --
   -- For instruction like :
   --                          foo := bar;
   --                          foo := bar + 1;
   --
   --

inherit INSTRUCTION;

creation make

feature

   left_side: EXPRESSION;

   right_side: EXPRESSION;

   end_mark_comment: BOOLEAN is false;

   is_pre_computable: BOOLEAN is
      local
         call: CALL;
         rf6: RUN_FEATURE_6;
      do
         if right_side.is_pre_computable then
            call ?= right_side;
            if call /= Void then
               rf6 ?= call.run_feature;
               Result := rf6 = Void;
            else
               Result := true;
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
         cast_t0: BOOLEAN;
      do
         cpp.se_trace_ins(start_position);
         if right_side.is_current then
            if left_type.is_reference then
               cast_t0 := right_type.is_reference;
            end;
         end;
         left_side.compile_to_c;
         cpp.put_character('=');
         if cast_t0 then
            cpp.put_string("((T0*)(");
         end;
         right_side.compile_to_c;
         if cast_t0 then
            cpp.put_string("))");
         end;
         cpp.put_string(fz_00);
      end;
   
   compile_to_jvm is
      do
         right_side.compile_to_jvm;
         left_side.jvm_assign;
      end;

   use_current: BOOLEAN is
      do
         Result := left_side.use_current;
         Result := Result or else right_side.use_current;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         if left_side.stupid_switch(r) then
            if right_side.stupid_switch(r) then
               Result := true;
            end;
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

   start_position: POSITION is
      do
         Result := left_side.start_position;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         l, r: EXPRESSION;
      do
	 l := left_side.to_runnable(ct);
	 if l = Void then
	    eh.add_position(left_side.start_position);
	    fatal_error(fz_blhsoa);
	 end;
	 r := right_side.to_runnable(ct);
	 if r = Void then
	    eh.add_position(right_side.start_position);
	    fatal_error(fz_brhsoa);
	 end;
	 if not r.result_type.is_a(l.result_type) then
	    eh.add_position(l.start_position);
	    fatal_error(" Bad assignment (VJAR).");
	 end;
	 if l = left_side and then r = right_side then
	    Result := implicit_conversion;
	 else
	    !!Result.make(l,r);
	    Result := Result.implicit_conversion;
	 end;
      end;

   pretty_print is
      do
         pretty_print_assignment(left_side,":=",right_side);
      end;

feature {ASSIGNMENT}

   implicit_conversion: like Current is
      local
         left_run_type, right_run_type: TYPE;
         rhs: EXPRESSION;
	 T1: TYPE;
      do
         left_run_type := left_type.run_type;
         right_run_type := right_type.run_type;
         if right_side.is_void and then left_run_type.is_expanded then
            eh.add_position(right_side.start_position);
            eh.append("Void may not be assigned to an %
                      %expanded entity. Left hand side is ");
            eh.add_type(left_type,".");
            eh.print_as_error;
         end;
	 T1 := right_side.result_type;
         rhs := conversion_handler.implicit_cast(right_side,left_run_type);
         if rhs = right_side then
            Result := Current;
         else
            !!Result.make(left_side,rhs);
         end;
      end;

feature {NONE}

   make(ls: like left_side; rs: like right_side) is
      require
         ls.is_writable;
         not ls.start_position.is_unknown;
         rs /= Void
      do
         left_side := ls;
         right_side := rs;
      ensure
         left_side = ls;
         right_side = rs
      end;

invariant

   left_side.is_writable;

   right_side /= Void

end -- ASSIGNMENT

