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
class TYPE_BIT_1
   --
   -- For declarations of the form :
   --        foo : BIT 32;
   --

inherit TYPE_BIT;

creation make

feature

   n: INTEGER_CONSTANT;

   is_run_type: BOOLEAN is true;

   pretty_print is
      do
         fmt.put_string(as_bit);
         fmt.put_character(' ');
         fmt.put_integer(nb);
      end;

   run_class: RUN_CLASS is
      do
         Result := small_eiffel.run_class(Current);
      end;

   run_time_mark: STRING is
      do
         Result := written_mark;
      end;

   run_type: like Current is
      do
         Result := Current;
      end;

   nb: INTEGER is
      do
         Result := n.value;
      end;

   to_runnable(rt: TYPE): like Current is
      do
         Result := Current;
         to_runnable_1_2;
      end;

feature {TYPE}

   short_hook is
      do
         short_print.a_class_name(base_class_name);
         short_print.hook_or("tm_blank"," ");
         short_print.a_integer(n.value);
      end;

feature {NONE}

   make(sp: like start_position; vn: like n) is
      require
         not sp.is_unknown;
         vn.value > 0
      do
         start_position := sp;
         n := vn;
         tmp_string.copy(as_bit);
	 tmp_string.extend(' ');
         nb.append_in(tmp_string);
         written_mark := string_aliaser.item(tmp_string);
      ensure
         start_position = sp;
         n = vn
      end;

invariant

   n /= Void;

end -- TYPE_BIT_1

