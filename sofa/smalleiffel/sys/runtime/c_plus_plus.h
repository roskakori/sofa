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
  This file (SmallEiffel/sys/runtime/c_plus_plus.h) is included in the
  header of C++ wrappers (when some external "C++" is in the live code).
*/

/*
  Following definitions MUST remain compatible with definitions
  of SmallEiffel/sys/runtime/base.h.
*/
#ifndef _SE_C_PLUS_PLUS
#define _SE_C_PLUS_PLUS 1
typedef int Tid;
typedef struct S0 T0;
struct S0{Tid id;};
typedef int T2;
typedef unsigned char T3;
typedef float T4;
typedef double T5;
typedef char T6;
typedef void* T8;

/*
  Some EIF_* defined in ETL :
*/
#define EIF_BOOLEAN T6
#define EIF_CHARACTER T3
#define EIF_INTEGER T2
#define EIF_REAL T4
#define EIF_DOUBLE T5
#define EIF_POINTER T8
#define EIF_REFERENCE T0*
#define EIF_OBJ T0*
#define EIF_OBJECT EIF_OBJ
#endif
