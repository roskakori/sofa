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
  This file (SmallEiffel/sys/runtime/trace.h) is automatically included when
  `run_control.no_check' is true (ie. all modes except -boost).
  This file comes after no_check.[hc] to implements the -trace flag.
*/
#ifdef SE_TRACE
void se_trace(se_dump_stack*ds,se_position p);
#endif
#ifdef SE_WEDIT
void se_trace(se_dump_stack*ds,se_position p);
#endif
