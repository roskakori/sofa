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
expanded class POSITION
   --
   -- A position in some source file (ie. an Eiffel source text file 
   -- or some -cecil file)..
   --

inherit GLOBALS;

feature

   base_class: BASE_CLASS;
         -- The corresponding one which may be Void for example when
         -- `is_unknown' or when parsing a -cecil file.

   line: INTEGER is
         -- The corresponding `line' number in the source file or 0 
         -- when `is_unknown'.
      local
         bit: BIT Integer_bits;
      do
         if mangling.last then
            bit := mangling @>> 1;
            bit := bit and 111111111111111B; 
         else
            bit := mangling @>> 8;
            bit := bit and 1111111111111B;
         end;
         Result := bit.to_integer;
      ensure
         not is_unknown implies Result >= 0
      end;
   
   column: INTEGER is
         -- The `column' number in the source file or 0 when `is_unknown' or 
         -- when there is not enough space in `mangling' for the `column'.
      local
         bit: BIT Integer_bits;
      do
         if mangling.last then
            -- Result is 0 because `column' is not memorized.
         else
            bit := mangling @>> 1; -- To drop the flag.
            bit := bit and 1111111B; 
            Result := bit.to_integer;
         end;
      ensure
         Result >= 0
      end;
   
   base_class_name: CLASS_NAME is
         -- The corresponding one when already loaded by the `eiffel_parser'.
      local
         bc: BASE_CLASS;
      do
         bc := base_class;
         if bc /= Void then
            Result := bc.name;
         end;
      end;

   path: STRING is
         -- The corresponding file `path' or Void when `is_unknown'.
      local
         bc: BASE_CLASS;
         id_value: INTEGER;
      do
         bc := base_class;
         if bc /= Void then
            Result := bc.path;
         end;
         if Result = Void then
            -- Looking for the path of the -cecil file.
            id_value := id;
            if id /= 0 then
               Result := id_provider.alias_of(id);
            end;
         end;
      ensure
         Result /= Void implies string_aliaser.item(Result) = Result
      end;

   is_unknown: BOOLEAN is
         -- True when the `eiffel_parser' as called `set'.
      do
         Result := mangling.to_integer = 0;
      end;

   before(other: like Current): BOOLEAN is
         -- Is `Current' position strictly before `other' (which is in the 
         -- same source text file).
      require
         path = other.path
      local
         li, other_li: INTEGER;
      do
         li := line;
         other_li := other.line;
         if li < other_li then
            Result := true;
         elseif li = other_li then
            Result := column < other.column;
         end;
      end;

   show is
      local
         li, co, nb: INTEGER;
         bc: BASE_CLASS;
         bcn: CLASS_NAME;
         name, file_path, the_line: STRING;
      do
         li := line;
         co := column;
         bc := base_class;
         if bc /= Void then
            check id = bc.id end;
            bcn := base_class_name;
         end;
         if bcn /= Void then
            name := bcn.to_string;
            file_path := bc.path;
         end;
         echo.w_put_string("Line ");
         echo.w_put_integer(li);
         if co > 0 then
            echo.w_put_string(" column ");
            echo.w_put_integer(co);
         end;
         echo.w_put_string(" in ");
         if name /= Void then
            echo.w_put_string(name);
         end;
         if file_path /= Void then
            echo.w_put_string(" (");
            echo.w_put_string(file_path);
            echo.w_put_character(')');
         end;
         echo.w_put_string(" :%N");
         if file_path /= Void then
            the_line := get_line(file_path,li);
            if li > 0 and then the_line /= Void then
               echo.w_put_string(the_line);
               echo.w_put_character('%N');
               if co > 0 then
                  from
                     nb := 1;
                  until
                     nb >= co
                  loop
                     if the_line.item(nb) = '%T' then
                        echo.w_put_character('%T');
                     else
                        echo.w_put_character(' ');
                     end;
                     nb := nb + 1;
                  end;
                  echo.w_put_string("^%N");
               end;
            end;
         end;
      end;

   append_in(buffer: STRING) is
      require
         buffer /= Void
      local
         li, co: INTEGER;
         bc: BASE_CLASS;
         bcn: CLASS_NAME;
         place: STRING;
      do
         li := line;
         co := column;
         buffer.append("Line ");
         li.append_in(buffer);
         if co > 0 then
            buffer.append(" column ");
            co.append_in(buffer);
         end;
         bc := base_class;
         if bc /= Void then
            place := bc.path;
            if place = Void then
               bcn := bc.name;
               if bcn /= Void then
                  place := bcn.to_string;
               end;
            end;
            if place /= Void then
               buffer.append(" in %"");
               buffer.append(place);
               buffer.append(fz_03);
            end;
         end;
      end;
   
feature {EIFFEL_PARSER}
   
   set(li, co, class_id: INTEGER; bc: like base_class) is
      require
         li >= 1;
         co >= 1;
         class_id >= 0
      do
         base_class := bc;
         check Integer_bits >= 32 end;
         if class_id <= 2047 and then li <= 8191 and then co <= 127 then
            mangling := (class_id.to_bit @<< 21);       -- 11 bits for `id'
            mangling := mangling or (li.to_bit @<< 8);  -- 13 bits for `line'
            mangling := mangling or (co.to_bit @<< 1);  -- 7  bits for `column'
         else
            -- The `column' is not memorized.
            mangling := (class_id.to_bit @<< 17);       -- 15 bits for `id'
            mangling := mangling or (li.to_bit @<< 1);  -- 16 bits for `line'
            mangling := mangling or (1).to_bit;         -- forget `column'.
         end;
      ensure
         line = li;
         id = class_id;
         column = 0 or else column = co;
      end;

feature {C_PRETTY_PRINTER}

   mangling: BIT Integer_bits;
         -- In order to save memory (there are a lot of objects like `Current'), 
         -- the `id' of the class, the `line' and the `column' are saved in this 
         -- BIT sequence. Two mangling are used, and the `column' may be 
         -- dropped (not memorized, see `set'). This implementation assume 
         -- that `Integer_bits' is greater or equal to 32.
   
feature {NONE}

   id: INTEGER is
      do
         if mangling.last then
            Result := (mangling @>> 17).to_integer; 
         else
            Result := (mangling @>> 21).to_integer; 
         end;
      ensure
         Result >= 0
      end;
   
   get_line(file_path: STRING; li: INTEGER): STRING is
      require
         not file_path.is_empty;
         li > 0
      local
         i: INTEGER;
      do
         echo.sfr_connect(tmp_file_read,file_path);
         if tmp_file_read.is_connected then
            from until tmp_file_read.end_of_input or else i = li
            loop
               tmp_file_read.read_line;
               i := i + 1;
            end;
            if not tmp_file_read.end_of_input then
               Result := tmp_file_read.last_string;
            end;
            tmp_file_read.disconnect;
         end;
      end;

end -- POSITION
