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
deferred class ARRAYED_COLLECTION[E]
   -- 
   -- Common root for ARRAY[E] and FIXED_ARRAY[E].
   --

inherit COLLECTION[E];

feature {ARRAYED_COLLECTION}
   
   storage: NATIVE_ARRAY[E];
         -- Internal access to storage location.
   
feature
   
   capacity: INTEGER;
         -- Internal storage capacity in number of item.
   
   upper: INTEGER;
         -- Upper index bound.
   
feature 

   frozen sub_array(low, up: INTEGER): like Current is
      obsolete "The new name of this feature is `subarray'."
      do
	 Result := subarray(low,up);
      end;

   subarray(min, max: INTEGER): like Current is
	 -- New collection consisting of items at indexes in [`min' .. `max'].
         -- Result has the same dynamic type as `Current'.
	 -- See also `slice'.
      require
         lower <= min;
         max <= upper;
         min <= max + 1
      deferred
      ensure
         same_type(Result);
         Result.count = (max - min + 1);
         Result.lower = min or Result.lower = 0
      end;

feature -- Implementation of deferred :

   first: like item is
      do
         Result := storage.item(0);
      end;

   last: like item is
      do
         Result := item(upper);
      end;

   add(element: like item; index: INTEGER) is
      do
         if index = upper + 1 then
            add_last(element);
         else
            add_last(element);
            move(index,upper - 1,1);
            put(element,index);
         end;
      end;

   remove_last is
      do
         upper := upper - 1;
      end;
   
   replace_all(old_value, new_value: like item) is
      do
         storage.replace_all(old_value,new_value,count - 1);
      end;
   
   fast_replace_all(old_value, new_value: like item) is
      do
         storage.fast_replace_all(old_value,new_value,count - 1);
      end;

feature -- Interfacing with C :
   
   to_external: POINTER is
         -- Gives C access into the internal `storage' of the ARRAY.
         -- Result is pointing the element at index `lower'.
         -- 
         -- NOTE: do not free/realloc the Result. Resizing of the array 
         --       can makes this pointer invalid. 
      require
         not is_empty
      do
         Result := storage.to_pointer;
      ensure
         Result.is_not_null
      end;

feature {ARRAYED_COLLECTION}

   set_upper(new_upper: like upper) is
      do
         upper := new_upper;
      end;

invariant

   capacity >= (upper - lower + 1);

   capacity > 0 implies storage.is_not_null;

end -- ARRAYED_COLLECTION[E]

