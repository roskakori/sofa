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
class CODE_ATTRIBUTE
   --
   -- Unique Global Object in charge of a Code_attribute as
   -- describe in the JVM specification.
   -- Obviously, the same object is recycled for all code part.
   --
inherit GLOBALS;

feature {NONE}

   code: FIXED_ARRAY[INTEGER] is
      once
         !!Result.with_capacity(1024);
      end;

   max_stack: INTEGER;
         -- To compute the maximum size of the operand stack.

   max_locals: INTEGER;

feature

   stack_level: INTEGER;
         -- Used to compute `max_stack';

feature {METHOD_INFO}

   clear is
      do
         code.clear;
         exception_table.clear;
         max_stack := 0;
         stack_level := 0;
         max_locals := jvm.max_locals;
      end;

   store_in(storage: STRING) is
      local
         i: INTEGER;
      do
         append_u2(storage,constant_pool.idx_constant_utf8);
         check
            program_counter > 0
         end;
         append_u4(storage,12 + program_counter);
         append_u2(storage,max_stack);
         append_u2(storage,max_locals);
         append_u4(storage,program_counter);
         from
            i := 0
         until
            i > code.upper
         loop
            append_u1(storage,code.item(i));
            i := i + 1;
         end;
         exception_table.store_in(storage);
         -- attribute_count :
         append_u2(storage,0);
      end;

feature

   program_counter: INTEGER is
      do
         Result := code.count;
      end;

   extra_local(local_type: TYPE): INTEGER is
      require
         local_type.is_run_type
      do
         Result := max_locals;
         max_locals := max_locals + local_type.jvm_stack_space;
      end;

   extra_local_size1: INTEGER is
      do
         Result := max_locals;
         max_locals := max_locals + 1;
      end;

feature -- opcode feature list :

   opcode_nop is
      do
         opcode(0,0);
      end;

   opcode_aconst_null is
      do
         opcode(1,1);
      end;

   opcode_iconst_m1 is
      do
         opcode(2,1);
      end;

   opcode_iconst_0 is
      do
         opcode(3,1);
      end;

   opcode_iconst_1 is
      do
         opcode(4,1);
      end;

   opcode_iconst_i(n: INTEGER) is
      require
         -1 <= n;
         n <= 5
      do
         opcode(3 + n,1);
      end;

   opcode_fconst_0 is
      do
         opcode(11,1);
      end;

   opcode_dconst_0 is
      do
         opcode(14,2);
      end;

   opcode_bipush(byte: INTEGER) is
         -- Sign-extended value.
      require
         byte.in_range(0,255)
      do
         opcode(16,1);
         add_u1(byte);
      end;

   opcode_sipush(u2: INTEGER) is
      require
         -32768 <= u2;
         u2 <= 32767;
         (u2 < -128 or 127 < u2)
      do
         opcode(17,1);
         add_u2(u2);
      end;

   opcode_ldc(idx: INTEGER) is
         -- For both ldc and ldc_w.
      require
         constant_pool.valid_index(idx)
      do
         if idx < 255 then
            opcode(18,1);
            add_u1(idx);
         else
            opcode(19,1);
            add_u2(idx);
         end;
      end;

   opcode_fload(index: INTEGER) is
      require
         0 <= index;
         index <= 255
      do
         if index <= 3 then
            opcode(34 + index,1);
         else
            opcode(23,1);
            add_u1(index);
         end;
      end;

   opcode_dload_0 is
      do
         opcode(38,2);
      end;

   opcode_dload(index: INTEGER) is
      require
         0 <= index;
         index <= 255
      do
         if index <= 3 then
            opcode(38 + index,2);
         else
            opcode(24,2);
            add_u1(index);
         end;
      end;

   opcode_aload(index: INTEGER) is
      require
         0 <= index;
         index <= 255
      do
         if index <= 3 then
            opcode(42 + index,1);
         else
            opcode(25,1);
            add_u1(index);
         end;
      end;

   opcode_iload_1 is
      do
         opcode(27,1);
      end;

   opcode_iload_3 is
      do
         opcode(29,1);
      end;

   opcode_iload(index: INTEGER) is
      require
         0 <= index;
         index <= 255
      do
         if index <= 3 then
            opcode(26 + index,1);
         else
            opcode(21,1);
            add_u1(index);
         end;
      end;

   opcode_aload_0 is
      do
         opcode(42,1);
      end;

   opcode_aload_1 is
      do
         opcode(43,1);
      end;

   opcode_aload_2 is
      do
         opcode(44,1);
      end;

   opcode_aload_3 is
      do
         opcode(45,1);
      end;

   opcode_iaload is
      do
         opcode(46,-1);
      end;

   opcode_laload is
      do
         opcode(47,0);
      end;

   opcode_faload is
      do
         opcode(48,-1);
      end;

   opcode_daload is
      do
         opcode(49,0);
      end;

   opcode_aaload is
      do
         opcode(50,-1);
      end;

   opcode_baload is
      do
         opcode(51,-1);
      end;

   opcode_caload is
      do
         opcode(52,-1);
      end;

   opcode_saload is
      do
         opcode(53,-1);
      end;

   opcode_istore_3 is
      do
         opcode(62,-1);
      end;

   opcode_istore(offset: INTEGER) is
      require
         0 <= offset;
         offset <= 255
      do
         if offset <= 3 then
            opcode(59 + offset,-1);
         else
            opcode(54,-1);
            add_u1(offset);
         end;
      end;

   opcode_fstore(offset: INTEGER) is
      require
         0 <= offset;
         offset <= 255
      do
         if offset <= 3 then
            opcode(67 + offset,-1);
         else
            opcode(56,-1);
            add_u1(offset);
         end;
      end;

   opcode_dstore(offset: INTEGER) is
      require
         0 <= offset;
         offset <= 255
      do
         if offset <= 3 then
            opcode(71 + offset,-1);
         else
            opcode(57,-1);
            add_u1(offset);
         end;
      end;

   opcode_astore_0 is
      do
         opcode(75,-1);
      end;

   opcode_astore_1 is
      do
         opcode(76,-1);
      end;

   opcode_astore_2 is
      do
         opcode(77,-1);
      end;

   opcode_astore_3 is
      do
         opcode(78,-1);
      end;

   opcode_astore(offset: INTEGER) is
      require
         0 <= offset;
         offset <= 255
      do
         if offset <= 3 then
            opcode(75 + offset,-1);
         else
            opcode(58,-1);
            add_u1(offset);
         end;
      end;

   opcode_iastore is
      do
         opcode(79,-3);
      end;

   opcode_fastore is
      do
         opcode(81,-3);
      end;

   opcode_dastore is
      do
         opcode(82,-4);
      end;

   opcode_aastore is
      do
         opcode(83,-3);
      end;

   opcode_bastore is
      do
         opcode(84,-3);
      end;

   opcode_pop is
      do
         opcode(87,-1);
      end;

   opcode_pop2 is
      do
         opcode(88,-2);
      end;

   opcode_dup is
      do
         opcode(89,1);
      end;

   opcode_dup_x1 is
      do
         opcode(90,1);
      end;

   opcode_dup_x2 is
      do
         opcode(91,1);
      end;

   opcode_dup2 is
      do
         opcode(92,2);
      end;

   opcode_dup2_x1 is
      do
         opcode(93,2);
      end;

   opcode_swap is
      do
         opcode(95,0);
      end;

   opcode_iadd is
      do
         opcode(96,-1);
      end;

   opcode_fadd is
      do
         opcode(98,-1);
      end;

   opcode_dadd is
      do
         opcode(99,-2);
      end;

   opcode_isub is
      do
         opcode(100,-1);
      end;

   opcode_fsub is
      do
         opcode(102,-1);
      end;

   opcode_dsub is
      do
         opcode(103,-2);
      end;

   opcode_imul is
      do
         opcode(104,-1);
      end;

   opcode_fmul is
      do
         opcode(106,-1);
      end;

   opcode_dmul is
      do
         opcode(107,-2);
      end;

   opcode_idiv is
      do
         opcode(108,-1);
      end;

   opcode_fdiv is
      do
         opcode(110,-1);
      end;

   opcode_ddiv is
      do
         opcode(111,-2);
      end;

   opcode_irem is
      do
         opcode(112,-1);
      end;

   opcode_ineg is
      do
         opcode(116,0);
      end;

   opcode_fneg is
      do
         opcode(118,0);
      end;

   opcode_dneg is
      do
         opcode(119,0);
      end;

   opcode_ishl is
      do
         opcode(120,-1);
      end;

   opcode_ishr is
      do
         opcode(122,-1);
      end;

   opcode_iushr is
      do
         opcode(124,-1);
      end;

   opcode_iand is
      do
         opcode(126,-1);
      end;

   opcode_ior is
      do
         opcode(128,-1);
      end;

   opcode_ixor is
      do
         opcode(130,-1);
      end;

   opcode_iinc(loc_idx, u1_increment: INTEGER) is
      do
         opcode(132,0);
         add_u1(loc_idx);
         add_u1(u1_increment);
      end;

   opcode_i2f is
      do
         opcode(134,0);
      end;

   opcode_i2d is
      do
         opcode(135,1);
      end;

   opcode_f2i is
      do
         opcode(139,0);
      end;

   opcode_f2d is
      do
         opcode(141,1);
      end;

   opcode_d2i is
      do
         opcode(142,-1);
      end;

   opcode_d2f is
      do
         opcode(144,-1);
      end;

   opcode_i2b is
      do
         opcode(145,0);
      end;

   opcode_fcmpg is
      do
         opcode(150,-1);
      end;

   opcode_fcmpl is
      do
         opcode(149,-1);
      end;

   opcode_dcmpl is
      do
         opcode(151,-3);
      end;

   opcode_dcmpg is
      do
         opcode(152,-3);
      end;

   opcode_ifeq: INTEGER is
      do
         opcode(153,-1);
         Result := skip_2_bytes;
      end;

   opcode_ifne: INTEGER is
      do
         opcode(154,-1);
         Result := skip_2_bytes;
      end;

   opcode_iflt: INTEGER is
      do
         opcode(155,-1);
         Result := skip_2_bytes;
      end;

   opcode_ifge: INTEGER is
      do
         opcode(156,-1);
         Result := skip_2_bytes;
      end;

   opcode_ifgt: INTEGER is
      do
         opcode(157,-1);
         Result := skip_2_bytes;
      end;

   opcode_ifle: INTEGER is
      do
         opcode(158,-1);
         Result := skip_2_bytes;
      end;

   opcode_if_icmpeq: INTEGER is
      do
         opcode(159,-2);
         Result := skip_2_bytes;
      end;

   opcode_if_icmpne: INTEGER is
      do
         opcode(160,-2);
         Result := skip_2_bytes;
      end;

   opcode_if_icmplt: INTEGER is
      do
         opcode(161,-2);
         Result := skip_2_bytes;
      end;

   opcode_if_icmpge: INTEGER is
      do
         opcode(162,-2);
         Result := skip_2_bytes;
      end;

   opcode_if_icmpgt: INTEGER is
      do
         opcode(163,-2);
         Result := skip_2_bytes;
      end;

   opcode_if_icmple: INTEGER is
      do
         opcode(164,-2);
         Result := skip_2_bytes;
      end;

   opcode_if_acmpeq: INTEGER is
      do
         opcode(165,-2);
         Result := skip_2_bytes;
      end;

   opcode_if_acmpne: INTEGER is
      do
         opcode(166,-2);
         Result := skip_2_bytes;
      end;

   opcode_goto: INTEGER is
      do
         opcode(167,0);
         Result := skip_2_bytes;
      end;

   opcode_goto_backward(back_point: INTEGER) is
         -- Produce a goto opcode to go back at `back_point'.
      require
         back_point < program_counter
      local
         r, q, offset: INTEGER;
      do
         offset := program_counter - back_point;
         opcode(167,0);
         r := offset \\ 256;
         q := offset // 256;
         if r = 0 then
            add_u1(256 - q);
            add_u1(0);
         else
            add_u1(255 - q);
            add_u1(256 - r);
         end;
      end;

   opcode_ireturn is
      do
         add_u1(172);
      end;

   opcode_lreturn is
      do
         add_u1(173);
      end;

   opcode_freturn is
      do
         add_u1(174);
      end;

   opcode_dreturn is
      do
         add_u1(175);
      end;

   opcode_areturn is
      do
         add_u1(176);
      end;

   opcode_return is
      do
         add_u1(177);
      end;

   opcode_getstatic(fieldref_idx, stack_inc: INTEGER) is
      require
         constant_pool.valid_index(fieldref_idx)
      do
         opcode(178,stack_inc);
         add_u2(fieldref_idx);
      end;

   opcode_putstatic(fieldref_idx, stack_inc: INTEGER) is
      require
         constant_pool.valid_index(fieldref_idx)
      do
         opcode(179,stack_inc);
         add_u2(fieldref_idx);
      end;

   opcode_getfield(fieldref_idx, stack_inc: INTEGER) is
      require
         constant_pool.valid_index(fieldref_idx)
      do
         opcode(180,stack_inc);
         add_u2(fieldref_idx);
      end;

   opcode_putfield(fieldref_idx, stack_inc: INTEGER) is
      require
         constant_pool.valid_index(fieldref_idx)
      do
         opcode(181,stack_inc);
         add_u2(fieldref_idx);
      end;

   opcode_invokevirtual(methodref_idx, stack_inc: INTEGER) is
      require
         constant_pool.is_methodref(methodref_idx)
      do
         opcode(182,stack_inc);
         add_u2(methodref_idx);
      end;

   opcode_invokespecial(methodref_idx, stack_inc: INTEGER) is
      require
         constant_pool.is_methodref(methodref_idx)
      do
         opcode(183,stack_inc);
         add_u2(methodref_idx);
      end;

   opcode_invokestatic(methodref_idx, stack_inc: INTEGER) is
      require
         constant_pool.is_methodref(methodref_idx)
      do
         opcode(184,stack_inc);
         add_u2(methodref_idx);
      end;

   opcode_new(class_idx: INTEGER) is
      require
         constant_pool.is_class(class_idx)
      do
         opcode(187,1);
         add_u2(class_idx);
      end;

   opcode_newarray(u1: INTEGER) is
      require
         4 <= u1;
         u1 <= 10
      do
         opcode(188,0);
         add_u1(u1);
      end;

   opcode_anewarray(idx: INTEGER) is
      require
         constant_pool.valid_index(idx)
      do
         opcode(189,0);
         add_u2(idx);
      end;

   opcode_arraylength is
      do
         opcode(190,0);
      end;

   opcode_athrow is
      do
         opcode(191,0);
      end;

feature {RUN_CLASS,NATIVE_SMALL_EIFFEL}

   opcode_checkcast(class_idx: INTEGER) is
      require
         constant_pool.is_class(class_idx)
      do
         opcode(192,0);
         add_u2(class_idx);
      end;

feature {RUN_CLASS}

   opcode_instanceof(class_idx: INTEGER) is
      require
         constant_pool.is_class(class_idx)
      do
         opcode(193,0);
         add_u2(class_idx);
      end;

feature

   opcode_ifnull: INTEGER is
      do
         opcode(198,-1);
         Result := skip_2_bytes;
      end;

   opcode_ifnonnull: INTEGER is
      do
         opcode(199,-1);
         Result := skip_2_bytes;
      end;

feature -- High level opcode calls :

   opcode_push_integer(i: INTEGER) is
      do
         if i < -32768 then
            push_strange_integer(i);
         elseif i < -128 then
            opcode_sipush(i);
         elseif i < -1 then
            opcode_bipush(256 + i);
         elseif i <= 5 then
            opcode_iconst_i(i);
         elseif i <= 127 then
            opcode_bipush(i);
         elseif i <= 32767 then
            opcode_sipush(i);
         else
            push_strange_integer(i);
         end;
      end;

   opcode_push_as_float(str: STRING) is
      require
         str.count >= 1
      do
         inspect
            str.item(1)
         when '0' then
            if str.count = 1 then
               opcode(11,1);
            else
               inspect
                  str.item(2)
               when '.' then
                  if str.count = 2 then
                     opcode(11,1);
                  elseif str.count = 3 and then str.item(3) = '0' then
                     opcode(11,1);
                  else
                     opcode_string2float(str);
                  end;
               else
                  opcode_string2float(str);
               end;
            end;
         when '1' then
            if str.count = 1 then
               opcode(12,1);
            else
               inspect
                  str.item(2)
               when '.' then
                  if str.count = 2 then
                     opcode(12,1);
                  elseif str.count = 3 and then str.item(3) = '0' then
                     opcode(12,1);
                  else
                     opcode_string2float(str);
                  end;
               else
                  opcode_string2float(str);
               end;
            end;
         when '2' then
            if str.count = 1 then
               opcode(13,1);
            else
               inspect
                  str.item(2)
               when '.' then
                  if str.count = 2 then
                     opcode(13,1);
                  elseif str.count = 3 and then str.item(3) = '0' then
                     opcode(13,1);
                  else
                     opcode_string2float(str);
                  end;
               else
                  opcode_string2float(str);
               end;
            end;
         else
            opcode_string2float(str);
         end;
      end;

   opcode_push_as_double(str: STRING) is
      require
         str.count >= 1
      do
         inspect
            str.item(1)
         when '0' then
            if str.count = 1 then
               opcode(14,2);
            else
               inspect
                  str.item(2)
               when '.' then
                  if str.count = 2 then
                     opcode(14,2);
                  elseif str.count = 3 and then str.item(3) = '0' then
                     opcode(14,2);
                  else
                     opcode_string2double(str);
                  end;
               else
                  opcode_string2double(str);
               end;
            end;
         when '1' then
            if str.count = 1 then
               opcode(15,2);
            else
               inspect
                  str.item(2)
               when '.' then
                  if str.count = 2 then
                     opcode(15,2);
                  elseif str.count = 3 and then str.item(3) = '0' then
                     opcode(15,2);
                  else
                     opcode_string2double(str);
                  end;
               else
                  opcode_string2double(str);
               end;
            end;
         else
            opcode_string2double(str);
         end;
      end;

   opcode_push_manifest_string(ms: STRING) is
         -- Produces code to push the corresponding Eiffel STRING.
      local
         ms_idx: INTEGER;
      do
         ms_idx := constant_pool.idx_string2(ms);
         opcode_ldc(ms_idx);
         opcode_java_string2eiffel_string;
      end;

   opcode_java_string2bytes_array is
         -- Used the pushed Java String to create the bytes array.
      local
         idx: INTEGER;
      do
         idx := constant_pool.idx_methodref3(fz_java_lang_string,fz_33,fz_34);
         opcode_invokevirtual(idx,0);
      end;

   opcode_java_string2eiffel_string is
         -- Used the pushed Java String to create a new Eiffel STRING.
      do
         opcode_java_string2bytes_array;
         opcode_bytes_array2eiffel_string;
      end;

   opcode_bytes_array2eiffel_string is
         -- Used the pushed Bytes array to create a new Eiffel STRING.
      local
         cp: like constant_pool;
         loc: INTEGER;
         rc_string: RUN_CLASS;
      do
         cp := constant_pool;
         rc_string := type_string.run_class;
         loc := extra_local_size1;
         opcode_astore(loc);
         -- The new STRING :
         rc_string.jvm_basic_new;
         -- Set count :
         opcode_dup;
         opcode_aload(loc);
         opcode_arraylength;
         opcode_putfield(cp.idx_eiffel_string_count_fieldref,-2);
         -- Set capacity :
         opcode_dup;
         opcode_aload(loc);
         opcode_arraylength;
         opcode_putfield(cp.idx_eiffel_string_capacity_fieldref,-2);
         -- Set storage :
         opcode_dup;
         opcode_aload(loc);
         opcode_putfield(cp.idx_eiffel_string_storage_fieldref,-2);
      end;

feature {TYPE_BIT}

   opcode_bitset_clone is
      local
         cp: like constant_pool;
         idx: INTEGER;
      do
         cp := constant_pool;
         idx := cp.idx_methodref3(fz_java_util_bitset,fz_a6,fz_a7);
         opcode_invokevirtual(idx,0);
         idx := cp.idx_class2(fz_java_util_bitset);
         opcode_checkcast(idx);
      end;

feature -- Easy access to some Java basics :

   opcode_system_in is
         -- Push `System.in'.
      local
         idx: INTEGER;
      do
         idx := constant_pool.idx_fieldref3(fz_java_lang_system,fz_37,fz_38);
         opcode_getstatic(idx,1);
      end;

   opcode_system_out is
         -- Push `System.out'.
      local
         idx: INTEGER;
      do
         idx := constant_pool.idx_fieldref3(fz_java_lang_system,fz_39,fz_40);
         opcode_getstatic(idx,1);
      end;

   opcode_system_err is
         -- Push `System.err'.
      local
         idx: INTEGER;
      do
         idx := constant_pool.idx_fieldref3(fz_java_lang_system,fz_49,fz_40);
         opcode_getstatic(idx,1);
      end;

   opcode_println(string_idx: INTEGER) is
      require
         constant_pool.valid_index(string_idx);
      local
         idx: INTEGER;
      do
         opcode_ldc(string_idx);
         idx := constant_pool.idx_methodref3(fz_25,fz_51,fz_57);
         opcode_invokevirtual(idx,-2);
      end;

   opcode_system_err_println(string_idx: INTEGER) is
         -- System.err.println(<string_idx>);
      require
         constant_pool.valid_index(string_idx);
      do
         opcode_system_err;
         opcode_println(string_idx);
      end;

feature {NONE}

   opcode(opcode_value, max_stack_increment: INTEGER) is
      require
         stack_level >= 0;
         opcode_value <= 255
      local
         cs: INTEGER;
      do
         add_u1(opcode_value);
         cs := stack_level + max_stack_increment;
         if cs >= 0 then
            stack_level := cs;
         else
            -- ????
         end;
         if stack_level > max_stack then
            max_stack := stack_level;
         end;
      ensure
         stack_level >= 0
      end;

   add_u1(u1: INTEGER) is
      do
         code.add_last(u1);
      ensure
         program_counter = 1 + old program_counter
      end;

   add_u2(u2: INTEGER) is
      do
         add_u1(u2 // 256);
         add_u1(u2 \\ 256);
      ensure
         program_counter = 2 + old program_counter
      end;

   skip_2_bytes: INTEGER is
         -- Return the `programm_counter' before the skip.
      do
         Result := program_counter;
         code.add_last(0);
         code.add_last(0);
      end;

feature

   resolve_u2_branch(start_point: INTEGER) is
      require
         start_point < program_counter
      local
         offset: INTEGER;
      do
         offset := program_counter - start_point + 1;
         code.put(offset // 256,start_point);
         code.put(offset \\ 256,start_point + 1);
      end;

feature

   branches: FIXED_ARRAY[INTEGER] is
      once
         !!Result.with_capacity(16);
      end;

   resolve_branches is
      do
         resolve_with(branches);
      end;

   resolve_with(points: FIXED_ARRAY[INTEGER]) is
      local
         i: INTEGER;
      do
         from
            i := points.upper;
         until
            i < 0
         loop
            resolve_u2_branch(points.item(i));
            i := i - 1;
         end;
      end;

feature {NONE}

   check_flag_idx,  skip_check: INTEGER;

feature {ASSERTION_LIST}

   check_opening is
      local
         cp: like constant_pool;
      do
         cp := constant_pool;
         opcode_iconst_1;
         check_flag_idx := cp.idx_fieldref3(jvm_root_class,fz_58,fz_41);
         opcode_getstatic(check_flag_idx,1);
         skip_check := opcode_ifne;
         opcode_putstatic(check_flag_idx,-1);
      end;

   check_closing is
      do
         opcode_iconst_0;
         opcode_putstatic(check_flag_idx,-1);
         resolve_u2_branch(skip_check);
      end;

feature {NONE}

   opcode_string2double(str: STRING) is
      local
         idx: INTEGER;
      do
         idx := constant_pool.idx_string(str);
         opcode_ldc(idx);
         idx := constant_pool.idx_methodref3(fz_java_lang_double,fz_60,fz_61);
         opcode_invokestatic(idx,1);
      end;

   opcode_string2float(str: STRING) is
      do
         opcode_string2double(str);
         opcode_d2f;
      end;

feature {NONE}

   push_strange_integer(i: INTEGER) is
      local
         idx: INTEGER;
         cp: like constant_pool;
      do
         cp := constant_pool;
         tmp_string.clear;
         i.append_in(tmp_string);
         idx := cp.idx_string(tmp_string);
         opcode_ldc(idx);
         idx := cp.idx_methodref3(fz_java_lang_integer,fz_82,fz_83);
         opcode_invokestatic(idx,0);
      end;

   tmp_string: STRING is
      once
         !!Result.make(32);
      end;

feature {NONE}

   exception_table: EXCEPTION_TABLE is
      once
         !!Result.make;
      end;

feature

   add_exception(f, t, h, idx: INTEGER) is
      do
         exception_table.add(f,t,h,idx);
      end;

feature -- Calls to SmallEiffelRuntime.java :


   runtime_die_with_code is
         -- Assume the status code is already pushed.
      local
         cp: like constant_pool;
         idx: INTEGER;
      do
         cp := constant_pool;
         idx := cp.idx_methodref3(fz_se_runtime,as_die_with_code,fz_27);
         opcode_invokestatic(idx,-1);
      end;

   runtime_internal_exception_number is
      local
         cp: like constant_pool;
         idx: INTEGER;
      do
         cp := constant_pool;
         idx := cp.idx_fieldref3(fz_se_runtime,"internal_exception_number",fz_i);
         opcode_getstatic(idx,1);
      end;

   runtime_error(p: POSITION; t: TYPE; message: STRING) is
      local
         cp: like constant_pool;
         idx: INTEGER;
      do
         cp := constant_pool;
         push_position(p);
         if t = Void then
            opcode_aconst_null;
         else
            opcode_ldc(cp.idx_string(t.run_time_mark));
         end;
         opcode_ldc(cp.idx_string(message));
         idx := cp.idx_methodref3(fz_se_runtime,"runtime_error",
         "(IILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
         opcode_invokestatic(idx,-5);
      end;

   runtime_error_bad_target(p: POSITION; t: TYPE; message: STRING) is
         -- Assume the bad target is pushed.
         -- The expected type, if any is `t'.
      local
         cp: like constant_pool;
         idx: INTEGER;
      do
         cp := constant_pool;
         push_position(p);
         opcode_ldc(cp.idx_string(t.run_time_mark));
         if message = Void then
            opcode_aconst_null;
         else
            opcode_ldc(cp.idx_string(message));
         end;
         idx := cp.idx_methodref3(fz_se_runtime,"runtime_error_bad_target",
         "(Ljava/lang/Object;IILjava/lang/String;Ljava/lang/String;%
         %Ljava/lang/String;)V");
         opcode_invokestatic(idx,-6);
      end;

feature {E_LOOP}

   runtime_check_loop_variant(expression: EXPRESSION) is
         -- Assume the loop counter and the previous variant value
         -- is already pushed.
         -- Returns the next variant value.
      require
         expression /= Void
      local
         cp: like constant_pool;
         idx: INTEGER;
      do
         cp := constant_pool;
         expression.compile_to_jvm;
         push_position(expression.start_position);
         idx := cp.idx_methodref3(fz_se_runtime,"runtime_check_loop_variant",
         "(IIIIILjava/lang/String;)I");
         opcode_invokestatic(idx,-5);
      end;

feature {E_INSPECT}

   runtime_error_inspect(expression: EXPRESSION) is
         -- Assume the not selected inspect value of `expression' is
         -- already pushed.
      local
         cp: like constant_pool;
         rt: TYPE;
         idx: INTEGER;
      do
         cp := constant_pool;
         rt := expression.result_type;
         if rt.is_character then
            -- Convert byte 2 int ??
         end;
         push_position(expression.start_position);
         idx := cp.idx_methodref3(fz_se_runtime,"runtime_error_inspect",
         "(IIILjava/lang/String;)I");
         opcode_invokestatic(idx,-3);
      end;

feature {COMPOUND}

   se_trace(ct: TYPE; p: POSITION) is
         -- Assume the Current target of type `ct' is pushed.
      require
         run_control.trace
      local
         cp: like constant_pool;
         idx: INTEGER;
      do
         if p.is_unknown then
            opcode_pop;
         else
            cp := constant_pool;
            ct.jvm_push_local(0);
            push_position(p);
            tmp_string.clear;
            tmp_string.extend('(');
            if ct.is_basic_eiffel_expanded then
               ct.jvm_descriptor_in(tmp_string);
            else
               tmp_string.append("Ljava/lang/Object;");
            end;
            tmp_string.append("IILjava/lang/String;)V");
            idx := cp.idx_methodref3(fz_se_runtime,"se_trace",tmp_string);
            opcode_invokestatic(idx,- ct.jvm_stack_space - 3);
         end;
      end;

feature {NONE}

   push_position(p: POSITION) is
      do
         opcode_push_integer(p.line);
         opcode_push_integer(p.column);
         if p.is_unknown then
            opcode_aconst_null;
         else
            opcode_ldc(constant_pool.idx_string(p.path));
         end;
      end;

feature {NATIVE_SMALL_EIFFEL}

   runtime_se_getenv is
      local
         point1: INTEGER;
         cp: like constant_pool;
         idx: INTEGER;
      do
         cp := constant_pool;
         idx := cp.idx_methodref3(fz_se_runtime,"se_getenv",
                                  "(Ljava/lang/Object;)Ljava/lang/String;");
         opcode_invokestatic(idx,0);
         opcode_dup;
         point1 := opcode_ifnull;
         opcode_java_string2eiffel_string;
         resolve_u2_branch(point1);
      end;

   read_byte is
      local
         cp: like constant_pool;
         idx: INTEGER;
      do
         cp := constant_pool;
         idx := cp.idx_class2(fz_java_io_inputstream);
         opcode_checkcast(idx);
         idx := cp.idx_methodref3(fz_java_io_inputstream,fz_70,fz_71);
         opcode_invokevirtual(idx,0);
      end;

invariant

   stack_level >= 0;

   stack_level <= max_stack;

end -- CODE_ATTRIBUTE

