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
  This file (SmallEiffel/sys/runtime/system_clock.c) is automatically
  included when some external "SmallEiffel" feature of class SYSTEM_CLOCK
  is live.
*/

EIF_INTEGER basic_time_time (void) {
    return time(NULL);
}

EIF_DOUBLE basic_time_difftime (EIF_INTEGER t2, EIF_INTEGER t1) {
    return difftime(t2, t1);
}

EIF_INTEGER basic_time_getyear(EIF_INTEGER t, EIF_INTEGER m) {
    if (m == 1) {
	return (((gmtime((time_t*)(&t)))->tm_year) + 1900);
    }
    else {
	return (((localtime((time_t*)(&t)))->tm_year) + 1900);
    }
}

EIF_INTEGER basic_time_getmonth(EIF_INTEGER t, EIF_INTEGER m) {
    if (m == 1) {
	return (((gmtime((time_t*)(&t)))->tm_mon) + 1);
    }
    else {
	return (((localtime((time_t*)(&t)))->tm_mon) + 1);
    }
}

EIF_INTEGER basic_time_getday(EIF_INTEGER t, EIF_INTEGER m) {
    if (m == 1) {
	return ((gmtime((time_t*)&(t)))->tm_mday);
    }
    else {
	return ((localtime((time_t*)&(t)))->tm_mday);
    }
}

EIF_INTEGER basic_time_gethour(EIF_INTEGER t, EIF_INTEGER m) {
    if (m == 1) {
	return ((gmtime((time_t*)(&t)))->tm_hour);
    }
    else {
	return ((localtime((time_t*)(&t)))->tm_hour);
    }
}

EIF_INTEGER basic_time_getminute (EIF_INTEGER t, EIF_INTEGER m) {
    if (m == 1) {
	return ((gmtime((time_t*)(&t)))->tm_min);
    }
    else {
	return ((localtime((time_t*)(&t)))->tm_min);
    }
}

EIF_INTEGER basic_time_getsecond(EIF_INTEGER t, EIF_INTEGER m) {
    if (m == 1) {
	return ((gmtime((time_t*)(&t)))->tm_sec);
    }
    else {
	return ((localtime((time_t*)(&t)))->tm_sec);
    }
}

EIF_INTEGER basic_time_getwday (EIF_INTEGER t, EIF_INTEGER m) {
    if (m == 1) {
	return ((gmtime((time_t*)(&t)))->tm_wday);
    }
    else {
	return ((localtime((time_t*)(&t)))->tm_wday);
    }
}

EIF_INTEGER basic_time_getyday (EIF_INTEGER t, EIF_INTEGER m) {
    if (m == 1) {
	return ((gmtime((time_t*)(&t)))->tm_yday);
    }
    else {
	return ((localtime((time_t*)(&t)))->tm_yday);
    }
}

EIF_BOOLEAN basic_time_is_summer_time_used(EIF_INTEGER t) {
    return (((localtime((time_t*)(&t)))->tm_isdst)!=0);
}

EIF_INTEGER basic_time_mktime(EIF_INTEGER year,
			      EIF_INTEGER mon,
			      EIF_INTEGER mday,
			      EIF_INTEGER hour,
			      EIF_INTEGER min,
			      EIF_INTEGER sec) {
    static struct tm tm_buf;

    tm_buf.tm_year  = year-1900;
    tm_buf.tm_mon   = mon - 1;
    tm_buf.tm_mday  = mday;
    tm_buf.tm_hour  = hour;
    tm_buf.tm_min   = min;
    tm_buf.tm_sec   = sec;
    tm_buf.tm_isdst = 1;

    return (mktime(&tm_buf));
}

EIF_INTEGER basic_time_clock(void) {
    return (clock());
}

