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
deferred class TYPE_BASIC_EIFFEL_EXPANDED
--
-- Root of TYPE_BOOLEAN, TYPE_CHARACTER, TYPE_INTEGER,
-- TYPE_REAL, TYPE_DOUBLE, and TYPE_POINTER.
--
inherit TYPE;

feature

   base_class_name: CLASS_NAME;

   is_basic_eiffel_expanded: BOOLEAN is true;

   is_none: BOOLEAN is false;

   is_array: BOOLEAN is false;

   is_expanded: BOOLEAN is true;

   is_reference: BOOLEAN is false;

   is_run_type: BOOLEAN is true;

   is_dummy_expanded: BOOLEAN is false;

   is_user_expanded: BOOLEAN is false;

   is_generic: BOOLEAN is false;

   is_any: BOOLEAN is false;

   is_like_current: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   need_c_struct: BOOLEAN is false;

   jvm_method_flags: INTEGER is 9;

   frozen pretty_print is
      do
         fmt.put_string(written_mark);
      end;

   frozen static_base_class_name: CLASS_NAME is
      do
         Result := base_class_name; 
      end;

   frozen jvm_target_descriptor_in(str: STRING) is
      do
         jvm_descriptor_in(str);
      end;

   frozen jvm_check_class_invariant is
      do
      end;

   frozen jvm_standard_is_equal is
      local
         ca: like code_attribute;
         point1, point2: INTEGER;
      do
         ca := code_attribute;
         point1 := jvm_if_x_eq;
         ca.opcode_iconst_0;
         point2 := ca.opcode_goto;
         ca.resolve_u2_branch(point1);
         ca.opcode_iconst_1;
         ca.resolve_u2_branch(point2);
      end;

   frozen start_position: POSITION is
      do
         Result := base_class_name.start_position;
      end;

   frozen has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
         eh.add_position(fn.start_position);
         error(start_position,
               "Such a simple Type has no creation clause.");
      end;

   frozen generic_list: ARRAY[TYPE] is
      do
         fatal_error_generic_list;
      end;

   frozen expanded_initializer: RUN_FEATURE_3 is
      do
      end;

   frozen stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := true;
      end;
   
   frozen run_type: TYPE is
      do
         Result := Current;
      end;

   frozen c_header_pass1 is
      do
      end;

   frozen c_header_pass2 is
      do
      end;

   frozen c_header_pass3 is
      do
      end;

   frozen c_header_pass4 is
      do
      end;

   frozen c_initialize is
      do
         if is_pointer then
            cpp.put_string(fz_null);
         else
            cpp.put_character('0');
         end;
      end;

   frozen c_initialize_in(str: STRING) is
      do
         if is_pointer then
            str.append(fz_null);
         else
            str.extend('0');
         end;
      end;

   frozen c_type_for_target_in(str: STRING) is
      do
         c_type_for_argument_in(str);
      end;

   frozen c_type_for_result_in(str: STRING) is
      do
         c_type_for_argument_in(str);
      end;

feature {RUN_CLASS,TYPE}

   need_gc_mark_function: BOOLEAN is false;

   frozen just_before_gc_mark_in(str: STRING) is
      do
      end;

   frozen gc_info_in(str: STRING) is
      do
      end;

   frozen gc_define1 is
      do
      end;

   frozen gc_define2 is
      do
      end;

feature {TYPE}

   frozen short_hook is
      do
         short_print.a_class_name(base_class_name);
      end;

feature {NONE}

   load_ref(n: STRING) is
	 -- Make the `item' feature live.
      local
         rc: RUN_CLASS;
         rf: RUN_FEATURE;
      do
	 rc := small_eiffel.run_class_for(n);
         rf := rc.get_feature_with(as_item);
      end;

end -- TYPE_BASIC_EIFFEL_EXPANDED

