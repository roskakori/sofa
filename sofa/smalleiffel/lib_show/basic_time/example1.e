class EXAMPLE1
--
-- This example shows how to know about the curent date and time 
-- using class BASIC_TIME.
--

creation make

feature {NONE}

   make is
      local
         basic_time: BASIC_TIME;
      do
         basic_time.update;
         io.put_string("Current date (");
         if basic_time.is_local_time then
            io.put_string("local time");
         else
            io.put_string("universal time");
         end;
         if basic_time.is_summer_time_used then
            io.put_string(" summer time");
         end;
         io.put_string("): ");
         io.put_string("%N   year: ");
         io.put_integer(basic_time.year);
         io.put_string("%N   month: ");
         io.put_integer(basic_time.month);
         io.put_string("%N   day: ");
         io.put_integer(basic_time.day);
         io.put_string(" (");
         io.put_integer(basic_time.year_day);
         io.put_string("th day of the year and ");
         io.put_integer(basic_time.week_day);
         io.put_string("th day of the week)%N   hour: ");
         io.put_integer(basic_time.hour);
         io.put_string("%N   minute: ");
         io.put_integer(basic_time.minute);
         io.put_string("%N   second: ");
         io.put_integer(basic_time.second);
         io.put_string("%N");
      end;
   
end
