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
  This file (SmallEiffel/sys/runtime/exception.c) is automatically included
  when exception handling is used somewhere in the live code.
*/

/*
  Miscellaneous Notes:
  We are currently using the old signal() system call instead of
  the prefered sigaction() call.

  On Linux systems at least, signal() is implemented by sigaction()
  so it doesn't really matter.  Need to investigate this on other
  Unix systems.

  James Graves (ansible@xnet.com)
*/

/*
   Top of the rescue context stack (or NULL if there is no current
   context) :
*/
struct rescue_context *rescue_context_top = NULL;

/*
   Set to nonzero if the exception was internally generated, as with an
   assertion violation.  It is Os_signal (11) for an OS signal.
*/
int internal_exception_number;
int original_internal_exception_number;

/*
   Set to nonzero if the exception was a signal (external).  It is 0
   for an internal exception.
*/
int signal_exception_number;

/*
   Used by some internal exceptions to print additional debugging
   information when the exception is not handled and a dump is done.
*/
char *additional_error_message;

static void critical_error_exit(void) {
/* This is called whenever a critical error in the SmallEiffel
   is encountered.  This kind of error cannot be handled by the
   exception handler.

   For instance, this routine is called if there is an error in the
   operation of the exception handler routines themselves.
*/
  fprintf(SE_ERR, "There was a critical error in the SmallEiffel runtime.\n");
  exit(EXIT_FAILURE);
}

void setup_signal_handler() {
/*
  Sets up the reception of signals.  If exception handling is enabled
  (by the existance of a rescue clause somewhere), then all OS signals
  now go to exception_handler instead of se_print_run_time_stack().
*/
#ifdef SIG_ERR
/* Check signal() call for errors.  Posix compliant systems should
   define SIG_ERR which is returned by signal() on an error. All Unix
   signals are included except * for SIGKILL and SIGSTOP.

   The other signals SmallEiffel traps for
   other OSs (like SIGBREAK) are not included here, but are below
   in the #else part, for non-Posix systems.
*/

#ifdef SIGHUP
   if ( SIG_ERR == signal( SIGHUP, signal_exception_handler ) )
      {
      fprintf(SE_ERR, "Error setting up signal handler for SIGHUP.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGINT
   if ( SIG_ERR == signal( SIGINT, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGINT.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGQUIT
   if ( SIG_ERR == signal( SIGQUIT, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGQUIT.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGILL
   if ( SIG_ERR == signal( SIGILL, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGILL.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGTRAP
   if ( SIG_ERR == signal( SIGTRAP, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGTRAP.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGIOT
   if ( SIG_ERR == signal( SIGIOT, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGIOT.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGBUS
   if ( SIG_ERR == signal( SIGBUS, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGBUS.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGFPE
   if ( SIG_ERR == signal( SIGFPE, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGFPE.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGUSR1
   if ( SIG_ERR == signal( SIGUSR1, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGUSR1.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGSEGV
   if ( SIG_ERR == signal( SIGSEGV, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGSEGV.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGUSR2
   if ( SIG_ERR == signal( SIGUSR2, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGUSR2.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGPIPE
   if ( SIG_ERR == signal( SIGPIPE, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGPIPE.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGALRM
   if ( SIG_ERR == signal( SIGALRM, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGALRM.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGTERM
   if ( SIG_ERR == signal( SIGTERM, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGTERM.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGCHLD
   if ( SIG_ERR == signal( SIGCHLD, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGCHLD.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGCONT
   if ( SIG_ERR == signal( SIGCONT, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGCONT.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGTSTP
   if ( SIG_ERR == signal( SIGTSTP, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGTSTP.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGTTIN
   if ( SIG_ERR == signal( SIGTTIN, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGTTIN.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGTTOU
   if ( SIG_ERR == signal( SIGTTOU, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGTTOU.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGURG
   if ( SIG_ERR == signal( SIGURG, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGURG.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGXCPU
   if ( SIG_ERR == signal( SIGXCPU, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGXCPU.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGXFSZ
   if ( SIG_ERR == signal( SIGXFSZ, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGXFSZ.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGVTALRM
   if ( SIG_ERR == signal( SIGVTALRM, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGVTALRM.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGPROF
   if ( SIG_ERR == signal( SIGPROF, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGPROF.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGWINCH
   if ( SIG_ERR == signal( SIGWINCH, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGWINCH.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGIO
   if ( SIG_ERR == signal( SIGIO, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGIO.\n");
      critical_error_exit();
      }
#endif

#ifdef SIGPWR
   if ( SIG_ERR == signal( SIGPWR, signal_exception_handler ) ) {
      fprintf(SE_ERR, "Error setting up signal handler for SIGPWR.\n");
      critical_error_exit();
      }
#endif

#else   /* SIG_ERR not defined, non-Posix system? */

/* These don't check return code for the signal() OS call.  Bad practice,
   but what can be done?  */

#ifdef SIGBREAK
   /* This signal does not exist on Unix systems. */
   signal( SIGBREAK, signal_exception_handler );
#endif

#ifdef SIGHUP
   signal( SIGHUP, signal_exception_handler );
#endif

#ifdef SIGINT
   signal( SIGINT, signal_exception_handler );
#endif

#ifdef SIGQUIT
   signal( SIGQUIT, signal_exception_handler );
#endif

#ifdef SIGILL
   signal( SIGILL, signal_exception_handler );
#endif

#ifdef SIGTRAP
   signal( SIGTRAP, signal_exception_handler );
#endif

#ifdef SIGIOT
   signal( SIGIOT, signal_exception_handler );
#endif

#ifdef SIGBUS
   signal( SIGBUS, signal_exception_handler );
#endif

#ifdef SIGFPE
   signal( SIGFPE, signal_exception_handler );
#endif

#ifdef SIGKILL
   /* This should silently fail on Unix systems, but is reported to work
      on other non-Unix systems.  You have been warned. */
   signal( SIGKILL, signal_exception_handler );
#endif

#ifdef SIGUSR1
   signal( SIGUSR1, signal_exception_handler );
#endif

#ifdef SIGSEGV
   signal( SIGSEGV, signal_exception_handler );
#endif

#ifdef SIGUSR2
   signal( SIGUSR2, signal_exception_handler );
#endif

#ifdef SIGPIPE
   signal( SIGPIPE, signal_exception_handler );
#endif

#ifdef SIGALRM
   signal( SIGALRM, signal_exception_handler );
#endif

#ifdef SIGTERM
   signal( SIGTERM, signal_exception_handler );
#endif

#ifdef SIGCHLD
   signal( SIGCHLD, signal_exception_handler );
#endif

#ifdef SIGCONT
   signal( SIGCONT, signal_exception_handler );
#endif

#ifdef SIGSTOP
   /* This should also silently fail on all Unix systems, but it may
      be effective on other OSs. */
   signal( SIGSTOP, signal_exception_handler );
#endif

#ifdef SIGTSTP
   signal( SIGTSTP, signal_exception_handler );
#endif

#ifdef SIGTTIN
   signal( SIGTTIN, signal_exception_handler );
#endif

#ifdef SIGTTOU
   signal( SIGTTOU, signal_exception_handler );
#endif

#ifdef SIGURG
   signal( SIGURG, signal_exception_handler );
#endif

#ifdef SIGXCPU
   signal( SIGXCPU, signal_exception_handler );
#endif

#ifdef SIGXFSZ
   signal( SIGXFSZ, signal_exception_handler );
#endif

#ifdef SIGTALRM
   signal( SIGTALRM, signal_exception_handler );
#endif

#ifdef SIGPROF
   signal( SIGPROF, signal_exception_handler );
#endif

#ifdef SIGWINCH
   signal( SIGWINCH, signal_exception_handler );
#endif

#ifdef SIGIO
   signal( SIGIO, signal_exception_handler );
#endif

#ifdef SIGPWR
   signal( SIGPWR, signal_exception_handler );
#endif

#endif  /* ifdef SIG_ERR */

}

#ifdef SE_NO_CHECK
static void reset_assertion_checking(struct rescue_context * current_context) {
  /* Unwind the dump stack, resetting assertion checking when a rescue
     clause is invoked.
     This function must be called just before the LONGJMP to the
     enclosing rescue context.
  */
  while(se_dst!=current_context->top_of_ds){
    if(se_dst->fd!=NULL)se_dst->fd->assertion_flag=1;
    se_dst = se_dst->caller;
  }
}
#endif

void signal_exception_handler(int signal_number) {
  /* Set up to be called whenever an OS signal has been received.
     Checks to see if there is a rescue clause active (somewhere on the
     call stack), and if so, transfer control to that.
  */
  struct rescue_context *current_context;

#ifdef SIG_ERR
  /* some OS implementations automatically block a signal while
   * executing the signal handler, but some do not. */
  if ( SIG_ERR == signal( signal_number, SIG_IGN ) ) {
    fprintf(SE_ERR, "In signal_exception_handler: ");
    fprintf(SE_ERR, "Error turning off signal %d.\n", signal_number );
    critical_error_exit();
  }
#else
  signal( signal_number, SIG_IGN );
#endif

  internal_exception_number = Os_signal;
  original_internal_exception_number = 0;
  signal_exception_number = signal_number;

  if ( rescue_context_top != NULL ) {
    current_context = rescue_context_top;
    rescue_context_top = rescue_context_top->next;

    /* now re-enable that signal */
#ifdef SIG_ERR
    if ( SIG_ERR == signal( signal_number, signal_exception_handler ) ) {
      fprintf(SE_ERR, "In signal_exception_handler: ");
      fprintf(SE_ERR, "Error turning on signal %d.\n", signal_number );
      critical_error_exit();
    }
#else
    signal( signal_number, signal_exception_handler );
#endif

#ifdef SE_NO_CHECK
    /* Unwind dump_stack structures PRIOR to jumping :
     */
    reset_assertion_checking(current_context) ;
#endif
    LONGJMP( current_context->jb, internal_exception_number );
  }

  /* No current rescue clause, exit with a dump : */
  print_exception();
  se_print_run_time_stack();
  exit(EXIT_FAILURE);
}

void internal_exception_handler(int exception_number) {
  /* Called whenever an internal (to SmallEiffel) exception is to
     be raised (`raise' feature, assertion violation, etc.).

     Checks to see if there is a current rescue clause (somewhere
     in the call stack), and transfers control to it.
     Else exit with a stack trace (if enabled).
  */
  struct rescue_context *current_context;

  /* UNCOMMENT THIS PART TO DEBUG WITH EXCEPTION:
     print_exception(); se_print_run_time_stack();
  */



  /* If this is not a routine failure, clear out old exception
   * information. */
  if ( exception_number != Routine_failure ) {
    internal_exception_number = exception_number;
    original_internal_exception_number = 0;
    signal_exception_number = 0;
  }
  else {
    original_internal_exception_number = internal_exception_number;
  }

  if ( rescue_context_top != NULL ) {
    current_context = rescue_context_top;
    rescue_context_top = rescue_context_top->next;
#ifdef SE_NO_CHECK
    /* Unwind dump_stack structures PRIOR to jumping :
     */
    reset_assertion_checking(current_context) ;
#endif
    LONGJMP( current_context->jb, exception_number );
  }

  /* No current rescue clause, exit with a dump : */
  print_exception();
  se_print_run_time_stack();
  exit(EXIT_FAILURE);
}

#ifdef SE_NO_CHECK
static void print_exception_case( int ex_num ) {
  switch( ex_num ) {
  case Check_instruction:
    fprintf(SE_ERR, "Check instruction failed.\n");
    break;
  case Class_invariant:
    fprintf(SE_ERR, "Class invariant not maintained.\n");
    break;
  case Developer_exception:
    fprintf(SE_ERR, "Developer exception:\n");
    break;
  case Incorrect_inspect_value:
    fprintf(SE_ERR, "Incorrect inspect value.\n");
    break;
  case Loop_invariant:
    fprintf(SE_ERR, "Loop invariant failed.\n");
    break;
  case Loop_variant:
    fprintf(SE_ERR, "Loop variant failed to decrease.\n");
    break;
  case No_more_memory:
    fprintf(SE_ERR, "Failed to allocate additional memory.\n");
    break;
  case Postcondition:
    fprintf(SE_ERR, "Postcondition (ensure clause) failed.\n");
    break;
  case Precondition:
    fprintf(SE_ERR, "Precondition (require clause) failed.\n");
    break;
  case Routine_failure:
    fprintf(SE_ERR, "Routine failure.\n");
    break;
  case Os_signal:
    fprintf(SE_ERR, "OS Signal (%d) received.\n",
	    signal_exception_number );
    break;
  case Void_attached_to_expanded:
    fprintf(SE_ERR, "A Void became attached to an expanded object.\n");
    fprintf(SE_ERR, "Please report this problem to the SmallEiffel team.\n");
    break;
  case Void_call_target:
    fprintf(SE_ERR, "Feature call attempted on a Void reference.\n");
    break;
  default:
    fprintf(SE_ERR, "There was an unknown exception.\n");
    fprintf(SE_ERR, "Please report this problem to the SmallEiffel team.\n");
  }
}
#endif

void print_exception(void) {
  /* Display some information about last not handled exception. */
#ifdef SE_NO_CHECK
  fprintf(SE_ERR,"Exception number %d not handled.\n",internal_exception_number);
  if ( internal_exception_number == Routine_failure ) {
    fprintf(SE_ERR, "Routine failure.  Original exception: \n");
    print_exception_case( original_internal_exception_number );
  }
  else {
    print_exception_case( internal_exception_number );
  }
  if ( additional_error_message != NULL ) {
    fprintf(SE_ERR, "%s\n", additional_error_message );
  }
#endif
}

