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
class E_PRECURSOR_FUNCTION
   --
   -- Handling of the Precursor function call.
   --

inherit
   E_PRECURSOR redefine run_feature end;
   EXPRESSION;

creation make

feature {E_PRECURSOR}

   run_feature: RUN_FEATURE_11;

feature

   is_current: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   is_result: BOOLEAN is false;

   is_void: BOOLEAN is false;

   is_pre_computable: BOOLEAN is false;

   is_static: BOOLEAN is false;

   is_writable: BOOLEAN is false;

   c_simple: BOOLEAN is false;

   can_be_dropped: BOOLEAN is false

   isa_dca_inline_argument: INTEGER is 0;

   static_result_base_class: BASE_CLASS is
      local
         e_feature: E_FEATURE;
         rt: TYPE;
         bcn: CLASS_NAME;
      do
         if run_feature /= Void then
            e_feature := run_feature.base_feature;
            rt := e_feature.result_type;
            bcn := rt.static_base_class_name;
            if bcn /= Void then
               Result := bcn.base_class;
            end;
         end;
      end;

   result_type: TYPE is
      do
         Result := run_feature.result_type;
      end;

   collect_c_tmp is
      do
         if run_feature /= Void then
            run_feature.collect_c_tmp;
         end;
         if arguments /= Void then
            arguments.collect_c_tmp;
         end;
      end;


   to_runnable(ct: TYPE): like Current is
      local
         wrf: RUN_FEATURE;
         super: EFFECTIVE_ROUTINE;
         pn: PRECURSOR_NAME;
      do
         if current_type = Void then
            current_type := ct;
            Result := Current;
            wrf := small_eiffel.top_rf;
            if wrf.result_type = Void then
               eh.add_position(start_position);
               fatal_error("Inside a procedure, a Precursor call must %
                           %be a procedure call (not a function call).");
            end;
            super := super_feature(wrf);
            pn := precursor_name(wrf.name,super);
            !!run_feature.make(ct,pn,super);
            prepare_arguments(ct);
         else
            !!Result.make(start_position,parent,arguments);
            Result := Result.to_runnable(ct);
         end;
      end;

   stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
      end;

   static_value: INTEGER is
      do
      end;

   dca_inline_argument(formal_arg_type: TYPE) is
      do
      end;

   assertion_check(tag: CHARACTER) is
      do
      end;

   precedence: INTEGER is
      do
         Result := dot_precedence;
      end;

   mapping_c_target(formal_type: TYPE) is
      do
         compile_to_c;
      end;

   mapping_c_arg(formal_arg_type: TYPE) is
      do
         compile_to_c;
      end;

   c_declare_for_old is
      do
         if arguments /= Void then
            arguments.c_declare_for_old;
         end;
      end;

   compile_to_c_old is
      do
         if arguments /= Void then
            arguments.compile_to_c_old;
         end;
      end;

   compile_target_to_jvm is
      do
         standard_compile_target_to_jvm;
      end;

   compile_to_jvm_old is
      do
         if arguments /= Void then
            arguments.compile_to_jvm_old;
         end;
      end;

   compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := standard_compile_to_jvm_into(dest);
      end;

   jvm_branch_if_false: INTEGER is
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifeq;
      end;

   jvm_branch_if_true: INTEGER is
      do
         compile_to_jvm;
         Result := code_attribute.opcode_ifne;
      end;

   jvm_assign is
      do
      end;

   bracketed_pretty_print is
      do
         pretty_print;
      end;

   print_as_target is
      do
         pretty_print;
         fmt.put_character('.');
      end;

   short is
      do
      end;

   short_target is
      do
      end;

feature {NONE}

   put_semi_colon is
      do
      end;

end -- E_PRECURSOR_FUNCTION
