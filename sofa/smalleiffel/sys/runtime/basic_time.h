/*
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
*/
/*
  This file (SmallEiffel/sys/runtime/basic_time.h) is automatically
  included when some external "SmallEiffel" feature of class BASIC_TIME
  is live.
*/
#include <time.h>

#ifdef WIN32
#include <windows.h>
#endif

EIF_INTEGER basic_time_time(void);
EIF_DOUBLE basic_time_difftime (EIF_INTEGER t1, EIF_INTEGER t2);
EIF_INTEGER basic_time_getyear(EIF_INTEGER t, EIF_INTEGER m);
EIF_INTEGER basic_time_getmonth(EIF_INTEGER t, EIF_INTEGER m);
EIF_INTEGER basic_time_getday(EIF_INTEGER t, EIF_INTEGER m);
EIF_INTEGER basic_time_gethour(EIF_INTEGER t, EIF_INTEGER m);
EIF_INTEGER basic_time_getminute(EIF_INTEGER t, EIF_INTEGER m);
EIF_INTEGER basic_time_getsecond(EIF_INTEGER t, EIF_INTEGER m);
EIF_INTEGER basic_time_getyday(EIF_INTEGER t, EIF_INTEGER m);
EIF_INTEGER basic_time_getwday(EIF_INTEGER t, EIF_INTEGER m);
EIF_BOOLEAN basic_time_is_summer_time_used(EIF_INTEGER t);
EIF_INTEGER basic_time_mktime(EIF_INTEGER year,
			      EIF_INTEGER mon,
			      EIF_INTEGER mday,
			      EIF_INTEGER hour,
			      EIF_INTEGER min,
			      EIF_INTEGER sec);
EIF_INTEGER  basic_time_clock(void);
