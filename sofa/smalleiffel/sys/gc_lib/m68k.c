/* For Motorola 68K Garbage Collector marking code. */

void marking_loop(void){
  void**sp;
  void*stack_top={NULL,NULL};
  sp=stack_top;
  for(;sp>=stack_bottom;sp--)
    gc_mark(*sp);
}

void mark_stack_and_registers(void){
  asm(" ld A0 SP");
  marking_loop();
}

