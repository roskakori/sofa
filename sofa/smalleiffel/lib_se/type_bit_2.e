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
class TYPE_BIT_2
   --
   -- For declarations of the form :
   --        foo : BIT Real_size;
   --

inherit TYPE_BIT;

creation make

feature

   n: SIMPLE_FEATURE_NAME;
         -- Which is supposed to gives the number of bits.

   run_type: TYPE_BIT_1;
         -- When runnable, the corresponding one.

   pretty_print is
      do
         fmt.put_string(written_mark);
      end;

   nb: INTEGER is
      do
         Result := run_type.nb;
      end;

   run_time_mark: STRING is
      do
         Result := run_type.written_mark;
      end;

   is_run_type: BOOLEAN is
      do
         Result := run_type /= Void;
      end;

   to_runnable(ct: TYPE): like Current is
      local
         rf: RUN_FEATURE;
         rf1: RUN_FEATURE_1;
         rf8: RUN_FEATURE_8;
         ic: INTEGER_CONSTANT;
         nb_value: INTEGER;
      do
         if run_type = Void then
            rf := n.run_feature(ct);
            if rf = Void then
               eh.feature_not_found(n);
               eh.print_as_fatal_error;
            else
               rf1 ?= rf;
               rf8 ?= rf;
               if rf1 /= Void then
                  ic ?= rf1.base_feature.value(1);
                  if ic = Void then
                     eh.add_position(n.start_position);
                     eh.add_position(rf1.start_position);
                     fatal_error(fz_iinaiv);
                  end;
                  nb_value := ic.value;
                  if nb_value < 0 then
                     eh.add_position(n.start_position);
                     eh.add_position(rf1.start_position);
                     fatal_error("Must be a positive INTEGER.");
                  end;
                  !!run_type.make(start_position,ic);
               elseif rf8 /= Void then
                  nb_value := rf8.integer_value(n.start_position);
                  !!ic.make(nb_value,n.start_position);
                  !!run_type.make(start_position,ic);
               else
                  eh.add_position(n.start_position);
                  eh.add_position(rf.start_position);
                  fatal_error(fz_iinaiv);
               end;
               Result := Current;
               to_runnable_1_2;
            end;
         else
            !!Result.make(start_position,n);
            Result := Result.to_runnable(ct);
         end;
      end;

feature {TYPE}

   short_hook is
      do
         short_print.a_class_name(base_class_name);
         short_print.hook_or("tm_blank"," ");
         n.short;
      end;

feature {NONE}

   make(sp: like start_position; name: like n) is
      require
         not sp.is_unknown;
         name /= Void
      do
         tmp_string.copy(as_bit);
         tmp_string.extend(' ');
         tmp_string.append(name.to_string);
         written_mark := string_aliaser.item(tmp_string);
         start_position := sp;
         n := name;
      end;

invariant

   n /= Void

end -- TYPE_BIT_2

