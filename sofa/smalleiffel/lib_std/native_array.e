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
expanded class NATIVE_ARRAY[E]
--
-- This class gives access to the lowest level for arrays both
-- for the C language and Java language.
-- 
-- Warning : using this class makes your Eiffel code non
-- portable on other Eiffel systems.
-- This class may also be modified in further release for a better
-- interoperability between Java and C low level arrays.
--

feature -- Basic features :

   element_sizeof: INTEGER is
         -- The size in number of bytes for type `E'.
      external "SmallEiffel"
      end;

   calloc(nb_elements: INTEGER): like Current is
         -- Allocate a new array of `nb_elements' of type `E'.
         -- The new array is initialized with default values.
      require
         nb_elements > 0
      external "SmallEiffel"
      end;

   item(index: INTEGER): E is
         -- To read an `item'.
         -- Assume that `calloc' is already done and that `index'
         -- is the range [0 .. nb_elements-1].
      external "SmallEiffel"
      end;

   put(element: E; index: INTEGER) is
         -- To write an item.
         -- Assume that `calloc' is already done and that `index'
         -- is the range [0 .. nb_elements-1].
      external "SmallEiffel"
      end;

feature 

   realloc(old_nb_elts, new_nb_elts: INTEGER): like Current is
         -- Assume Current is a valid NATIVE_ARRAY in range 
         -- [0 .. `old_nb_elts'-1]. Allocate a bigger new array in
         -- range [0 .. `new_nb_elts'-1].
         -- Old range is copied in the new allocated array.
         -- New items are initialized with default values.
      require
         is_not_null;
         old_nb_elts > 0;
         old_nb_elts < new_nb_elts
      do
         Result := calloc(new_nb_elts);
         Result.copy_from(Current,old_nb_elts - 1);
      end;

feature -- Comparison :

   memcmp(other: like Current; capacity: INTEGER): BOOLEAN is
         -- True if all elements in range [0..capacity-1] are
         -- identical using `equal'. Assume Current and `other' 
         -- are big enough. 
         -- See also `fast_memcmp'.
      require
         capacity > 0 implies other.is_not_null
      local
         i: INTEGER;
      do
         from
            i := capacity - 1;
         until
            i < 0 or else not equal_like(item(i),other.item(i))
         loop
            i := i - 1;
         end;
         Result := i < 0;
      end;

   fast_memcmp(other: like Current; capacity: INTEGER): BOOLEAN is
         -- Same jobs as `memcmp' but uses infix "=" instead `equal'.
      require
         capacity > 0 implies other.is_not_null
      local
         i: INTEGER;
      do
         from
            i := capacity - 1;
         until
            i < 0 or else item(i) /= other.item(i)
         loop
            i := i - 1;
         end;
         Result := i < 0;
      end;

   deep_memcmp(other: like Current; capacity: INTEGER): BOOLEAN is
         -- Same jobs as `memcmp' but uses `is_deep_equal' instead `equal'.
      local
         i: INTEGER;
	 e1, e2: like item;
      do
         from
            i := capacity - 1;
	    Result := true;
         until
            not Result or else i < 0
         loop
	    e1 := item(i);
	    e2 := other.item(i);
	    if e1 = e2 then
	    elseif e1 /= Void then
	       if e2 /= Void then
		  Result := e1.is_deep_equal(e2);
	       end;
	    end;
            i := i - 1;
         end;
         Result := i < 0;
      end;

feature -- Searching :

   index_of(element: like item; upper: INTEGER): INTEGER is
         -- Give the index of the first occurrence of `element' using
         -- `is_equal' for comparison.
         -- Answer `upper + 1' when `element' is not inside.
      require
         upper >= -1
      do
         from  
         until
            Result > upper or else equal_like(element,item(Result))
         loop
            Result := Result + 1;
         end;
      end;

   fast_index_of(element: like item; upper: INTEGER): INTEGER is
         -- Same as `index_of' but use basic `=' for comparison.
      require
         upper >= -1
      do
         from  
         until
            Result > upper or else element = item(Result)
         loop
            Result := Result + 1;
         end;
      end;

   has(element: like item; upper: INTEGER): BOOLEAN is
         -- Look for `element' using `is_equal' for comparison.
         -- Also consider `has' to choose the most appropriate.
      require
         upper >= -1
      local
         i: INTEGER;
      do
         from
            i := upper;
         until
            Result or else i < 0
         loop
            Result := equal_like(element,item(i));
            i := i - 1;
         end;
      end;

   fast_has(element: like item; upper: INTEGER): BOOLEAN is
         -- Look for `element' using basic `=' for comparison.
         -- Also consider `has' to choose the most appropriate.
      require
         upper >= -1
      local
         i: INTEGER;
      do
         from
            i := upper;
         until
            i < 0 or else element = item(i)
         loop
            i := i - 1;
         end;
         Result := i >= 0;
      end;


feature -- Removing :

   remove_first(upper: INTEGER) is
         -- Assume `upper' is a valid index.
         -- Move range [1 .. `upper'] by 1 position left.
      require
         upper >= 0
      local
         i: INTEGER;
      do
         from 
         until
            i = upper
         loop
            put(item(i + 1),i);
            i := i + 1;
         end;
      end;

   remove(index, upper: INTEGER) is
         -- Assume `upper' is a valid index.
         -- Move range [`index' + 1 .. `upper'] by 1 position left.
      require
         index >= 0;
         index <= upper
      local
         i: INTEGER;
      do
         from 
            i := index;
         until
            i = upper
         loop
            put(item(i + 1),i);
            i := i + 1;
         end;
      end;

feature -- Replacing :

   replace_all(old_value, new_value: like item; upper: INTEGER) is
         -- Replace all occurences of the element `old_value' by `new_value' 
         -- using `is_equal' for comparison.
         -- See also `fast_replace_all' to choose the apropriate one.
      require
         upper >= -1
      local
         i: INTEGER;
      do
         from
            i := upper;
         until
            i < 0
         loop
            if equal_like(old_value,item(i)) then
               put(new_value,i);
            end;
            i := i - 1;
         end;
      end;


   fast_replace_all(old_value, new_value: like item; upper: INTEGER) is
         -- Replace all occurences of the element `old_value' by `new_value' 
         -- using basic `=' for comparison.
         -- See also `replace_all' to choose the apropriate one.
      require
         upper >= -1
      local
         i: INTEGER;
      do
         from
            i := upper;
         until
            i < 0
         loop
            if old_value = item(i) then
               put(new_value,i);
            end;
            i := i - 1;
         end;
      end;

feature -- Adding :

   copy_at(at: INTEGER; src: like Current; src_capacity: INTEGER) is
         -- Copy range [0 .. `src_capacity' - 1] of `src' to range 
	 -- [`at' .. `at + src_capacity'] of `Current'. 
	 -- No subscript checking.
      require
         at >= 0;
         src_capacity >= 0;
      local
         i1, i2: INTEGER;
      do
         from
            i1 := at;
         until
            i2 = src_capacity
         loop
            put(src.item(i2),i1);
            i2 := i2 + 1;
            i1 := i1 + 1;
         end;
      end;

   copy_slice(at: INTEGER; src: like Current; src_min, src_max: INTEGER) is
         -- Copy range [`src_min' .. `src_max'] of `src' to range 
         -- [`at' .. `at + src_max - src_min - 1'] of `Current'.
	 -- No subscript checking.
      require
         at >= 0;
         src_min <= src_max + 1
      local
         i1, i2: INTEGER;
      do
         from
            i1 := at;
	    i2 := src_min;
         until
            i2 > src_max
         loop
            put(src.item(i2),i1);
            i2 := i2 + 1;
            i1 := i1 + 1;
         end;
      end;

feature -- Other :

   set_all_with(v: like item; upper: INTEGER) is
         -- Set all elements in range [0 .. upper] with
         -- value `v'.
      local
         i: INTEGER;
      do
         from
            i := upper;
         until
            i < 0
         loop
            put(v,i);
            i := i - 1;
         end;
      end;

   clear_all(upper: INTEGER) is
         -- Set all elements in range [0 .. `upper'] with
         -- the default value.
      local
         v: E;
         i: INTEGER;
      do
         from
            i := upper;
         until
            i < 0
         loop
            put(v,i);
            i := i - 1;
         end;
      end;

   clear(lower, upper: INTEGER) is
         -- Set all elements in range [`lower' .. `upper'] with
         -- the default value
      require
         lower >= 0;
         upper >= lower
      local
         v: E;
         i: INTEGER;
      do
         from
            i := lower
         until
            i > upper
         loop
            put(v, i);
            i := i + 1;
         end
      end

   copy_from(model: like Current; upper: INTEGER) is
         -- Assume `upper' is a valid index both in Current and `model'.
      local
         i: INTEGER;
      do
         from
            i := upper;
         until
            i < 0
         loop
            put(model.item(i),i);
            i := i - 1;
         end;
      end;

   deep_twin_from(capacity: INTEGER): like Current is
	 -- To implement `deep_twin'. Allocate a new array of 
	 -- `capacity' initialized with `deep_twin'.
         -- Assume `capacity' is valid both in Current and `model'.
      require
	 capacity >= 0
      local
         i: INTEGER;
	 element: like item;
      do
	 if capacity > 0 then
	    from
	       Result := calloc(capacity);
	       i := capacity - 1;
	    until
	       i < 0
	    loop
	       element := item(i);
	       if element /= Void then
		  element := element.deep_twin;
	       end;
	       Result.put(element,i);
	       i := i - 1;
	    end;
	 end;
      end;

   move(lower, upper, offset: INTEGER) is
         -- Move range [`lower' .. `upper'] by `offset' positions.
         -- Freed positions are not initialized to default values.
      require
         lower >= 0;
         upper >= lower;
         lower + offset >= 0
      local
         i: INTEGER;
      do
         if offset = 0 then
         elseif offset < 0 then
            from
               i := lower;
            until
               i > upper
            loop
               put(item(i), i + offset);
               i := i + 1;
            end
         else
            from
               i := upper;
            until
               i < lower
            loop
               put(item(i), i + offset);
               i := i - 1;
            end
         end
      end

   nb_occurrences(element: like item; upper: INTEGER): INTEGER is
         -- Number of occurrences of `element' in range [0..upper]
         -- using `equal' for comparison.
         -- See also `fast_nb_occurrences' to chose the apropriate one.
      local
         i: INTEGER;
      do
         from  
            i := upper;
         until
            i < 0
         loop
            if equal_like(element,item(i)) then
               Result := Result + 1;
            end;
            i := i - 1;
         end;
      end;

   fast_nb_occurrences(element: like item; upper: INTEGER): INTEGER is
         -- Number of occurrences of `element' in range [0..upper]
         -- using basic "=" for comparison.
         -- See also `fast_nb_occurrences' to chose the apropriate one.
      local
         i: INTEGER;
      do
         from  
            i := upper;
         until
            i < 0
         loop
            if element = item(i) then
               Result := Result + 1;
            end;
            i := i - 1;
         end;
      end;

   all_default(upper: INTEGER): BOOLEAN is
         -- Do all items in range [0 .. `upper'] have their type's
	 -- default value?
      require
         upper >= -1
      local
         i: INTEGER;
         model: like item;
      do
         from
            Result := true;
            i := upper;
         until
            i < 0 or else not Result
         loop
            Result := model = item(i)
            i := i - 1;
         end;
      end;

   all_cleared(upper: INTEGER): BOOLEAN is
      obsolete "The new name of this feature is `all_default'."
      do
	 Result := all_default(upper);
      end;

feature -- Interfacing with C :

   to_external: POINTER is
         -- Gives access to the C pointer on the area of storage.
      do
         Result := to_pointer;
      end;

   from_pointer(pointer: POINTER): like Current is
         -- Convert `pointer' into Current type.
      external "SmallEiffel"
      end;

   is_not_null: BOOLEAN is
      do
         Result := to_pointer.is_not_null;
      end;

   is_not_void: BOOLEAN is
      obsolete "This feature will be soon removed. %
               %Since release -0.78, the new name for this feature %
               %is `is_not_null'. Please, update your code."
      do
         Result := is_not_null;
      end;

feature -- For C only :

   bytes_malloc(nb_bytes: INTEGER): like Current is
      obsolete "This dangerous feature will be soon removed. %
               %Please, update your code."
      external "C_InlineWithoutCurrent"
      alias "malloc"
      end;

feature {NONE}

   frozen equal_like(e1, e2: like item): BOOLEAN is
         -- Note: this feature is called to avoid calling `equal'
         -- on expanded types (no automatic conversion to 
         -- corresponding reference type).
      do
         if e1.is_basic_expanded_type then
            Result := e1 = e2;
         elseif e1.is_expanded_type then
            Result := e1.is_equal(e2);
         elseif e1 = e2 then
            Result := true;
         elseif e1 = Void or else e2 = Void then
         else
            Result := e1.is_equal(e2);
         end;
      end;

end -- NATIVE_ARRAY[E]

