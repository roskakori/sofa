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
class INSTRUCTION_WITH_COMMENT
   --
   -- To store one instruction with a following comment.
   --

inherit INSTRUCTION;

creation make

feature

   instruction : INSTRUCTION;

   comment : COMMENT;

feature

   make(i: like instruction; c: like comment) is
      require
         i /= void;
         really_a_comment: c.count > 0;
      do
         instruction := i;
         comment := c;
      end;

feature

   end_mark_comment: BOOLEAN is false;

feature

   use_current: BOOLEAN is
      do
         Result := instruction.use_current;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := instruction.stupid_switch(r);
      end;

   afd_check is
      do
         instruction.afd_check;
      end;

   collect_c_tmp is
      do
         instruction.collect_c_tmp;
      end;

   compile_to_c is
      do
         instruction.compile_to_c;
      end;

   compile_to_jvm is
      do
         instruction.compile_to_jvm;
      end;

   is_pre_computable: BOOLEAN is
      do
         Result := instruction.is_pre_computable;
      end;

   start_position: POSITION is
      do
         Result := instruction.start_position;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         ri: like instruction;
      do
         ri := instruction.to_runnable(ct);
         if ri = Void then
            error(instruction.start_position,"Bad instruction.");
            Result := Current;
         elseif ri = instruction then
            Result := Current;
         else
            !!Result.make(ri,comment);
         end;
      end;

   pretty_print is
      local
         fmt_mode: INTEGER;
      do
         if comment.dummy then
            instruction.pretty_print;
         else
            fmt_mode := fmt.mode;
            fmt.set_zen;
            instruction.pretty_print;
            fmt.level_incr;
            fmt.indent;
            fmt.level_decr;
            comment.pretty_print;
            fmt.set_mode(fmt_mode);
         end;
      end;

invariant

   instruction /= Void;

   comment /= Void;

end -- INSTRUCTION_WITH_COMMENT

