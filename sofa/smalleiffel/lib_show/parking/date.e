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
class DATE

inherit
   ANY
      redefine print_on
      end;

creation {ANY}
   make

feature {ANY}

   print_on(file: OUTPUT_STREAM) is
      do
         file.put_string("day : ");
         file.put_integer(day);
         file.put_string(" minute : ");
         file.put_integer(min);
      end;

   minutes_to(after: DATE): INTEGER is
         -- Count of minutes to go to `after'.
      require
         after >= Current
      do
         Result := ((after.day - day) * 24 * 60 + (after.min - min));
      ensure
         Result >= 0;
      end;

   day_night_to(d2: DATE): ARRAY[INTEGER] is
         -- Result @ Result.lower : Night time.
         -- Result @ Result.upper : Day time.
      require
         d2 >= Current
      local
         min_jour, min_nuit: INTEGER;
         save_day, save_min: INTEGER;
      do
         from
            save_day := day;
            save_min := min;
         until
            is_equal(d2)
         loop
            if day_time then
               min_jour := min_jour + 1;
            else
               min_nuit := min_nuit + 1;
            end;
            add_time(1);
         end;
         day := save_day;
         min := save_min;
         Result := <<min_jour,min_nuit>>
      ensure
         Result.count = 2;
         (Result @ 1) + (Result @ 2) = minutes_to(d2)
      end;

   infix ">=" (d2: like Current): BOOLEAN is
      require
         d2 /= Void
      do
         Result := (day > d2.day) or else
                   ((day = d2.day) and then (min >= d2.min));
      end

   day_time: BOOLEAN is
         -- Is it Sunny ?
      do
         Result := (min >= 6*60) and (min <= 22*60);
      end;

   nigth_time: BOOLEAN is
         -- Is it the night ?
      do
         Result := not day_time;
      end;

feature {ANY} -- Modifications :

   make(vday, vmin: INTEGER) is
      do
         day := vday;
         min := vmin;
      ensure
         day = vday;
         min = vmin;
      end;

   add_time(nb_min: INTEGER) is
      do
         min := min + nb_min;
         if min > (24*60) then
            day := day + (min // (24*60));
            min := min \\ (24*60);
         end;
      end;

feature {DATE}

   day, min : INTEGER;

invariant

   day >= 0;

   min >= 0;

   min < 24 * 60;

end -- DATE
