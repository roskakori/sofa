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
--
-- Originally written by Cyril ADRIAN and Antony LE LABOUSSE
--
class SPREAD_ILLNESS
   -- To compile type command : compile SPREAD_ILLNESS make
   --
   -- Also try Optimised version adding options "-boost -O2"
   --
creation {ANY}
   make

feature {NONE}

   world1, world2: ARRAY2[INTEGER];

   empty : INTEGER is 1;

   healthy : INTEGER is 0;

   di: ARRAY[INTEGER] is
      once
         Result := <<-1,-1,-1,0,1,1,1,0 >>
      end;

   dj: ARRAY[INTEGER] is
      once
         Result := <<-1,0,1,1,1,0,-1,-1 >>
      end;

   error_msg : STRING is "Error : do it again !%N"

feature {ANY}

   make is
         -- Try to spreads an illness through a set of people.
      local
         day: INTEGER;
         fed_up: BOOLEAN;
      do
         from
            day := 1;
            first_day;
         until
            fed_up
         loop
            io.put_string("Day #");
            io.put_integer(day);
            io.put_new_line;
            display;
            io.put_string("Continue ? [y/n] ");
            io.flush;
            io.read_line;
            io.last_string.to_lower;
            fed_up := (io.last_string.first = 'n')
            day := day + 1;
            next_day
         end;
      end;

feature {ANY}

   first_day is
         -- Create the world in the 1st day's state.
      local
         i, j, ill_state: INTEGER;
         ok: BOOLEAN;
      do
         io.put_string("Default First World (y/n) ? ");
         io.flush;
         io.read_word;
         if io.last_string.is_equal("y") then
            !!world1.from_model(
              <<<<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
                <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>>>);
         else
            io.put_string("World size : ");
            io.flush;
            io.read_integer;
            !!world1.make(1,io.last_integer,1,io.last_integer);
            io.put_string("%Ne)mpty, i)ll with number of days, h)ealthy%N%N");
            from
               i := world1.lower1
            until
               i > world1.upper1
            loop
               from
                  j := world1.lower2
               until
                  j > world1.upper2
               loop
                  from
                     ok := false;
                  until
                     ok
                  loop
                     io.put_string("State of [");
                     io.put_integer(i);
                     io.put_character(',');
                     io.put_integer(j);
                     io.put_string("] : ");
                     io.flush;
                     io.read_word;
                     inspect
                        io.last_string.first
                     when 'E','e' then
                        if io.last_string.count /= 1 then
                           io.put_string(error_msg)
                        else
                           world1.put(empty,i,j);
                           ok := true
                        end
                     when 'H','h' then
                        if io.last_string.count /= 1 then
                           io.put_string(error_msg)
                        else
                           world1.put(healthy,i,j);
                           ok := true
                        end
                     when 'I','i' then
                        ok := true;
                        io.flush;
                        io.read_integer;
                        ill_state := io.last_integer;
                        ill_state := ill_state.max(1);
                        ill_state := ill_state.min(4);
                        world1.put(- ill_state,i,j);
                     else
                        io.put_string(error_msg)
                     end;
                  end;
                  j := j + 1;
               end;
               i := i + 1;
            end;
         end;
         world2 := clone(world1)
      end;

   display is
         -- Displays current `world2'.
      local
         i,j : INTEGER;
      do
         io.put_character('+');
         io.put_character('-');
         from
            i := world1.lower1
         until
            i > world1.upper1
         loop
            io.put_character('-');
            io.put_character('-');
            i := i+1
         end;
         io.put_character('+');
         io.put_new_line;
         from
            i := world1.lower1
         until
            i > world1.upper1
         loop
            io.put_character('|');
            io.put_character(' ');
            from
               j := world1.lower2
            until
               j > world1.upper2
            loop
               inspect
                  world2.item(i,j)
               when empty then
                  io.put_character(' ')
               when healthy then
                  io.put_character('O')
               else
                  io.put_character((- world2.item(i,j)).digit)
               end;
               io.put_character(' ');
               j := j+1
            end;
            io.put_character('|');
            io.put_new_line;
            i := i+1
         end;
         io.put_character('+');
         io.put_character('-');
         from
            i := world1.lower1
         until
            i > world1.upper1
         loop
            io.put_character('-');
            io.put_character('-');
            i := i+1
         end;
         io.put_character('+');
         io.put_new_line;
      end;

   next_day is
         -- `world1' and `world2' are swapped.
      local
         i,j: INTEGER;
      do
         world1.copy(world2);
         from
            i := world1.lower1;
         until
            i > world1.upper1
         loop
            from
               j := world1.lower2;
            until
               j > world1.upper2
            loop
               inspect
                  world1.item(i,j)
               when empty then
               when healthy then
                  spread(i,j);
               else
                  cure_or_die(i,j);
               end;
               j := j + 1;
            end;
            i := i + 1;
         end;
      end;

feature {NONE}

   cure_or_die(i,j : INTEGER)  is
         -- When ill, inspects if must be death or more ill or cured.
      do
         inspect
            - world1.item(i,j)
         when 1 then
            world2.put(-2,i,j)
         when 2 then
            die(i,j)
         when 3 then
            world2.put(-4,i,j)
         when 4 then
            world2.put(healthy,i,j)
         end
      end;

   die(i,j: INTEGER) is
         -- When two days ill, dies or more ill ?
      local
         d,k:INTEGER;
      do
         from
            d := 1;
         variant
            9 - d
         until
            d > 8
         loop
            if v(i+di.item(d),j+dj.item(d)) <= -2 then
               k := k+1;
            end;
            d := d+1;
         end;
         if k >= 4 then
            world2.put(empty,i,j);
         else
            world2.put(-3,i,j);
         end
      end;

   spread(i,j: INTEGER) is
         -- spread the illness ?
      local
         d: INTEGER;
      do
         from
            d := 1;
         variant
            10 - d
         until
            d = 9
         loop
            if ill(i + di @ d , j + dj @ d) then
               world2.put(-1,i,j);
               d := 9;
            else
               d := d+1;
            end
         end
      end;

   ill(i,j: INTEGER): BOOLEAN is
         -- Is there someone is ill at `i', `j'.
      do
         Result := (v(i,j) < 0)
      end;

   v(i,j: INTEGER): INTEGER is
         -- Gives `empty' when out of range or the
         -- value in `world1'
      do
         if (world1.lower1 <= i and then i <= world1.upper1)
            and (world1.lower2 <= j and then j <= world1.upper2) then
            Result := world1.item(i,j)
         else
            Result := empty
         end;
      end;

end -- SPREAD_ILLNESS
