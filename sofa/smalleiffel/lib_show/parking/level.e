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
class LEVEL

creation make

feature

   count: INTEGER;
         -- Total count of occupied places.
   
   free_count: INTEGER is
      do
         Result := park.count - count;
      end;
   
   capacity : INTEGER is
      do
         Result := count + free_count;
      end;
   
   full: BOOLEAN is
      do
         Result := count = capacity;
      end;
   
feature -- Modifications:

   make(max_cars: INTEGER) is
      require
         max_cars > 0
      do
         !!park.make(1,max_cars);
         !!tickets.make(park.lower,park.upper);
         count := 0;
      ensure
         count = 0
      end;

   arrival(car: INTEGER; arrival_time: DATE) is
      require
         not full;
         car > 0
      local
         i: INTEGER;
         stop: BOOLEAN;
         ticket: TICKET;
      do
         from
            i := park.lower;
            stop := false;
         until
            stop
         loop
            if park @ i <= 0 then
               stop := true;
               park.put(car,i);
               !!ticket.make(arrival_time);
               tickets.put(ticket,i);
               count := count + 1;
            end;
            i := i + 1;
         end;
      ensure
         count >= old count + 1
      end;

   departure(car: INTEGER; departure_time: DATE; hour_price: REAL): REAL is
         -- Gives price to pay or -1 when car is not at this level.
      require
         car > 0
      local
         i: INTEGER;
      do
         i := park.index_of(car);
         if i > park.upper then
            Result := -1;
         else
            Result := (tickets @ i).price(departure_time,hour_price);
            tickets.put(Void,i);
            park.put(0,i);
            count := count - 1;
         end;
      end;

feature {NONE}

   park: ARRAY[INTEGER];

   tickets: ARRAY[TICKET];

invariant

   count >= 0;

   free_count >= 0;
   
   capacity = count + free_count;
   
   capacity >= 1;
   
   tickets.count = park.count;
   
end -- LEVEL
