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
  This file (SmallEiffel/sys/runtime/deep_twin.h) contains the basic
  runtime support for the GENERAL.deep_twin feature as well as the basic
  runtime support for the GENERAL.is_deep_equal feature.
  This file is automatically included in the header when `deep_twin' or
  `is_deep_equal' is in the live code of the system.
*/

/* Runtime support for `deep_twin':
 */
void se_deep_twin_start(void);
void* se_deep_twin_search(void* object);
void se_deep_twin_register(void* object, void* deep_twin);
void* se_deep_twin_trats(void* object);

/* Runtime support for `is_deep_equal':
 */
void se_deep_equal_start(void);
int se_deep_equal_search(void* object, void* deep);
void se_deep_equal_trats(void);
