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
   Stack and Registers traversal for PC Linux with gcc.
   Addresses decrease as the stack grows.
   Registers are saved using SETJMP().
   A little correction of the non-accurate `stack_bottom' seams to
   be necessary here.
*/

void mark_stack_and_registers (void) {
  void** max = stack_bottom + 8; /* stack_bottom correction here. */
  void** stack_pointer;
  jmp_buf registers;

  (void)setjmp(registers);
  stack_pointer = ((void**)(&registers));
  while (stack_pointer < max) {
    gc_mark(*(stack_pointer++));
  }
}
