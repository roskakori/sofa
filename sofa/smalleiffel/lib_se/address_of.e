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
class ADDRESS_OF
   --
   -- For the special address form notation : $ feature_name
   --

inherit EXPRESSION;

creation make

feature

   feature_name: FEATURE_NAME;

   is_writable: BOOLEAN is false;

   is_current: BOOLEAN is false;

   is_static: BOOLEAN is false;

   is_pre_computable: BOOLEAN is false;

   is_result: BOOLEAN is false;

   is_void: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   isa_dca_inline_argument: INTEGER is 0;

   use_current: BOOLEAN is true;

   can_be_dropped: BOOLEAN is false;

   c_simple: BOOLEAN is true;

   static_result_base_class: BASE_CLASS is
      do
         Result := small_eiffel.get_class(as_pointer);
      end;

   static_value: INTEGER is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   result_type: TYPE_POINTER is
      do
         Result := type_pointer;
      end;

   assertion_check(tag: CHARACTER) is
      do
      end;

   afd_check is
      do
      end;

   compile_target_to_jvm, compile_to_jvm is
      do
         eh.add_position(start_position);
         fatal_error(fz_jvm_error);
      end;

   jvm_branch_if_false: INTEGER is
      do
      end;

   jvm_branch_if_true: INTEGER is
      do
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
      end;

   collect_c_tmp is
      do
      end;

   compile_to_c is
      do
         cpp.put_string("/*$*/((void*)");
         run_feature.address_of_c_mapping;
         cpp.put_character(')');
      end;

   frozen mapping_c_target(target_type: TYPE) is
      do
         compile_to_c;
      end;

   frozen mapping_c_arg(formal_arg_type: TYPE) is
      do
         compile_to_c;
      end;

   c_declare_for_old is
      do
      end;

   compile_to_c_old is
      do
      end;

   compile_to_jvm_old is
      do
      end;

   to_runnable(ct: TYPE): like Current is
      local
         rc: RUN_CLASS;
         bc: BASE_CLASS;
      do
         if current_type = Void then
            current_type := ct;
            rc := ct.run_class;
            bc := ct.base_class;
            if bc.has(feature_name) then
               run_feature := rc.get_rf_with(feature_name);
               address_of_pool.register_for(Current);
            else
               eh.add_position(feature_name.start_position);
               eh.append(fz_vuar4);
               eh.print_as_fatal_error;
            end;
            Result := Current;
         else
            !!Result.make(feature_name);
            Result := Result.to_runnable(ct);
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
      end;

   precedence: INTEGER is
      do
         Result := atomic_precedence;
      end;

   start_position: POSITION is
      do
         Result := feature_name.start_position;
      end;

   pretty_print is
      do
         fmt.put_character('%D');
         feature_name.pretty_print;
      end;

   print_as_target is
      do
         error(start_position,"ADDRESS_OF/does_not_understand");
      end;

   bracketed_pretty_print is
      do
         fmt.put_character('(');
         pretty_print;
         fmt.put_character(')');
      end;

   short is
      do
         short_print.a_character('%D');
         feature_name.short;
      end;

   short_target is
      do
         bracketed_short;
         short_print.a_dot;
      end;

   jvm_assign is
      do
      end;

feature {ADDRESS_OF_POOL}

   run_feature: RUN_FEATURE;
         -- Corresponding one when runnable.

feature {NONE}

   make(fn: like feature_name) is
      require
         fn /= Void
      do
         feature_name := fn;
      ensure
         feature_name = fn;
      end;

   current_type: TYPE;

invariant

   feature_name /= Void

end --  ADDRESS_OF
