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
class ARRAY[E]
   -- 
   -- General purpose resizable ARRAYs.
   -- 

inherit ARRAYED_COLLECTION[E];

creation make, with_capacity, from_collection

feature
   
   lower: INTEGER;     
         -- Lower index bound.
   
feature -- Creation and Modification :
   
   make(min_index, max_index: INTEGER) is
         -- Prepare the array to hold values for indexes in range
	 -- [`min_index' .. `max_index']. Set all values to default.
         -- When `max_index' = `min_index' - 1, the array `is_empty'.
      require
         valid_bounds: min_index <= max_index + 1
      local
         needed: INTEGER;
      do
         lower := min_index;
         upper := max_index;
         needed := max_index - min_index + 1;
         if needed > 0 then
            if capacity < needed then
               storage := storage.calloc(needed);
               capacity := needed;
            else
               clear_all;
            end;
         end;
      ensure
         lower_set: lower = min_index;
         upper_set: upper = max_index;
         items_set: all_default
      end;

   with_capacity(needed_capacity, low: INTEGER) is
         -- Create an empty array with `capacity' initialized
         -- at least to `needed_capacity' and `lower' set to `low'.
      require
         needed_capacity >= 0
      do
         if capacity < needed_capacity then
            storage := storage.calloc(needed_capacity);
            capacity := needed_capacity;
         end;
         lower := low;
         upper := low - 1;
      ensure
         is_empty;
         needed_capacity <= capacity;
         lower = low
      end;

feature -- Modification :
   
   resize(min_index, max_index: INTEGER) is
         -- Resize to bounds `min_index' and `max_index'. Do not lose any 
         -- item whose index is in both [`lower' .. `upper'] and 
         -- [`min_index' .. `max_index']. New positions if any are 
         -- initialized with the appropriate default value.
      require
         min_index <= max_index + 1
      local
         needed, offset, intersize: INTEGER;
      do
         needed := max_index - min_index + 1;
         if needed > 0 then
            if needed > capacity then
               if capacity = 0 then
                  storage := storage.calloc(needed);
                  capacity := needed;
               else
                  storage := storage.realloc(capacity, needed);
                  capacity := needed;
               end;
            end;
            offset := lower - min_index;
            intersize := max_index.min(upper) - min_index.max(lower) + 1;
            if intersize > 0 then
               if offset = 0 then
                  if intersize < capacity then
                     storage.clear(intersize, capacity - 1);
                  end;
               elseif offset < 0 then
                  storage.move(-offset, intersize - offset - 1, offset);
                  if intersize < capacity then
                     storage.clear(intersize, capacity - 1);
                  end;
               else
                  storage.move(0, intersize - 1, offset);
                  storage.clear(0, offset - 1);
                  if intersize + offset < capacity then
                     storage.clear(intersize + offset, capacity - 1);
                  end;
               end;
            else
	       storage.clear(0, capacity - 1);
            end;
         end;
         lower := min_index;
         upper := max_index;
      ensure
	 lower = min_index;
	 upper = max_index
      end;

   reindex(new_lower: INTEGER) is
	 -- Change indexing to take in account the expected `new_lower' 
	 -- index. The `upper' index is translated accordingly.
      local
	 i: INTEGER;
      do
	 i := new_lower - lower;
	 lower := lower + i;
	 upper := upper + i;
      ensure
	 lower = new_lower;
	 count = old count
      end;
   

feature -- Implementation of deferred :

   subarray(min, max: INTEGER): like Current is
      do
	 Result := slice(min,max);
	 Result.reindex(min);
      ensure then
         Result.lower = min;
      end;

   is_empty: BOOLEAN is
      do
         Result := upper < lower;
      end;

   count: INTEGER is
      do
         Result := upper - lower + 1;
      end;

   item, infix "@" (index: INTEGER): E is
      do
         Result := storage.item(index - lower);
      end;
   
   put(element: like item; index: INTEGER) is
      do
         storage.put(element,index - lower);
      end;

   force(element: like item; index: INTEGER) is
      require else
         true
      do
         if upper < index then
            if index = upper + 1 then
               add_last(element);
            else
               resize(lower,index);
               put(element,index);
            end;
         elseif index < lower then
            resize(index,upper);
            put(element,index);
         else
            put(element,index);
         end;
      ensure then
	 lower = index.min(old lower)
      end;

   copy(other: like Current) is
      local
         needed_capacity: INTEGER;
      do
         lower := other.lower;
         upper := other.upper;
         needed_capacity := upper - lower + 1;
         if capacity < needed_capacity then
            capacity := needed_capacity;
            storage := storage.calloc(capacity);
         end;
         if needed_capacity > 0 then
            storage.copy_from(other.storage,needed_capacity - 1);
         end;
      end;
   
   set_all_with(v: like item) is
      do
         storage.set_all_with(v,upper - lower);
      end;

   remove_first is
      do
         storage.remove_first(upper - lower);
         lower := lower + 1;
      ensure then
         upper = old upper;
      end;
   
   remove(index: INTEGER) is
      do
         storage.remove(index - lower,upper - lower);
         upper := upper - 1;
      end;
   
   clear is
      do
         upper := lower - 1;
      ensure then
         capacity = old capacity
      end;

   add_first(element: like item) is
      do
         if upper < lower then
            add_last(element);
         else
            add_last(element);
            move(lower,upper - 1,1);
            put(element,lower);
         end;
      end;

   add_last(element: like item) is
      local
         new_capacity: INTEGER;
      do
         if capacity < count + 1 then
            if capacity = 0 then
               capacity := 16;
               storage := storage.calloc(capacity);
            else
               new_capacity := 2 * capacity;
               storage := storage.realloc(capacity,new_capacity);
               capacity := new_capacity;
            end;
         end;
         upper := upper + 1;
         put(element,upper);
      end;

   from_collection(model: COLLECTION[like item]) is
      local
         i, up: INTEGER;
      do
         from
            with_capacity(model.count,model.lower);
            i := model.lower;
            up := model.upper;
            upper := up;
         until
            i > up
         loop
            put(model.item(i),i);
            i := i + 1;
         end;
      ensure then
         lower = model.lower;
         upper = model.upper
      end;

   all_default: BOOLEAN is
      do
         Result := storage.all_default(upper - lower);
      end;

   nb_occurrences(element: like item): INTEGER is
      do
         Result := storage.nb_occurrences(element,upper - lower);
      end;
      
   fast_nb_occurrences(element: like item): INTEGER is
      do
         Result := storage.fast_nb_occurrences(element,upper - lower);
      end;
      
   index_of(element: like item): INTEGER is
      do
         Result := lower + storage.index_of(element,upper - lower);
      end;

   fast_index_of(element: like item): INTEGER is
      do
         Result := lower + storage.fast_index_of(element,upper - lower);
      end;

   is_equal(other: like Current): BOOLEAN is
      do
         if Current = other then
            Result := true;
         elseif lower = other.lower and then upper = other.upper then
            Result := storage.fast_memcmp(other.storage,count);
         end;
      end;

   is_equal_map(other: like Current): BOOLEAN is
      do
         if Current = other then
            Result := true;
         elseif lower = other.lower and then upper = other.upper then
            Result := storage.memcmp(other.storage,count);
         end;
      end;

   slice(min, max: INTEGER): like Current is
      do
	 !!Result.make(lower,lower + max - min);
	 Result.storage.copy_slice(0,storage,min - lower,max - lower);
      end;

   get_new_iterator: ITERATOR[E] is
      do
         !ITERATOR_ON_COLLECTION[E]!Result.make(Current);
      end;

end -- ARRAY[E]

