-- This file is  free  software, which  comes  along  with  SmallEiffel. This
-- software  is  distributed  in the hope that it will be useful, but WITHOUT 
-- ANY  WARRANTY;  without  even  the  implied warranty of MERCHANTABILITY or
-- FITNESS  FOR A PARTICULAR PURPOSE. You can modify it as you want, provided
-- this header is kept unaltered, and a notification of the changes is added.
-- You  are  allowed  to  redistribute  it and sell it, alone or as a part of 
-- another product.
--          Copyright (C) 1994-98 LORIA - UHP - CRIN - INRIA - FRANCE
--            Dominique COLNET and Suzanne COLLIN - colnet@loria.fr 
--                       http://SmallEiffel.loria.fr
--
expanded class TIME_IN_ENGLISH
--
-- NOTE: THIS IS AN ALPHA VERSION. THIS CLASS IS NOT STABLE AT ALL AND 
-- MIGHT EVEN CHANGE COMPLETELY IN THE NEXT RELEASE !
-- 
--
-- The English format class for BASIC_TIME.
--

inherit TIME_IN_SOME_LANGUAGE;

feature

   day_in(buffer: STRING) is
         -- According to the current `short_mode', append in the `buffer' 
         -- the name of the day.
      local
         s: STRING;
      do
         if short_mode then
            inspect
               basic_time.week_day
            when 0 then
               s := "Su";
            when 1 then
               s := "Mo";
            when 2 then
               s := "Tu";
            when 3 then
               s := "We";
            when 4 then
               s := "Th";
            when 5 then
               s := "Fr";
            when 6 then
               s := "Sa";
            end;
         else
            inspect
               basic_time.week_day
            when 0 then
               s := "Sunday";
            when 1 then
               s := "Monday";
            when 2 then
               s := "Tuesday";
            when 3 then
               s := "Wensday";
            when 4 then
               s := "Thursday";
            when 5 then
               s := "Friday";
            when 6 then
               s := "Saturday";
            end;
         end;
         buffer.append(s);
      end;

   month_in(buffer: STRING) is
         -- According to the current `short_mode', append in the `buffer' 
         -- the name of the day.
      local
         s: STRING;
      do
         if short_mode then
            inspect
               basic_time.month
            when 1 then
               s := "Jan";
            when 2 then
               s := "Feb";
            when 3 then
               s := "Mar";
            when 4 then
               s := "Apr";
            when 5 then
               s := "May";
            when 6 then
               s := "Jun";
            when 7 then
               s := "Jul"
            when 8 then
               s := "Aug"
            when 9 then
               s := "Sep"
            when 10 then
               s := "Oct";
            when 11 then
               s := "Nov";
            when 12 then
               s := "Dec";
            end;
         else
            inspect
               basic_time.month
            when 1 then
               s := "January";
            when 2 then
               s := "February";
            when 3 then
               s := "March";
            when 4 then
               s := "April";
            when 5 then
               s := "May";
            when 6 then
               s := "June";
            when 7 then
               s := "July"
            when 8 then
               s := "August"
            when 9 then
               s := "September"
            when 10 then
               s := "October";
            when 11 then
               s := "November";
            when 12 then
               s := "December";
            end;
         end;
         buffer.append(s);
      end;

feature

   append_in(buffer: STRING) is
      do
         day_in(buffer);
         buffer.extend(' ');
         month_in(buffer);
         buffer.extend(' ');
         basic_time.day.append_in(buffer);
         buffer.extend(' ');
         basic_time.hour.append_in(buffer);
         buffer.extend(':');
         basic_time.minute.append_in(buffer);
         if not short_mode then
            buffer.extend(':');
            basic_time.second.append_in(buffer);
         end;
         buffer.extend(' ');
         basic_time.year.append_in(buffer);
      end;

end
