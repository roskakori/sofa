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
deferred class COLLECTION[E]
-- 
-- Common abstract definition of a sequenceable collection of objects. 
-- Such a collection is traversable using a simple INTEGER index from `lower' 
-- to `upper'. Items can be added, changed or removed.
-- 
-- The SmallEiffel standard library (lib_std) provides four implementations: 
-- ARRAY[E], FIXED_ARRAY[E], LINKED_LIST[E] and TWO_WAY_LINKED_LIST[E].
-- All implementations have exactly the same behavior. Switching from one 
-- implementation to another only change the memory used and the execution 
-- time.
--

inherit SAFE_EQUAL[E] redefine copy, is_equal, fill_tagged_out_memory end;

feature -- Indexing :

   lower: INTEGER is
         -- Minimum index.
      deferred
      end;

   upper: INTEGER is
         -- Maximum index.
      deferred
      end;

   frozen valid_index(index: INTEGER): BOOLEAN is
         -- True when `index' is valid (ie. inside actual 
         -- bounds of the collection).
      do
         Result := lower <= index and then index <= upper;
      ensure      
         Result = (lower <= index and then index <= upper);
      end;

feature -- Counting :

   count: INTEGER is
         -- Number of available indices.
      deferred
      ensure
         Result = upper - lower + 1
      end;

   is_empty: BOOLEAN is
         -- Is collection empty ?
      deferred
      ensure
	 Result = (count = 0)
      end;

   empty: BOOLEAN is
      obsolete "The new name of this feature is `is_empty'."
      do
         Result := is_empty;
      end;

feature -- Accessing :

   item, infix "@" (index: INTEGER): E is
         -- Item at the corresponding `index'.
      require
         valid_index(index)
      deferred
      end;

   first: like item is
         -- The very `first' item.
      require
         count >= 1
      deferred
      ensure
         Result = item(lower)
      end;
   
   last: like item is
         -- The `last' item.
      require
         not is_empty
      deferred
      ensure
         Result = item(upper)
      end;

feature -- Writing :

   put(element: like item; index: INTEGER) is
         -- Make `element' the item at `index'.
      require
         valid_index(index)
      deferred
      ensure
         item(index) = element;
         count = old count
      end;

   swap(i1, i2: INTEGER) is
         -- Swap item at index `i1' with item at index `i2'.
      require
         valid_index(i1);
         valid_index(i2)
      local
         tmp: like item;
      do
         tmp := item(i1);
         put(item(i2),i1);
         put(tmp,i2);
      ensure
         item(i1) = old item(i2);
         item(i2) = old item(i1);
         count = old count
      end;

   set_all_with(v: like item) is
         -- Set all items with value `v'.
      deferred
      ensure
         count = old count
      end;
   
   set_slice_with(v: like item; lower_index, upper_index: INTEGER) is
         -- Set all items in range [`lower_index' .. `upper_index'] with `v'.
      require
         lower_index <= upper_index;
         valid_index(lower_index);
         valid_index(upper_index)
      local
         i: INTEGER;
      do
         from  
            i := lower_index;
         until
            i > upper_index
         loop
            put(v,i);
            i := i + 1;
         end;      
      ensure
         count = old count
      end;
   
   clear_all is
         -- Set every item to its default value.
         -- The `count' is not affected (see also `clear').
      local
         value: like item;
      do
         set_all_with(value);
      ensure
	 stable_upper: upper = old upper
	 stable_lower: lower = old lower
         all_default
      end;
   
feature -- Adding :

   add_first(element: like item) is
         -- Add a new item in first position : `count' is increased by 
         -- one and all other items are shifted right.
      deferred
      ensure
         first = element;
         count = 1 + old count;
         lower = old lower;
         upper = 1 + old upper
      end;

   add_last(element: like item) is
         -- Add a new item at the end : `count' is increased by one.
      deferred
      ensure
         last = element;
         count = 1 + old count;
         lower = old lower;
         upper = 1 + old upper
      end;

   add(element: like item; index: INTEGER) is
         -- Add a new `element' at rank `index' : `count' is increased 
         -- by one and range [`index' .. `upper'] is shifted right
         -- by one position.
      require
         lower <= index;
         index <= upper + 1
      deferred
      ensure
         item(index) = element;
         count = 1 + old count;
         upper = 1 + old upper
      end;

   append_collection(other: COLLECTION[E]) is
         -- Append `other' to Current.
      require
         other /= Void
      local
         i: INTEGER;
      do
         from
            i := other.lower;
         until
            i > other.upper
         loop
            add_last(other.item(i));
            i := i + 1;
         end;
      ensure
         count = other.count + old count
      end;

feature -- Modification :

   force(element: E; index: INTEGER) is
         -- Make `element' the item at `index', enlarging the collection if 
         -- necessary (new bounds except `index' are initialized with 
         -- default values).
      require
         index >= lower
      deferred
      ensure
         upper = index.max(old upper);
         item(index) = element
      end;

   copy(other: like Current) is
	 -- Reinitialize by copying all the items of `other'.
      deferred
      end;

   from_collection(model: COLLECTION[like item]) is
	 -- Initialize the current object with the contents of `model'.
      require
         model /= Void
      deferred
      ensure
         count = model.count;
      end;

feature -- Removing :

   remove_first is
         -- Remove the `first' element of the collection.
      require
         not is_empty
      deferred
      ensure
         count = (old count) - 1;
         (lower = (old lower) + 1) xor (upper = (old upper) - 1) 
      end;

   remove(index: INTEGER) is
         -- Remove the item at position `index'. Followings items
         -- are shifted left by one position.
      require
         valid_index(index)
      deferred
      ensure
         count = (old count) - 1;
         upper = (old upper) - 1;
      end;

   remove_last is
         -- Remove the `last' item.
      require
         not is_empty;
      deferred
      ensure
         count = (old count) - 1;
         upper = (old upper) - 1
      end;

   clear is
         -- Discard all items in order to make it `is_empty'.
         -- See also `clear_all'.
      deferred
      ensure
         is_empty;
      end;

feature -- Looking and Searching :

   has(x: like item): BOOLEAN is
         -- Look for `x' using `equal' for comparison.
         -- Also consider `fast_has' to choose the most appropriate.
      do
         Result := valid_index(index_of(x));
      end;
   
   fast_has(x: like item): BOOLEAN is
         -- Look for `x' using basic `=' for comparison.
         -- Also consider `has' to choose the most appropriate.
      do
         Result := valid_index(fast_index_of(x));
      end;
   
   index_of(element: like item): INTEGER is
         -- Give the index of the first occurrence of `element' using
         -- `is_equal' for comparison.
         -- Answer `upper + 1' when `element' is not inside.
         -- Also consider `fast_index_of' to choose the most appropriate.
      deferred
      ensure
         lower <= Result;
         Result <= upper + 1;
         Result <= upper implies equal(element,item(Result));
      end;
   
   fast_index_of(element: like item): INTEGER is
         -- Give the index of the first occurrence of `element' using
         -- basic `=' for comparison.
         -- Answer `upper + 1' when `element' is not inside.
         -- Also consider `index_of' to choose the most appropriate.
      deferred
      ensure
         lower <= Result;
         Result <= upper + 1;
         Result <= upper implies element = item(Result);
      end;
   
feature -- Looking and comparison :

   is_equal(other: like Current): BOOLEAN is
	 -- Do both collections have the same `lower', `upper', and 
	 -- items?
	 -- The basic `=' is used for comparison of items.
	 -- See also `is_equal_map'.
      deferred
      ensure then
	 Result implies (lower = other.lower and upper = other.upper)
      end;

   is_equal_map(other: like Current): BOOLEAN is
	 -- Do both collections have the same `lower', `upper', and 
	 -- items?
	 -- Feature `is_equal' is used for comparison of items.
	 -- See also `is_equal'.
      deferred
      ensure then
	 Result implies (lower = other.lower and upper = other.upper)
      end;

   all_default: BOOLEAN is
         -- Do all items have their type's default value?
      deferred
      end;

   frozen all_cleared: BOOLEAN is
      obsolete "The new name of this feature is `all_default'."
      do
	 Result := all_default;
      end;

   same_items(other: COLLECTION[E]): BOOLEAN is
	 -- Do both collections have the same items? The basic `=' is used 
	 -- for comparison of items and indices are not considered (for 
	 -- example this routine may yeld true with `Current' indexed in 
	 -- range [1..2] and `other' indexed in range [2..3]).
      require
	 other /= Void
      local
	 i, j: INTEGER;
      do
	 if count = other.count then
	    from
	       Result := true;
	       i := lower;
	       j := other.lower;
	    until
	       not Result or else i > upper
	    loop
	       Result := item(i) = other.item(i);
	       i := i + 1;
	       j := j + 1;
	    end;
	 end;
      ensure
	 Result implies count = other.count
      end;

   nb_occurrences(element: like item): INTEGER is
         -- Number of occurrences of `element' using `equal' for comparison.
         -- Also consider `fast_nb_occurrences' to choose the most appropriate.
      deferred
      ensure
         Result >= 0
      end;
      
   fast_nb_occurrences(element: like item): INTEGER is
         -- Number of occurrences of `element' using basic `=' for comparison.
         -- Also consider `nb_occurrences' to choose the most appropriate.
      deferred
      ensure
         Result >= 0;
      end;
      
feature -- Printing :

   frozen fill_tagged_out_memory is
      local
         i: INTEGER;
         v: like item;
      do
         tagged_out_memory.append("lower: "); 
         lower.append_in(tagged_out_memory);
         tagged_out_memory.append(" upper: "); 
         upper.append_in(tagged_out_memory);
         tagged_out_memory.append(" [");
         from  
            i := lower;
         until
            i > upper or else tagged_out_memory.count > 2048
         loop
            v := item(i);
            if v = Void then
               tagged_out_memory.append("Void");
            else
               v.out_in_tagged_out_memory;
            end;
            if i < upper then
               tagged_out_memory.extend(' ');
            end;
            i := i + 1;
         end;
         if i <= upper then
            tagged_out_memory.append(" ..."); 
         end;
         tagged_out_memory.extend(']'); 
      end;

feature -- Other Features :

   get_new_iterator: ITERATOR[E] is
      deferred
      end;

   replace_all(old_value, new_value: like item) is
         -- Replace all occurrences of the element `old_value' by `new_value' 
         -- using `equal' for comparison.
         -- See also `fast_replace_all' to choose the apropriate one.
      deferred
      ensure
         count = old count;
         nb_occurrences(old_value) = 0
      end;
   
   fast_replace_all(old_value, new_value: like item) is
         -- Replace all occurrences of the element `old_value' by `new_value' 
         -- using operator `=' for comparison.
         -- See also `replace_all' to choose the apropriate one.
      deferred
      ensure
         count = old count;
         fast_nb_occurrences(old_value) = 0
      end;

   move(lower_index, upper_index, distance: INTEGER) is
         -- Move range `lower_index' .. `upper_index' by `distance' 
         -- positions. Negative distance moves towards lower indices.
         -- Free places get default values.
      require
         lower_index <= upper_index;
         valid_index(lower_index);
         valid_index(lower_index + distance);
         valid_index(upper_index);
         valid_index(upper_index + distance)
      local
         default_value: like item;
         i: INTEGER;
      do
         if distance = 0 then
         elseif distance < 0 then
            from  
               i := lower_index;
            until
               i > upper_index
            loop
               put(item(i),i + distance);
               put(default_value,i);
               i := i + 1;
            end;
         else
            from  
               i := upper_index;
            until
               i < lower_index
            loop
               put(item(i),i + distance);
               put(default_value,i);
               i := i - 1;
            end;
         end;
      ensure
         count = old count
      end;

   slice(min, max: INTEGER): like Current is
         -- New collection consisting of items at indexes in [`min'..`max']. 
         -- Result has the same dynamic type as `Current'.
	 -- The `lower' index of the `Result' is the same as `lower'.
      require
         lower <= min;
         max <= upper;
         min <= max + 1
      deferred
      ensure
         same_type(Result);
         Result.count = max - min + 1;
         Result.lower = lower
      end;

   reverse is
	 -- Reverse the order of the elements.
      local
	 i, j: INTEGER;
      do
	 from
	    i := lower;
	    j := upper;
	 until
	    i >= j
	 loop
	    swap(i,j);
	    i := i + 1;
	    j := j - 1;
	 end;
      ensure 
	 count = old count
      end;

invariant

   valid_bounds: lower <= upper + 1;

end -- COLLECTION[E]

