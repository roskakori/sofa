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
class PRINT_JVM_CLASS
   --
   -- The `print_jvm_class' command.
   --

inherit COMMAND_FLAGS; CP_INFO_TAGS;

creation make

feature {NONE}

   command_name: STRING is "print_jvm_class";

   bytes: FIXED_ARRAY[INTEGER] is
         -- All bytes of the class file.
      once
         !!Result.with_capacity(4096);
      end;

   constant_pool_count: INTEGER;

   this_class_idx: INTEGER;

   super_class_idx: INTEGER;

   interfaces_count: INTEGER;

   fields_count: INTEGER;

   methods_count: INTEGER;

   attributes_count: INTEGER;

   make is
      local
         path: STRING;
         file_of_bytes: BINARY_FILE_READ;
         byte, i, index: INTEGER;
         s: STRING;
         interface_idx: INTEGER;
         access_flags: BIT Integer_bits;
      do
         if argument_count /= 1 then
            system_tools.bad_use_exit("print_jvm_class");
         elseif is_flag_version(argument(1)) then
         else
            path := argument(1).twin;
            if not path.has_suffix(".class") then
               path.append(".class");
            end;
            !!file_of_bytes.connect_to(path);
            if file_of_bytes.is_connected then
               from
                  io.put_string("Contents of file %"");
                  io.put_string(file_of_bytes.path);
                  io.put_string("%".%N");
                  file_of_bytes.read_byte;
                  if file_of_bytes.end_of_input then
                     bad_class_file("Invalid empty class file.",0);
                  end;
               until
                  file_of_bytes.end_of_input
               loop
                  byte := file_of_bytes.last_byte;
                  bytes.add_last(byte)
                  file_of_bytes.read_byte;
               end;
               file_of_bytes.disconnect;
               io.put_string("Total bytes: ");
               io.put_integer(bytes.count);
               io.put_new_line;
               io.put_string("Magic number: ");
               s := hexa4_at(0);
               if not ("0xCAFEBABE").is_equal(s) then
                  bad_class_file("Invalid Magic number.",0);
               else
                  io.put_string(s);
                  io.put_new_line;
               end;
               io.put_string("Minor version: ");
               io.put_string(hexa2_at(4));
               io.put_new_line;
               io.put_string("Major version: ");
               io.put_string(hexa2_at(6));
               io.put_new_line;
               io.put_string("Constant pool count: ");
               constant_pool_count := u2_integer_at(8);
               io.put_integer(constant_pool_count);
               io.put_new_line;
               io.put_string("Loading constant pool items :%N");
               from
                  constant_pool.reset(constant_pool_count - 1);
                  index := 10; -- of first item in constant pool.
                  i := 1;
               until
                  i >= constant_pool_count
               loop
                  index := load_cp_info(i,index);
                  i := i + 1;
               end;
               io.put_string("Constant pool view :%N");
               from
                  index := 10; -- of first item in constant pool.
                  i := 1;
               until
                  i >= constant_pool_count
               loop
                  tmp_string.clear;
                  integer_to_hexa_in(i,tmp_string);
                  tmp_string.extend(' ');
                  extend_string(tmp_string,' ',6);
                  i.append_in(tmp_string);
                  tmp_string.extend(' ');
                  extend_string(tmp_string,' ',12);
                  tmp_string.extend('(');
                  integer_to_hexa_in(index,tmp_string);
                  tmp_string.extend(')');
                  extend_string(tmp_string,' ',20);
                  tmp_string.append(" : ");
                  io.put_string(tmp_string);
                  index := print_cp_info(i,index);
                  io.put_new_line;
                  i := i + 1;
               end;
               io.put_string("Access flag: ");
               io.put_string(hexa2_at(index));
               io.put_character(' ');
               access_flags := bytes.item(index + 1).to_bit;
               if (access_flags and 1B).to_boolean then
                  io.put_string("public ");
               end;
               if (access_flags and 10000B).to_boolean then
                  io.put_string("final (no subclass)");
               end;
               if (access_flags and 100000B).to_boolean then
                  io.put_string("invokespecial (for superclass) ");
               end;
               access_flags := bytes.item(index).to_bit;
               if (access_flags and 10B).to_boolean then
                  io.put_string("interface ");
               end;
               if (access_flags and 100B).to_boolean then
                  io.put_string("abstract ");
               end;
               io.put_new_line;
               index := index + 2;
               io.put_new_line;
               io.put_string("This Class: ");
               this_class_idx := u2_integer_at(index);
               index := index + 2;
               if constant_pool.is_class(this_class_idx) then
                  tmp_string.copy(" is ");
                  constant_pool.view_in(tmp_string,this_class_idx);
                  io.put_string(tmp_string);
               else
                  io.put_string("??%N");
                  bad_class_file("Bad `this_class' value.",index - 2);
               end;
               io.put_new_line;
               io.put_string("Super Class: ");
               super_class_idx := u2_integer_at(index);
               index := index + 2;
               if constant_pool.is_class(super_class_idx) then
                  tmp_string.copy("is ");
                  constant_pool.view_in(tmp_string,super_class_idx);
                  io.put_string(tmp_string);
               else
                  io.put_string("??%N");
                  bad_class_file("Bad `super_class' value.",index - 2);
               end;
               io.put_new_line;
               io.put_string("Interfaces count: ");
               interfaces_count := u2_integer_at(index);
               index := index + 2;
               io.put_integer(interfaces_count);
               i := interfaces_count;
               if i > 0 then
                  io.put_string(" {");
                  from
                  until
                     i = 0
                  loop
                     interface_idx := u2_integer_at(index);
                     index := index + 2;
                     io.put_integer(interface_idx);
                     i := i - 1;
                     if i > 0 then
                        io.put_character(',');
                     end;
                  end;
                  io.put_character('}');
               end;
               io.put_new_line;
               io.put_string("----- Fields count: ");
               fields_count := u2_integer_at(index);
               index := index + 2;
               io.put_integer(fields_count);
               io.put_new_line;
               from
                  i := 1
               until
                  i > fields_count
               loop
                  io.put_integer(i);
                  if i < 10 then
                     io.put_string("   ");
                  elseif i < 100 then
                     io.put_string("  ");
                  else
                     io.put_string(" ");
                  end;
                  io.put_string(": ");
                  index := print_field_info(index);
                  io.put_new_line;
                  i := i + 1;
               end;
               io.put_string("----- Methods count: ");
               methods_count := u2_integer_at(index);
               index := index + 2;
               io.put_integer(methods_count);
               io.put_new_line;
               from
                  i := 1
               until
                  i > methods_count
               loop
                  io.put_integer(i);
                  if i < 10 then
                     io.put_string("   ");
                  elseif i < 100 then
                     io.put_string("  ");
                  else
                     io.put_string(" ");
                  end;
                  io.put_string(": ");
                  index := print_method_info(index);
                  io.put_new_line;
                  i := i + 1;
               end;
               io.put_string("Attributes count: ");
               attributes_count := u2_integer_at(index);
               index := index + 2;
               io.put_integer(attributes_count);
               io.put_new_line;
               from
                  i := 1
               until
                  i > attributes_count
               loop
                  io.put_integer(i);
                  if i < 10 then
                     io.put_string("   ");
                  elseif i < 100 then
                     io.put_string("  ");
                  else
                     io.put_string(" ");
                  end;
                  io.put_string(": ");
                  index := print_attribute_info(index);
                  io.put_new_line;
                  i := i + 1;
               end;
               check
                  index = bytes.upper + 1
               end;
            else
               io.put_string("File %"");
               io.put_string(path);
               io.put_string("%" not found.%N");
            end;
         end;
      end;

feature {NONE} -- Low level access in `bytes' :

   character_at(index: INTEGER): CHARACTER is
      do
         Result := bytes.item(index).to_character;
      end;

   u2_at(index: INTEGER): STRING is
      do
         !!Result.make(2);
         Result.extend(character_at(index + 0));
         Result.extend(character_at(index + 1));
      end;

   u4_at(index: INTEGER): STRING is
      do
         !!Result.make(4);
         Result.extend(character_at(index + 0));
         Result.extend(character_at(index + 1));
         Result.extend(character_at(index + 2));
         Result.extend(character_at(index + 3));
      end;

   u8_at(index: INTEGER): STRING is
      do
         !!Result.make(8);
         Result.extend(character_at(index + 0));
         Result.extend(character_at(index + 1));
         Result.extend(character_at(index + 2));
         Result.extend(character_at(index + 3));
         Result.extend(character_at(index + 4));
         Result.extend(character_at(index + 5));
         Result.extend(character_at(index + 6));
         Result.extend(character_at(index + 7));
      end;

   hexa1_at(index: INTEGER): STRING is
      do
         !!Result.copy("0x");
         bytes.item(index).to_character.to_hexadecimal_in(Result);
      end;

   hexa2_at(index: INTEGER): STRING is
      do
         !!Result.copy("0x");
         bytes.item(index + 0).to_character.to_hexadecimal_in(Result);
         bytes.item(index + 1).to_character.to_hexadecimal_in(Result);
      end;

   hexa4_at(index: INTEGER): STRING is
      do
         !!Result.copy("0x");
         bytes.item(index + 0).to_character.to_hexadecimal_in(Result);
         bytes.item(index + 1).to_character.to_hexadecimal_in(Result);
         bytes.item(index + 2).to_character.to_hexadecimal_in(Result);
         bytes.item(index + 3).to_character.to_hexadecimal_in(Result);
      end;

   hexa8_at(index: INTEGER): STRING is
      do
         !!Result.copy("0x");
         bytes.item(index + 0).to_character.to_hexadecimal_in(Result);
         bytes.item(index + 1).to_character.to_hexadecimal_in(Result);
         bytes.item(index + 2).to_character.to_hexadecimal_in(Result);
         bytes.item(index + 3).to_character.to_hexadecimal_in(Result);
         bytes.item(index + 4).to_character.to_hexadecimal_in(Result);
         bytes.item(index + 5).to_character.to_hexadecimal_in(Result);
         bytes.item(index + 6).to_character.to_hexadecimal_in(Result);
         bytes.item(index + 7).to_character.to_hexadecimal_in(Result);
      end;

   u2_integer_at(index: INTEGER): INTEGER is
      do
         Result := bytes.item(index) * 256 + bytes.item(index + 1);
      end;

   u4_integer_at(index: INTEGER): INTEGER is
      do
         Result := bytes.item(index);
         Result := Result * 256;
         Result := Result + bytes.item(index + 1);
         Result := Result * 256;
         Result := Result + bytes.item(index + 2);
         Result := Result * 256;
         Result := Result + bytes.item(index + 3);
      end;

feature {NONE} -- Basic stuff to view values :

   integer_to_hexa_in(int: INTEGER; str: STRING) is
      require
         int >= 0
      do
         str.append("0x");
         inspect
            int
         when 0 .. 255 then
            int.to_character.to_hexadecimal_in(str);
         when 256 .. 65535 then
            (int \\ 256).to_character.to_hexadecimal_in(str);
            (int // 256).to_character.to_hexadecimal_in(str);
         end;
      end;

   extend_string(s: STRING; c: CHARACTER; length: INTEGER) is
      do
         from
         until
            s.count >= length
         loop
            s.extend(c);
         end;
      end;


feature {NONE}

   bad_class_file(msg: STRING; at: INTEGER) is
         -- If `at' is greater than 0, the corresponding byte
         -- is shown during the class file dump.
      require
         bytes.valid_index(at)
      local
         fz_visible, fz_hexadec: STRING;
         index: INTEGER;
         byte: CHARACTER;
         left_margin: INTEGER;
      do
         io.put_string(msg);
         io.put_new_line;
         io.put_string("Class file dump:%N");
         from
            !!fz_visible.make(16);
            !!fz_hexadec.make(32);
         until
            index > bytes.upper
         loop
            if fz_visible.is_empty then
               tmp_string.clear;
               integer_to_hexa_in(index,tmp_string);
               tmp_string.extend(' ');
               extend_string(tmp_string,' ',9);
               index.append_in(tmp_string);
               tmp_string.extend(' ');
               extend_string(tmp_string,' ',15);
               io.put_string(tmp_string);
               left_margin := tmp_string.count;
            end;
            byte := character_at(index);
            byte.to_hexadecimal_in(fz_hexadec);
            inspect
               byte.code
            when 32 .. 126 then
               fz_visible.extend(byte);
            else
               fz_visible.extend('.');
            end
            if fz_visible.count = 16 then
               show_dump_line(fz_hexadec,fz_visible,left_margin,index,at);
            end;
            index := index + 1;
         end;
         if fz_visible.count > 0 then
            from
               index := index - 1;
            until
               fz_visible.count = 16
            loop
               fz_visible.extend(' ');
               fz_hexadec.append("  ");
               index := index + 1;
            end;
            show_dump_line(fz_hexadec,fz_visible,left_margin,index,at);
         end;
         die_with_code(exit_failure_code);
      end;

   show_dump_line(hexadec, visible: STRING; left_margin, index, at: INTEGER) is
         -- Where `index - 15' is the index of `visible.item(1)'.
      require
         bytes.valid_index(at);
         visible.count = 16;
         hexadec.count = 32
      local
         min, max, i: INTEGER;
      do
         io.put_string(hexadec);
         io.put_string(" ");
         io.put_string(visible);
         io.put_new_line;
         min := index - 15;
         max := index;
         if (at > 0) and (min <= at) and (at <= max) then
            from
               tmp_string.clear;
               extend_string(tmp_string,'_',left_margin);
               i := min;
            until
               i = at
            loop
               tmp_string.append("__");
               i := i + 1;
            end;
            io.put_string(tmp_string);
            io.put_string("^^%N*** Error at this byte%N");
            io.put_string("Remainder of the class file :%N");
         end;
         visible.clear;
         hexadec.clear;
      ensure
         visible.is_empty;
         hexadec.is_empty
      end;

feature {NONE}

   load_cp_info(i: INTEGER; index: INTEGER): INTEGER is
         -- Gives the index of the following item.
      local
         tag, i2, length: INTEGER;
         utf8: STRING;
      do
         tmp_string.clear;
         tmp_string.append("item #");
         i.append_in(tmp_string);
         extend_string(tmp_string,' ',8);
         tmp_string.append(" : ");
         io.put_string(tmp_string);
         tag := bytes.item(index);
         inspect
            tag.to_character
         when Constant_class then
            io.put_string("CONSTANT_Class");
            constant_pool.set_class(i,u2_at(index + 1));
            Result := index + 3;
         when Constant_fieldref then
            io.put_string("CONSTANT_Fieldref");
            constant_pool.set_fieldref(i,u4_at(index + 1));
            Result := index + 5;
         when Constant_methodref then
            io.put_string("CONSTANT_Methodref");
            constant_pool.set_methodref(i,u4_at(index + 1));
            Result := index + 5;
         when Constant_interfacemethodref then
            io.put_string("CONSTANT_InterfaceMethodref");
            constant_pool.set_interface_methodref(i,u4_at(index + 1));
            Result := index + 5;
         when Constant_string then
            io.put_string("CONSTANT_String");
            constant_pool.set_string(i,u2_at(index + 1));
            Result := index + 3;
         when Constant_integer then
            io.put_string("CONSTANT_Integer");
            constant_pool.set_integer(i,u4_at(index + 1));
            Result := index + 5;
         when Constant_float then
            io.put_string("CONSTANT_Float");
            constant_pool.set_float(i,u4_at(index + 1));
            Result := index + 5;
         when Constant_long then
            io.put_string("CONSTANT_Long");
            constant_pool.set_long(i,u8_at(index + 1));
            Result := index + 9;
         when Constant_double then
            io.put_string("CONSTANT_Double");
            constant_pool.set_double(i,u8_at(index + 1));
            Result := index + 9;
         when Constant_name_and_type then
            io.put_string("CONSTANT_NameandType");
            constant_pool.set_name_and_type(i,u4_at(index + 1));
            Result := index + 5;
         when Constant_utf8 then
            io.put_string("CONSTANT_Utf8");
            length := u2_integer_at(index + 1);
            Result := index + 3;
            !!utf8.make(length + 2);
            utf8.extend(character_at(index + 1));
            utf8.extend(character_at(index + 2));
            from
               i2 := length;
            until
               i2 = 0
            loop
               utf8.extend(character_at(Result));
               Result := Result + 1;
               i2 := i2 - 1;
            end;
            constant_pool.set_utf8(i,utf8);
         else
            io.put_string("Error while loading constant pool.%N");
            io.put_string("Problem with item #");
            io.put_integer(i);
            io.put_string("%NBad cp_info tag : ");
            io.put_integer(tag);
            io.put_string("%N");
            bad_class_file("Bad constant pool.",index);
         end;
         io.put_new_line;
      end;

feature {NONE}

   u2_to_integer(u2: STRING): INTEGER is
      require
         u2.count = 2
      do
         Result := u2.item(1).code;
         Result := Result * 256;
         Result := Result + u2.item(2).code;
      ensure
         Result >= 0
      end;

   print_cp_info(i: INTEGER; index: INTEGER): INTEGER is
         -- Gives the index of the following item.
      local
         tag: INTEGER;
         cp_info: CP_INFO;
         info: STRING;
         class_idx, name_idx, type_idx, string_idx: INTEGER;
      do
         tag := bytes.item(index);
         cp_info := constant_pool.item(i);
         info := cp_info.info;
         check
            tag.to_character = cp_info.tag
         end;
         inspect
            tag.to_character
         when Constant_class then -- CONSTANT_Class :
            io.put_string("class at ");
            class_idx := u2_to_integer(info);
            if constant_pool.valid_index(class_idx) then
               io.put_integer(class_idx);
               io.put_string(": ");
               cp_info := constant_pool.item(class_idx);
               if cp_info.tag.code = 1 then
                  tmp_string.clear;
                  constant_pool.view_in(tmp_string,i);
                  io.put_string(tmp_string);
               else
                  io.put_string("%NUtf8 index expected.%N");
                  bad_class_file("Bad constant pool.",index + 1);
               end;
            else
               io.put_string("Class index out of range.%N");
               bad_class_file("Bad constant pool.",index + 1);
            end;
            Result := index + 3;
         when Constant_fieldref then -- CONSTANT_Fieldref :
            io.put_string("fieldref class: ");
            print_cp_info_fields_methods(index,info);
            Result := index + 5;
         when Constant_methodref then -- CONSTANT_Methodref :
            io.put_string("methodref class: ");
            print_cp_info_fields_methods(index,info);
            Result := index + 5;
         when Constant_interfacemethodref then -- CONSTANT_InterfaceMethodref :
            io.put_string("interface methodref class: ");
            print_cp_info_fields_methods(index,info);
            Result := index + 5;
         when Constant_string then -- CONSTANT_String :
            io.put_string("string at ");
            string_idx := u2_to_integer(info);
            if constant_pool.valid_index(string_idx) then
               io.put_integer(string_idx);
               io.put_string(" : %"");
               cp_info := constant_pool.item(string_idx);
               if cp_info.tag.code = 1 then
                  tmp_string.clear;
                  constant_pool.view_in(tmp_string,i);
                  io.put_string(tmp_string);
                  io.put_string("%"");
               else
                  io.put_string("%NUtf8 index expected.%N");
                  bad_class_file("Bad constant pool.",index + 1);
               end;
            else
               io.put_string("??%NString index out of range.%N");
               bad_class_file("Bad constant pool.",index + 1);
            end;
            Result := index + 3;
         when Constant_integer then -- CONSTANT_Integer :
            io.put_string("integer: ");
            io.put_string(hexa4_at(index + 1));
            Result := index + 5;
         when Constant_float then -- CONSTANT_Float :
            io.put_string("float: ");
            io.put_string(hexa4_at(index + 1));
            Result := index + 5;
         when Constant_long then -- CONSTANT_Long :
            io.put_string("long: ");
            io.put_string(hexa8_at(index + 1));
            Result := index + 9;
         when Constant_double then -- CONSTANT_Double :
            io.put_string("double: ");
            io.put_string(hexa8_at(index + 1));
            Result := index + 9;
         when Constant_name_and_type then -- CONSTANT_NameandType :
            io.put_string("name: ");
            name_idx := u2_to_integer(info.substring(1,2));
            if constant_pool.valid_index(name_idx) then
               cp_info := constant_pool.item(name_idx);
               if cp_info.tag.code = 1 then
                  tmp_string.clear;
                  constant_pool.view_in(tmp_string,name_idx);
                  io.put_string(tmp_string);
                  io.put_string(" type: ");
                  type_idx := u2_to_integer(info.substring(3,4));
                  if constant_pool.valid_index(type_idx) then
                     cp_info := constant_pool.item(type_idx);
                     if cp_info.tag.code = 1 then
                        tmp_string.clear;
                        constant_pool.view_in(tmp_string,type_idx);
                        io.put_string(tmp_string);
                     else
                        io.put_string("??%NUtf8 index expected.%N");
                        bad_class_file("Bad constant pool.",index + 3);
                     end;
                  else
                     io.put_string("%NType index out of range.%N");
                     bad_class_file("Bad constant pool.",index + 3);
                  end;
               else
                  io.put_string("%NUtf8 index expected.%N");
                  bad_class_file("Bad constant pool.",index + 1);
               end;
            else
               io.put_string("??%NClass index out of range.%N");
               bad_class_file("Bad constant pool.",index + 1);
            end;
            Result := index + 5;
         when Constant_utf8 then -- CONSTANT_Utf8 :
            io.put_string("utf8: %"");
            tmp_string.clear;
            constant_pool.view_in(tmp_string,i);
            io.put_string(tmp_string);
            io.put_string("%"");
            Result := index + 1 + cp_info.info.count;
         end;
      end;

   print_cp_info_fields_methods(index: INTEGER; info: STRING) is
      require

      local
         cp_info: CP_INFO;
         class_idx, utf8_idx, name_and_type_idx: INTEGER;
      do
         class_idx := u2_to_integer(info.substring(1,2));
         name_and_type_idx := u2_to_integer(info.substring(3,4));
         if constant_pool.valid_index(class_idx) then
            cp_info := constant_pool.item(class_idx);
            if cp_info.tag.code = 7 then
               utf8_idx := u2_to_integer(cp_info.info);
               if constant_pool.valid_index(utf8_idx) then
                  tmp_string.clear;
                  constant_pool.view_in(tmp_string,class_idx);
                  io.put_string(tmp_string);
                  io.put_string(" name_and_type: ");
                  if constant_pool.valid_index(name_and_type_idx) then
                     tmp_string.clear;
                     constant_pool.view_in(tmp_string,name_and_type_idx);
                     io.put_string(tmp_string);
                  else
                     io.put_string("??%N*** Error: name_and_type_index expected.");
                     bad_class_file("Bad constant pool.",index + 3);
                  end;
               else
                  io.put_string("??%N*** Error: Class index expected.");
               end;
            else
               io.put_string("%NClass index expected.%N");
               bad_class_file("Bad constant pool.",index + 1);
            end;
         else
            io.put_string("??%NClass index out of range.%N");
            bad_class_file("Bad constant pool.",index + 1);
         end;
      end;

feature {NONE}

   print_field_info(index: INTEGER): INTEGER is
      local
         access_flags_idx, name_idx: INTEGER;
         descriptor_idx, field_attributes_count: INTEGER;
         access_flags: BIT Integer_bits;
      do
         access_flags_idx := index;
         Result := index + 2;
         io.put_string("access flags (");
         io.put_string(hexa2_at(access_flags_idx));
         io.put_string("): ");
         access_flags := bytes.item(access_flags_idx + 1).to_bit;
         if (access_flags and 1B).to_boolean then
            io.put_string("public ");
         end;
         if (access_flags and 10B).to_boolean then
            io.put_string("private ");
         end;
         if (access_flags and 100B).to_boolean then
            io.put_string("protected ");
         end;
         if (access_flags and 1000B).to_boolean then
            io.put_string("static ");
         end;
         if (access_flags and 10000B).to_boolean then
            io.put_string("final ");
         end;
         if (access_flags and 1000000B).to_boolean then
            io.put_string("volatile ");
         end;
         if (access_flags and 10000000B).to_boolean then
            io.put_string("transient ");
         end;
         io.put_new_line;
         io.put_string("Field name: ");
         name_idx := u2_integer_at(Result);
         Result := Result + 2;
         if constant_pool.valid_index(name_idx) then
            tmp_string.clear;
            constant_pool.view_in(tmp_string,name_idx);
            io.put_string(tmp_string);
            descriptor_idx := u2_integer_at(Result);
            Result := Result + 2;
            io.put_string(" descriptor: ");
            if constant_pool.valid_index(descriptor_idx) then
               tmp_string.clear;
               constant_pool.view_in(tmp_string,descriptor_idx);
               io.put_string(tmp_string);
               field_attributes_count := u2_integer_at(Result);
               Result := Result + 2;
               io.put_new_line;
               io.put_string("Attributes count: ");
               io.put_integer(field_attributes_count);
               io.put_new_line;
               from
               until
                  field_attributes_count = 0
               loop
                  Result := print_attribute_info(Result);
                  field_attributes_count := field_attributes_count - 1;
               end;
            else
               io.put_string("??%NDescriptor index out of range.%N");
               bad_class_file("Bad constant pool.",Result - 2);
            end;
         else
            io.put_string("??%NName index out of range.%N");
            bad_class_file("Bad constant pool.",Result - 2);
         end;
      end;

   print_attribute_info(index: INTEGER): INTEGER is
      local
         attribute_name_idx, attribute_length: INTEGER;
         attribute_name: STRING;
         tmp: INTEGER;
      do
         attribute_name_idx := u2_integer_at(index);
         Result := index + 2;
         io.put_string("Attribute Name: ");
         tmp_string.clear;
         constant_pool.view_in(tmp_string,attribute_name_idx);
         io.put_string(tmp_string);
         attribute_name := tmp_string.twin;
         attribute_length := u4_integer_at(Result);
         Result := Result + 4;
         io.put_string(" length: ");
         io.put_integer(attribute_length);
         io.put_character(' ');
         if ("Code").is_equal(attribute_name) then
            tmp := print_code_attribute(Result,attribute_length);
            Result := Result + attribute_length;
         else
            io.put_string(" Ignored (skipped)%N");
            Result := Result + attribute_length;
         end;
      end;


   print_method_info(index: INTEGER): INTEGER is
      local
         access_flags_idx, name_idx: INTEGER;
         descriptor_idx, method_attributes_count: INTEGER;
         access_flags: BIT Integer_bits;
      do
         access_flags_idx := index;
         Result := index + 2;
         io.put_string("access flags (");
         io.put_string(hexa2_at(access_flags_idx));
         io.put_string("): ");
         access_flags := bytes.item(access_flags_idx + 1).to_bit;
         if (access_flags and 1B).to_boolean then
            io.put_string("public ");
         end;
         if (access_flags and 10B).to_boolean then
            io.put_string("private ");
         end;
         if (access_flags and 100B).to_boolean then
            io.put_string("protected ");
         end;
         if (access_flags and 1000B).to_boolean then
            io.put_string("static ");
         end;
         if (access_flags and 10000B).to_boolean then
            io.put_string("final ");
         end;
         if (access_flags and 100000B).to_boolean then
            io.put_string("synchronized ");
         end;
         access_flags := bytes.item(access_flags_idx).to_bit;
         if (access_flags and 1B).to_boolean then
            io.put_string("native ");
         end;
         if (access_flags and 100B).to_boolean then
            io.put_string("abstract ");
         end;
         io.put_new_line;
         name_idx := u2_integer_at(Result);
         Result := Result + 2;
         io.put_string("Method name: ");
         tmp_string.clear;
         constant_pool.view_in(tmp_string,name_idx);
         io.put_string(tmp_string);
         io.put_string(" descriptor: ");
         descriptor_idx := u2_integer_at(Result);
         Result := Result + 2;
         tmp_string.clear;
         constant_pool.view_in(tmp_string,descriptor_idx);
         io.put_string(tmp_string);
         io.put_new_line;
         io.put_string("Attributes count: ");
         method_attributes_count := u2_integer_at(Result);
         Result := Result + 2;
         io.put_integer(method_attributes_count);
         io.put_new_line;
         from
         until
            method_attributes_count = 0
         loop
            Result := print_attribute_info(Result);
            method_attributes_count := method_attributes_count - 1;
         end;
      end;

   print_code_attribute(index, length: INTEGER): INTEGER is
      local
         code_length: INTEGER;
         exception_table_length: INTEGER;
         max_stack, max_locals: INTEGER;
         -- idx: INTEGER;
         local_attributes_count: INTEGER;
      do
         io.put_string("%Nmax_stack: ");
         max_stack := u2_integer_at(index);
         Result := index + 2;
         io.put_integer(max_stack);
         io.put_string(" max_locals: ");
         max_locals := u2_integer_at(Result);
         Result := Result + 2;
         io.put_integer(max_locals);
         io.put_string(" code_length: ");
         code_length := u4_integer_at(Result);
         Result := Result + 4;
         io.put_integer(code_length);
         io.put_new_line;
         print_byte_code(Result,code_length);
         Result := Result + code_length;
         exception_table_length := u2_integer_at(Result);
         Result := Result + 2;
         io.put_string("Exception(s): ");
         io.put_integer(exception_table_length);
         io.put_new_line;
         print_exception_table(Result,exception_table_length);
         Result := Result + exception_table_length * 8;
         io.put_string("Attributes count: ");
         local_attributes_count := u2_integer_at(Result);
         Result := Result + 2;
         io.put_integer(local_attributes_count);
         io.put_new_line;
         from
         until
            local_attributes_count = 0
         loop
            Result := print_attribute_info(Result);
            local_attributes_count := local_attributes_count - 1;
         end;
      end;

   inst_view(byte_idx: INTEGER; cp_idx_type: CHARACTER) is
      local
         cp_idx: INTEGER;
         cp_info: CP_INFO;
      do
         cp_idx := u2_integer_at(byte_idx);
         if constant_pool.valid_index(cp_idx) then
            cp_info := constant_pool.item(cp_idx);
            if cp_info.tag = cp_idx_type then
               constant_pool.view_in(inst,cp_idx);
            else
               tmp_string.clear;
               tmp_string.append("????%N");
               tmp_string.append("Invalid type entry in constant pool at: ");
               cp_idx.append_in(tmp_string);
               tmp_string.append(" : ");
               constant_pool.view_in(tmp_string,cp_idx);
               tmp_string.append("%NExpected tag: ");
               cp_idx_type.code.append_in(tmp_string);
               tmp_string.append(" (");
               cp_info_tag_name_in(cp_idx_type,tmp_string);
               tmp_string.append(")%NActual   tag: ");
               cp_info.tag.code.append_in(tmp_string);
               tmp_string.append(" (");
               cp_info_tag_name_in(cp_info.tag,tmp_string);
               tmp_string.append(")%N");
               io.put_string(tmp_string);
               bad_class_file("Constant pool type index error.",byte_idx);
            end;
         else
            io.put_string("????%N");
            bad_class_file("Valid index in constant pool expected.",byte_idx);
         end;
      end;

   u2sign_extended_view(str: STRING; idx: INTEGER) is
      local
         byte: INTEGER;
      do
         byte := bytes.item(idx);
         str.append(hexa1_at(idx));
         str.append(" (");
         if byte < 128 then
            byte.append_in(str);
         else
            (byte - 256).append_in(str)
         end;
         str.append(")");
      end;

   print_one_instruction(pc_idx, pc: INTEGER): INTEGER is
         -- Return the following `pc_idx'.
      local
         opcode: INTEGER;
         idx: INTEGER;
      do
         Result := pc_idx + 1;
         opcode := bytes.item(pc_idx);
         inspect
            opcode
         when 0 then
            inst_opcode("nop (Do nothing)");
         when 1 then
            inst_opcode("aconst_null (Push null)");
         when 2 then
            inst_opcode("iconst_m1 (Push int -1)");
         when 3 .. 8 then
            inst_opcode("iconst_");
            (opcode - 3).append_in(inst);
            inst.append(" (Push int ");
            (opcode - 3).append_in(inst);
            inst.extend(')');
         when 9 then
            inst_opcode("lconst_0 (Push long 0)");
         when 10 then
            inst_opcode("lconst_1 (Push long 1)");
         when 11 .. 13 then
            inst_opcode("fconst_");
            (opcode - 11).append_in(inst);
         when 14 .. 15 then
            inst_opcode("dconst_");
            (opcode - 14).append_in(inst);
         when 16 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("bipush ");
            u2sign_extended_view(inst,pc_idx + 1);
            Result := Result + 1;
         when 17 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("sipush ");
            inst.append(hexa2_at(pc_idx + 1));
            inst_opcode("(Push short with sign-extension)");
            Result := Result + 2;
         when 18 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            idx := bytes.item(pc_idx + 1);
            inst_opcode("ldc at ");
            idx.append_in(inst);
            inst.append(" : ");
            if constant_pool.valid_index(idx) then
               constant_pool.view_in(inst,idx);
            else
               io.put_string("??%N");
               bad_class_file("Constant pool index out of range.",pc_idx + 1);
            end;
            Result := Result + 1;
         when 19 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("ldc_w ");
            idx := u2_integer_at(pc_idx + 1);
            if constant_pool.valid_index(idx) then
               constant_pool.view_in(inst,idx);
            else
               io.put_string("????%N");
               bad_class_file("Constant pool index out of range.",pc_idx + 1);
            end;
            Result := Result + 2;
         when 20 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("ldc2_w ");
            idx := u2_integer_at(pc_idx + 1);
            if constant_pool.valid_index(idx) then
               constant_pool.view_in(inst,idx);
            else
               io.put_string("????%N");
               bad_class_file("CONSTANT_Long or CONSTANT_Double expected.",pc_idx + 1);
            end;
            Result := Result + 2;
         when 21 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("iload ");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.append(" (load int from local #");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.extend(')');
            Result := Result + 1;
         when 22 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("lload ");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.append(" (load long from local #");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.extend(')');
            Result := Result + 1;
         when 23 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("fload ");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.append(" (load float from local #");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.extend(')');
            Result := Result + 1;
         when 24 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("dload ");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.append(" (load double from local #");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.extend(')');
            Result := Result + 1;
         when 25 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("aload ");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.append(" (load reference from local #");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.extend(')');
            Result := Result + 1;
         when 26 .. 29 then
            inst_opcode("iload_");
            (opcode - 26).append_in(inst);
            inst.append(" (load int from local #");
            (opcode - 26).append_in(inst);
            inst.extend(')');
         when 30 .. 33 then
            inst_opcode("lload_");
            (opcode - 30).append_in(inst);
            inst.append(" (load long from local #");
            (opcode - 30).append_in(inst);
            inst.extend(')');
         when 34 .. 37 then
            inst_opcode("fload_");
            (opcode - 34).append_in(inst);
            inst.append(" (load float from local #");
            (opcode - 34).append_in(inst);
            inst.extend(')');
         when 38 .. 41 then
            inst_opcode("dload_");
            (opcode - 38).append_in(inst);
            inst.append(" (load double from local #");
            (opcode - 38).append_in(inst);
            inst.extend(')');
         when 42 .. 45 then
            inst_opcode("aload_");
            (opcode - 42).append_in(inst);
            inst.append(" (load reference from local #");
            (opcode - 42).append_in(inst);
            inst.extend(')');
         when 46 then
            inst_opcode("iaload");
         when 47 then
            inst_opcode("laload");
         when 48 then
            inst_opcode("faload");
         when 49 then
            inst_opcode("daload");
         when 50 then
            inst_opcode("aaload");
         when 51 then
            inst_opcode("baload");
         when 52 then
            inst_opcode("caload");
         when 53 then
            inst_opcode("saload");
         when 54 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("istore ");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.append(" (store int into local #");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.extend(')');
            Result := Result + 1;
         when 55 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("lstore ");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.append(" (store long into local #");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.extend(')');
            Result := Result + 1;
         when 56 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("fstore ");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.append(" (store float into local #");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.extend(')');
            Result := Result + 1;
         when 57 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("dstore ");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.append(" (store double into local #");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.extend(')');
            Result := Result + 1;
         when 58 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("astore ");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.append(" (store reference into local #");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.extend(')');
            Result := Result + 1;
         when 59 .. 62 then
            inst_opcode("istore_");
            (opcode - 59).append_in(inst);
         when 63 .. 66 then
            inst_opcode("lstore_");
            (opcode - 63).append_in(inst);
            inst.append(" (store long into local #");
            (opcode - 63).append_in(inst);
            inst.extend(')');
         when 67 .. 70 then
            inst_opcode("fstore_");
            (opcode - 67).append_in(inst);
            inst.append(" (store float into local #");
            (opcode - 67).append_in(inst);
            inst.extend(')');
         when 71 .. 74 then
            inst_opcode("dstore_");
            (opcode - 71).append_in(inst);
            inst.append(" (store double into local #");
            (opcode - 71).append_in(inst);
            inst.extend(')');
         when 75 .. 78 then
            inst_opcode("astore_");
            (opcode - 75).append_in(inst);
            inst.append(" (store reference into local #");
            (opcode - 75).append_in(inst);
            inst.extend(')');
         when 79 then
            inst_opcode("iastore");
         when 80 then
            inst_opcode("lastore");
         when 81 then
            inst_opcode("fastore");
         when 82 then
            inst_opcode("dastore");
         when 83 then
            inst_opcode("aastore");
         when 84 then
            inst_opcode("bastore");
         when 85 then
            inst_opcode("castore");
         when 86 then
            inst_opcode("sastore");
         when 87 then
            inst_opcode("pop (...,w => ...)");
         when 88 then
            inst_opcode("pop2 (...,w1,w2 => ...)");
         when 89 then
            inst_opcode("dup (...,w => ...,w,w)");
         when 90 then
            inst_opcode("dup_x1 (...,w2,w1 => ...,w1,w2,w1)");
         when 91 then
            inst_opcode("dup_x2 (...,w3,w2,w1 => ...,w1,w3,w2,w1)");
         when 92 then
            inst_opcode("dup2 (...,w2,w1 => ...,w2,w1,w2,w1)");
         when 93 then
            inst_opcode("dup2_x1 (...,w3,w2,w1 => ...,w2,w1,w3,w2,w1)");
         when 94 then
            inst_opcode("dup2_x2 (...,w4,w3,w2,w1 => ...,w2,w1,w4,w3,w2,w1)");
         when 95 then
            inst_opcode("swap (...,w2,w1 => ...,w1,w2)");
         when 96 then
            inst_opcode("iadd");
         when 97 then
            inst_opcode("ladd");
         when 98 then
            inst_opcode("fadd");
         when 99 then
            inst_opcode("dadd");
         when 100 then
            inst_opcode("isub");
         when 101 then
            inst_opcode("lsub");
         when 102 then
            inst_opcode("fsub");
         when 103 then
            inst_opcode("dsub");
         when 104 then
            inst_opcode("imul");
         when 105 then
            inst_opcode("lmul");
         when 106 then
            inst_opcode("fmul");
         when 107 then
            inst_opcode("dmul");
         when 108 then
            inst_opcode("idiv");
         when 109 then
            inst_opcode("ldiv");
         when 110 then
            inst_opcode("fdiv");
         when 111 then
            inst_opcode("ddiv");
         when 112 then
            inst_opcode("irem");
         when 116 then
            inst_opcode("ineg");
         when 117 then
            inst_opcode("lneg");
         when 118 then
            inst_opcode("fneg");
         when 119 then
            inst_opcode("dneg");
         when 120 then
            inst_opcode("ishl");
         when 124 then
            inst_opcode("iushr");
         when 126 then
            inst_opcode("iand");
         when 128 then
            inst_opcode("ior");
         when 130 then
            inst_opcode("ixor");
         when 132 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("iinc local #");
            bytes.item(pc_idx + 1).append_in(inst);
            inst.append(" with: :");
            inst.append(hexa1_at(pc_idx + 2));
            inst.append(" (sign-extended)");
            Result := Result + 2;
         when 133 then
            inst_opcode("i2l (Convert int to long)");
         when 134 then
            inst_opcode("i2f (Convert int to float)");
         when 135 then
            inst_opcode("i2d (Convert int to double)");
         when 136 then
            inst_opcode("l2i (Convert long to int)");
         when 137 then
            inst_opcode("l2f (Convert long to float)");
         when 138 then
            inst_opcode("l2d (Convert long to double)");
         when 139 then
            inst_opcode("f2i (Convert float to int)");
         when 140 then
            inst_opcode("f2l (Convert float to long)");
         when 141 then
            inst_opcode("f2d (Convert float to double)");
         when 142 then
            inst_opcode("d2i (Convert double to int)");
         when 143 then
            inst_opcode("d2l (Convert double to long)");
         when 144 then
            inst_opcode("d2f (Convert double to float)");
         when 145 then
            inst_opcode("i2b (Convert int to byte)");
         when 146 then
            inst_opcode("i2c (Convert int to char)");
         when 149 then
            inst_opcode("fcmpl");
         when 150 then
            inst_opcode("fcmpg");
         when 151 .. 152 then
            inst_opcode("dcmp");
            inspect
               opcode
            when 151 then
               inst.append("l");
            when 152 then
               inst.append("g");
            end;
         when 153 .. 158 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("if");
            inspect
               opcode
            when 153 then
               inst.append("eq");
            when 154 then
               inst.append("ne");
            when 155 then
               inst.append("lt");
            when 156 then
               inst.append("ge");
            when 157 then
               inst.append("gt");
            when 158 then
               inst.append("le");
            end;
            inst.extend(' ');
            view_pc(u2_integer_at(pc_idx + 1),pc);
            Result := Result + 2;
         when 159 .. 166 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("if_");
            inspect
               opcode
            when 159 .. 164 then
               inst.extend('i');
            else
               inst.extend('a');
            end;
            inst.append("cmp");
            inspect
               opcode
            when 159 then
               inst.append("eq");
            when 160 then
               inst.append("ne");
            when 161 then
               inst.append("lt");
            when 162 then
               inst.append("ge");
            when 163 then
               inst.append("gt");
            when 164 then
               inst.append("le");
            when 165 then
               inst.append("eq");
            when 166 then
               inst.append("ne");
            end;
            inst.extend(' ');
            view_pc(u2_integer_at(pc_idx + 1),pc);
            Result := Result + 2;
         when 167 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("goto ");
            view_pc(u2_integer_at(pc_idx + 1),pc);
            Result := Result + 2;
         when 172 then
            inst_opcode("ireturn");
         when 173 then
            inst_opcode("lreturn");
         when 174 then
            inst_opcode("freturn");
         when 175 then
            inst_opcode("dreturn");
         when 176 then
            inst_opcode("areturn");
         when 177 then
            inst_opcode("return");
         when 178 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("getstatic ");
            inst_view(pc_idx + 1,Constant_fieldref);
            Result := Result + 2;
         when 179 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("putstatic ");
            inst_view(pc_idx + 1,Constant_fieldref);
            Result := Result + 2;
         when 180 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("getfield ");
            inst_view(pc_idx + 1,Constant_fieldref);
            Result := Result + 2;
         when 181 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("putfield ");
            inst_view(pc_idx + 1,Constant_fieldref);
            Result := Result + 2;
         when 182 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("invokevirtual ");
            inst_view(pc_idx + 1,Constant_methodref);
            Result := Result + 2;
         when 183 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("invokespecial ");
            inst_view(pc_idx + 1,Constant_methodref);
            Result := Result + 2;
         when 184 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("invokestatic ");
            inst_view(pc_idx + 1,Constant_methodref);
            Result := Result + 2;
         when 185 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("invokeinterface ");
            inst_view(pc_idx + 1,Constant_interfacemethodref);
            Result := Result + 2;
         when 187 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("new ");
            inst_view(pc_idx + 1,Constant_class);
            Result := Result + 2;
         when 188 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            inst_opcode("newarray of ");
            inspect
               bytes.item(pc_idx + 1)
            when 4 then
               inst.append("boolean");
            when 5 then
               inst.append("character");
            when 6 then
               inst.append("float");
            when 7 then
               inst.append("double");
            when 8 then
               inst.append("byte");
            when 9 then
               inst.append("short");
            when 10 then
               inst.append("int");
            when 11 then
               inst.append("long");
            else
               io.put_string("??%NInvalid newarray instruction.%N");
               bad_class_file("Bad array type.",pc_idx + 1);
            end;
            Result := Result + 1
         when 189 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("anewarray of ");
            inst_view(pc_idx + 1,Constant_class);
            Result := Result + 2;
         when 190 then
            inst_opcode("arraylength");
         when 191 then
            inst_opcode("athrow");
         when 192 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("checkcast ");
            inst_view(pc_idx + 1,Constant_class);
            Result := Result + 2;
         when 193 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("instanceof ");
            inst_view(pc_idx + 1,Constant_class);
            Result := Result + 2;
         when 198 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("ifnull ");
            view_pc(u2_integer_at(pc_idx + 1),pc);
            Result := Result + 2;
         when 199 then
            character_at(pc_idx + 1).to_hexadecimal_in(inst);
            character_at(pc_idx + 2).to_hexadecimal_in(inst);
            inst_opcode("ifnonnull ");
            view_pc(u2_integer_at(pc_idx + 1),pc);
            Result := Result + 2;
         else
            io.put_string(inst);
            io.put_new_line;
            io.put_string("Unknown Opcode: ");
            io.put_integer(opcode);
            io.put_string(" (0x");
            io.put_string(opcode.to_character.to_hexadecimal);
            io.put_string(")%N");
            bad_class_file("Unknown Opcode.",pc_idx);
         end;
      ensure
         Result >= pc_idx + 1
      end;

   print_byte_code(start_idx, length: INTEGER) is
         -- Print the byte code stored in range :
         --    [`start_idx' .. `start_idx' + `length']
      require
         bytes.valid_index(start_idx);
         length >= 0
      local
         pc_idx, pc: INTEGER;
      do
         from
            pc_idx := start_idx;
         until
            pc_idx = start_idx + length
         loop
            pc := pc_idx - start_idx;
            tmp_string.copy("  ");
            integer_to_hexa_in(pc,tmp_string);
            tmp_string.append("  ");
            pc.append_in(tmp_string);
            tmp_string.extend(' ');
            extend_string(tmp_string,' ',12);
            character_at(pc_idx).to_hexadecimal_in(tmp_string);
            io.put_string(tmp_string);
            inst.clear;
            pc_idx := print_one_instruction(pc_idx, pc_idx - start_idx);
            io.put_string(inst);
            io.put_new_line;
         end;
      end;

   print_exception_table(index, length: INTEGER) is
      local
         i, idx: INTEGER;

      do
         from
            i := length
          idx := index;
         until
            i = 0
         loop
            io.put_string("start:   ");
          io.put_integer(u2_integer_at(idx));
            io.put_string("%Nend:     ");
          io.put_integer(u2_integer_at(idx + 2));
            io.put_string("%Nhandler: ");
          io.put_integer(u2_integer_at(idx + 4));
            io.put_string("%Ntype:    ");
          io.put_integer(u2_integer_at(idx + 6));
          inst.copy("");
            inst_view(idx + 6, Constant_class);
          io.put_string(" (class ");
          io.put_string(inst);
          io.put_string(")%N");
            i := i - 1;
          idx := idx + 8;
         end;
      end;

feature {NONE}

   tmp_string: STRING is
      once
         !!Result.make(32);
      end;

feature {NONE}

   inst_opcode(msg: STRING) is
      do
         extend_string(inst,' ',4);
         inst.extend(' ');
         inst.append(msg);
      end;

   inst: STRING is
      once
         !!Result.make(80);
      end;

feature {NONE}

   view_pc(offset, pc: INTEGER) is
      local
         view: INTEGER;
         bits: BIT Integer_bits;
      do
         if offset < ((2 ^ 15) - 1) then
            view := pc + offset;
         else
            view := (offset - (2 ^ 16)) + pc;
         end;
         view.append_in(inst);
      end;

end -- PRINT_JVM_CLASS

