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
  This file (SmallEiffel/sys/runtime/basic_gui.h) is automatically
  included when some external "SmallEiffel" feature of the Graphic User
  Interface (i.e. lib_gui) is live.
*/
EIF_BOOLEAN basic_gui_initialize(EIF_POINTER display_name,
				 EIF_BOOLEAN sync,
				 EIF_BOOLEAN no_xshm,
				 EIF_POINTER name,
				 EIF_POINTER progclass,
				 EIF_POINTER gxid_host,
				 EIF_INTEGER gxid_port);
EIF_BOOLEAN basic_gui_exit(void);
