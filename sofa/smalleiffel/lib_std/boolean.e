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
expanded class BOOLEAN
--
-- Note: An Eiffel BOOLEAN is mapped as a C int or as a Java int.
--

inherit
   BOOLEAN_REF
      redefine
         infix "and", infix "and then", infix "or",
         infix "or else", infix "implies", infix "xor",
         prefix "not", out_in_tagged_out_memory, fill_tagged_out_memory
      end;

feature 

   infix "and" (other: BOOLEAN): BOOLEAN is
         -- `and' of Current with `other'.
         -- 
         -- Note: when evaluation of `other' has no side effects, it 
         -- may be better to use "and then" to avoid execution-time
         -- overhead.
      do
         Result := Current and then other;
      end;

   infix "and then" (other: BOOLEAN): BOOLEAN is
         -- Semi-strict `and' of Current with `other'.
      external "SmallEiffel"
      end;

   infix "implies"(other: BOOLEAN): BOOLEAN is
         -- Does Current imply `other'.
      external "SmallEiffel"
      end;

   infix "or" (other: BOOLEAN): BOOLEAN is
         -- `or' of Current with `other'
         --
         -- Note: when evaluation of `other' has no side effects, it 
         -- may be better to use "or else" to avoid execution-time
         -- overhead.
      do
         Result := Current or else other;
      end;

   infix "or else" (other: BOOLEAN): BOOLEAN is
         -- Semi-strict `or' of Current with `other'
      external "SmallEiffel"
      end;

   infix "xor" (other: BOOLEAN): BOOLEAN is
         -- `xor' of Current with `other'
      do
         if Current then
            Result := not other;
         else
            Result := other;
         end;
      end;

   prefix "not": BOOLEAN is
         -- `not' of Current.
      do
         if Current then
         else
            Result := true;
         end;
      end;

   to_string: STRING is
      do
         if Current then
            Result := "true";
         else
            Result := "false";
         end;
      ensure
         ("true").is_equal(Result) implies Current;
         ("false").is_equal(Result) implies not Current
      end;

   to_integer: INTEGER is
      do
         if Current then
            Result := 1;
         else
            Result := 0;
         end;
      ensure
         Result = 1 implies Current;
         Result = 0 implies not Current
      end;

   to_character: CHARACTER is
      do
         if Current then
            Result := '1';
         else
            Result := '0';
         end;
      ensure
         Result = '1' implies Current;
         Result = '0' implies not Current
      end;

   append_in(str: STRING) is
      do
         str.append(to_string);
      end;

feature -- Object Printing :

   out_in_tagged_out_memory, fill_tagged_out_memory is
      do
         tagged_out_memory.append(to_string);
      end;

end -- BOOLEAN

