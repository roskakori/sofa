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
expanded class TIME_IN_ITALIAN
--
-- NOTE: THIS IS AN ALPHA VERSION. THIS CLASS IS NOT STABLE AT ALL AND 
-- MIGHT EVEN CHANGE COMPLETELY IN THE NEXT RELEASE !
-- 
--
-- The Italian format class for BASIC_TIME.
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
               s := "Dom";
            when 1 then
               s := "Lun";
            when 2 then
               s := "Mar";
            when 3 then
               s := "Mer";
            when 4 then
               s := "Gio";
            when 5 then
               s := "Ven";
            when 6 then
               s := "Sab";
            end;
         else
            inspect
               basic_time.week_day
            when 0 then
               s := "Domenica";
            when 1 then
               s := "Lunedi";
            when 2 then
               s := "Martedi";
            when 3 then
               s := "Mercoledi";
            when 4 then
               s := "Giovedi";
            when 5 then
               s := "Venerdi";
            when 6 then
               s := "Sabato";
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
               s := "Gen";
            when 2 then
               s := "Feb";
            when 3 then
               s := "Mar";
            when 4 then
               s := "Apr";
            when 5 then
               s := "Mag";
            when 6 then
               s := "Giu";
            when 7 then
               s := "Lug"
            when 8 then
               s := "Ago"
            when 9 then
               s := "Set"
            when 10 then
               s := "Ott";
            when 11 then
               s := "Nov";
            when 12 then
               s := "Dic";
            end;
         else
            inspect
               basic_time.month
            when 1 then
               s := "Gennaio";
            when 2 then
               s := "Febbraio";
            when 3 then
               s := "Marzo";
            when 4 then
               s := "Aprile";
            when 5 then
               s := "Maggio";
            when 6 then
               s := "Giugno";
            when 7 then
               s := "Luglio"
            when 8 then
               s := "Agosto"
            when 9 then
               s := "Settembre"
            when 10 then
               s := "Ottobre";
            when 11 then
               s := "Novembre";
            when 12 then
               s := "Dicembre";
            end;
         end;
         buffer.append(s);
      end;

feature

   append_in(buffer: STRING) is
      do
         day_in(buffer);
         buffer.extend(' ');
         basic_time.day.append_in(buffer);
         buffer.extend(' ');
         month_in(buffer);
         buffer.extend(' ');
         basic_time.year.append_in(buffer);
         buffer.extend(' ');
         basic_time.hour.append_in(buffer);
         buffer.extend(':');
         basic_time.minute.append_in(buffer);
         if not short_mode then
            buffer.extend(':');
            basic_time.second.append_in(buffer);
         end;
      end;

end
