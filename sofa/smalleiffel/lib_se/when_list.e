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
class WHEN_LIST

inherit GLOBALS;

creation {E_INSPECT} make

creation {E_INSPECT,WHEN_LIST} from_when_list

feature

   e_inspect: E_INSPECT;
         -- Corresponding one when checked.

feature {WHEN_LIST}

   list: ARRAY[E_WHEN];

feature {NONE}

   make(first: E_WHEN) is
      require
	 first /= Void
      do
         !!list.with_capacity(4,1);
	 list.add_last(first);
      ensure
         list.first = first
      end;

feature {E_INSPECT,WHEN_LIST}

   from_when_list(wl: like Current) is
      local
         i: INTEGER;
         e_when: E_WHEN;
      do
         from
            list := wl.list.twin;
            i := 1;
         until
            i > list.upper
         loop
            !!e_when.from_e_when(list.item(i));
            list.put(e_when,i);
            i := i + 1;
         end;
      end;

feature

   pretty_print is
      local
         i, fmt_mode: INTEGER;
      do
         fmt_mode := fmt.mode;
         fmt.set_zen;
         from
            i := 1;
         until
            i > list.upper
         loop
            list.item(i).pretty_print;
            i := i + 1;
            if i <= list.upper then
               fmt.put_character('%N');
               fmt.indent;
            end;
         end;
         fmt.set_mode(fmt_mode);
      end;

   start_position: POSITION is
         -- When not empty, the position of the first
         -- keyword "when".
      do
         Result := list.item(1).start_position;
      end;

feature {E_INSPECT}

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

feature {E_INSPECT,WHEN_LIST}

   includes_integer(v: INTEGER): BOOLEAN is
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            Result or else i > list.upper
         loop
            Result := list.item(i).includes_integer(v);
            i := i + 1;
         end;
      end;

   to_runnable_integer(ei: E_INSPECT): like Current is
      require
         ei /= Void;
      local
         i: INTEGER;
         e_when: E_WHEN;
      do
         if e_inspect = Void then
            e_inspect := ei;
            from
               i := 1;
            until
               i > list.upper or else nb_errors > 0
            loop
               e_when := list.item(i).to_runnable_integer(Current);
               if e_when = Void then
                  error(start_position,em1);
               else
                  list.put(e_when,i);
               end;
               i := i + 1;
            end;
            Result := Current;
         else
            !!Result.from_when_list(Current);
            Result := Result.to_runnable_integer(ei);
         end;
      ensure
         Result.e_inspect = ei
      end;

   to_runnable_character(ei: E_INSPECT): like Current is
      require
         ei /= Void;
      local
         i: INTEGER;
         e_when: E_WHEN;
      do
         if e_inspect = Void then
            e_inspect := ei;
            from
               i := 1;
            until
               i > list.upper or else nb_errors > 0
            loop
               e_when := list.item(i).to_runnable_character(Current);
               if e_when = Void then
                  error(start_position,em1);
               else
                  list.put(e_when,i);
               end;
               i := i + 1;
            end;
            Result := Current;
         else
            !!Result.from_when_list(Current);
            Result := Result.to_runnable_character(ei);
         end;
      ensure
         Result.e_inspect = ei
      end;

   compile_to_c(else_position: POSITION) is
      local
         i: INTEGER;
         last_compound: COMPOUND;
      do
         if list /= Void then
            from
               i := 1;
            until
               i = list.upper
            loop
               list.item(i).compile_to_c;
               i := i + 1;
               if i < list.upper then
                  cpp.put_character(' ');
                  cpp.put_string(fz_else);
                  cpp.put_character(' ');
               end;
            end;
            if i > 1 then
               cpp.put_character(' ');
               cpp.put_string(fz_else);
               cpp.put_character(' ');
            end;
            if else_position.is_unknown and then run_control.boost then
               cpp.put_character('{');
               last_compound := list.item(i).compound;
               if last_compound /= Void then
                  last_compound.compile_to_c;
               end;
               cpp.put_character('}');
            else
               list.item(i).compile_to_c;
            end;
         end;
      end;

   compile_to_jvm(else_position: POSITION) is
      local
         r, i: INTEGER;
      do
         if list /= Void then
            from
               r := list.upper;
               i := 1;
            until
               r = 0
            loop
               r := r - 1;
               list.item(i).compile_to_jvm(else_position,r);
               i := i + 1;
            end;
         end;
      end;

   compile_to_jvm_resolve_branch is
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := list.upper;
            until
               i = 0
            loop
               list.item(i).compile_to_jvm_resolve_branch;
               i := i - 1;
            end;
         end;
      end;


   use_current: BOOLEAN is
      local
         i: INTEGER;
      do
         if list /= Void then
            from
               i := 1;
            until
               i > list.upper or else Result
            loop
               Result := list.item(i).use_current;
               i := i + 1;
            end;
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      local
         i: INTEGER;
      do
         Result := true;
         if list /= Void then
            from
               i := 1;
            until
               not Result or else i > list.upper
            loop
               Result := list.item(i).stupid_switch(r);
               i := i + 1;
            end;
         end;
      end;

feature {E_INSPECT}

   add_last(ew: E_WHEN) is
      require
         ew /= Void;
      do
         list.add_last(ew);
      end;

feature {NONE}

   em1: STRING is "Bad when list.";

end -- WHEN_LIST

