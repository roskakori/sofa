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
  This file (SmallEiffel/sys/runtime/no_check.h) is automatically included
  when `run_control.no_check' is true (ie. all modes except mode -boost).
*/
#define SE_NO_CHECK 1

void se_prinT0(T0**o);
void se_prinT2(EIF_INTEGER*o);
void se_prinT3(EIF_CHARACTER*o);
void se_prinT4(EIF_REAL*o);
void se_prinT5(EIF_DOUBLE*o);
void se_prinT6(EIF_BOOLEAN*o);
void se_prinT7(EIF_STRING*o);
void se_prinT8(EIF_POINTER*o);

/*
   This type is used to store a position in some Eiffel source file.
   It must be compatible with the implementation of class POSITION.
*/
typedef unsigned int se_position;

EIF_INTEGER se_position2line(se_position position);
EIF_INTEGER se_position2column(se_position position);
EIF_INTEGER se_position2path_id(se_position position);

/*
  To be able to print a stack frame in a human readable format :
*/
typedef struct _se_frame_descriptor se_frame_descriptor;
struct _se_frame_descriptor {
  char* name;
  int use_current;
  int local_count; /* Number of C variable to print. */
  char* local_format; /* Format information. */
  int assertion_flag; /* 1 when assertions can be checked. */
};

/*
  To keep the track of execution in order to be able to print a
  dump when things goes wrong :
*/
typedef struct _se_dump_stack se_dump_stack;
struct _se_dump_stack {
  se_frame_descriptor* fd;
  void** current; /* NULL when not used. */
  se_position p; /* The current position. */
  se_dump_stack* caller; /* Back to the caller. */
  void*** locals;
};
extern se_dump_stack* se_dst;
void se_print_run_time_stack(void);
void se_print_one_frame(se_dump_stack*ds);
void se_core_dump(char *msg);

extern int se_rspf;
extern int se_require_uppermost_flag;
extern int se_require_last_result;
int se_rci(void*C);
void error0(char*m,char*vv);
void error1(char*m,se_position position);
void error2(T0*o,se_position position);
T0* vc(void*o,se_position position);
T0* ci(int id,void*o,se_position position);
void ac_req(int v,char*vv);
void ac_ens(int v,char*vv);
void ac_inv(int v,char*vv);
void ac_liv(int v,char*vv);
void ac_insp(int v);
int ac_lvc(int lc,int lv1,int lv2);
void ac_civ(int v,char*vv);
void se_evobt(void*o,se_position position);
void sigrsp(int sig);
void se_gc_check_id(void*o,int id);
