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
expanded class BASIC_TIME
--
-- NOTE: THIS IS AN ALPHA VERSION. THIS CLASS IS NOT STABLE AT ALL AND 
-- MIGHT EVEN CHANGE COMPLETELY IN THE NEXT RELEASE !
-- 
--
-- Basic time and date facilities.
--

inherit HASHABLE; COMPARABLE;

feature

   is_local_time: BOOLEAN is
         -- Is the local time in use ?
         -- This information applies to all objects of this class.
      do
         Result := (time_mode = 0);
      ensure
         Result implies not is_universal_time
      end;
   
   is_universal_time: BOOLEAN is
         -- Is Universal Time in use ?
         -- This information applies to all objects of this class.
      do
         Result := (time_mode = 1);
      ensure
         Result implies not is_local_time
      end;
   
   year: INTEGER is
         -- Number of the year.
      do
         Result := basic_time_getyear(time_memory,time_mode);
      end;
   
   month: INTEGER is
         -- Number of the month (1 for January, 2 for February, ... 
         -- 12 for December).
      do
         Result := basic_time_getmonth(time_memory,time_mode);
      ensure
         Result.in_range(1,12)
      end;
   
   day: INTEGER is
         -- Day of the `month' in range 1 .. 31.
      do
         Result := basic_time_getday(time_memory,time_mode);
      ensure
         Result.in_range(1,31)
      end;
   
   hour: INTEGER is
         -- Hour in range 0..23.
      do
         Result := basic_time_gethour(time_memory,time_mode);
      ensure
         Result.in_range(0,23)
      end;
   
   minute: INTEGER is
         -- Minute in range 0 .. 59.
      do
         Result := basic_time_getminute(time_memory,time_mode);
      ensure
         Result.in_range(0,59)
      end;
   
   second: INTEGER is
         -- Second in range 0 .. 59.
      do
         Result := basic_time_getsecond(time_memory, time_mode)
      ensure
         Result.in_range(0,59)
      end;

   week_day: INTEGER is
         -- Number of the day in the week (Sunday is 0, Monday is 1, etc.).
      do
         Result := basic_time_getwday(time_memory,time_mode);
      ensure
         Result.in_range(0,6)
      end;
   
   year_day: INTEGER is
         -- Number of the day in the year in range 0 .. 365.
      do
         Result := basic_time_getyday(time_memory,time_mode);
      end;
   
   is_summer_time_used: BOOLEAN is
         -- Is summer time in effect?
      do
         Result := basic_time_is_summer_time_used(time_memory);
      end;
   
feature -- Setting :

   update is
         -- Update `Current' with the current system clock.
      do
         time_memory := basic_time_time;
      end;

   set(a_year, a_month, a_day, a_hour, a_min, sec: INTEGER): BOOLEAN is
         -- Try to set `Current' using the given information. If this input
         -- is not a valid date, the `Result' is false and `Current' is not updated.
      local
         time_mem: INTEGER;
      do
         time_mem := basic_time_mktime(a_year,a_month,a_day,a_hour,a_min,sec);
         if time_mem /= -1 then
            Result := true;
            time_memory := time_mem;
         end;
      ensure
         Result implies (year = a_year);
         Result implies (month = a_month);
         Result implies (day = a_day);
         Result implies (hour = a_hour);
         Result implies (minute = a_min);
         Result implies (second = sec);
         not Result implies Current = old Current
      end;

feature
   
   elapsed_seconds(other: like Current): INTEGER is
         -- Elapsed time in seconds from `Current' to `other'.
      require
         Current <= other
      do
         Result := basic_time_difftime(other.time_memory,time_memory);
      ensure
         Result >= 0
      end;

   infix "<" (other: like Current): BOOLEAN is
      local
         v1, v2: INTEGER;
      do
         v1 := year;
         v2 := other.year;
         if v1 < v2 then
            Result := true;
         elseif v1 = v2 then
            v1 := year_day;
            v2 := other.year_day;
            if v1 < v2 then
               Result := true;
            elseif v1 = v2 then
               v1 := hour;
               v2 := other.hour;
               if v1 < v2 then
                  Result := true;
               elseif v1 = v2 then
                  v1 := minute;
                  v2 := other.minute;
                  if v1 < v2 then
                     Result := true;
                  elseif v1 = v2 then
                     Result := second < other.second;
                  end;
               end;
            end;
         end;
      end;
   
feature -- Setting common time mode (local or universal) :
   
   set_universal_time is
      do
         time_mode_memo.set_item(1);
      ensure
         is_universal_time
      end;
   
   set_local_time is
      do
         time_mode_memo.set_item(0);
      ensure
         is_local_time
      end;

feature

   clock_periods: INTEGER is
         -- CPU time usage if available (-1 if not).
      do
         Result := basic_time_clock;
      end;

feature -- Hashing :

   hash_code: INTEGER is
      do
         Result := time_memory.hash_code;
      end;
   
feature {BASIC_TIME}

   time_memory : INTEGER
         -- The current time value of `Current'. As far as I know, this 
         -- kind of information fits on 32 bits for all platforms.
   
feature {NONE}

   time_mode_memo: MEMO[INTEGER] is
         -- The global default `time_mode' memory.
      once
         !!Result;
      end;
   
   time_mode: INTEGER is
      do
         Result := time_mode_memo.item;
      ensure
         Result = 0 or Result = 1
      end;

   basic_time_time : INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_difftime (time2, time1 : INTEGER) : INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getyear (tm: INTEGER; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getmonth (tm: INTEGER; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getday (tm: INTEGER; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_gethour (tm: INTEGER; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getminute(tm: INTEGER; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getsecond(tm: INTEGER; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_is_summer_time_used(tm: INTEGER): BOOLEAN is
      external "SmallEiffel"
      end;
   
   basic_time_getyday(tm: INTEGER; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getwday(tm: INTEGER; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_mktime(a_year, a_mon, a_day, 
                     a_hour, a_min, a_sec: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_clock: INTEGER is
      external "SmallEiffel"
      end;
   
end -- BASIC_TIME
