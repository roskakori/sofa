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
class FIXED_ARRAY[E]
   --
   -- Resizable, fixed lower bound array.
   -- Unlike ARRAY, the `lower' bound of a FIXED_ARRAY is frozen 
   -- to 0. Thus, some memory is saved and looping toward `lower'
   -- bound (which is 0) run a little bit faster.
   --

inherit ARRAYED_COLLECTION[E];

creation 
   make, with_capacity, from_collection

feature

   lower: INTEGER is 0;
         -- Frozen lower bound.
   
feature -- Creation and modification :
   
   make(new_count: INTEGER) is
         -- Make array with range [0 .. `new_count' - 1]. 
         -- When `new_count' = 0 the array is empty.
      require
         new_count >= 0
      do
         if new_count = 0 then
            upper := -1;
         elseif capacity = 0 then
            storage := storage.calloc(new_count);
            capacity := new_count;
            upper := new_count - 1;
         elseif capacity < new_count then
            storage := storage.calloc(new_count);
            capacity := new_count;
            upper := new_count - 1;
         else
            upper := new_count - 1;
            clear_all;
         end;
      ensure
         count = new_count;
         capacity >= old capacity;
         all_default
      end;

   with_capacity(needed_capacity: INTEGER) is
         -- Create an empty array with at least `needed_capacity'.
      require
	 needed_capacity >= 0
      do
         if capacity < needed_capacity then
            storage := storage.calloc(needed_capacity);
            capacity := needed_capacity;
         end;
         upper := -1;
      ensure
         capacity >= needed_capacity;
         is_empty
      end;

feature -- Modification :

   resize(new_count: INTEGER) is
         -- Resize the array. When `new_count' is greater than
         -- `count', new positions are initialized with appropriate 
         -- default values.
      require
         new_count >= 0
      local
         new_capacity, i: INTEGER;
         elt_default: like item;
      do
         if new_count <= count then
            upper := new_count - 1;
         else
            new_capacity := new_count;
            if capacity < new_capacity then
               if capacity = 0 then
                  storage := storage.calloc(new_capacity);
               else
                  storage := storage.realloc(capacity,new_capacity);
               end;
               capacity := new_capacity;
            end;
            from
               new_capacity := upper;
               upper := new_count - 1;
               i := upper;
            until
               i = new_capacity
            loop
               put(elt_default,i);
               i := i - 1;
            end;
         end;
      ensure
         count = new_count;
         capacity >= old capacity
      end;

feature -- Implementation of deferred :

   is_empty: BOOLEAN is
      do
         Result := upper < 0;
      end;

   item, infix "@" (index: INTEGER): E is
      do
         Result := storage.item(index);
      end;
   
   put(element: E; index: INTEGER) is
      do
         storage.put(element,index);
      end;

   add_first(element: like item) is
      do
         add_last(element);
         if upper = 0 then
         elseif upper = 1 then
            swap(0,1);
         else
            move(0,upper - 1,1);
            put(element,0);
         end;
      end;

   add_last(element: like item) is
      local
         new_capacity: INTEGER;
      do
         if upper + 1 <= capacity - 1 then
            upper := upper + 1;
         elseif capacity = 0 then
            storage := storage.calloc(2);
            capacity := 2;
            upper := 0
         else
            new_capacity := 2 * capacity;
            storage := storage.realloc(capacity,new_capacity);
            capacity := new_capacity;
            upper := upper + 1;
         end;
         put(element,upper);
      end;

   count: INTEGER is
      do
         Result := upper + 1;
      end;

   clear is
      do
         upper := -1;
      ensure then
         capacity = old capacity
      end;

   copy(other: like Current) is
         -- Copy `other' onto Current.
      local
         other_upper, new_capacity: INTEGER;
      do
         other_upper := other.upper;
         if other_upper >= 0 then
            new_capacity := other_upper + 1;
            if capacity < new_capacity then
               capacity := new_capacity;
               storage := storage.calloc(new_capacity);
            elseif capacity > 0 then
               storage.clear_all(capacity - 1);
            end;
            storage.copy_from(other.storage,other_upper);
         elseif capacity > 0 then
            storage.clear_all(capacity - 1);
         end;
         upper := other_upper;
      end;

   set_all_with(v: like item) is
      do
         storage.set_all_with(v,upper);
      end;

   from_collection(model: COLLECTION[like item]) is
      local
         i1, i2, up: INTEGER;
      do
         from
            with_capacity(model.count);
            upper := model.count - 1;
            i1 := 0;
            i2 := model.lower;
            up := model.upper;
         until
            i2 > up 
         loop
            put(model.item(i2),i1);
            i1 := i1 + 1;
            i2 := i2 + 1;
         end;
      end;
   
   is_equal(other: like Current): BOOLEAN is
      do
         if Current = other then
            Result := true;
         elseif upper = other.upper then
            Result := storage.fast_memcmp(other.storage,upper + 1);
         end;
      end;

   is_equal_map(other: like Current): BOOLEAN is
      do
         if Current = other then
            Result := true;
         elseif upper = other.upper then
            Result := storage.memcmp(other.storage,upper + 1);
         end;
      end;

   all_default: BOOLEAN is
      do
         Result := storage.all_default(upper);
      end;

   nb_occurrences(element: like item): INTEGER is
      do
         Result := storage.nb_occurrences(element,upper);
      end;
      
   fast_nb_occurrences(element: E): INTEGER is
      do
         Result := storage.fast_nb_occurrences(element,upper);
      end;

   index_of(element: like item): INTEGER is
      do
         Result := storage.index_of(element,upper);
      end;

   fast_index_of(element: like item): INTEGER is
      do
         Result := storage.fast_index_of(element,upper);
      end;

   subarray, slice(min, max: INTEGER): like Current is
      do
	 !!Result.make(max - min + 1);
	 Result.storage.copy_slice(0,storage,min, max);
      end;

   force(element: E; index: INTEGER) is
      do
         if index <= upper then
            put(element,index);
         elseif index = upper + 1 then
            add_last(element);
         else
            resize(index + 1);
            put(element,index);
         end;
      end;
         
   remove_first is
      local
         dummy: like storage;
      do
         if upper = 0 then
            storage := dummy;
            capacity := 0;
            upper := -1;
         else
            storage.remove_first(upper);
            upper := upper - 1;
         end;
      ensure then
         lower = old lower
      end;

   remove(index: INTEGER) is
      do
         storage.remove(index,upper);
         upper := upper - 1;
      end;
   
   get_new_iterator: ITERATOR[E] is
      do
         !ITERATOR_ON_COLLECTION[E]!Result.make(Current);
      end;

end -- FIXED_ARRAY[E]

