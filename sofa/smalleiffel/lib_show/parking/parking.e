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
class PARKING

creation make

feature

   lower_level: INTEGER is
      do
         Result := level_list.lower;
      end;
   
   upper_level: INTEGER is
      do
         Result := level_list.upper;
      end;
   
   hour_price: REAL;
   
   default_hour_price: REAL is 1.50;
   
   count: INTEGER is
      local
         i: INTEGER;
      do
         from
            i := lower_level;
         until
            i > upper_level
         loop
            Result := Result + level_count(i);
            i := i + 1;
         end;
      end;
   
   clock: DATE;
   
   level_count(number: INTEGER): INTEGER is
      require
         number <= upper_level;
         lower_level <= number
      do
         Result := (level_list @ number).count;
      ensure
         Result >= 0;
      end;

feature -- Modifications:

   make(ll: like level_list) is
      require
         ll /= Void
      do
         !!clock.make(0,360);
         hour_price := default_hour_price;
         level_list := ll;
         last_car := 0;
      ensure
         hour_price = default_hour_price;
         level_list = ll;
         last_car = 0;
      end;
   
   arrival: INTEGER is
	 -- Gives 0 when no more place.
      local
         i: INTEGER;
      do
         from
            i := lower_level;
         until
            (i > upper_level) or else
            (not (level_list @ i).full)
         loop
            i := i + 1;
         end;
         if (i > upper_level) or else
            (level_list @ i).full
         then
            Result := 0;
         else
            last_car := last_car + 1;
            level_list.item(i).arrival(last_car,clone(clock));
            Result := last_car;
         end;
      ensure
         Result >= 0;
      end;
   
   departure(car: INTEGER): REAL is
         -- Gives the price to pay or -1 when car has already leaved.
      require
         car > 0;
      local
         i: INTEGER;
         stop: BOOLEAN;
         c: like clock;
      do
         from
            i := lower_level;
            stop := level_list.count <= 0;
            Result := -1;
            c := clone(clock);
         until
            stop
         loop
            Result := (level_list @ i).departure(car,c,hour_price);
            i := i + 1;
            stop := (Result >= 0) or (i > upper_level);
         end;
      end;
   
   add_time(incr: INTEGER) is
      do
         clock.add_time(incr);
      end;
   
   set_hour_price(hp: REAL) is
      require
         hp >= 0;
      do
         hour_price := hp;
      ensure
         hour_price = hp;
      end;
   
feature {NONE}
   
   level_list: ARRAY[LEVEL];
   
   last_car: INTEGER;
   
invariant
   
   valid_price: hour_price >= 0;
   
   clock /= Void;
   
   last_car >= 0;
   
   level_list /= Void;
   
end -- PARKING
