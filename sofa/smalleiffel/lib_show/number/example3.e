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
class EXAMPLE3
   --
   -- To start with NUMBERs, just compile an run it :
   -- 
   --            compile -o example2 -boost example2
   --

inherit NUMBER_TOOLS;

creation make

feature

   make is
      local
         n: NUMBER;
	 s: STRING;
      do
	 if argument_count = 0 then
	    io.put_string("factorial of 10 :%N");
	    n := from_integer(10);
	 else
	    s := argument(1);
	    if is_number(s) then
	       n := from_string(s);
	       if not n.is_abstract_integer then
		  io.put_number(n);
		  io.put_string(" : this is not an integer !%N");
		  die_with_code(exit_failure_code);
	       end;
	       if n @< 0 then
		  io.put_number(n);
		  io.put_string(" : this is not a positive integer !%N");
		  die_with_code(exit_failure_code);
	       end;
	    else
	       io.put_string(s);
	       io.put_string(" : this is not a number !%N");
	       die_with_code(exit_failure_code);
	    end;
	 end;
	 compute_factorial(n);
      end;

   compute_factorial(n: NUMBER) is
      do
	 io.put_character('(');
	 io.put_number(n);
	 io.put_string(").factorial = ");
	 io.put_number(n.factorial);
	 io.put_character('%N');
      end;

end -- EXAMPLE3

