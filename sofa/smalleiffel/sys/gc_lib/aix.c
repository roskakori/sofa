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
--                       http://www.loria.fr/SmallEiffel
--
*/
/*
   For IBM AIX architecture.
*/

void mark_stack_and_registers(void){
  void**stack_pointer;
  jmp_buf stack_top;
  (void)setjmp(stack_top);
  stack_pointer=((void**)stack_top);
  /* Addresses decrease as the stack grows. */
  for(; stack_pointer <= stack_bottom; stack_pointer++)
    gc_mark(*stack_pointer);
}
