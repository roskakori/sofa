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
class ID_PROVIDER
   --
   -- Unique object in charge of some id providing.
   --

inherit GLOBALS;

creation make

feature {SMALL_EIFFEL}

   max_id: INTEGER;

feature {COMPILE_TO_C}

   disk_save is
      local
         i, id: INTEGER;
         sfw: STD_FILE_WRITE;
         str: STRING;
      do
         !!sfw.make;
         echo.sfw_connect(sfw,system_tools.id_file_path);
         from
            i := 1;
         until
            i > id_memory.count
         loop
            str := id_memory.key(i);
            id := id_memory.item(i);
            sfw.put_integer(id);
            sfw.put_character(' ');
            sfw.put_character('%"');
            sfw.put_string(str);
            sfw.put_character('%"');
            sfw.put_character(' ');
            small_eiffel.id_extra_information(sfw,str);
            sfw.put_character('%N');
            i := i + 1;
         end;
         sfw.disconnect;
      end;

feature {EIFFEL_PARSER,BASE_CLASS,RUN_CLASS}

   item(str: STRING): INTEGER is
      require
         str = string_aliaser.item(str)
      do
         if id_memory.has(str) then
            Result := id_memory.at(str);
         else
            max_id := max_id + 1;
            Result := max_id;
            id_memory.put(Result,str);
         end;
      end;

feature {POSITION}

   alias_of(id: INTEGER): STRING is
      do
         Result := id_memory.fast_key_at(id);
      end;

feature {NONE}

   id_memory: DICTIONARY[INTEGER,STRING] is
      once
         !!Result.with_capacity(2048);
      end;

   make is
      do
         id_memory.put(0,as_none);
         id_memory.put(1,as_general);
         id_memory.put(2,as_integer);
         id_memory.put(3,as_character);
         id_memory.put(4,as_real);
         id_memory.put(5,as_double);
         id_memory.put(6,as_boolean);
         id_memory.put(7,as_string);
         id_memory.put(8,as_pointer);
         id_memory.put(9,as_native_array_character);
         id_memory.put(10,as_any);
         id_memory.put(11,as_tuple);
         id_memory.put(12,as_gui_color);
         id_memory.put(13,as_gui_event);
         id_memory.put(14,as_gui_font);
         id_memory.put(15,as_gui_gc);
         id_memory.put(16,as_gui_pixmap);
         max_id := 16;
         disk_restore;
      end;

   disk_restore is
      local
	 cc: CHARACTER;
         type_name: STRING;
         id, item_count: INTEGER;
         sfr: STD_FILE_READ;
	 state: INTEGER;
	 -- state = 0 : waiting first digit of `id'.
	 -- state = 1 : inside `id'.
	 -- state = 2 : waiting opening ".
	 -- state = 3 : inside `type_name'.
	 -- state = 4 : waiting end of line.
	 -- state = 5 : final success.
         -- state = 6 : final error.
      do
         !!sfr.make;
         echo.sfr_connect(sfr,system_tools.id_file_path);
         if sfr.is_connected then
            from
	       if sfr.end_of_input then
		  state := 6;
	       end;
            until
	       state > 4
            loop
	       sfr.read_character;
	       if sfr.end_of_input then
		  state := 5;
	       else
		  cc := sfr.last_character;
	       end;
	       inspect
		  state
	       when 0 then
		  inspect
		     cc
		  when ' ', '%R', '%N', '%T' then
		  when '0' .. '9' then
		     id := cc.decimal_value;
		     state := 1;
		  else
		     state := 6;
		  end;
	       when 1 then
		  inspect
		     cc
		  when '0' ..'9' then
		     id := id * 10 + cc.decimal_value;
		  when '%"' then
		     type_name := temporary_type_name;
		     type_name.clear;
		     state := 3;
		  when ' ', '%T' then
		     state := 2;
		  else
		     state := 6;
		  end;
	       when 2 then
		  inspect
		     cc
		  when '%"' then
		     type_name := temporary_type_name;
		     type_name.clear;
		     state := 3;
		  when ' ', '%T', '%N', '%R' then
		  else
		     state := 6;
		  end;
	       when 3 then
		  inspect
		     cc
		  when '%"' then
		     type_name := string_aliaser.item(type_name);
		     item_count := item_count + 1;
		     id_memory.put(id,type_name);
		     max_id := max_id.max(id);
		     state := 4;
		  when '%N', '%R', '%T' then
		     state := 6;
		  else
		     type_name.extend(cc);
		  end;
	       when 4 then
		  inspect
		     cc
		  when '%N', '%R' then
		     state := 0;
		  else
		  end;
	       else
	       end;
            end;
            sfr.disconnect;
	    if state = 6 then
	       echo.put_string("Corrupted *.id file (after ");
	       echo.put_integer(item_count);
	       echo.put_string(" correct items).%N");
	    end;
            echo.put_string("Previous IDs reloaded (");
            echo.put_integer(id_memory.count);
            echo.put_character('/');
            echo.put_integer(max_id);
            echo.put_string(").%N");
         end;
      end;

   temporary_type_name: STRING is
      once
	 !!Result.make(128);
      end;

end -- ID_PROVIDER
