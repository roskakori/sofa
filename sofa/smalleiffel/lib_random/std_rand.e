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
class STD_RAND
   -- Press' standard generator, which uses the minimal standard
   -- and then uses shuffling to break up short order corelations.

inherit
   MIN_STAND
      redefine with_seed, next
      select with_seed, next
      end;
   MIN_STAND
      rename
         next as min_next
      export
         {NONE} min_next
      redefine
         last_integer, last_real
      end;

creation make, with_seed

feature {NONE}

   iv: ARRAY[INTEGER];

   ntab: INTEGER is 32;

   iy: INTEGER;

feature

   with_seed(seed_value:INTEGER) is
      require
         valid_seed: seed_value > 0 and seed_value < im
      local
         i: INTEGER;
      do
         seed := seed_value;
         min_next;
         !!iv.make(1,ntab);
         from
            i := 1;
         until
            i > 7
         loop
            min_next;
            i := i + 1;
         end;
         from
            i := ntab;
         until
            i = 0
         loop
            iv.put(seed,i);
            min_next;
            i := i - 1;
         end
         iy := iv.item(1);
         next;
      end

feature

   next is
      local
         tmp:INTEGER
      do
         tmp := iy \\ ntab + 1;
         min_next;
         iy := iv.item(tmp);
         iv.put(seed,tmp);
      end

   last_integer(n:INTEGER):INTEGER is
      do
         Result := iy \\ n + 1;
      end

   last_real:REAL is
      do
         Result := (iy / im).to_real;
      end

end -- STD_RAND

