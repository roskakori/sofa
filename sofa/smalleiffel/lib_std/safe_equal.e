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
class SAFE_EQUAL[E]
   --
   -- The goal of this class is to share the definition of feature `safe_equal'. 
   -- Feature `safe_equal' compares two arguments of type E, by calling `is_equal' 
   -- only and only if both arguments have the `same_type'.
   --

feature {NONE}

   safe_equal(e1, e2: E): BOOLEAN is
         -- In order to avoid run-time type errors, feature `safe_equal' call 
         -- `is_equal' only when `e1' and `e2' have exactly the same `generating_type'. 
         -- Furthermore, this feature avoid argument passing from some 
         -- expanded type to the corresponding reference type (no automatic 
         -- allocation of some reference type during the comparison). 
      do
         if e1.is_basic_expanded_type then
            Result := e1 = e2;
         elseif e1.is_expanded_type then
            Result := e1.is_equal(e2);
         elseif e1 = e2 then
            Result := true;
         elseif e1 = Void or else e2 = Void then
	 elseif e1.generating_type = e2.generating_type then
            Result := e1.is_equal(e2);
         end;
      end;

end
