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
class E_CHECK
   --
   -- Instruction "check ... end;".
   --

inherit INSTRUCTION;

creation make

feature

   end_mark_comment: BOOLEAN is true;

   start_position: POSITION is
         -- Of keyword "check".
      do
         if check_invariant /= Void then
            Result := check_invariant.start_position;
         end;
      end;

   to_runnable(ct: TYPE): like Current is
      do
         if run_control.all_check then
            if current_type = Void then
               current_type := ct;
               if check_invariant /= Void then
                  check_invariant := check_invariant.to_runnable(ct);
               end;
               Result := Current;
            else
               !!Result.make(start_position,Void,check_invariant.list);
               Result := Result.to_runnable(ct);
            end;
         else
            current_type := ct;
            Result := Current;
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := true;
      end;

   afd_check is
      do
         if run_control.all_check and then check_invariant /= Void then
            check_invariant.afd_check;
         end;
      end;

   collect_c_tmp is
      do
      end;

   compile_to_c is
      do
         if run_control.all_check and then check_invariant /= Void then
            check_invariant.compile_to_c;
         end;
      end;

   compile_to_jvm is
      do
         if run_control.all_check and then check_invariant /= Void then
            check_invariant.compile_to_jvm(true);
            code_attribute.opcode_pop;
         end;
      end;

   is_pre_computable: BOOLEAN is
      do
         if run_control.all_check and then check_invariant /= Void then
            Result := check_invariant.is_pre_computable;
         else
            Result := true;
         end;
      end;

   use_current: BOOLEAN is
      do
         if run_control.all_check and then check_invariant /= Void then
            Result := check_invariant.use_current;
         end;
      end;

   pretty_print is
      do
         if check_invariant /= Void then
            check_invariant.pretty_print;
            fmt.put_string("end;");
            if fmt.print_end_check then
               fmt.put_end("check");
            end;
         end;
      end;

feature {NONE}

   check_invariant: CHECK_INVARIANT;

   current_type: TYPE;

   make(sp: like start_position; hc: COMMENT; l: ARRAY[ASSERTION]) is
      require
         not sp.is_unknown
      do
         if hc /= Void or else l /= Void then
            !!check_invariant.make(sp,hc,l);
         end;
      end;

end -- E_CHECK
