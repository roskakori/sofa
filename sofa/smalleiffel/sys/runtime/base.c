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
  This file (SmallEiffel/sys/runtime/base.c) is included for _all_ modes of
  compilation (-boost, -no_check, ... -all_check, -debug_check).
*/

/*
  The wrapper for `malloc' (generated C code is supposed to use
  only `se_malloc' instead of direct `malloc').
*/
void* se_malloc(size_t size) {
  void *result = malloc(size);
  if (result == NULL) {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(No_more_memory);
#elif SE_NO_CHECK
    error0("No more memory.", NULL);
#else
  fprintf(SE_ERR,"No more memory.\n");
  se_print_run_time_stack();
  exit(EXIT_FAILURE);
#endif
  }
  return result;
}

/*
  The wrapper for `calloc' (generated C code is supposed to use
  only `se_calloc' instead of direct `calloc').
*/
void* se_calloc(size_t nmemb, size_t size) {
  void *result = calloc(nmemb,size);
  if (result == NULL) {
#ifdef SE_EXCEPTIONS
    internal_exception_handler(No_more_memory);
#elif SE_NO_CHECK
    error0("No more memory.", NULL);
#else
  fprintf(SE_ERR,"No more memory.\n");
  se_print_run_time_stack();
  exit(EXIT_FAILURE);
#endif
  }
  return result;
}
