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
class NATIVE_JVM

inherit NATIVE;

feature

   frozen stupid_switch_function(r: ARRAY[RUN_CLASS]; name: STRING): BOOLEAN is
      do
         check false end;
      end;

   frozen stupid_switch_procedure(r: ARRAY[RUN_CLASS]; name: STRING): BOOLEAN is
      do
         check false end;
      end;

   frozen c_define_procedure(rf7: RUN_FEATURE_7; bcn, name: STRING) is
      do
         fe_c2c(rf7)
      end;

   frozen c_mapping_procedure(rf7: RUN_FEATURE_7; bcn, name: STRING) is
      do
         fe_c2c(rf7)
      end;

   frozen c_define_function(rf8: RUN_FEATURE_8; bcn, name: STRING) is
      do
         fe_c2c(rf8)
      end;

   frozen c_mapping_function(rf8: RUN_FEATURE_8; bcn, name: STRING) is
      do
         fe_c2c(rf8)
      end;

feature {NONE}

   idx_methodref(er: EXTERNAL_ROUTINE): INTEGER is
      local
         i: integer;
         alias_string: STRING;
         cp: like constant_pool;
      do
         cp := constant_pool;
         alias_string := er.alias_string;
         if alias_string = Void then
            eh.add_position(er.start_position);
            fatal_error(
             "Missing %"alias%" field description (see %
             %external.html documentation).");
         end;
         from
            i := 1;
            tmp_class.clear;
         until
            alias_string.item(i) = '.'
         loop
            tmp_class.extend(alias_string.item(i));
            i := i + 1;
         end;
         from
            i := i + 1;
            tmp_name.clear;
         until
            alias_string.item(i) = ' '
         loop
            tmp_name.extend(alias_string.item(i));
            i := i + 1;
         end;
         from
            i := i + 1;
            tmp_descriptor.clear;
         until
            i > alias_string.count
         loop
            tmp_descriptor.extend(alias_string.item(i));
            i := i + 1;
         end;
         Result := cp.idx_methodref3(tmp_class,tmp_name,tmp_descriptor);
      end;

   tmp_class: STRING is
      once
         !!Result.make(32);
      end;

   tmp_name: STRING is
      once
         !!Result.make(32);
      end;

   tmp_descriptor: STRING is
      once
         !!Result.make(32);
      end;

end -- NATIVE_JVM

