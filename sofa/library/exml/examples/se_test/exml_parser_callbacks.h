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
  This file (base.h) is automatically included in the header for all modes
  of compilation : -boost, -no_check, -require_check, ...
  This file is also included in the header of any cecil file.
*/
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <signal.h>
#include <stddef.h>
#include <stdarg.h>
#include <limits.h>
#include <float.h>
#include <setjmp.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#ifndef O_RDONLY
#include <sys/file.h>
#endif
#ifndef O_RDONLY
#define O_RDONLY 0000
#endif

/*
   On Linux glibc systems, we need to use sig.* versions of jmp_buf,
   setjmp and longjmp to preserve the signal handling context.
   Currently, the way I figured to detect this is if _SIGSET_H_types has
   been defined in /usr/include/setjmp.h.
*/
#ifdef _SIGSET_H_types
# define JMP_BUF    sigjmp_buf
# define SETJMP(x)  sigsetjmp( (x), 1)
# define LONGJMP    siglongjmp
#else
# define JMP_BUF    jmp_buf
# define SETJMP(x)  setjmp( (x) )
# define LONGJMP    longjmp
#endif

/*
   Type to store reference objects Id :
 */
typedef int Tid;

typedef struct S0 T0;

struct S0{
  Tid id;
};

/*
   The default channel used to print runtime error messages :
*/
#define SE_ERR stderr

/*
   Eiffel type INTEGER is #2 :
*/
typedef int T2;
#define M2 (0)
#define T2BITS (CHAR_BIT*sizeof(int))
#define T2MIN INT_MIN
#define T2MAX INT_MAX

/*
  Eiffel type CHARACTER is #3 :
*/
typedef char T3;
#define M3 (0)
#define T3BITS CHAR_BIT
#define T3MIN (0)
#define T3MAX (255)

/*
  Eiffel type REAL is #4 :
*/
typedef float T4;
#define M4 (0.0)
#define T4BITS (CHAR_BIT*sizeof(float))
#define T4MIN (-(FLT_MAX))
#define T4MAX FLT_MAX

/*
  Eiffel type DOUBLE is #5 :
*/
typedef double T5;
#define M5 (0.0)
#define T5BITS (CHAR_BIT*sizeof(double))
#define T5MIN (-(DBL_MAX))
#define T5MAX DBL_MAX

/*
  Eiffel type BOOLEAN is #6 :
*/
typedef int T6;
#define M6 (0)
#define T6BITS (CHAR_BIT*sizeof(int))

/*
   Eiffel type POINTER is #8 :
*/
typedef void* T8;
#define M8 (NULL)
#define T8BITS (CHAR_BIT*sizeof(void*))

extern void*eiffel_root_object;

typedef char* T9;
/* Available Eiffel routines via -cecil:
*/
T2 eif_exml_on_unkown_encoding(void* C,T8 a1,T8 a2);
T2 eif_exml_on_external_entity_reference(void* C,T8 a1,T8 a2,T8 a3,T8 a4);
void eif_exml_on_notation_declaration(void* C,T8 a1,T8 a2,T8 a3,T8 a4);
void eif_exml_on_unparsed_entity_declaration(void* C,T8 a1,T8 a2,T8 a3,T8 a4,T8 a5);
void eif_exml_on_default(void* C,T8 a1,T2 a2);
void eif_exml_on_processing_instruction(void* C,T8 a1,T8 a2);
void eif_exml_on_content_tag_proc(void* C,T8 a1,T2 a2);
void eif_exml_on_end_tag_proc(void* C,T8 a1);
void eif_exml_on_start_tag_proc(void* C,T8 a1,T8 a2);
