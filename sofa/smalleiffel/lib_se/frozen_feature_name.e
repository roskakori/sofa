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
class FROZEN_FEATURE_NAME
   --
   -- For a frozen FEATURE_NAME.
   --

inherit FEATURE_NAME;

creation {EIFFEL_PARSER} make

feature {NONE}

   feature_name: FEATURE_NAME;

feature

   is_frozen: BOOLEAN is true;

feature {NONE}

   make(fn: like feature_name) is
      require
         fn /= void
      do
         feature_name := fn;
      ensure
         feature_name = fn
      end;

feature

   to_string: STRING is
      do
         Result := feature_name.to_string;
      end;

   to_key: STRING is
      do
         Result := feature_name.to_key;
      end;

   start_position: POSITION is
      do
         Result := feature_name.start_position;
      end;

   mapping_c_in(str: STRING) is
      do
         feature_name.mapping_c_in(str);
      end;

   declaration_in(str: STRING) is
      do
         feature_name.declaration_in(str);
      end;

   short is
      do
         feature_name.short;
      end;

   declaration_pretty_print is
      do
         fmt.keyword("frozen");
         feature_name.declaration_pretty_print;
      end;

   pretty_print is
      do
         feature_name.pretty_print;
      end;

feature {RUN_FEATURE,FEATURE_NAME}

   put_cpp_tag is
      do
         feature_name.put_cpp_tag;
      end;

end -- FROZEN_FEATURE_NAME
