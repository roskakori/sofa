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
  This file (SmallEiffel/sys/runtime/exception.h) is automatically included
  when exception handling is used somewhere in the live code.
*/

#define SE_EXCEPTIONS 1

/*
  Constants from Eiffel class EXCEPTIONS :
*/
#define Check_instruction 	  1
#define Class_invariant 	  2
#define Developer_exception 	  3
#define Incorrect_inspect_value   4
#define Loop_invariant 		  5
#define Loop_variant 		  6
#define No_more_memory  	  7
#define Postcondition 		  8
#define Precondition  		  9
#define Routine_failure  	  10
#define	Os_signal		  11
#define Void_attached_to_expanded 12
#define Void_call_target 	  13

/*
   This will be the structure of rescue contexts.  A rescue context
   will be declared for every routine that has a rescue clause.

   The `next' pointer is the address of the next rescue context if there
   is one higher up the call chain, or NULL if there is no other
   context.
*/
struct rescue_context {
  JMP_BUF jb;
#ifdef SE_NO_CHECK
  /* To keep track of dump stack to unwind it safely
     before the LONGJMP :
  */
  struct _se_dump_stack * top_of_ds ;
#endif
  struct rescue_context *next;
};

extern struct rescue_context *rescue_context_top;
extern int internal_exception_number;
extern int original_internal_exception_number;
extern int signal_exception_number;
extern char *additional_error_message;

void setup_signal_handler(void);
void signal_exception_handler(int);
void internal_exception_handler(int);
void print_exception(void);
