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
  This file (SmallEiffel/sys/runtime/trace.c) is automatically included when
  `run_control.no_check' is true (ie. all modes except -boost).
  This file comes after no_check.[hc] to implements the -trace flag.
*/


#ifdef SE_WEDIT
/*
   Smooth interface with the Wedit debugger.
*/
#define MAXBREAKPOINTS 256
static int __BreakpointsList[MAXBREAKPOINTS];
void SE_CallDebugger(void) {
}

se_position se_trace(se_position p) {
  int l = se_position2line(p);
  int c = se_position2column(p);
  int f = se_position2path_id(p);
  int i,s;

  s = (f <<16)|l;
  for (i=0; i< MAXBREAKPOINTS;i++) {
    if (__BreakpointsList[i] == s) {
      SE_CallDebugger();
    }
    else if (__BreakpointsList[i] == 0)
      break;
  }
  return p;
}
#elif SE_TRACE
/*
  The SmallEiffel -trace is used, so the command line SmallEiffel
  step-by-step se_trace function is defined.
*/
static FILE* se_trace_file = NULL;
static int se_write_trace_flag = 0;
static int se_trace_ready_flag = 0;
static int se_step_by_step_flag = 1;

int get_answer(void) {
  int result = 0;
  char c = getc(stdin);
  if (c != '\n') {
    result = c;
  }
  while (c != '\n') {
    c = getc(stdin);
  }
  return result;
}

static void sedb_help_command(void) {
  printf("SmallEiffel debugger.\n");
  printf("List of classes of commands:\n");
  printf("   (h) Help.\n");
  printf("   (s) Stack view.\n");
  printf("   (q) Quit.\n");
  printf("   Return to see the current Eiffel source line.");
  printf("   \n");
  printf("Please, feel free to debug or to complete this simple\n");
  printf("step-by-step debugger (see source file in\n");
  printf("\"SmallEiffel/sys/runtime/trace.c\".\n");
}

static void sedb_show_source_line(int l,int c,int f) {
  static int f_memo = 0;
  if (p[f] == NULL) {
    printf("line %d column %d of ???\t\t",l,c);
  }
  else {
    FILE *file = fopen(p[f],"r");
    if (file != NULL) {
      int line = 1;
      int column = 1;
      char cc;
      while (line < l) {
	cc = fgetc(file);
	if (cc == '\n') {
	  line++;
	}
      }
      cc = fgetc(file);
      while (cc != '\n') {
	if (cc == '\t') {
	  printf("        ");
	  column+=7;
	}
	else {
	  fputc(cc,stdout);
	}
	cc = fgetc(file);
	column++;
      }
      while (column < 72) {
	fputc(' ',stdout);
	column++;
      }
      printf("l%dc%d ",l,c);
      if (f_memo != f) {
	printf(" %s ",p[f]);
      }
      f_memo = f;
      fclose(file);
    }
    else {
      printf("line %d column %d of %s\t\t",l,c,p[f]);
    }
  }
}

void se_trace(se_dump_stack*ds, se_position position) {
  if (se_trace_flag) {
    static char cmd_memo = 1;
    static char cmd;
    int l = se_position2line(position);
    int c = se_position2column(position);
    int f = se_position2path_id(position);
    ds->p = position;
    if (se_trace_ready_flag) {
      if (se_write_trace_flag) {
	fprintf(se_trace_file,"line %d column %d in %s\n",l,c,p[f]);
	fflush(se_trace_file);
      }
    next_command:
      if (se_step_by_step_flag) {
	if (cmd_memo != 0) {
	  printf("(sedb) ");
	}
	fflush(stdout);
	cmd = get_answer();
	cmd_memo = cmd;
	if ((cmd == 'h') || (cmd == 'H') || (cmd == '?')) {
	  sedb_help_command();
	  goto next_command;
	}
	else if ((cmd == 's') || (cmd == 'S')) {
	  se_print_run_time_stack();
	  goto next_command;
	}
	else if ((cmd == 'q') || (cmd == 'Q')) {
	  exit(EXIT_FAILURE);
	}
	else if (cmd == 0) {
	  sedb_show_source_line(l,c,f);
	}
	else {
	  printf("Unknown command.\nTtype H for help\n");
	  goto next_command;
	}
      }
    }
    else {
      se_trace_ready_flag = 1;
      printf("Write the execution trace in \"trace.se\" file (y/n) ? [n]");
      fflush(stdout);
      if (get_answer() == 'y') {
	se_write_trace_flag = 1;
	se_trace_file = fopen("trace.se","w");
      }
      printf("Step-by-step execution (y/n) ? [y]");
      fflush(stdout);
      if (get_answer() == 'n') {
	se_step_by_step_flag = 0;
      }
      else {
	sedb_help_command();
      }
    }
  }
}
#endif

