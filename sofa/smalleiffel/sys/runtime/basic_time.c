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
  This file (SmallEiffel/sys/runtime/basic_time.c) is automatically
  included when some external "SmallEiffel" feature of class BASIC_TIME
  is use (ie. in live code).
*/

/* To switch from (or to) C to (from) Eiffel. */
typedef union _basic_time_union basic_time_union;
union _basic_time_union {
  time_t c_mapping;
  EIF_DOUBLE eiffel_mapping;
};

EIF_DOUBLE basic_time_time(void) {
  basic_time_union btu;
  btu.c_mapping = time(NULL);
  return btu.eiffel_mapping;
}

EIF_DOUBLE basic_time_difftime(EIF_DOUBLE t2, EIF_DOUBLE t1) {
  basic_time_union btu2;
  basic_time_union btu1;
  btu2.eiffel_mapping = t2;
  btu1.eiffel_mapping = t1;

  return difftime(btu2.c_mapping, btu1.c_mapping);
}

EIF_INTEGER basic_time_getyear(EIF_DOUBLE t, EIF_INTEGER m) {
  basic_time_union btu;
  btu.eiffel_mapping = t;
  if (m == 1) {
    return (((gmtime(&btu.c_mapping))->tm_year) + 1900);
    }
  else {
    return (((localtime(&(btu.c_mapping)))->tm_year) + 1900);
  }
}

EIF_INTEGER basic_time_getmonth(EIF_DOUBLE t, EIF_INTEGER m) {
  basic_time_union btu;
  btu.eiffel_mapping = t;
  if (m == 1) {
    return (((gmtime(&(btu.c_mapping)))->tm_mon) + 1);
  }
  else {
    return (((localtime(&(btu.c_mapping)))->tm_mon) + 1);
  }
}

EIF_INTEGER basic_time_getday(EIF_DOUBLE t, EIF_INTEGER m) {
  basic_time_union btu;
  btu.eiffel_mapping = t;
  if (m == 1) {
    return (gmtime(&(btu.c_mapping)))->tm_mday;
    }
  else {
    return (localtime(&(btu.c_mapping)))->tm_mday;
  }
}

EIF_INTEGER basic_time_gethour(EIF_DOUBLE t, EIF_INTEGER m) {
  basic_time_union btu;
  btu.eiffel_mapping = t;
  if (m == 1) {
    return (gmtime(&(btu.c_mapping)))->tm_hour;
  }
  else {
    return (localtime(&(btu.c_mapping)))->tm_hour;
  }
}

EIF_INTEGER basic_time_getminute(EIF_DOUBLE t, EIF_INTEGER m) {
  basic_time_union btu;
  btu.eiffel_mapping = t;
  if (m == 1) {
    return (gmtime(&(btu.c_mapping)))->tm_min;
  }
  else {
    return (localtime(&(btu.c_mapping)))->tm_min;
  }
}

EIF_INTEGER basic_time_getsecond(EIF_DOUBLE t, EIF_INTEGER m) {
  basic_time_union btu;
  btu.eiffel_mapping = t;
  if (m == 1) {
    return (gmtime(&(btu.c_mapping)))->tm_sec;
  }
  else {
    return (localtime(&(btu.c_mapping)))->tm_sec;
  }
}

EIF_INTEGER basic_time_getwday(EIF_DOUBLE t, EIF_INTEGER m) {
  basic_time_union btu;
  btu.eiffel_mapping = t;
  if (m == 1) {
    return (gmtime(&(btu.c_mapping)))->tm_wday;
  }
  else {
    return (localtime(&(btu.c_mapping)))->tm_wday;
  }
}

EIF_INTEGER basic_time_getyday(EIF_DOUBLE t, EIF_INTEGER m) {
  basic_time_union btu;
  btu.eiffel_mapping = t;
  if (m == 1) {
    return (gmtime(&(btu.c_mapping)))->tm_yday;
  }
  else {
    return (localtime(&(btu.c_mapping)))->tm_yday;
  }
}

EIF_BOOLEAN basic_time_is_summer_time_used(EIF_DOUBLE t) {
  basic_time_union btu;
  btu.eiffel_mapping = t;
  return (((localtime(&(btu.c_mapping)))->tm_isdst) != 0);
}

EIF_DOUBLE basic_time_mktime(EIF_INTEGER year,
			     EIF_INTEGER mon,
			     EIF_INTEGER mday,
			     EIF_INTEGER hour,
			     EIF_INTEGER min,
			     EIF_INTEGER sec) {
  basic_time_union btu;
  static struct tm tm_buf;

  tm_buf.tm_year  = (year - 1900);
  tm_buf.tm_mon   = (mon - 1);
  tm_buf.tm_mday  = mday;
  tm_buf.tm_hour  = hour;
  tm_buf.tm_min   = min;
  tm_buf.tm_sec   = sec;
  tm_buf.tm_isdst = -1;

  btu.c_mapping = ((time_t)mktime(&tm_buf));
  if (btu.c_mapping == ((time_t)(-1))) {
    btu.eiffel_mapping = ((EIF_DOUBLE)(-1));
  }
  return btu.eiffel_mapping;
}

EIF_INTEGER basic_time_clock(void) {
  return (clock());
}
