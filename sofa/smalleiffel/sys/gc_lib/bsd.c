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
   Stack and Registers traversal for all BSD like: FreeBSD, BSD/OS, NetBSD,
   as well as OpenBSD.
   Addresses decrease as the stack grows.
   Registers are saved using SETJMP().

   NOT YET TESTED, BUT I AM QUITE SURE THAT IT IS OK.
   PLEASE LET ME KNOW.
   IN FACT, THIS FILE IS A COPY OF linux.c
*/

void mark_stack_and_registers(void) {
  void** max = stack_bottom;
  void** stack_pointer;
  JMP_BUF registers;

  (void)SETJMP(registers);
  stack_pointer=((void**)(&registers));
  while(stack_pointer < max) {
    gc_mark(*(stack_pointer++));
  }
}
