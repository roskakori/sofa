--          This file is part of SmallEiffel The GNU Eiffel Compiler.
--          Copyright (C) 1994-98 LORIA - UHP - CRIN - INRIA - FRANCE
--            Dominique COLNET and Suzanne COLLIN - colnet@loria.fr
--                       http://www.loria.fr/SmallEiffel
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
class TOWER

creation full, empty

feature {NONE}

   t:ARRAY[INTEGER];

   top:INTEGER;

feature {NONE}

   full(n:INTEGER) is
      require
         n >= 1
      local
         i:INTEGER;
      do
         !!t.make(1,n);
         from
            i := n;
         until
            i = 0
         loop
            t.put(n-i+1,i);
            i := i - 1;
         end;
         top := n;
      ensure
         nb = n;
         top = nb;
         t.item(top) = 1
      end;

   empty(n:INTEGER) is
      require
         n >= 1
      do
         !!t.make(1,n);
         top := 1;
      ensure
         nb = n;
         top = 1
      end;

feature {HANOI}

   nb: INTEGER is
      do
         Result := t.upper;
      end;

   show_a_discus(d: INTEGER; picture: STRING) is
      require
         1 <= d;
         d <= nb;
         picture /= Void
      local
         nb_of_free_slots, nb_of_used_slots, i : INTEGER;
      do
         nb_of_used_slots := t.item(d);
         nb_of_free_slots := nb - nb_of_used_slots;
         from
            i := nb_of_free_slots;
         until
            i = 0
         loop
            picture.extend(' ');
            i := i - 1;
         end;
         from
            i := nb_of_used_slots;
         until
            i = 0
         loop
            picture.extend('=');
            i := i - 1;
         end;
         picture.extend('|');
         from
            i := nb_of_used_slots;
         until
            i = 0
         loop
            picture.extend('=');
            i := i -1;
         end;
         from
            i := nb_of_free_slots;
         until
            i = 0
         loop
            picture.extend(' ');
            i := i - 1;
         end;
      end;

   remove_discus: INTEGER is
      do
         debug
            if t.item(top) = 0 then
               std_error.put_string("Error in 'remove_discus'.%N");
               crash;
            end;
         end;
         Result := t.item(top);
         t.put(0,top);
         if top > 1 then
            top := top - 1;
         end;
      ensure
         top >= 1
      end;

   add_discus(d: INTEGER) is
      do
         debug
            if (top = nb) then
               std_error.put_string("Error in 'add_discus', %
                                    %the tower was already full.%N")
               crash;
            end;
            if (d > t.item(top)) then
--	       std_error.put_string("Error in 'add_discus', the %
--				    %discus you wanted to put is larger %
--				    %than allowed.");
--	       crash;
            end;
         end;
         if t.item(top) > d then
            top := top + 1;
            t.put(d,top);
         end;
         if t.item(top) = 0 then
            t.put(d,top);
         end;
      ensure
         top <= nb
      end;

end -- TOWER
