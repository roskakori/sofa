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
  This file (SmallEiffel/sys/runtime/no_check.c) is automatically included
  when `run_control.no_check' is true (ie. all modes except -boost).
*/

/*
   To print object into the trace-stack :
*/
void se_prinT0(T0** o) {
  if (*o == NULL) {
    fprintf(SE_ERR,"Void");
  }
  else {
    fprintf(SE_ERR,"#%p",(void*)*o);
  }
}

void se_prinT2(EIF_INTEGER* o) {
  fprintf(SE_ERR,"%d",*o);
}

void se_prinT3(EIF_CHARACTER* o) {
  fprintf(SE_ERR,"'%c'",*o);
}

void se_prinT4(EIF_REAL* o) {
  fprintf(SE_ERR,"%f",((double)*o));
}

void se_prinT5(EIF_DOUBLE* o) {
  fprintf(SE_ERR,"%f",*o);
}

void se_prinT6(EIF_BOOLEAN* o) {
  if (*o) {
    fprintf(SE_ERR,"true");
  }
  else {
    fprintf(SE_ERR,"false");
  }
}

void se_prinT7(EIF_STRING* o) {
  if (*o == NULL) {
    fprintf(SE_ERR,"Void");
  }
  else {
    T3* storage = (*o)->_storage;
    int count = (*o)->_count;
    int i = 0;
    fprintf(SE_ERR,"\"");
    while (i < count) {
      fprintf(SE_ERR,"%c",storage[i]);
      i++;
    }
    fprintf(SE_ERR,"\"");
  }
}

void se_prinT8(EIF_POINTER* o) {
  if (*o == NULL) {
    fprintf(SE_ERR,"NULL");
  }
  else {
    fprintf(SE_ERR,"POINTER#%p",(void*)*o);
  }
}


EIF_INTEGER se_position2line(se_position position) {
  /*
     Computes the line number using the given `position'.
  */
  if (position & 1) {
    return (EIF_INTEGER) ((position >> 1) & 0x7FFF);
  }
  else{
    return (EIF_INTEGER) ((position >> 8) & 0x1FFF);
  }
}

EIF_INTEGER se_position2column(se_position position) {
  /*
     Computes the column number using the given `position'.
  */
  if (position & 1) {
    return 0; /* Not memorized. */
  }
  else{
    return (EIF_INTEGER) ((position >> 1) & 0x7F);
  }
}

EIF_INTEGER se_position2path_id(se_position position) {
  /*
     Computes the file path id using the given `position'.
  */
  return (EIF_INTEGER) ((position & 1) ? (position >> 17) : (position >> 21));
}

/*
  The upper most context (SmallEiffel Dump stack Top) :
*/
se_dump_stack* se_dst=NULL;

void se_print_run_time_stack(void) {
  /* GENERAL.print_run_time_stack */
  se_dump_stack* ds = NULL;
  se_dump_stack* ds2;
  int frame_count = 1;

  ds = se_dst;
  if (ds == NULL) {
    fprintf(SE_ERR,"Empty stack.\n");
    return ;
  }
  else {
    while (ds->caller != NULL) {
      ds = ds->caller;
      frame_count++;
    }
  }
  fprintf(SE_ERR,"%d frames in current stack.\n",frame_count);
  fprintf(SE_ERR,"=====  Bottom of run-time stack  =====\n");
  while (ds != NULL) {
    if (ds->fd != NULL) {
      se_print_one_frame(ds);
    }
    else {
      fprintf(SE_ERR,"External CECIL call.\n");
    }
    /* Next frame : */
    if (ds == se_dst) {
      ds = NULL;
    }
    else {
      ds2 = se_dst;
      while (ds2->caller != ds) {
	ds2 = ds2->caller;
      }
      ds = ds2;
    }
    if (--frame_count) {
      fprintf(SE_ERR,"======================================\n");
    }
  }
  fprintf(SE_ERR,"=====   Top of run-time stack    =====\n");
}

void se_print_one_frame(se_dump_stack* ds) {
  se_frame_descriptor* fd = ds->fd;
  int i = 0;
  int local_count = 0;
  char* local_format = fd->local_format;
  int expanded;
  int id;
  void** var;
  fprintf(SE_ERR,"%s\n",fd->name);
  if (fd->use_current) {
    fprintf(SE_ERR,"Current = ");
    i = 2;
    id = 0;
    while (local_format[i] != '%') {
      id = (id * 10) + (local_format[i] - '0');
      i++;
    }
    i++;
    (se_prinT[id])(ds->current);
    fprintf(SE_ERR,"\n");
  }
  while (local_count < fd->local_count) {
    while (local_format[i] != '%') {
      fprintf(SE_ERR,"%c",local_format[i]);
      i++;
    }
    i++;
    expanded = ((local_format[i++] == 'E')?1:0);
    fprintf(SE_ERR," = ");
    id = 0;
    while (local_format[i] != '%') {
      id = (id * 10) + (local_format[i] - '0');
      i++;
    }
    i++;
    var = (ds->locals)[local_count];
    if (expanded) {
      (se_prinT[id])((void**)(var));
    }
    else if (*var == NULL) {
      fprintf(SE_ERR,"Void");
    }
    else {
      (se_prinT[((T0*)(*var))->id])((void**)(var));
    }
    fprintf(SE_ERR,"\n");
    local_count++;
  }
  if (ds->p != 0) {
    fprintf(SE_ERR,"line %d ",se_position2line(ds->p));
    fflush(SE_ERR);
    fprintf(SE_ERR,"column %d ",se_position2column(ds->p));
    fflush(SE_ERR);
    fprintf(SE_ERR,"file %s \n",p[se_position2path_id(ds->p)]);
    fflush(SE_ERR);
  }
}

void se_core_dump(char*msg) {
  if (msg != NULL) {
    fprintf(SE_ERR,"%s\n",msg);
  }
#ifdef SE_EXCEPTIONS
  print_exception();
#endif
  se_print_run_time_stack();
  exit(EXIT_FAILURE);
}

int se_require_uppermost_flag;

/*
  Require Last Result :
*/
int se_require_last_result;

int se_rci(void*C) {
  /* Return 1 if class invariant must be checked for Current
     before leaving the routine.
  */
  se_dump_stack*ds = se_dst;
  ds = ds->caller;
  if (ds != NULL) {
    se_frame_descriptor* fd = ds->fd;
    if (fd == NULL) {
      /* As for example when coming via CECIL. */
      return 0;
    }
    else {
      if (fd->use_current) {
	if (fd->local_format[1] == 'R') {
	  if (((void*)*(ds->current)) == C) {
	    return 0;
	  }
	}
      }
    }
  }
  return 1;
}

void error0(char*m,char*vv) {
  static char*f1="*** Error at Run Time *** : %s\n";
  static char*f2="*** Error at Run Time *** : %s\n";
  fprintf(SE_ERR,f1,m);
  if (vv!=NULL)
     fprintf(SE_ERR,f2,vv);
#ifdef SE_EXCEPTIONS
  print_exception();
#endif
  se_print_run_time_stack();
  fprintf(SE_ERR,f1,m);
  if (vv!=NULL)
     fprintf(SE_ERR,f2,vv);
  exit(EXIT_FAILURE);
}

void error1(char*m,se_position position) {
  int l = se_position2line(position);
  int c = se_position2column(position);
  int f = se_position2path_id(position);
  char* f1 = "Line : %d column %d in %s.\n";
  char* f2 = "*** Error at Run Time *** : %s\n";

  fprintf(SE_ERR,f1,l,c,p[f]);
  fprintf(SE_ERR,f2,m);
#ifdef SE_EXCEPTIONS
  print_exception();
#endif
  se_print_run_time_stack();
  fprintf(SE_ERR,f1,l,c,p[f]);
  fprintf(SE_ERR,f2,m);
  exit(EXIT_FAILURE);
}

void se_print_string(FILE*stream, EIF_STRING s) {
  /* To print some Eiffel STRING. */
  if (s == NULL) {
    fprintf(stream,"Void");
  }
  else {
    int count = s->_count;
    EIF_CHARACTER* storage = s->_storage;
    int i = 0;
    fprintf(stream,"\"");
    while (count != 0) {
      fprintf(stream,"%c",storage[i]);
      i++;
      count--;
    }
    fprintf(stream,"\"");
  }
}

void se_print_bad_target(FILE*stream, int id, T0* o, int l, int c, int f) {
  /* Print Bad Target Type Error Message. */
  if (l != 0) {
    fprintf(stream,"Line : %d column %d in %s.\n",l,c,p[f]);
  }
  fprintf(stream,"*** Error at Run Time *** :\n");
  fprintf(stream,"   Target is not valid (not the good type).\n");
  fprintf(stream,"   Expected: ");
  se_print_string(stream,t[id]);
  fprintf(stream,", Actual: ");
  se_print_string(stream,t[o->id]);
  fprintf(stream,".\n");
}

void error2(T0*o, se_position position) {
  fprintf(SE_ERR,"Target Type ");
  se_print_string(SE_ERR,t[o->id]);
  fprintf(SE_ERR," is not valid.\n");
  error1("Bad target.",position);
}

T0* vc(void*o,se_position position) {
  /*
    VoidCheck for reference target.
  */
  if (o != NULL) {
    return ((T0*)o);
  }
  else {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(Void_call_target);
#else
    error1("Call with a Void target.",position);
#endif
    return NULL;
  }
}

T0* ci(int id,void*o,se_position position) {
  /*
    Check Id for reference target.
  */
  vc(o,position);
  if (id == (((T0*)o)->id)) {
    return ((T0*)o);
  }
  else {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(Routine_failure);
#else
    int l = se_position2line(position);
    int c = se_position2column(position);
    int f = se_position2path_id(position);

    se_print_bad_target(SE_ERR,id,(T0*)o,l,c,f);
    se_print_run_time_stack();
    se_print_bad_target(SE_ERR,id,(T0*)o,l,c,f);
    exit(EXIT_FAILURE);
#endif
  }
  return ((T0*)o);
}

void ac_req(int v,char*vv) {
  if (!v && se_require_uppermost_flag) {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(Precondition);
#else
    error0("Require Assertion Violated.",vv);
#endif
  }
  se_require_last_result=se_require_last_result&&v;
}

void ac_ens(int v,char*vv) {
  if (!v) {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(Postcondition);
#else
    error0("Ensure Assertion Violated.",vv);
#endif
  }
}

void ac_inv(int v,char*vv) {
  if (!v) {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(Class_invariant);
#else
    error0("Class Invariant Violation.",vv);
#endif
  }
}

void ac_liv(int v,char*vv) {
  /* Assertion Check : Loop Invariant check. */
  if (!v) {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(Loop_invariant);
#else
    error0("Loop Invariant Violation.",vv);
#endif
  }
}

int ac_lvc(int lc,int lv1,int lv2) {
  /* Assertion Check : Loop Variant check. */
  if (lc == 0) {
    if (lv2 < 0) {
#ifdef SE_EXCEPTIONS
      internal_exception_handler(Loop_variant);
#else
      se_print_run_time_stack();
      fprintf(SE_ERR,"Bad First Variant Value = %d\n",lv2);
      exit(EXIT_FAILURE);
#endif
    }
    else {
      return lv2;
    }
  }
  else if ((lv2 < 0) || (lv2 >= lv1)) {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(Loop_variant);
#else
    se_print_run_time_stack();
    fprintf(SE_ERR,"Loop Body Count = %d (done)\n",lc);
    fprintf(SE_ERR,"New Variant = %d\n",lv2);
    fprintf(SE_ERR,"Previous Variant = %d\n",lv1);
    exit(EXIT_FAILURE);
#endif
  }
  return lv2;
}

void ac_civ(int v,char*vv) {
  if (!v) {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(Check_instruction);
#else
    error0("Check Assertion Violated.",vv);
#endif
  }
}

void se_evobt(void*o,se_position position) {
  /*
    Error Void Or Bad Type.
  */
  if (!o) {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(Void_call_target);
#else
    error1("Target is Void.",position);
#endif
  }
  else {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(Void_call_target);
#else
    error2(((T0*)o),position);
#endif
  }
}

void sigrsp(int sig) {
  printf("Received signal %d (man signal).\n",sig);
  se_print_run_time_stack();
  exit(1);
}

void se_gc_check_id(void*o,int id) {
  if (id != (((T0*)o)->id)) {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(Routine_failure);
#else
    fprintf(SE_ERR,"System-validity error detected during GC cycle.\n");
    se_print_bad_target(SE_ERR,id,(T0*)o,0,0,0);
    se_print_run_time_stack();
    fprintf(SE_ERR,"System-validity error detected during GC cycle.\n");
    se_print_bad_target(SE_ERR,id,(T0*)o,0,0,0);
    exit(1);
#endif
  }
}
