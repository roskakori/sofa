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
deferred class TYPE_BIT
   --
   -- For declarations of the form :
   --        foo : BIT 32;
   --        foo : BIT Real_size;
   --
   -- And then it is the root class of TYPE_BIT_1 and TYPE_BIT_2.
   --

inherit TYPE redefine is_bit end;

feature

   start_position: POSITION;
         -- Of the BIT class name.

   written_mark: STRING;

feature

   is_bit: BOOLEAN is true;

   is_expanded: BOOLEAN is true;

   is_basic_eiffel_expanded: BOOLEAN is false;

   is_reference: BOOLEAN is false;

   is_dummy_expanded: BOOLEAN is false;

   is_user_expanded: BOOLEAN is false;

   is_generic: BOOLEAN is false;

   is_any: BOOLEAN is false;

   is_array: BOOLEAN is false;

   is_none: BOOLEAN is false;

   is_like_current: BOOLEAN is false;

   is_like_argument: BOOLEAN is false;

   is_like_feature: BOOLEAN is false;

   jvm_method_flags: INTEGER is 9;

feature

   nb: INTEGER is
         -- Number of bits.
      require
         is_run_type
      deferred
      ensure
         nb > 0
      end;

   need_c_struct: BOOLEAN is 
      do
         Result := mapping_code = Cuptr;
      end;

   frozen actual_reference(destination: TYPE): TYPE is
      local
         sp: POSITION;
      do
         sp := destination.start_position;
         !TYPE_BIT_REF!Result.from_type_bit(sp,Current);
      end;

   is_c_char: BOOLEAN is
      do
         Result := Cchar = mapping_code;
      end;

   is_c_int: BOOLEAN is
      do
         Result := Cint = mapping_code;
      end;

   is_c_unsigned_ptr: BOOLEAN is
      do
         Result := Cuptr = mapping_code;
      end;

   static_base_class_name: CLASS_NAME is
      do
         Result := base_class_name; 
      end;

   base_class_name: CLASS_NAME is
      once
         !!Result.unknown_position(as_bit_n);
      end;

   id: INTEGER is
      do
         Result := run_class.id;
      end;

   frozen expanded_initializer: RUN_FEATURE_3 is
      do
      end;

   frozen stupid_switch(r: ARRAY[RUN_CLASS]): BOOLEAN is
      do
         Result := true;
      end;
   
   frozen generic_list: ARRAY[TYPE] is
      do
         fatal_error_generic_list;
      end;

   frozen jvm_target_descriptor_in, jvm_descriptor_in(str: STRING) is
      do
         str.append(fz_a9);
      end;

   frozen jvm_return_code is
      do
         code_attribute.opcode_areturn;
      end;

   frozen jvm_push_local(offset: INTEGER) is
      do
         code_attribute.opcode_aload(offset);
      end;

   frozen jvm_check_class_invariant is
      do
      end;

   frozen jvm_push_default: INTEGER is
      local
         idx: INTEGER;
         ca: like code_attribute;
         cp: like constant_pool;
      do
         ca := code_attribute;
         cp := constant_pool;
         idx := cp.idx_class2(fz_java_util_bitset);
         ca.opcode_new(idx);
         ca.opcode_dup;
         ca.opcode_push_integer(nb);
         idx := cp.idx_methodref3(fz_java_util_bitset,fz_35,fz_27);
         ca.opcode_invokespecial(idx,0);
      end;

   frozen jvm_write_local(offset: INTEGER) is
      do
         code_attribute.opcode_bitset_clone;
         code_attribute.opcode_astore(offset);
      end;

   frozen jvm_xnewarray is
      local
         idx: INTEGER;
      do
         idx := constant_pool.idx_java_lang_object;
         code_attribute.opcode_anewarray(idx);
      end;

   frozen jvm_xastore is
      do
         code_attribute.opcode_bitset_clone;
         code_attribute.opcode_aastore;
      end;

   frozen jvm_xaload is
      do
         code_attribute.opcode_aaload;
      end;

   frozen jvm_if_x_eq: INTEGER is
      local
         idx: INTEGER;
         ca: like code_attribute;
         cp: like constant_pool;
      do
         ca := code_attribute;
         cp := constant_pool;
         idx := cp.idx_methodref3(fz_java_util_bitset,fz_a1,fz_a8);
         ca.opcode_invokevirtual(idx,0);
         Result := ca.opcode_ifne;
      end;

   frozen jvm_if_x_ne: INTEGER is
      local
         idx: INTEGER;
         ca: like code_attribute;
         cp: like constant_pool;
      do
         ca := code_attribute;
         cp := constant_pool;
         idx := cp.idx_methodref3(fz_java_util_bitset,fz_a1,fz_a8);
         ca.opcode_invokevirtual(idx,0);
         Result := ca.opcode_ifeq;
      end;

   frozen jvm_to_reference is
      local
         rc: RUN_CLASS;
         idx: INTEGER;
         type_bit_ref: TYPE_BIT_REF;
         ca: like code_attribute;
      do
         ca := code_attribute;
         !!type_bit_ref.from_type_bit(start_position,Current);
         rc := type_bit_ref.run_class;
         rc.jvm_basic_new;
         ca.opcode_dup_x1;
         ca.opcode_swap;
         idx := rc.jvm_constant_pool_index;
         idx := constant_pool.idx_fieldref4(idx,as_item,fz_a9);
         ca.opcode_putfield(idx,-2);
      end;

   frozen jvm_expanded_from_reference(other: TYPE): INTEGER is
      do
         check false end;
      end;

   frozen jvm_convert_to(destination: TYPE): INTEGER is
      local
         space, idx, loc1, loc2: INTEGER;
         point1, point2, point3: INTEGER;
         other_bit: TYPE_BIT;
         ca: like code_attribute;
         cp: like constant_pool;
      do
         Result := 1;
         if destination.is_reference then
            jvm_to_reference;
         else
            ca := code_attribute;
            cp := constant_pool;
            other_bit ?= destination;
            space := other_bit.jvm_push_default;
            ca.opcode_swap;
            loc1 := ca.extra_local_size1;
            ca.opcode_push_integer(other_bit.nb);
            ca.opcode_istore(loc1);
            loc2 := ca.extra_local_size1;
            ca.opcode_push_integer(nb);
            ca.opcode_istore(loc2);
            ca.opcode_iload(loc2);
            point1 := ca.program_counter;
            point2 := ca.opcode_ifeq;
            ca.opcode_iinc(loc1,255);
            ca.opcode_iinc(loc2,255);
            ca.opcode_dup2;
            ca.opcode_iload(loc2);
            idx := cp.idx_methodref3(fz_java_util_bitset,fz_a2,fz_a3);
            ca.opcode_invokevirtual(idx,0);
            point3 := ca.opcode_ifne;
            ca.opcode_pop;
            ca.opcode_iload(loc2);
            ca.opcode_goto_backward(point1);
            ca.resolve_u2_branch(point3);
            ca.opcode_iload(loc1);
            idx := cp.idx_methodref3(fz_java_util_bitset,fz_a4,fz_27);
            ca.opcode_invokevirtual(idx,0);
            ca.opcode_iload(loc2);
            ca.opcode_goto_backward(point1);
            ca.resolve_u2_branch(point2);
            ca.opcode_pop;
         end;
      end;

   frozen jvm_standard_is_equal is
      local
         rc: RUN_CLASS;
         wa: ARRAY[RUN_FEATURE_2];
      do
         rc := run_class;
         wa := rc.writable_attributes;
         jvm.std_is_equal(rc,wa);
      end;

   frozen c_header_pass1 is
      local
         mem_id, i: INTEGER;
      do
         mem_id := id;
         inspect
            mapping_code
         when Cchar, Cint then
            tmp_string.copy(fz_typedef);
            tmp_string.append(fz_unsigned);
            tmp_string.extend(' ');
            if mapping_code = Cchar then
               tmp_string.append(fz_char);
            else
               tmp_string.append(fz_int);
            end;
            tmp_string.extend(' ');
            tmp_string.extend('T');
            mem_id.append_in(tmp_string);
            tmp_string.append(fz_00);
         when Cuptr then
            tmp_string.copy(fz_struct);
            tmp_string.extend('S');
            mem_id.append_in(tmp_string);
            tmp_string.extend('{');
            from
               i := nb_unsigned;
            until
               i = 0
            loop
               tmp_string.append("unsigned int item");
               i.append_in(tmp_string);
               tmp_string.extend(';');
               i := i - 1;
            end;
            tmp_string.append("};%Ntypedef struct S");
            mem_id.append_in(tmp_string);
            tmp_string.extend(' ');
            tmp_string.extend('T');
            mem_id.append_in(tmp_string);
            tmp_string.append(fz_00);
         end;
         cpp.put_string(tmp_string);
      end;

   frozen c_header_pass2 is
      do
      end;

   frozen c_header_pass3 is
      do
      end;

   frozen c_header_pass4 is
      do
         standard_c_print_function;
      end;

   frozen c_type_for_argument_in(str: STRING) is
      do
         str.extend('T');
         id.append_in(str);
      end;

   frozen c_type_for_target_in(str: STRING) is
      do
         c_type_for_argument_in(str);
         if mapping_code = Cuptr then
            str.extend('*');
         end;
      end;

   frozen c_type_for_result_in(str: STRING) is
      do
         c_type_for_argument_in(str);
      end;

   frozen c_sizeof: INTEGER is
      do
         Result := nb_unsigned * (Integer_bits // Character_bits);
      end;

   frozen has_creation(fn: FEATURE_NAME): BOOLEAN is
      do
      end;

   frozen smallest_ancestor(other: TYPE): TYPE is
      local
         other_bit: TYPE_BIT;
      do
         other_bit ?= other.run_type;
         if other_bit /= Void then
            if nb < other_bit.nb then
               Result := Current;
            else
               Result := other_bit;
            end;
         else
            Result := type_any;
         end;
      end;

   frozen is_a(other: TYPE): BOOLEAN is
      local
         other_bit: TYPE_BIT;
      do
         if other.is_bit then
            other_bit ?= other.run_type;
            if nb <= other_bit.nb then
               Result := true;
            else
               eh.add_type(Current,fz_inako);
               eh.add_type(other," (VNCB.2).");
            end;
         elseif base_class.is_subclass_of(other.base_class) then
            Result := true;
         else
            eh.add_type(Current,fz_inako);
            eh.add_type(other,fz_dot);
         end;
      end;

   frozen c_initialize is
      local
         i: INTEGER;
      do
         if mapping_code = Cuptr then
            tmp_string.clear;
            tmp_string.extend('{');
            from
               i := nb_unsigned;
            until
               i = 0
            loop
               tmp_string.extend('0');
               i := i - 1;
               if i > 0 then
                  tmp_string.extend(',');
               end;
            end;
            tmp_string.extend('}');
            cpp.put_string(tmp_string);
         else
            cpp.put_character('0');
         end;
      end;

   frozen c_initialize_in(str: STRING) is
      local
         i: INTEGER;
      do
         if mapping_code = Cuptr then
            str.extend('{');
            from
               i := nb_unsigned;
            until
               i = 0
            loop
               str.extend('0');
               i := i - 1;
               if i > 0 then
                  str.extend(',');
               end;
            end;
            str.extend('}');
         else
            str.extend('0');
         end;
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

feature {NATIVE_SMALL_EIFFEL}

   unsigned_padding: INTEGER is
      do
         Result := (nb_unsigned * Integer_bits) - nb;
      end;

feature {NONE}

   Cchar, Cint, Cuptr: INTEGER is unique;

   mapping_code: INTEGER is
      do
         if nb <= Character_bits then
            Result := Cchar;
         elseif nb <= Integer_bits then
            Result := Cint;
         else
            Result := Cuptr;
         end;
      end;

   to_runnable_1_2 is
      local
         rc: RUN_CLASS;
         rf: RUN_FEATURE;
      do
         rc := run_class;
         rf := rc.get_feature_with(as_put_0);
         rf := rc.get_feature_with(as_put_1);
      end;

   nb_unsigned: INTEGER is
      local
         ib: INTEGER;
      do
         ib := Integer_bits
         Result := nb // ib;
         if (nb \\ ib) > 0 then
            Result := Result + 1;
         end;
      end;

end -- TYPE_BIT

