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
class MIN_STAND
   --
   -- Implements the Minimal Standard generator from Press et. al.
   -- Numerical Recipies.
   --

inherit GEN_RAND;

creation make, with_seed

feature

   im: INTEGER is 2147483647;

feature {NONE}

   ia: INTEGER is 16807;

   iq: INTEGER is 127773;

   ir: INTEGER is 2836;

   seed:INTEGER

feature 

   make is
      local
         seed_init: INTEGER;
      do
         seed_init := 1 + Current.to_pointer.hash_code;
         from
         until
            seed_init < im
         loop
            seed_init := seed_init - iq;
         end;
         with_seed(seed_init);
      end;

   with_seed(seed_value: INTEGER) is
      require
         valid_seed: seed_value > 0 and seed_value < im
      do
         seed:= seed_value;
         next;
      end;

   next is
      local
         k: INTEGER;
      do
         k := seed // iq;
         seed := ia * (seed -k * iq) - ir * k;
         if seed < 0 then
            seed := seed + im;
         end;
      end;

   last_real: REAL is
      do
         Result := (seed/im).to_real;
      end;

   last_integer(n:INTEGER): INTEGER is
      do
         Result := seed \\ n+1;
      end;

invariant

   good_seed: seed > 0 and seed < im

end -- MIN_STAND


