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
class NATIVE_JVM_INVOKESTATIC

inherit NATIVE_JVM;

creation make

feature

   use_current(er: EXTERNAL_ROUTINE): BOOLEAN is
      do
      end;

   jvm_mapping_function(rf8: RUN_FEATURE_8; bcn, name: STRING) is
      local
         space, idx: INTEGER;
         ca: like code_attribute;
      do
         ca := code_attribute;
         jvm.drop_target;
         space := jvm.push_arguments;
         idx := idx_methodref(rf8.base_feature);
         space := rf8.result_type.jvm_stack_space - space;
         ca.opcode_invokestatic(idx,space);
      end;

   jvm_define_function(rf8: RUN_FEATURE_8; bcn, name: STRING) is
      do
      end;

   jvm_mapping_procedure(rf7: RUN_FEATURE_7; bcn, name: STRING) is
      do
      end;

   jvm_define_procedure(rf7: RUN_FEATURE_7; bcn, name: STRING) is
      do
      end;

   jvm_add_method_for_function(rf8: RUN_FEATURE_8; bcn, name: STRING) is
      do
      end;

   jvm_add_method_for_procedure(rf7: RUN_FEATURE_7; bcn, name: STRING) is
      do
      end;

end -- NATIVE_JVM_INVOKESTATIC

