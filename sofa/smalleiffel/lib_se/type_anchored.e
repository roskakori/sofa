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
deferred class TYPE_ANCHORED
   --
   -- Root of anchored declaration type marks.
   --

inherit
   TYPE
      redefine is_anchored, is_boolean, is_character, is_integer, is_real,
         is_double, is_string, is_bit, is_pointer
      end;

feature

   start_position: POSITION;
         -- Of first letter of `like'.

   is_anchored: BOOLEAN is true;

feature

   frozen pretty_print is
      do
         fmt.put_string(written_mark);
      end;

   frozen id: INTEGER is
      do
         Result := run_class.id;
      end;

   frozen base_class_name: CLASS_NAME is
      do
         Result := run_type.base_class_name;
      end;

   frozen actual_reference(destination: TYPE): TYPE is
      do
         Result := run_type.actual_reference(destination);
      end;

   frozen smallest_ancestor(other: TYPE): TYPE is
      do
         Result := run_type.smallest_ancestor(other);
      end;

   frozen run_time_mark: STRING is
      do
         if run_type /= Void then
            Result := run_type.run_time_mark;
         end;
      end;

   frozen has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
         Result := run_type.has_creation(fn);
      end;

   frozen expanded_initializer: RUN_FEATURE_3 is
      do
         Result := run_type.expanded_initializer;
      end;

   frozen stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         -- There is certainly something better to do here, 
         -- but I have no more time to do it ...
      end;
      
   frozen is_expanded: BOOLEAN is
      do
         Result := run_type.is_expanded;
      end;

   is_basic_eiffel_expanded: BOOLEAN is
      do
         Result := run_type.is_basic_eiffel_expanded;
      end;

   frozen is_reference: BOOLEAN is
      do
         Result := run_type.is_reference;
      end;

   frozen is_user_expanded: BOOLEAN is
      do
         Result := run_type.is_user_expanded;
      end;

   frozen is_dummy_expanded: BOOLEAN is
      do
         Result := run_type.is_dummy_expanded;
      end;

   frozen is_generic: BOOLEAN is
      do
         Result := run_type.is_generic;
      end;

   frozen generic_list: ARRAY[TYPE] is
      do
         if is_generic then
            Result := run_type.generic_list;
         else
            fatal_error_generic_list;
         end;
      end;

   frozen c_header_pass1 is
      do
         run_type.c_header_pass1;
      end;

   frozen c_header_pass2 is
      do
         run_type.c_header_pass2;
      end;

   frozen c_header_pass3 is
      do
         run_type.c_header_pass3;
      end;

   frozen c_header_pass4 is
      do
         run_type.c_header_pass4;
      end;

   frozen c_type_for_argument_in(str: STRING) is
      do
         run_type.c_type_for_argument_in(str);
      end;

   frozen c_type_for_target_in(str: STRING) is
      do
         run_type.c_type_for_target_in(str);
      end;

   frozen c_type_for_result_in(str: STRING) is
      do
         run_type.c_type_for_result_in(str);
      end;

   frozen need_c_struct: BOOLEAN is
      do
         Result := run_type.need_c_struct;
      end;

   frozen c_initialize is
      do
         run_type.c_initialize;
      end;

   frozen c_initialize_in(str: STRING) is
      do
         run_type.c_initialize_in(str);
      end;

   frozen jvm_method_flags: INTEGER is
      do
         Result := run_type.jvm_method_flags;
      end;

   frozen jvm_descriptor_in(str: STRING) is
      do
         run_type.jvm_descriptor_in(str);
      end;

   frozen jvm_target_descriptor_in(str: STRING) is
      do
         run_type.jvm_target_descriptor_in(str);
      end;

   frozen jvm_return_code is
      do
         run_type.jvm_return_code;
      end;

   frozen jvm_push_local(offset: INTEGER) is
      do
         run_type.jvm_push_local(offset);
      end;

   frozen jvm_check_class_invariant is
      do
         run_type.jvm_check_class_invariant;
      end;

   frozen jvm_push_default: INTEGER is
      do
         Result := run_type.jvm_push_default;
      end;

   frozen jvm_write_local(offset: INTEGER) is
      do
         run_type.jvm_write_local(offset);
      end;

   frozen jvm_xnewarray is
      do
         run_type.jvm_xnewarray;
      end;

   frozen jvm_xastore is
      do
         run_type.jvm_xastore;
      end;

   frozen jvm_xaload is
      do
         run_type.jvm_xaload;
      end;

   frozen jvm_if_x_eq: INTEGER is
      do
         Result := run_type.jvm_if_x_eq;
      end;

   frozen jvm_if_x_ne: INTEGER is
      do
         Result := run_type.jvm_if_x_ne;
      end;

   frozen jvm_to_reference is
      do
         run_type.jvm_to_reference;
      end;

   frozen jvm_expanded_from_reference(other: TYPE): INTEGER is
      do
         check
            false
         end;
      end;

   frozen jvm_convert_to(destination: TYPE): INTEGER is
      do
         Result := run_type.jvm_convert_to(destination.run_type);
      end;

   frozen jvm_standard_is_equal is
      do
         run_type.jvm_standard_is_equal;
      end;

   frozen c_sizeof: INTEGER is
      do
         Result := run_type.c_sizeof;
      end;

   frozen is_boolean: BOOLEAN is
      do
         Result := run_type.is_boolean;
      end;

   frozen is_character: BOOLEAN is
      do
         Result := run_type.is_character;
      end;

   frozen is_integer: BOOLEAN is
      do
         Result := run_type.is_integer;
      end;

   frozen is_real: BOOLEAN is
      do
         Result := run_type.is_real;
      end;

   frozen is_double: BOOLEAN is
      do
         Result := run_type.is_double;
      end;

   frozen is_string: BOOLEAN is
      do
         Result := run_type.is_string;
      end;

   frozen is_array: BOOLEAN is
      do
         Result := run_type.is_array;
      end;

   frozen is_bit: BOOLEAN is
      do
         Result := run_type.is_bit;
      end;

   frozen is_any: BOOLEAN is
      do
         Result := run_type.is_any;
      end;

   frozen is_none: BOOLEAN is
      do
         Result := run_type.is_none;
      end;

   frozen is_pointer: BOOLEAN is
      do
         Result := run_type.is_pointer;
      end;

feature {RUN_CLASS,TYPE}

   frozen need_gc_mark_function: BOOLEAN is
      do
         Result := run_type.need_gc_mark_function;
      end;

   frozen just_before_gc_mark_in(str: STRING) is
      do
         run_type.just_before_gc_mark_in(str);
      end;

   frozen gc_info_in(str: STRING) is
      do
         run_type.gc_info_in(str);
      end;

   frozen gc_define1 is
      do
         run_type.gc_define1;
      end;

   frozen gc_define2 is
      do
         run_type.gc_define2;
      end;

feature {NONE}

   written_mark_buffer: STRING is
      once
	 !!Result.make(128);
      end;

   anchor_cycle_start is
      local
         i: INTEGER;
      do
         if visited.upper < 0 then
            visited.add_last(start_position);
         elseif visited.fast_has(start_position) then
            from
               i := 0;
            until
               i > visited.upper
            loop
               eh.add_position(visited.item(i));
               i := i + 1;
            end;
            fatal_error(fz_cad);
         else
            visited.add_last(start_position);
         end;
      ensure
         not visited.is_empty
      end;

   anchor_cycle_end is
      do
         if start_position = visited.first then
            visited.clear;
         end;
      end;

   visited: FIXED_ARRAY[POSITION] is
         -- Cycle detection.
      once
         !!Result.with_capacity(4);
      end;

end -- TYPE_ANCHORED

