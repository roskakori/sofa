/* GC code for AmigaOS/68k by Rudi Chiarito <chiarito@cli.di.unipi.it>
 * Contrary to what m68k.c implies, SP *decreases* as the stack grows!
 * Tested with SAS/C 6, to be tested with GCC, DICE, Storm and others.
 *
 * NOTE: the current collection algorithm only works with a CONTIGUOUS
 * stack. I.e. use garbage collection WITHOUT ENABLING AUTOMATIC STACK
 * EXTENSION. Stack overflow checking can (SHOULD) be enabled, though.
 */

void mark_stack_and_registers(void){
  void**sp;
#ifdef __SASC
  #include <dos.h>
  sp=(void**)getreg(REG_A7);
#else
  void*stack_top[2]={NULL,NULL};
  sp=stack_top;
#endif
  for (;sp<=stack_bottom;sp++) gc_mark(*sp);
}

