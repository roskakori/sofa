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
class TYPE_FORMAL_GENERIC

inherit
   TYPE
      redefine is_formal_generic, is_boolean, is_character, is_integer, 
         is_real, is_double, is_string, is_array, is_bit, is_pointer
      end;

creation make

feature

   formal_name: CLASS_NAME;
         -- Formal argument name.

   rank: INTEGER;
         -- Rank in the corresponding generic list.

   run_type: TYPE;
         -- Not Void when real type is known.

feature {NONE}

   make(fn: like formal_name; r: INTEGER) is
      require
         fn /= Void;
         r > 0
      do
         rank := r;
         formal_name := fn;
      ensure
         formal_name = fn;
         rank = r
      end;

feature

   is_formal_generic: BOOLEAN is true;

   is_like_current: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   pretty_print is
      do
         fmt.put_string(written_mark);
      end;

   actual_reference(destination: TYPE): TYPE is
      do
         Result := run_type.actual_reference(destination);
      end;

   static_base_class_name: CLASS_NAME is
      local
         t: TYPE;
      do
         t := constraint;
         if t /= Void then
            Result := t.static_base_class_name;
         else
            -- *** eh.append("TYPE_FORMAL_GENERIC.static_base_class_name NYI");
            -- *** eh.print_as_warning;
         end;
      end;

   run_class: RUN_CLASS is
      do
         Result := small_eiffel.run_class(run_type);
      end;

   c_sizeof: INTEGER is
      do
         Result := run_type.c_sizeof;
      end;

   is_boolean: BOOLEAN is
      do
         Result := run_type.is_boolean;
      end;

   is_character: BOOLEAN is
      do
         Result := run_type.is_character;
      end;

   is_integer: BOOLEAN is
      do
         Result := run_type.is_integer;
      end;

   is_real: BOOLEAN is
      do
         Result := run_type.is_real;
      end;

   is_double: BOOLEAN is
      do
         Result := run_type.is_double;
      end;

   is_string: BOOLEAN is
      do
         Result := run_type.is_string;
      end;

   is_array: BOOLEAN is
      do
         Result := run_type.is_array;
      end;

   is_bit: BOOLEAN is
      do
         Result := run_type.is_bit;
      end;

   is_any: BOOLEAN is
      do
         Result := run_type.is_any;
      end;

   is_none: BOOLEAN is
      do
         Result := run_type.is_none;
      end;

   is_pointer: BOOLEAN is
      do
         Result := run_type.is_pointer;
      end;

   is_reference: BOOLEAN is
      do
         Result := run_type.is_reference;
      end;

   is_expanded: BOOLEAN is
      do
         Result := run_type.is_expanded;
      end;

   is_basic_eiffel_expanded: BOOLEAN is
      do
         Result := run_type.is_basic_eiffel_expanded;
      end;

   is_dummy_expanded: BOOLEAN is
      do
         Result := run_type.is_dummy_expanded;
      end;

   is_user_expanded: BOOLEAN is
      do
         Result := run_type.is_user_expanded;
      end;

   is_generic: BOOLEAN is
      do
         Result := run_type.is_generic;
      end;

   generic_list: ARRAY[TYPE] is
      do
         if is_generic then
            Result := run_type.generic_list;
         else
            fatal_error_generic_list;
         end;
      end;

   c_header_pass1 is
      do
         run_type.c_header_pass1;
      end;

   c_header_pass2 is
      do
         run_type.c_header_pass2;
      end;

   c_header_pass3 is
      do
         run_type.c_header_pass3;
      end;

   c_header_pass4 is
      do
         run_type.c_header_pass4;
      end;

   c_initialize is
      do
         run_type.c_initialize;
      end;

   c_initialize_in(str: STRING) is
      do
         run_type.c_initialize_in(str);
      end;

   expanded_initializer: RUN_FEATURE_3 is
      do
         Result := run_type.expanded_initializer;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := standard_stupid_switch(r);
      end;
   
   id: INTEGER is
      do
         Result := run_class.id;
      end;

   has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
         if Current = run_type then
            Result := base_class.has_creation(fn);
         else
            Result := run_type.has_creation(fn);
         end;
      end;

   base_class_name: CLASS_NAME is
      do
         Result := run_type.base_class_name;
      end;

   start_position: POSITION is
      do
         Result := formal_name.start_position;
      end;

   c_type_for_argument_in(str: STRING) is
      do
         run_type.c_type_for_argument_in(str);
      end;

   c_type_for_target_in(str: STRING) is
      do
         run_type.c_type_for_target_in(str);
      end;

   c_type_for_result_in(str: STRING) is
      do
         run_type.c_type_for_result_in(str);
      end;

   need_c_struct: BOOLEAN is
      do
         Result := run_type.need_c_struct;
      end;

   formal_generic_list: FORMAL_GENERIC_LIST is
         -- Formal generic list it belongs to.
      do
         Result := start_position.base_class.formal_generic_list;
      end;

   formal_arg: FORMAL_GENERIC_ARG is
      do
         Result := formal_generic_list.item(rank);
      end;

   constraint: TYPE is
      do
         Result := formal_arg.constraint;
      end;

   smallest_ancestor(other: TYPE): TYPE is
      do
         Result := run_type.smallest_ancestor(other);
      end;

   is_a(other: TYPE): BOOLEAN is
      do
         Result := run_type.is_a(other);
      end;

   is_run_type: BOOLEAN is
      do
         Result := run_type /= Void;
      end;

   written_mark: STRING is
      do
         Result := formal_name.to_string;
      end;

   run_time_mark: STRING is
      do
         Result := run_type.run_time_mark;
      end;

   jvm_method_flags: INTEGER is
      do
         Result := run_type.jvm_method_flags;
      end;

   jvm_descriptor_in(str: STRING) is
      do
         run_type.jvm_descriptor_in(str);
      end;

   jvm_target_descriptor_in(str: STRING) is
      do
         run_type.jvm_target_descriptor_in(str);
      end;

   jvm_return_code is
      do
         run_type.jvm_return_code;
      end;

   jvm_push_local(offset: INTEGER) is
      do
         run_type.jvm_push_local(offset);
      end;

   jvm_check_class_invariant is
      do
         run_type.jvm_check_class_invariant;
      end;

   jvm_push_default: INTEGER is
      do
         Result := run_type.jvm_push_default;
      end;

   jvm_write_local(offset: INTEGER) is
      do
         run_type.jvm_write_local(offset);
      end;

   jvm_xnewarray is
      do
         run_type.jvm_xnewarray;
      end;

   jvm_xastore is
      do
         run_type.jvm_xastore;
      end;

   jvm_xaload is
      do
         run_type.jvm_xaload;
      end;

   jvm_if_x_eq: INTEGER is
      do
         Result := run_type.jvm_if_x_eq;
      end;

   jvm_if_x_ne: INTEGER is
      do
         Result := run_type.jvm_if_x_ne;
      end;

   jvm_to_reference is
      do
         run_type.jvm_to_reference;
      end;

   jvm_expanded_from_reference(other: TYPE): INTEGER is
      do
         Result := run_type.jvm_expanded_from_reference(other);
      end;

   jvm_convert_to(destination: TYPE): INTEGER is
      do
         Result := run_type.jvm_convert_to(destination);
      end;

   jvm_standard_is_equal is
      do
         run_type.jvm_standard_is_equal;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         bc_written, bc_ct: BASE_CLASS;
         p: PARENT;
         t: TYPE;
         gl: ARRAY[TYPE];
      do
         bc_written := start_position.base_class;
         bc_ct := ct.base_class;
         if bc_written = bc_ct then
            gl := ct.generic_list;
            if gl = Void or else rank > gl.upper then
               eh.add_position(ct.start_position);
               eh.add_position(start_position);
               fatal_error(fz_bnga);
            else
               Result := make_runnable(gl.item(rank));
            end;
         else
            check
               bc_ct.is_subclass_of(bc_written)
            end;
            from
               p := bc_ct.first_parent_for(bc_written);
            until
               p = Void
            loop
               t := p.type;
               t := t.to_runnable(ct).run_type;
               if Result = Void then
                  Result := to_runnable(t);
                  p := Void;
               else
                  p := bc_ct.next_parent_for(bc_written,p);
               end;
            end;
            if Result = Void then
               eh.add_type(ct," is the context.");
               warning(start_position,"Unable to compute this type.");
            end;
         end;
      end;

feature {RUN_CLASS,TYPE}

   need_gc_mark_function: BOOLEAN is
      do
         Result := run_type.need_gc_mark_function;
      end;

   just_before_gc_mark_in(str: STRING) is
      do
         run_type.just_before_gc_mark_in(str);
      end;

   gc_info_in(str: STRING) is
      do
         run_type.gc_info_in(str);
      end;

   gc_define1 is
      do
         run_type.gc_define1;
      end;

   gc_define2 is
      do
         run_type.gc_define2;
      end;

feature {TYPE_FORMAL_GENERIC}

   make_runnable(rt: like run_type): like Current is
      local
         rt2: TYPE;
      do
         rt2 := rt.run_type;
         if rt2 = Void then
            if rt /= Void then
               eh.add_position(rt.start_position);
            end;
            error(start_position,fz_bga);
         elseif run_type = Void then
            run_type := rt2;
            Result := Current;
         else
            Result := twin;
            Result.set_run_type(rt2);
         end;
      end;

   set_run_type(rt: TYPE) is
      require
         rt /= Void
      do
         run_type := rt;
      ensure
         run_type = rt
      end;

feature {TYPE}

   frozen short_hook is
      do
         short_print.a_class_name(formal_name);
      end;

invariant

   not start_position.is_unknown;

end -- TYPE_FORMAL_GENERIC

