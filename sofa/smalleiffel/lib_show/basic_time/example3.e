class EXAMPLE3
--
-- Using the TIME_IN_ENGLISH class.
--

creation make

feature {NONE}

   make is
      local
         basic_time: BASIC_TIME;
         format: TIME_IN_ENGLISH;
      do
         basic_time.update;
         format.set_basic_time(basic_time);
         io.put_string("The complete format :%N");
         format.set_short_mode(false);
         format.print_on(io);
         io.put_new_line;
         io.put_string("The short format :%N");
         format.set_short_mode(true);
         format.print_on(io);
         io.put_new_line;
      end;
   
end
