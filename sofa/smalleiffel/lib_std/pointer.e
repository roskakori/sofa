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
expanded class POINTER
--
-- References to objects meant to be exchanged with non-Eiffel 
-- software.
--
-- Note : An Eiffel POINTER is mapped as C type "void *" or as
-- Java "java.lang.Object" type.
--

inherit 
   POINTER_REF
      redefine fill_tagged_out_memory, hash_code
      end;

feature

   is_null: BOOLEAN is
         -- Is the external POINTER a NULL pointer ?
      do
         Result := not is_not_null;
      end;

   is_not_null: BOOLEAN is
         -- Is the external POINTER a non-NULL pointer ?
      external "SmallEiffel"
      end;

   is_void: BOOLEAN is
      obsolete "This feature will be soon removed. %
               %Since release -0.78, the new name for this feature %
               %is `is_null'. Please, update your code."
      do
         Result := is_null;
      end;

   is_not_void: BOOLEAN is
      obsolete "This feature will be soon removed. %
               %Since release -0.78, the new name for this feature %
               %is `is_not_null'. Please, update your code."
      do
         Result := is_not_null;
      end;

feature -- Object Printing :

   append_in(str: STRING) is
         -- Append on `str' a viewable version of Current.
      local
         i: INTEGER;
      do
         sprintf_pointer(tmp_native_array);
         from
            i := 0;
         until
            tmp_native_array.item(i) = '%U'
         loop
            str.extend(tmp_native_array.item(i));
            i := i + 1;
         end;
      end;

   fill_tagged_out_memory is
      do
         Current.append_in(tagged_out_memory);
      end;

   hash_code: INTEGER is
      local
         i: INTEGER;
         view: STRING;
      do
         view := "    ";
         view.clear;
         append_in(view);
         from
            i := view.count;
         until
            i = 0
         loop
            if not view.item(i).is_digit then
               view.remove(i);
            end;
            i := i - 1;
         end;
         if view.count = 0 then
            view.extend('1');
         end;
         Result := view.to_integer.hash_code;
      end;

feature 

   to_any: ANY is
         -- Assume that `Current' is really an Eiffel reference.
      do
         c_inline_c("R=((void*)C);");
      end;

feature {NONE}

   sprintf_pointer(native_array: NATIVE_ARRAY[CHARACTER]) is
      external "SmallEiffel"
      end;
   
   tmp_native_array: NATIVE_ARRAY[CHARACTER] is
      once
         Result := Result.calloc(32);
      end;

end -- POINTER

