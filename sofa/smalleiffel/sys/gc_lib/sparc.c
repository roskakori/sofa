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
   For SPARC architecture.
   As this file contains assembly code (asm), you must not use
   the flag -ansi of gcc (in file ${SmallEiffel}/sys/compiler.*).
*/

void mark_loop (void) {
  void** max = stack_bottom + 11;
  void** stack_pointer;
  void* stack_top[2]={NULL,NULL};
  stack_pointer = stack_top;
  /* Addresses decrease as the stack grows. */
  while (stack_pointer < max) {
    gc_mark(*(stack_pointer++));
  }
}

void mark_stack_and_registers (void) {
  asm("	ta	0x3   ! ST_FLUSH_WINDOWS");
  mark_loop();
}
