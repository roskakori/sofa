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
class TYPE_DOUBLE
   --
   -- Handling of DOUBLE type mark.
   --

inherit
   TYPE_BASIC_EIFFEL_EXPANDED
      redefine is_double
      end;

creation make

feature

   is_double: BOOLEAN is true;

   id: INTEGER is 5;

feature

   make(sp: like start_position) is
      do
         !!base_class_name.make(as_double,sp);
      end;

   actual_reference(destination: TYPE): TYPE is
      local
         cn: CLASS_NAME;
      do
         if destination.run_time_mark = as_double_ref then
            Result := destination;
         else
            !!cn.make(as_double_ref,destination.start_position);
            !TYPE_CLASS!Result.make(cn);
         end;
      end;

   c_sizeof: INTEGER is
      do
         Result := (0.0).to_double.object_size;
      end;

   is_a(other: TYPE): BOOLEAN is
      do
         if other.is_double then
            Result := true;
         elseif base_class.is_subclass_of(other.base_class) then
            Result := true;
         end;
         if not Result then
            eh.add_type(Current,fz_inako);
            eh.add_type(other,fz_dot);
         end;
      end;

   smallest_ancestor(other: TYPE): TYPE is
      local
         rto: TYPE;
      do
         rto := other.run_type;
         if rto.is_integer then
            Result := Current;
         elseif rto.is_real then
            Result := Current;
         elseif rto.is_double then
            Result := Current;
         else
            Result := type_double_ref.smallest_ancestor(rto);
         end;
      end;

   to_runnable(rt: TYPE): like Current is
      do
         Result := Current;
         check_type;
      end;

   written_mark, run_time_mark: STRING is
      do
         Result := as_double
      end;

   c_type_for_argument_in(str: STRING) is
      do
         str.extend('T');
         str.extend('5');
      end;

   jvm_descriptor_in(str: STRING) is
      do
         str.extend('D');
      end;

   jvm_return_code is
      do
         code_attribute.opcode_dreturn;
      end;

   jvm_push_local(offset: INTEGER) is
      do
         code_attribute.opcode_dload(offset);
      end;

   jvm_push_default: INTEGER is
      do
         code_attribute.opcode_dconst_0;
         Result := 2;
      end;

   jvm_write_local(offset: INTEGER) is
      do
         code_attribute.opcode_dstore(offset);
      end;

   jvm_xnewarray is
      do
         code_attribute.opcode_newarray(7);
      end;

   jvm_xastore is
      do
         code_attribute.opcode_dastore;
      end;

   jvm_xaload is
      do
         code_attribute.opcode_daload;
      end;

   jvm_if_x_eq: INTEGER is
      local
         ca: like code_attribute;
      do
         ca := code_attribute;
         ca.opcode_dcmpg;
         Result := ca.opcode_ifeq;
      end;

   jvm_if_x_ne: INTEGER is
      local
         ca: like code_attribute;
      do
         ca := code_attribute;
         ca.opcode_dcmpg;
         Result := ca.opcode_ifne;
      end;

   jvm_to_reference is
      local
         rc: RUN_CLASS;
         idx: INTEGER;
         ca: like code_attribute;
      do
         ca := code_attribute;
         rc := type_double_ref.run_class;
         rc.jvm_basic_new;
         ca.opcode_dup_x2;
         ca.opcode_dup_x2;
         ca.opcode_pop;
         idx := rc.jvm_constant_pool_index;
         idx := constant_pool.idx_fieldref4(idx,as_item,fz_77);
         ca.opcode_putfield(idx,-3);
      end;

   jvm_expanded_from_reference(other: TYPE): INTEGER is
      local
         rc: RUN_CLASS;
         idx: INTEGER;
         ca: like code_attribute;
      do
         ca := code_attribute;
         rc := type_double_ref.run_class;
         rc.opcode_checkcast;
         idx := rc.jvm_constant_pool_index;
         idx := constant_pool.idx_fieldref4(idx,as_item,fz_77);
         ca.opcode_getfield(idx,1);
         Result := 2;
      end;

   jvm_convert_to(destination: TYPE): INTEGER is
      do
         if destination.is_reference then
            jvm_to_reference;
            Result := 1;
         elseif destination.is_real then
            code_attribute.opcode_d2f
            Result := 1;
         elseif destination.is_integer then
            code_attribute.opcode_d2i
            Result := 1;
         else
            check
               destination.is_double
            end;
            Result := 2;
         end;
      end;

feature {NONE}

   type_double_ref: TYPE_CLASS is
      local
         double_ref: CLASS_NAME;
      once
         !!double_ref.unknown_position(as_double_ref);
         !!Result.make(double_ref);
      end;

   check_type is
         -- Do some checking for type DOUBLE.
      local
         bc: BASE_CLASS;
         rc: RUN_CLASS;
      once
         bc := base_class;
         if nb_errors = 0 then
            rc := run_class;
            load_ref(as_double_ref);
         end;
         if nb_errors = 0 then
            if not bc.is_expanded then
               error(start_position,"DOUBLE must be expanded.");
            end;
         end;
      end;

invariant

   written_mark = as_double

end -- TYPE_DOUBLE

