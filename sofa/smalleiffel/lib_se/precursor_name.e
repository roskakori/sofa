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
class PRECURSOR_NAME
   --
   -- The name of a Precursor RUN_FEATURE (RUN_FEATURE_10 | RUN_FEATURE_11).
   --

inherit FEATURE_NAME;

creation {PRECURSOR_CALL} refer_to

feature

   to_key: STRING;

   to_string: STRING is
      do
         Result := enclosing.to_string;
      end;

   start_position: POSITION is
      do
         Result := enclosing.start_position;
      end;

   is_frozen: BOOLEAN is
      do
         Result := enclosing.is_frozen;
      end;

   mapping_c_in(str: STRING) is
      do
         str.append(to_key);
      end;

   declaration_in(str: STRING) is
      do
      end;

   pretty_print is
      do
         fmt.put_string(as_precursor);
      end;

   declaration_pretty_print is
      do
      end;

   short is
      do
      end;

feature {RUN_FEATURE,FEATURE_NAME}

   put_cpp_tag is
      do
         cpp.put_string(as_precursor);
         cpp.put_character(' ');
      end;

feature {NONE}

   enclosing: FEATURE_NAME;
         -- Name of the enclosing RUN_FEATURE which contains the
         -- Precursor call.

   refer_to(id: INTEGER; e: like enclosing) is
         -- Where `id' is the base class id of the Precursor routine.
      require
         e /= Void
      do
         enclosing := e;
         !!to_key.make(8 + enclosing.to_key.count);
         to_key.extend('_');
         id.append_in(to_key);
         to_key.extend('P');
         to_key.append(enclosing.to_key);
         to_key := string_aliaser.item(to_key);
      ensure
         enclosing = e;
      end;

end

