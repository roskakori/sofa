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

inherit HASHABLE; COMPARABLE  redefine is_equal end;
   
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
      require
	 valid_month: a_month.in_range(1,12);
	 valid_day: a_day.in_range(1,31);
	 valid_hour: a_hour.in_range(0,23);
	 valid_minute: a_min.in_range(0,59);
	 valid_second: sec.in_range(0,59)
      local
         tm: like time_memory;
      do
         tm := basic_time_mktime(a_year,a_month,a_day,a_hour,a_min,sec);
         if tm /= -1 then
            time_memory := tm;
            Result := true;
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

   is_equal(other: like Current): BOOLEAN is
      do
         Result := basic_time_difftime(other.time_memory,time_memory) = 0
      end;

   infix "<" (other: like Current): BOOLEAN is
      do
         Result := basic_time_difftime(other.time_memory,time_memory) > 0
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

   time_memory: DOUBLE;
         -- The current time value of `Current'. As far as I know, this 
         -- kind of information should always fit into a double.
   
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

   basic_time_time: DOUBLE is
      external "SmallEiffel"
      end;
   
   basic_time_difftime(time2, time1: DOUBLE): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getyear(tm: DOUBLE; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getmonth(tm: DOUBLE; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getday(tm: DOUBLE; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_gethour(tm: DOUBLE; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getminute(tm: DOUBLE; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getsecond(tm: DOUBLE; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_is_summer_time_used(tm: DOUBLE): BOOLEAN is
      external "SmallEiffel"
      end;
   
   basic_time_getyday(tm: DOUBLE; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_getwday(tm: DOUBLE; mode: INTEGER): INTEGER is
      external "SmallEiffel"
      end;
   
   basic_time_mktime(a_year, a_mon, a_day, 
                     a_hour, a_min, a_sec: INTEGER): DOUBLE is
      external "SmallEiffel"
      end;
   
   basic_time_clock: INTEGER is
      external "SmallEiffel"
      end;
   
end -- BASIC_TIME
