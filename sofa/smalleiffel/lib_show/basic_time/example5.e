class EXAMPLE5
--
-- Using the TIME_IN_FRENCH class.
--

creation make

feature {NONE}

   make is
      local
         basic_time: BASIC_TIME;
         french: TIME_IN_FRENCH;
         english: TIME_IN_ENGLISH;
         italian: TIME_IN_ITALIAN;
      do
         basic_time.update;
         french.set_basic_time(basic_time);
         english.set_basic_time(basic_time);
         italian.set_basic_time(basic_time);
         io.put_string("The French format :%N");
         show_time(french);
         io.put_string("The English format :%N");
         show_time(english);
         io.put_string("The Italian format :%N");
         show_time(italian);
      end;
   
   show_time(format: TIME_IN_SOME_LANGUAGE) is
      do
         format.set_short_mode(false);
         io.put_string("        ");
         io.put_string(format.to_string);
         io.put_string("%N        ");
         format.set_short_mode(true);
         io.put_string(format.to_string);
         io.put_new_line;
      end;
   
end
