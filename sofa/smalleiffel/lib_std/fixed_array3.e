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
class FIXED_ARRAY3[E]
   --   
   -- Resizable three dimensional array.
   -- Unlike ARRAY3, the `lower1', `lower2' and `lower3' bounds are 
   -- frozen to 0. Thus, one can expect better performances.
   --
   -- Initially written by Jean-Philippe Caillaut in Mai 1999
   --
   
inherit COLLECTION3[E];
   
creation
   make, copy, from_collection3, from_collection, from_model
   
feature
   
   upper1, count1, upper2, count2, upper3, count3, count: INTEGER;
   
feature {NONE}

   count2x3: INTEGER;
         -- To speed up access, this value is always equal to
         -- `count2' * `count3'

feature {FIXED_ARRAY3}
   
   storage: NATIVE_ARRAY[E];
   
   capacity: INTEGER; -- of `storage'.

feature
   
   lower1: INTEGER is 0;      

   lower2: INTEGER is 0;      

   lower3: INTEGER is 0;
      
   make(new_count1, new_count2, new_count3 : INTEGER) is
	 -- Create or reset `Current' with new dimensions.
	 -- All elements are set to the default value of type E.
      require
	 new_count1 > 0;
         new_count2 > 0;
         new_count3 > 0
      do
	 count1 := new_count1;
	 upper1 := new_count1 - 1;
	 count2 := new_count2;
	 upper2 := new_count2 - 1;	 
         count3 := new_count3;
         count2x3 := count2 * count3;
         upper3 := new_count3 - 1;       
         count := count1 * count2x3;
	 if capacity < count then
	    capacity := count;
	    storage := storage.calloc(capacity);
	 else
	    storage.clear_all(capacity - 1);
	 end;
      ensure
	 count1 = new_count1;
	 count2 = new_count2;
         count3 = new_count3;
	 all_default
      end;
   
   from_collection3(model: COLLECTION3[like item]) is
	 -- Uses the `model' to update Current.
      local
         i, j, k: INTEGER;
      do
         make(model.upper1+1, model.upper2+1, model.upper3+1);
	 from
	    i := 0;
	 until
	    i > upper1
	 loop
	    from
	       j := 0;
	    until
	       j > upper2
	    loop
               from
                  k := 0;
               until
                  k > upper3
               loop
                  put(model.item(i,j,k),i,j,k);
                  k := k + 1;
               end
	       j := j + 1;
	    end
	    i := i + 1;
	 end
      end;

   from_collection(contents: COLLECTION[E];
        new_count1, new_count2, new_count3: INTEGER) is
         --  Reset all bounds using `new_count#i'.
	 --  Copy all elements of `contents', line by line into Current.
      require
         new_count1 >= 0;
         new_count2 >= 0;
         new_count3 >= 0;
         contents.count = new_count1 * new_count2 * new_count3
      local
         i: INTEGER;
      do
         make(new_count1, new_count2, new_count3);
	 from 
	    i := 0  
	 until
	    i >= count
	 loop
	    storage.put(contents.item(contents.lower + i),i);
            i := i + 1;
	 end
      ensure
         line_maximum = new_count1 - 1;
         column_maximum = new_count2 - 1;
         depth_maximum = new_count3 - 1;
         count = contents.count
      end

   from_model(model: COLLECTION[COLLECTION[COLLECTION[E]]]) is
         -- The `model' is used to fill line by line the COLLECTION3.
         -- Assume all sub-collections of have the same indexing.
      local
         line, column, depth, n: INTEGER;
      do
         make(model.upper - model.lower + 1,
              model.first.upper - model.first.lower + 1,
              model.first.first.upper - model.first.first.lower + 1);
	 from
	    line := model.lower;
	 until
	    line > model.upper
	 loop
	    from
	       column := model.first.lower
	    until
	       column > model.first.upper
	    loop
               from
                  depth := model.first.first.lower
               until
                  depth > model.first.first.upper
               loop
                  storage.put(model.item(line).item(column).item(depth),n);
                  n := n + 1;
                  depth := depth + 1;
               end;
	       column := column + 1;
	    end;
	    line := line + 1;
	 end;
      ensure
         line_maximum = model.upper - model.lower;
         column_maximum = model.first.upper - model.first.lower;
         depth_maximum = model.first.first.upper - model.first.first.lower
      end;


feature -- Implementation of others feature from COLLECTION3 :

   item(line, column, depth: INTEGER): E is
      do
         Result := storage.item(line * count2x3 + column * count3 + depth);
      end;
   
   put(x: like item; line, column, depth: INTEGER) is
      do
         storage.put(x,line * count2x3 + column * count3 + depth);
      end;
   
   force(element: like item; line, column, depth : INTEGER) is
      do
         if not valid_index(line, column, depth) then
            resize(line.max(upper1) + 1,
                   column.max(upper2) + 1,
                   depth.max(upper3) + 1);
	 end;
         put(element,line,column,depth);
      end;

   copy(other: like Current) is
      do
	 count1 := other.count1;
	 upper1 := count1 - 1;
	 count2 := other.count2;
	 upper2 := count2 - 1;
         count3 := other.count3;
         count2x3 := count2 * count3;
         upper3 := count3 - 1;
         count := count1 * count2x3;
	 if capacity < count then
	    capacity := count;
	    storage := storage.calloc(capacity);
	 end;
	 storage.copy_from(other.storage, count - 1);
      end;
   
   is_equal(other: like Current): BOOLEAN is
      do
	 if other = Current then
	    Result := true;
	 elseif upper1 /= other.upper1 then
	 elseif upper2 /= other.upper2 then
         elseif upper3 /= other.upper3 then
	 else
	    Result := storage.memcmp(other.storage,count);
	 end;
      end;

   sub_collection3(line_min, line_max, column_min, column_max,
                   depth_min, depth_max: INTEGER): like Current is
      local
         i, j, k, n: INTEGER;
      do
         !!Result.make(line_max - line_min + 1,
                       column_max - column_min + 1,
                       depth_max - depth_min + 1);
	 from
            i := line_min;
	    k := 0;
	 until
	    i > line_max
	 loop
	    from
               j := column_min;
	    until
	       j > column_max
	    loop
               from
                  k := depth_min;
               until
                  k > depth_max
               loop
                  Result.storage.put(item(i,j,k),n);
                  n := n + 1;
                  k := k + 1;
               end;
               j := j + 1;
	    end;
	    i := i + 1;
	 end;
      ensure
         Result.upper1 = line_max - line_min;
         Result.upper2 = column_max - column_min;
         Result.upper3 = depth_max - depth_min;
      end;

feature -- Writing :
   
   set_all_with(x: E) is
	 --  All element are set with the value x.
      do
	 storage.set_all_with(x,count - 1)
      end;

   all_default: BOOLEAN is
      do
	 result := storage.all_default(count - 1);
      end;
   
   slice(l1,up1,l2,up2,l3,up3: INTEGER): like Current is
	 -- Create a new collection initialized with elements of
	 -- range `low'..`up'. Result has the same dynamic type 
	 -- as Current collection.
      local
         line, column, depth : INTEGER;
	 k : INTEGER;
      do
	 from 
            !!Result.make((up1 - l1) + 1,(up2 - l2) + 1,(up3 - l3) + 1);
            line := l1;
	 until 
            line > up1
	 loop 
	    from 
               column := l2;
	    until 
               column > up2
	    loop 
               from 
                  depth := l3;
               until 
                  depth > up3
               loop 
                  Result.put(item(line,column,depth),
                             line - l1,
                             column - l2,
                             depth - l3);
                  depth := depth + 1;
               end;
               column := column + 1;
	    end; 
            line := line + 1;
	 end; 
      end; -- slice
   
   set_slice(element: like item;  l1,up1,l2,up2,l3,up3: INTEGER) is
         -- Set all the elements in the 
         -- range [(l1,up1),(l2,up2),(l3,up3)] of
         -- Current with the element 'element'.
      local
         i,j,k : INTEGER;
      do
	 from 
            i := l1 * count2x3;
         until 
            i > up1 * count2x3
         loop 
            from 
               j := l2 * count3;
            until 
               j > up2 * count3
            loop 
               from 
                  k := l3;
               until 
                  k > up3
               loop 
                  storage.put(element,i + j + k);
                  k := k + 1;
               end;
               j := j + count3;
            end; 
            i := i + count2x3;
         end; 
      end;

   swap(line1, column1, depth1, line2, column2, depth2 : INTEGER) is
      local
	 tmp: like item;
         c3, c2x3, index1, index2 : INTEGER
      do
	 c3 := count3;
         c2x3 := count2x3;
         index1 := line1 * c2x3 + column1 * c3 + depth1;
         index2 := line2 * c2x3 + column2 * c3 + depth2;
	 tmp := storage.item( index1);	 
         storage.put(storage.item(index2), index1);
	 storage.put(tmp,index2);
      end
   
feature -- Looking and comparison :

   nb_occurrences(elt: E): INTEGER is
	 -- Number of occurrences using `equal'.
         -- See also `fast_nb_occurrences' to choose
	 -- the apropriate one.
      do
         Result := storage.nb_occurrences(elt,count - 1);
      end;
      
   fast_nb_occurrences(elt: E): INTEGER is
	 -- Number of occurrences using `='.
      do
	 Result := storage.fast_nb_occurrences(elt,count - 1);
      end;

feature -- Resizing :

   resize(new_count1 , new_count2, new_count3: INTEGER) is
      require
	 new_count1 > 0;
	 new_count2 > 0;
         new_count3 > 0
      local
	 tmp: like Current;
         l, c, d: INTEGER;
      do
         !!tmp.make(new_count1, new_count2, new_count3);
         -- It may be possible to avoid this creation when :
	 --    new `capacity' <= old `capacity'
	 from
	    l := line_maximum;
	 until
	    l < 0
	 loop
	    from
	       c := column_maximum;
	    until
	       c < 0
	    loop
               from
                  d := depth_maximum;
               until
                  d < 0
               loop
                  if tmp.valid_index(l,c,d) then
                     tmp.put(item(l,c,d),l,c,d);
                  end;
                  d := d - 1;
	       end;
	       c := c - 1;
	    end;
	    l := l - 1;
	 end;
	 standard_copy(tmp);
      ensure
	 upper1 = new_count1 - 1;
	 count1 = new_count1;	 
	 upper2 = new_count2 - 1;
	 count2 = new_count2;
         upper3 = new_count3 - 1;
         count3 = new_count3;
         count = new_count1 * new_count2 * new_count3
      end;

feature -- Looking and Searching :

   has(x: like item): BOOLEAN is
	 -- Look for `x' using `equal' for comparison.      
      do
	 Result := storage.index_of(x,count-1) <= (count-1);
      end;  -- has
   
   fast_has(x: like item): BOOLEAN is
	 -- Same as `has' but use `=' for comparison      
      do
	 Result := storage.fast_index_of(x,count - 1) <= (count - 1);
      end; -- fast_has

feature -- Other features :
   
   replace_all(old_value, new_value: like item) is
      do
	 storage.replace_all(old_value,new_value,count - 1);
      end;
	 
   fast_replace_all(old_value, new_value: like item) is
      do
	 storage.fast_replace_all(old_value,new_value,count - 1);
      end;

feature {COLLECTION3}

   same_as(other: COLLECTION3[E]): BOOLEAN is
      do
         Result := other.same_as_fixed_array3(Current);
      end;

   same_as_array3(other: ARRAY3[E]): BOOLEAN is
      do
	 Result := standard_same_as(other);
      end;

   same_as_fixed_array3(other: FIXED_ARRAY3[E]): BOOLEAN is
      do
	 Result := standard_same_as(other);
      end;

invariant

   count1 = upper1 + 1;
   
   count2 = upper2 + 1;

   count3 = upper3 + 1;

   count = count1 * count2 * count3;

   count2x3 = count2 * count3;

   capacity >= count;

end -- FIXED_ARRAY3[E]
