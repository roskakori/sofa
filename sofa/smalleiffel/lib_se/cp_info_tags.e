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
deferred class CP_INFO_TAGS
   --
   -- Some usefull Java Virtual machine constants
   --
inherit GLOBALS;

feature {NONE} --
   -- As defined page 93 of "The Java Virtual Machine Specification",
   -- The Java Series, Tim Lindholm and Frank Yellin, ISBN 0-201-63452-X
   --

   Constant_class: CHARACTER is '%/7/';

   Constant_fieldref: CHARACTER is '%/9/';

   Constant_methodref: CHARACTER is '%/10/';

   Constant_interfacemethodref: CHARACTER is '%/11/';

   Constant_string: CHARACTER is '%/8/';

   Constant_integer: CHARACTER is '%/3/';

   Constant_float: CHARACTER is '%/4/';

   Constant_long: CHARACTER is '%/5/';

   Constant_double: CHARACTER is '%/6/';

   Constant_name_and_type: CHARACTER is '%/12/';

   Constant_utf8: CHARACTER is '%/1/';

feature {NONE}

   cp_info_tag_name_in(tag: CHARACTER; s: STRING) is
         -- Append in `s' the original name of the constant.
      do
         inspect
            tag
         when Constant_class then
            s.append("CONSTANT_Class");
         when Constant_fieldref then
            s.append("CONSTANT_Fieldref");
         when Constant_methodref then
            s.append("CONSTANT_Methodref");
         when Constant_interfacemethodref then
            s.append("CONSTANT_InterfaceMethodref");
         when Constant_string then
            s.append("CONSTANT_String");
         when Constant_integer then
            s.append("CONSTANT_Integer");
         when Constant_float then
            s.append("CONSTANT_Float");
         when Constant_long then
            s.append("CONSTANT_Long");
         when Constant_double then
            s.append("CONSTANT_Double");
         when Constant_name_and_type then
            s.append("CONSTANT_NameAndType");
         when Constant_utf8 then
            s.append("CONSTANT_Utf8");
         end;
      end;

feature {NONE} --
   -- For SmallEifel internal usage :

   Constant_empty: CHARACTER is '%/0/';

feature {NONE}

   string_to_utf8(string, utf8: STRING) is
         -- Source `string' is not affected.
      require
         string /= Void;
         utf8 /= Void;
         utf8 /= string
      do
         utf8.clear;
         append_u2(utf8,string.count);
         utf8.append(string);
      ensure
         string.count = old string.count;
         utf8.count = 2 + string.count
      end;

end -- CP_INFO_TAGS

