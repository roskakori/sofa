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
class FMT
   --
   -- Driver for Pretty Printing Eiffel code.
   --

creation make

feature {NONE}

   sfw: STD_FILE_WRITE;
         -- Where printing is done.

   C_default: INTEGER is 0;
   C_zen:     INTEGER is 1;
   C_end:     INTEGER is 2;
   C_parano:  INTEGER is 3;

   indent_increment: INTEGER is 3;
         -- Basic standard increment.

   make is
      do
      end;

feature

   mode: INTEGER;
         -- Internal code to memorize the mode : "-zen|-default|-end|-parano"

   valid_mode(m: INTEGER): BOOLEAN is
         -- Is the mode previously obtained using `mode' ?
      do
         inspect
            m
         when C_zen, C_default, C_end, C_parano then
            Result := true;
         else
         end;
      end;

   set_mode(m: INTEGER) is
         -- Where `m' is a valid mode previously obtained using `mode'.
      require
         valid_mode(m)
      do
         mode := m;
      ensure
         mode = m
      end;

   column: INTEGER;
         -- Current column in output file. Left most
         -- column is number 1;

   line: INTEGER;
         -- Current column in output file.

   blank_lines: INTEGER;
         -- Number of blank lines at current position.


   last_character: CHARACTER;
         -- Last printed one.

   indent_level: INTEGER;
         -- Current `indent_level'.

   semi_colon_flag: BOOLEAN;
         -- When Current instruction must add a following semi_colon.

   set_semi_colon_flag(v: like semi_colon_flag) is
      do
         semi_colon_flag := v;
      end;

   set_indent_level(il: INTEGER) is
      require
         il >= 0;
      do
         indent_level := il;
      ensure
         indent_level = il;
      end;

   level_incr is
      do
         indent_level := indent_level + 1;
      end;

   level_decr is
      require
         indent_level > 0;
      do
         indent_level := indent_level - 1;
      end;

feature -- Initial mode setting :

   set_zen is
         -- The less you can print, no Current when not necessary,
         -- no end of constructs, no ends of routine and
         -- compact printing.
      do
         mode := C_zen;
      end;

   set_default is
         -- Default pretty printing mode.
      do
         mode := C_default;
      end;

   set_end is
         -- Print ends of all constructs.
      do
         mode := C_end;
      end;

   set_parano is
         -- The more you can print (parano mode).
      do
         mode := C_parano;
      end;

feature -- Printing Features :

   put_end(what: STRING) is
      do
         put_string("-- ");
         put_string(what);
         put_character('%N');
      end;

   keyword(k: STRING) is
         -- Print keyword `k'.
         -- If needed, a space is added before `k'.
         -- Always add a ' ' after `k'.
      require
         not k.has('%N');
         not k.has('%T');
      do
         inspect
            last_character
         when ' ','%N','%U' then
         else
            put_character(' ');
         end;
         put_string(k);
         if last_character /= ' ' then
            put_character(' ');
         end;
      ensure
         last_character = ' ';
      end;

   skip(line_count: INTEGER) is
      -- Add if needed `line_count' blanks lines and do `indent'.
      require
         line_count >= 0;
      do
         from
         until
            blank_lines >= line_count
         loop
            put_character('%N');
         end;
         indent;
      ensure
         blank_lines >= line_count;
      end;

   put_integer(i: INTEGER) is
      -- Print `i' using `put_string'.
      do
         tmp_string.clear;
         i.append_in(tmp_string);
         put_string(tmp_string);
      end;

   put_string(s: STRING) is
      require
         s /= Void;
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > s.count
         loop
            put_character(s.item(i));
            i := i + 1;
         end;
      end;

   indent is
         -- Go if needed to the `column' according to
         -- the current `indent_level'.
         -- Ensure that the last printed character is ' ' or '%N';
      local
         goal: INTEGER;
      do
         goal := 1 + indent_level * indent_increment;
         if column > goal then
            put_character('%N');
         end;
         from
         until
            goal = column
         loop
            put_character(' ');
         end;
         inspect
            last_character
         when ' ','%N' then
         else
            put_character('%N');
            indent;
         end;
      ensure
         column = indent_level * indent_increment + 1;
         last_character = ' ' or last_character = '%N';
      end;

   put_character(c: CHARACTER) is
      do
         sfw.put_character(c);
         last_character := c;
         inspect
            c
         when '%N' then
            line := line + 1;
            column := 1;
            blank_lines := blank_lines + 1;
         when ' ','%T' then
            column := column + 1;
         else
            column := column + 1;
            blank_lines := -1;
         end;
      end;

feature {PRETTY}

   connect_to(s: like sfw) is
      require
         s /= Void;
      do
         sfw := s;
         line := 1;
         column := 1;
         blank_lines := 0;
         last_character := '%U';
      ensure
         sfw = s;
      end;

feature {NONE}

   tmp_string: STRING is
      once
         !!Result.blank(256);
      end;

feature -- Computed flags :

   zen_mode: BOOLEAN is
      do
         Result := mode = C_zen;
      end;

   print_end_check: BOOLEAN is
      do
         inspect
            mode
         when C_zen then
         when C_default then
         when C_end then
            Result := true;
         when C_parano then
            Result := true;
         end;
      end;

   print_end_loop: BOOLEAN is
      do
         inspect
            mode
         when C_zen then
         when C_default then
         when C_end then
            Result := true;
         when C_parano then
            Result := true;
         end;
      end;

   print_end_if: BOOLEAN is
      do
         inspect
            mode
         when C_zen then
         when C_default then
         when C_end then
            Result := true;
         when C_parano then
            Result := true;
         end;
      end;

   print_end_inspect: BOOLEAN is
      do
         inspect
            mode
         when C_zen then
         when C_default then
         when C_end then
            Result := true;
         when C_parano then
            Result := true;
         end;
      end;

   print_end_debug: BOOLEAN is
      do
         inspect
            mode
         when C_zen then
         when C_default then
         when C_end then
            Result := true;
         when C_parano then
            Result := true;
         end;
      end;

   print_end_routine: BOOLEAN is
      do
         inspect
            mode
         when C_zen then
         when C_default then
            Result := true;
         when C_end then
            Result := true;
         when C_parano then
            Result := true;
         end;
      end;

   print_current: BOOLEAN is
      do
         inspect
            mode
         when C_zen then
         when C_default then
         when C_end then
         when C_parano then
            Result := true;
         end;
      end;

invariant

   indent_level >= 0;

   valid_mode(mode)

end -- FMT


