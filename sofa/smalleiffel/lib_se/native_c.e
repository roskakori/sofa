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
deferred class NATIVE_C
   --
   -- Common root for NATIVE_WITHOUT_CURRENT, NATIVE_INLINE_WITHOUT_CURRENT,
   -- NATIVE_WITH_CURRENT, NATIVE_INLINE_WITH_CURRENT and NATIVE_C_PLUS_PLUS..
   --

inherit NATIVE;

feature

   frozen stupid_switch_function(r: ARRAY[RUN_CLASS]; name: STRING): BOOLEAN is
      do
         Result := true;
      end;

   frozen stupid_switch_procedure(r: ARRAY[RUN_CLASS]; name: STRING): BOOLEAN is
      do
         Result := true;
      end;

   need_prototype: BOOLEAN is
      deferred
      end;

feature {NONE}

   frozen standard_c_define_function(rf8: RUN_FEATURE_8; bcn, name: STRING) is
      do
         if need_prototype then
            rf8.c_prototype;
         end;
         if run_control.no_check then
            body.clear;
            body.extend('R');
            body.extend('=');
            wrapped_external_call(rf8.base_feature,rf8.arg_count);
            rf8.c_define_with_body(body);
         end;
      end;

   frozen c_mapping_function(rf8: RUN_FEATURE_8; bcn, name: STRING) is
      do
         if run_control.boost then
            c_mapping_external(rf8.base_feature,rf8.arg_count);
         else
            rf8.default_mapping_function;
         end;
      end;

   frozen standard_c_define_procedure(rf7: RUN_FEATURE_7; bcn, name: STRING) is
      do
         if need_prototype then
            rf7.c_prototype;
         end;
         if run_control.no_check then
            body.clear;
            wrapped_external_call(rf7.base_feature,rf7.arg_count);
            rf7.c_define_with_body(body);
         end;
      end;

   frozen c_mapping_procedure(rf7: RUN_FEATURE_7; bcn, name: STRING) is
      do
         if run_control.boost then
            c_mapping_external(rf7.base_feature,rf7.arg_count);
            cpp.put_string(fz_00);
         else
            rf7.default_mapping_procedure;
         end;
      end;

   frozen c_mapping_external(er: EXTERNAL_ROUTINE; arg_count: INTEGER) is
      local
         eruc, tcbd: BOOLEAN;
      do
         eruc := use_current(er);
         if not eruc then
            tcbd := cpp.target_cannot_be_dropped;
            if tcbd then
               cpp.put_character(',');
            end;
         end;
         cpp.put_string(er.external_c_name);
         cpp.put_character('(');
         if eruc then
            cpp.put_target_as_value;
         end;
         if arg_count > 0 then
            if eruc then
               cpp.put_character(',');
            end;
            cpp.put_arguments;
         end;
         cpp.put_character(')');
         if not eruc and then tcbd then
            cpp.put_character(')');
         end;
      end;

   frozen wrapped_external_call(er: EXTERNAL_ROUTINE; arg_count: INTEGER) is
      local
         i: INTEGER;
      do
         body.append(er.external_c_name);
         body.extend('(');
         if use_current(er) then
            body.extend('C');
            if arg_count > 0 then
               body.extend(',');
            end;
         end;
         from
            i := 1;
         until
            i > arg_count
         loop
            body.extend('a');
            i.append_in(body);
            i := i + 1;
            if i <= arg_count then
               body.extend(',');
            end;
         end;
         body.append(fz_14);
      end;

end -- NATIVE_C

