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
class COMMAND
   --
   -- To separate Handling of Keyboard Input.
   --

creation make

feature 

   arrival: BOOLEAN is
      do
         Result := (code = c_arrival)
      end;

   departure: BOOLEAN is
      do
         Result := (code = c_departure)
      end;
   
   level_count: BOOLEAN is
      do
         Result := (code = c_level_count)
      end;
   
   hour_price: BOOLEAN is
      do
         Result := (code = c_hour_price)
      end;
   
   add_time: BOOLEAN is
      do
         Result := (code = c_add_time)
      end;
   
   clock: BOOLEAN is
      do
         Result := (code = c_clock)
      end;
   
   quit: BOOLEAN is
      do
         Result := (code = c_quit)
      end;
   
   help: BOOLEAN is
      do
         Result := (code = c_help)
      end;
   
   arg_real: REAL is
      do
         Result := cmd.to_real;
      end;
   
   arg_integer: INTEGER is
      do
         Result := cmd.to_integer;
      end;
   
   count: BOOLEAN is
      do
         Result := (code = c_count)
      end;
   
feature -- Modifications:

   make is
      do
      end;
   
   get_command(sio: STD_INPUT_OUTPUT) is
      require
         sio /= Void
      local
         stop: BOOLEAN;
      do
         sio.read_line;
         cmd := sio.last_string;
         from
            code := ' ';
            stop := (cmd.count < 1);
         until
            stop
         loop
            code := cmd @ 1;
            cmd.remove(1);
            stop := ((code /= ' ') and (code /= '%T')) or (cmd.count < 1)
         end;
      end;

   print_help_on(sio: STD_INPUT_OUTPUT) is
      require
         sio /= Void
      do
         sio.put_string(
            " Commands :%N%
	    % -------------------%N%
	    % q        Quit%N%
	    % a        Arrival of a car%N%
	    % d <i>    Departure of car number <i>%N%
	    % l <i>    number of car at Level <i>%N%
	    % h <x>    set Hour price with <x>%N%
	    % c        total Count of cars%N%
	    % t <i>    add Time <i> minutes%N%
	    % T        current Time%N%
	    % ?        help%N");
      end;
   
feature {COMMAND}
   
   c_arrival : CHARACTER is 'a';
   c_departure : CHARACTER is 'd';
   c_level_count : CHARACTER is 'l';
   c_hour_price : CHARACTER is 'h';
   c_add_time : CHARACTER is 't';
   c_clock : CHARACTER is 'T';
   c_quit : CHARACTER is 'q';
   c_count : CHARACTER is 'c';
   c_help : CHARACTER is '?';
   
   code : CHARACTER;
   
feature {NONE}
   
   cmd: STRING;
   
end -- COMMAND
