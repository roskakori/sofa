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
deferred class GLOBALS
   --
   -- Global Tools for the SmallEiffel system.
   --

inherit ALIASED_STRING_LIST; FROZEN_STRING_LIST;

feature

   frozen small_eiffel: SMALL_EIFFEL is
      once
         !!Result.make;
      end;

   frozen eiffel_parser : EIFFEL_PARSER is
      once
         !!Result;
      end;

   frozen run_control: RUN_CONTROL is
      once
         !!Result.make;
      end;

   frozen eh: ERROR_HANDLER is
      once
         !!Result;
      end;

   frozen string_aliaser: STRING_ALIASER is
      once
         !!Result.make;
      end;

   frozen cpp: C_PRETTY_PRINTER is
      once
         !!Result;
      end;

   frozen jvm: JVM is
      once
         !!Result.make;
      end;

   frozen fmt: FMT is
      once
         !!Result.make;
      end;

   frozen constant_pool: CONSTANT_POOL is
      once
         !!Result;
      end;

   nb_errors: INTEGER is
      do
         Result := eh.error_counter;
      ensure
         Result >= 0
      end;

   frozen gc_handler: GC_HANDLER is
      once
         !!Result.make;
      end;

feature {SMALL_EIFFEL}

   frozen parser_buffer: PARSER_BUFFER is
      once
         !!Result.make;
      end;

feature {NONE}

   frozen system_tools: SYSTEM_TOOLS is
      once
         !!Result.make;
      end;

   frozen id_provider: ID_PROVIDER is
      once
         !!Result.make;
      end;

   frozen manifest_string_pool: MANIFEST_STRING_POOL is
      once
         !!Result;
      end;

   frozen manifest_array_pool: MANIFEST_ARRAY_POOL is
      once
         !!Result;
      end;

   frozen once_routine_pool: ONCE_ROUTINE_POOL is
      once
         !!Result;
      end;

   frozen cecil_pool: CECIL_POOL is
      once
         !!Result;
      end;

   frozen address_of_pool: ADDRESS_OF_POOL is
      once
         !!Result;
      end;

   frozen short_print: SHORT_PRINT is
      once
         !!Result.make;
      end;

   frozen echo: ECHO is
      once
         !!Result.make;
      end;

   frozen conversion_handler: CONVERSION_HANDLER is
      once
         !!Result;
      end;

   frozen switch_collection: SWITCH_COLLECTION is
      once
      end;

   frozen assertion_collector: ASSERTION_COLLECTOR is
      once
         !!Result.make;
      end;

   frozen exceptions_handler: EXCEPTIONS_HANDLER is
      once
         !!Result.make;
      end;

   frozen field_info: FIELD_INFO is
      once
         !!Result;
      end;

   frozen code_attribute: CODE_ATTRIBUTE is
      once
         !!Result;
      end;

   frozen method_info: METHOD_INFO is
      once
         !!Result;
      end;

   nb_warnings: INTEGER is
      do
         Result := eh.warning_counter;
      ensure
         Result >= 0
      end;

   warning(p: POSITION; msg: STRING) is
         -- Warning `msg' at position `p'.
      require
         not msg.is_empty
      do
         eh.add_position(p);
         eh.append(msg);
         eh.print_as_warning;
      ensure
         nb_warnings = old nb_warnings + 1
      end;

   error(p: POSITION; msg: STRING) is
         -- When error `msg' occurs at position `p'.
      require
         not msg.is_empty
      do
         eh.add_position(p);
         eh.append(msg);
         eh.print_as_error;
      ensure
         nb_errors = old nb_errors + 1
      end;

   fatal_error(msg: STRING) is
         -- Should not append but it is better to know :-)
      require
         not msg.is_empty
      do
         eh.append(msg);
         eh.print_as_fatal_error;
      end;

   tmp_path: STRING is
      once
         !!Result.make(512);
      end;

   tmp_file_read: STD_FILE_READ is
      once
         !!Result.make;
      end;

   class_any: BASE_CLASS is
      once
         Result := small_eiffel.get_class(as_any);
      end;

   class_general: BASE_CLASS is
      once
         Result := small_eiffel.get_class(as_general);
      end;

   type_boolean: TYPE_BOOLEAN is
      local
         unknown_position: POSITION;
      once
         !!Result.make(unknown_position);
      end;

   type_string: TYPE_STRING is
      local
         unknown_position: POSITION;
      once
         !!Result.make(unknown_position);
      end;

   type_any: TYPE_ANY is
      local
         unknown_position: POSITION;
      once
         !!Result.make(unknown_position);
      end;

   type_pointer: TYPE_POINTER is
      local
         unknown_position: POSITION;
      once
         !!Result.make(unknown_position);
      end;

   sort_running(run: ARRAY[RUN_CLASS]) is
         -- Sort `run' to put small `id' first.
      require
         run.lower = 1;
         run.upper >= 2;
      local
         min, max, buble: INTEGER;
         moved: BOOLEAN;
      do
         from
            max := run.upper;
            min := 1;
            moved := true;
         until
            not moved
         loop
            moved := false;
            if max - min > 0 then
               from
                  buble := min + 1;
               until
                  buble > max
               loop
                  if run.item(buble - 1).id > run.item(buble).id then
                     run.swap(buble - 1,buble);
                     moved := true;
                  end;
                  buble := buble + 1;
               end;
               max := max - 1;
            end;
            if moved and then max - min > 0 then
               from
                  moved := false;
                  buble := max - 1;
               until
                  buble < min
               loop
                  if run.item(buble).id > run.item(buble + 1).id then
                     run.swap(buble,buble + 1);
                     moved := true;
                  end;
                  buble := buble - 1;
               end;
               min := min + 1;
            end;
         end;
      end;

   no_errors: BOOLEAN is
      do
         Result := nb_errors = 0;
      end;

   character_coding(c: CHARACTER; str: STRING) is
         -- Append in `str' the Eiffel coding of the character (Table
         -- in chapter 25 of ETL, page 423).
         -- When letter notation exists, it is returned in priority :
         --  '%N' gives "%N", '%T' gives "%T", ...
         -- When letter notation does not exists (not in ETL table),
         -- numbered coding is used ("%/1/", "%/2/" etc).
      local
         special: CHARACTER
      do
         inspect
            c
         when '%A' then special := 'A';
         when '%B' then special := 'B';
         when '%C' then special := 'C';
         when '%D' then special := 'D';
         when '%F' then special := 'F';
         when '%H' then special := 'H';
         when '%L' then special := 'L';
         when '%N' then special := 'N';
         when '%Q' then special := 'Q';
         when '%R' then special := 'R';
         when '%S' then special := 'S';
         when '%T' then special := 'T';
         when '%U' then special := 'U';
         when '%V' then special := 'V';
         when '%%' then special := '%%';
         when '%'' then special := '%'';
         when '%"' then special := '"';
         when '%(' then special := '(';
         when '%)' then special := ')';
         when '%<' then special := '<';
         when '%>' then special := '>';
         else
         end;
         str.extend('%%');
         if special = '%U' then
            str.extend('/');
            c.code.append_in(str);
            str.extend('/');
         else
            str.extend(special);
         end;
      end;

   fatal_error_vtec_2 is
      do
         fatal_error("Expanded class must have no creation procedure,%
                      % or only one creation procedure with%
                      % no arguments (VTEC.2).");
      end;

   eiffel_suffix: STRING is ".e";
         -- Eiffel Source file suffix.

   c_suffix: STRING is ".c";
         -- C files suffix.

   h_suffix: STRING is ".h";
         -- Heading C files suffix.

   c_plus_plus_suffix: STRING is ".cpp";
         -- C++ files suffix.

   backup_suffix: STRING is ".bak";
         -- Backup suffix for command `pretty'.

   help_suffix: STRING is ".txt";
         -- Suffix for SmallEiffel On-line Help Files.

   class_suffix: STRING is ".class";

   dot_precedence: INTEGER is 12;
         -- The highest precedence value according to ETL.

   atomic_precedence: INTEGER is 13;
         -- Used for atomic elements.

   jvm_root_class: STRING is
         -- Fully qualified name for the jvm SmallEiffel object's
         -- added root : "<Package>/<fz_jvm_root>".
      once
         !!Result.make(12);
         Result.copy(run_control.output_name);
         Result.extend('/');
         Result.append(fz_jvm_root);
      end;

   jvm_root_descriptor: STRING is
         -- Descriptor for `jvm_root_class': "L<jvm_root_class>;"
      once
         !!Result.make(12);
         Result.extend('L');
         Result.append(jvm_root_class);
         Result.extend(';');
      end;

   append_u1(str: STRING; u1: INTEGER) is
      require
         u1.in_range(0,255);
      do
         str.extend(u1.to_character);
      end;

   append_u2(str: STRING; u2: INTEGER) is
      require
         u2.in_range(0,65536)
      do
         append_u1(str,u2 // 256);
         append_u1(str,u2 \\ 256);
      end;

   append_u4(str: STRING; u4: INTEGER) is
      require
         u4.in_range(0,(2 ^ 31) - 1)
      do
         append_u2(str,u4 // 65536);
         append_u2(str,u4 \\ 65536);
      end;

   c_frame_descriptor_local_count: COUNTER is
         -- Current is not in this total.
      once
         !!Result;
      end;

   c_frame_descriptor_format: STRING is
         -- The format to print Current and other locals.
      once
         !!Result.make(512);
      end;

   c_frame_descriptor_locals: STRING is
         -- To initialize field `locals' of `se_dump_stack'.
      once
         !!Result.make(512);
      end;

end -- GLOBALS
