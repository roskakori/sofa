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
class TICKET

creation make

feature

   arrival_time: DATE;

   price(departure_time: DATE; hour_price: REAL): REAL is
      require
         departure_time >= arrival_time
      local
         nb_min: ARRAY[INTEGER];
      do
         nb_min := arrival_time.day_night_to(departure_time);
         io.put_integer(nb_min @ nb_min.upper);
         Result := (((hour_price/4) * (nb_min @ nb_min.upper))
                    + (hour_price * (nb_min @ nb_min.lower))) / 60;
      end;

   make(arrival: DATE) is
      do
         arrival_time := arrival;
      ensure
         arrival_time = arrival
      end;

end -- TICKET
