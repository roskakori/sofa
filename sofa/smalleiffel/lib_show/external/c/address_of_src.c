/*
  Hand-written C code to be used with address_of_demo.e
*/

#include <stdio.h>

void write_integer_attribute(int*attribute) {
  /*
     Assume an Eiffel INTEGER is really mapped as a C int.
     Have a look is ${SmallEiffel}/sys/runtime/base.h
     One ca also use the -cecil interface to be always compatible.
  */
  *attribute=2;
}

void call_back1(void* target, void*routine_ptr) {
  ((void (*)(void*))routine_ptr)(target);
}

int call_back2(void* target, void*routine_ptr) {
  return (((int (*)(void*))routine_ptr)(target));
}

int call_back3(void* target, void*routine_ptr, void*eiffel_string) {
  return (((int (*)(void*,void*))routine_ptr)(target,eiffel_string));
}

int call_back4(void* target, void*routine_ptr, void*eiffel_string) {
  return (((int (*)(void*,void*,char))routine_ptr)(target,eiffel_string,'G'));
}

void call_back5(void* target, void*routine_ptr) {
  (((void (*)(void*,void*))routine_ptr)(target,target));
}

void call_back6(void* target, void*routine_ptr) {
  (((void (*)(void*))routine_ptr)(target));
}

int call_back7(void* target, void*routine_ptr) {
  return ((((int (*)(void*))routine_ptr)(target)));
}
