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
class RUN_CONTROL
   --
   -- Singleton object in charge of Eiffel run time options..
   --

inherit GLOBALS;

creation make

feature {NONE} -- Numbering of levels is that of E.T.L. (pp 133) :

   level: INTEGER;
         -- Actual level of checking;

   level_no: INTEGER is -5;
         -- No assertion checking of any kind.

   level_require: INTEGER is -4;
         -- Evaluate the preconditions.

   level_ensure: INTEGER is -3;
         -- Also evaluate postconditions.

   level_invariant: INTEGER is -2;
         -- Also evaluate the class invariant on entry to and return from.

   level_loop: INTEGER is -1;
         -- Also evaluate the loop variant and the loop invariant.

   level_check_all: INTEGER is 0;
         -- Also evaluate the check instruction.
         -- The default value.

   level_check_debug: INTEGER is 1;
         -- Also evaluate the debug instruction.

   level_boost: INTEGER is -6;
         -- BOOST :-). Very very speed level.
         -- Do not check for Void target.
         -- Do not check system level validity.

   make is
      do
      end;

feature  -- Consultation :

   trace: BOOLEAN;
         -- Code generated with the -trace flag mode.

   boost: BOOLEAN is
      do
         Result := level = level_boost;
      end;

   no_check: BOOLEAN is
      do
         Result := level >= level_no;
      end;

   require_check: BOOLEAN is
      do
         Result := level >= level_require;
      end;

   ensure_check: BOOLEAN is
      do
         Result := level >= level_ensure;
      end;

   invariant_check: BOOLEAN is
      do
         Result := level >= level_invariant;
      end;

   loop_check: BOOLEAN is
      do
         Result := level >= level_loop;
      end;

   all_check: BOOLEAN is
      do
         Result := level >= level_check_all;
      end;

   debug_check: BOOLEAN is
      do
         Result := level = level_check_debug;
      end;

   root_class: STRING;
         -- Name of the root class using only upper case letter.

   root_procedure: STRING is
         -- Name of the root procedure.
      do
         Result := root_procedure_memory;
         if Result = Void then
            Result := as_make;
         end;
      end;

feature

   compute_root_class(command_line_name: STRING) is
         -- Create and compute the `root_class' name using the `command_line_name'
         -- as a model.
         -- Trailing Eiffel file suffix is removed if any.
         -- Leading path is also removed if any.
         -- Finally, the feature `to_upper' is applied.
      require
         not command_line_name.is_empty
      local
         i: INTEGER;
         c: CHARACTER;
      do
         root_class := command_line_name.twin;
         if root_class.has_suffix(eiffel_suffix) then
            root_class.remove_last(2);
         end;
         from
            i := root_class.count;
         until
            i = 0
         loop
            c := root_class.item(i);
            if c.is_letter then
               i := i - 1;
            elseif c = '_' then
               i := i - 1;
            elseif c.is_digit then
               i := i - 1;
            else
               root_class.remove_first(i);
               i := 0;
            end;
         end;
         root_class.to_upper;
         root_class := string_aliaser.item(root_class);
      ensure
         root_class /= command_line_name;
         root_class = string_aliaser.item(root_class);
         not root_class.has_suffix(eiffel_suffix)
      end;

feature

   generating_type_used: BOOLEAN;
         -- When GENERAL `generating_type' is used.

   generator_used: BOOLEAN;
         -- When GENERAL `generator' is used.

   deep_twin_used: BOOLEAN;
	 -- When GENERAL `deep_twin' is used.

   is_deep_equal_used: BOOLEAN;
	 -- When GENERAL `is_deep_equal' is used.

feature -- Setting :

   set_boost is
      do
         level := level_boost;
      end;

   set_no_check is
      do
         level := level_no;
      end;

   set_require_check is
      do
         level := level_require;
      end;

   set_ensure_check is
      do
         level := level_ensure;
      end;

   set_invariant_check is
      do
         level := level_invariant;
      end;

   set_loop_check is
      do
         level := level_loop;
      end;

   set_all_check is
      do
         level := level_check_all;
      end;

   set_debug_check is
      do
         level := level_check_debug;
      end;

   set_trace is
      do
         trace := true;
      end;

feature

   set_generating_type_used is
      do
         generating_type_used := true;
      end;

   set_generator_used is
      do
         generator_used := true;
      end;

feature {RUN_FEATURE_8}

   set_deep_twin_used is
      do
         deep_twin_used := true;
      end;

   set_is_deep_equal_used is
      do
	 set_deep_twin_used;
         is_deep_equal_used := true;
      end;

feature -- Other settings :

   set_root_procedure(rp: STRING) is
      do
         root_procedure_memory := rp;
      ensure
         root_procedure = rp
      end;

   output_name: STRING;
         -- The executable `ouuput_name'. A Void value means that "a.out" 
         -- is to be used for C mode while using gcc for example.For 
         -- the Java byte-code this name is used as the name of the main 
         -- output class file and as the name of the directory used to 
         -- store auxilliary class files.

feature {COMPILE_TO_C, COMPILE_TO_JVM, INSTALL}

   set_output_name(name: STRING) is
      require
         source_file_protection: not name.has_suffix(".e")
      do
         output_name := name;
      ensure
         output_name = name
      end;

feature {NONE}

   root_procedure_memory: STRING;

   singleton_memory: RUN_CONTROL is
      once
         Result := Current;
      end;

invariant

   is_real_singleton: Current = singleton_memory;

   level_boost <= level ;

   level <= level_check_debug;

end -- RUN_CONTROL

