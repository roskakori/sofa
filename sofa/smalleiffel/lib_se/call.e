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
deferred class CALL
   --
   -- For all sort of feature calls with result value.
   -- So it does not include procedure calls (see PROC_CALL).
   --
   -- Classification: CALL_0 when 0 argument, CALL_1 when
   -- 1 argument and CALL_N when N arguments.
   --

inherit CALL_PROC_CALL; EXPRESSION;

feature

   is_writable: BOOLEAN is false;

   is_current: BOOLEAN is false;

   is_manifest_string: BOOLEAN is false;

   is_manifest_array: BOOLEAN is false;

   is_result: BOOLEAN is false;

   is_void: BOOLEAN is false;

   c_simple: BOOLEAN is false;

   static_result_base_class: BASE_CLASS is
      local
         bc: BASE_CLASS;
         e_feature: E_FEATURE;
         rt: TYPE;
         cn: CLASS_NAME;
      do
         bc := target.static_result_base_class;
         if bc /= Void then
            e_feature := bc.e_feature(feature_name);
            if e_feature /= Void then
               rt := e_feature.result_type;
               if rt /= Void then
                  cn := rt.static_base_class_name;
                  if cn /= Void then
                     Result := cn.base_class;
                  end;
               end;
            end;
         end;
      end;
         
   frozen mapping_c_target(formal_type: TYPE) is
      local
         flag: BOOLEAN;
         actual_type: like result_type;
      do
         flag := cpp.call_invariant_start(formal_type);
         actual_type := result_type.run_type;
         if actual_type.is_reference then
            if formal_type.is_reference then
               -- Reference into Reference :
               formal_type.mapping_cast;
               cpp.put_character('(');
               compile_to_c;
               cpp.put_character(')');
            else
               -- Reference into Expanded :
               compile_to_c;
            end;
         else
            if formal_type.is_reference then
               -- Expanded into Reference :
               compile_to_c;
            else
               -- Expanded into Expanded :
               if formal_type.need_c_struct then
                  cpp.put_character('&');
                  cpp.put_character('(');
                  compile_to_c;
                  cpp.put_character(')');
               else
                  compile_to_c;
               end;
            end;
         end;
         if flag then
            cpp.call_invariant_end;
         end;
      end;

   frozen mapping_c_arg(formal_arg_type: TYPE) is
      do
         compile_to_c;
      end;

   frozen c_declare_for_old is
      do
         target.c_declare_for_old;
         if arg_count > 0 then
            arguments.c_declare_for_old;
         end;
      end;

   frozen compile_to_c_old is
      do
         target.compile_to_c_old;
         if arg_count > 0 then
            arguments.compile_to_c_old;
         end;
      end;

   frozen compile_to_jvm_old is
      do
         target.compile_to_jvm_old;
         if arg_count > 0 then
            arguments.compile_to_jvm_old;
         end;
      end;

   print_as_target is
      do
         pretty_print;
         fmt.put_character('.');
      end;

   frozen compile_target_to_jvm is
      do
         standard_compile_target_to_jvm;
      end;

   frozen compile_to_jvm_into(dest: TYPE): INTEGER is
      do
         Result := standard_compile_to_jvm_into(dest);
      end;

   frozen jvm_assign is
      do
      end;

   frozen stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := call_proc_call_stupid_switch(r);
         if Result then
            Result := not result_type.is_native_array;
         end;
      end;

feature {NONE}

   frozen run_feature_has_result is
      do
         if run_feature.result_type = Void then
            eh.add_position(run_feature.start_position);
            eh.add_position(feature_name.start_position);
            fatal_error("Feature found is a procedure.");
         end;
      end;

end -- CALL
