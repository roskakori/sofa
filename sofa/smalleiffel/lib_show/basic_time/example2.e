class EXAMPLE2
--
-- This example shows how to know about time variation using
-- class BASIC_TIME.
--

creation make

feature {NONE}

   make is
      local
         time1, time2: BASIC_TIME;
         sec, wait: INTEGER;
      do
         time1.update;
         show_basic_time(time1);
         from
            sec := time1.second;
            wait := 2;
         until
            wait = 0
         loop
            time2.update;
            if time2.second /= sec then
               sec := time2.second;
               wait := wait - 1;
            end;
         end;
         io.put_string("Elapsed time: ");
         io.put_integer(time1.elapsed_seconds(time2));
         io.put_string(" seconds%N");
         show_basic_time(time2);
         show_cpu_usage;
      end;
   
   show_basic_time(basic_time: BASIC_TIME) is
      do
         io.put_string("hour: ");
         io.put_integer(basic_time.hour);
         io.put_string(" minute: ");
         io.put_integer(basic_time.minute);
         io.put_string(" second: ");
         io.put_integer(basic_time.second);
         io.put_string("%N");

      end;

   show_cpu_usage is
      local
         used_cpu: INTEGER;
         basic_time: BASIC_TIME;
      do
         used_cpu := basic_time.clock_periods;
         if used_cpu /= -1 then
            io.put_string("CPU clock used: ");
            io.put_integer(used_cpu);
            io.put_string("%N");
         end;
      end;

end
