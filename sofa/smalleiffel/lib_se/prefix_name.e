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
class PREFIX_NAME
   --
   -- To store a prefix name of some unary operator.
   --

inherit FEATURE_NAME;

creation make

feature

   start_position: POSITION;

   to_string: STRING;

   to_key: STRING;

feature

   is_frozen: BOOLEAN is false;

feature {NONE}

   make(n: STRING; sp: like start_position) is
      require
         n.count >= 1;
         n = string_aliaser.item(n);
         not sp.is_unknown
      do
         to_string := n;
         start_position := sp;
         to_key := string_aliaser.for_prefix(to_string);
      ensure
         to_string = n;
         start_position = sp;
         to_key = string_aliaser.item(to_key)
      end;

feature

   mapping_c_in(str: STRING) is
      do
         str.append(to_key);
      end;

   declaration_in(str: STRING) is
      do
         str.append(fz_prefix);
         str.extend(' ');
         str.extend('%"');
         str.append(to_string);
         str.extend('%"');
      end;

   pretty_print is
      do
         fmt.put_string(to_string);
      end;

   declaration_pretty_print is
      do
         fmt.keyword(fz_prefix);
         fmt.put_character('%"');
         fmt.put_string(to_string);
         fmt.put_character('%"');
      end;

feature

   short is
      local
         i: INTEGER;
         c: CHARACTER;
      do
         short_print.hook_or("Bpfn","prefix %"");
         from
            i := 1;
         until
            i > to_string.count
         loop
            c := to_string.item(i);
            short_print.a_character(c);
            i := i + 1;
         end;
         short_print.hook_or("Apfn","%"");
      end;

feature {RUN_FEATURE,FEATURE_NAME}

   put_cpp_tag is
      do
         cpp.put_string(fz_prefix);
         cpp.put_character(' ');
      end;

end -- PREFIX_NAME

