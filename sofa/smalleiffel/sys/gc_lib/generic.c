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

   Files of directory SmallEiffel/gc_lib/ are supposed to define the
   appropriate `mark_stack_and_registers' C function which is called by the
   Garbage Collector (GC) of SmallEiffel. The `mark_stack_and_registers'
   function may changed from one system to another, but also from one C
   compiler to another. On some architecture, addresses increase as the
   stack grows; or, conversely, addresses decrease as the stack grows.
   A C compiler may be clever enough to hide some root object inside
   registers. Unfortunately all registers are not always accessible via
   the C `setjmp' function !

   Thus, in order to be able to use the GC on your architecture/C-compiler,
   you have to provide the correct `mark_stack_and_registers' function.

   What is the `mark_stack_and_registers' function supposed to do ?
   The `mark_stack_and_registers' function is supposed to notify the GC
   with all possible root one can find in C stack and registers by calling
   the `gc_mark' function. A root is an object which must not be collected.
   The SmallEiffel GC already knows about some root objects like once
   function results or manifest strings. The `mark_stack_and_registers'
   function have to notify others possible roots. Obviously, one can find
   in the C stack any kind of adresses, but the `gc_mark' function is clever
   enough to determine if the passed pointer is an Eiffel object or not.
   When the passed pointer reach some Eiffel object, this object as well as
   its descendant(s) are automatically marked as un-collectable.

   In order to provide the most appropriate `mark_stack_and_registers'
   function, the very first question is to know about the way the C stack
   is managed (addresses of the stack may increase or decrease as the C
   stack grows). In this "generic.c" file, the test is done dynamically
   each time the `mark_stack_and_registers' is called. Indeed, the global
   C variable `stack_bottom' is set with some pointer which is supposed to
   be the bottom of the stack (this variable is automatically initialized
   in the C main function). Using the current stack pointer inside
   `mark_stack_and_registers', it is quite obvious to determine if addresses
   increase or not as the C stack grows.

   The second problem to solve is to be sure that the bottom of the stack
   is really reached. The global variable 'stack_bottom' is not always
   accurately set. If it is the case, we have to go under the predefined
   value of 'stack_bottom' on some architectures.

   Some roots may be stored only in registers and not in the C stack.
   In order to reach registers as well, the first attempt is to use
   setjmp, in the hope that setjmp will save registers in the stack !

   Finally, I am not sure to that previous explaination are cler enough,
   be here is the "generic.c" definition of `mark_stack_and_registers'.
*/

void mark_stack_and_registers(void) {
  /*
     Works on many architecture/C-compilers.
  */
  void**stack_pointer; /* Use to traverse the stack and registers assuming
			  that `setjmp' will save registers in the C stack.
		       */
  jmp_buf stack_top; /* The jmp_buf buffer is in the C stack. */

  (void)setjmp(stack_top); /* To fill the C stack with registers. */

  stack_pointer=((void**)(&stack_top));

  if (stack_pointer > stack_bottom){
    /*
       Addresses increase as the stack grows (add some printf here to see
       if this is true on your architecture).
    */
    stack_pointer+=(sizeof(jmp_buf)/sizeof(void*)); /* To traverse the
						       jmp_buf as well.
						    */
    for ( ; stack_pointer >= stack_bottom; stack_pointer--) {
      gc_mark(*stack_pointer);
    }
  }
  else {
    /*
      Addresses decrease as the stack grows (add some printf here to see
      if this is true on your architecture).
    */
    for ( ; stack_pointer <= stack_bottom; stack_pointer++) {
      gc_mark(*stack_pointer);
    }
  }
}

