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
class FIXED_ARRAY2[E]
   --   
   -- Resizable two dimensional array.
   -- Unlike ARRAY2, the `lower1' bound and the `lower2' bound are 
   -- frozen to 0. Thus, one can expect better performances.
   --
   
inherit COLLECTION2[E];
   
creation
   make, copy, from_collection2, from_collection, from_model
   
feature
   
   upper1, count1, upper2, count2, count: INTEGER;
   
feature {FIXED_ARRAY2}
   
   storage: NATIVE_ARRAY[E];
   
   capacity : INTEGER; -- of `storage'.

feature
   
   lower1: INTEGER is 0;      

   lower2: INTEGER is 0;      
   
feature
   
   make(new_count1 , new_count2 : INTEGER) is
         -- Create or reset Current with new dimensions.
         -- All elements are set to the default value of type E.
      require
         new_count1 > 0;
         new_count2 > 0
      do
         count1 := new_count1;
         upper1 := new_count1 - 1;
         count2 := new_count2;
         upper2 := new_count2 - 1;
         count := count1 * count2;
         if capacity < count then
            capacity := count;
            storage := storage.calloc(capacity);
         else
            storage.clear_all(capacity - 1);
         end;
      ensure
         count1 = new_count1;
         count2 = new_count2;
         all_default
      end;
   
   from_collection(model: COLLECTION2[like item]) is
         -- Uses the `model' to update Current.
      local
         i, j: INTEGER;
      do
         make(model.upper1+1, model.upper2+1);
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
               put(model.item(i,j),i,j);
               j := j + 1;
            end
            i := i + 1;
         end
      end;

feature -- Implementation of others feature from COLLECTION2 :

   item(line, column: INTEGER): E is
      do
         Result := storage.item(line * count2 + column);
      end;
   
   put(x: like item; line, column: INTEGER) is
      do
         storage.put(x,line * count2 + column);
      end;
   
   force(element: like item; line , column : INTEGER) is
      do
         if not valid_index(line, column) then
            resize(line.max(upper1),column.max(upper2));
         end;
         put(element,line,column);
      end;

   copy(other: like Current) is
      do
         count1 := other.count1;
         upper1 := count1 - 1;
         count2 := other.count2;
         upper2 := count2 - 1;
         count := count1 * count2;
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
         else
            Result := storage.memcmp(other.storage,count);
         end;
      end;

feature -- Writing :
   
   set_all_with(x: E) is
         --  All element are set with the value x.
      do
         storage.set_all_with(x,count - 1)
      ensure
         count = old count
      end; -- set_all_with

   all_default: BOOLEAN is
      do
         result := storage.all_default(count - 1);
      end;
   
   slice(l1,up1,l2,up2: INTEGER): like Current is
         -- Create a new collection initialized with elements of
         -- range `low'..`up'. Result has the same dynamic type 
         -- as Current collection.
      local
         ligne,colonne : INTEGER;
         k : INTEGER;
      do
         from 
            !!Result.make((up1 - l1) + 1,(up2 - l2) + 1);
            ligne := l1;
         until 
            ligne > up1
         loop 
            from 
               colonne := l2;
            until 
               colonne > up2
            loop 
               Result.put(item(ligne,colonne),ligne - l1,colonne - l2);
               colonne := colonne + 1;
            end; 
            ligne := ligne + 1;
         end; 
      end; -- slice
   
   set_slice(element: like item;  l1,up1,l2,up2: INTEGER) is
    -- Set all the elements in the 
    -- range [(l1,up1),(l2,up2)] of
    -- Current with the element 'element'.

      local
         i,j : INTEGER;
      do
         from 
            i := l1 * count2;
         until 
            i > up1 * count2
         loop 
            from 
               j := l2;
            until 
               j > up2
            loop 
               storage.put(element,i + j);
               j := j + 1;
            end; 
            i := i + count2;
         end; 
      end;

   swap(line1, column1, line2, column2 : INTEGER) is
      local
         tmp: like item;
         c2, index1, index2 : INTEGER
      do
         c2 := count2;
         index1 := line1 * c2 + column1;
         index2 := line2 * c2 + column2;
         tmp := storage.item( index1);
         storage.put(storage.item(index2) ,index1);
         storage.put(tmp,index2);
      end
   
feature -- Looking and comparison :

   nb_occurrences(elt: E): INTEGER is
         -- Number of occurrences using `equal'.
         -- See also `fast_nb_occurrences' to chose
         -- the apropriate one.
      do
         Result := storage.nb_occurrences(elt,count - 1);
      ensure
         Result >= 0;
      end; -- nb_occurences
      
   fast_nb_occurrences(elt: E): INTEGER is
         -- Number of occurrences using `='.
      do
         Result := storage.fast_nb_occurrences(elt,count - 1);
      ensure
         Result >= 0;
      end; -- fast_nb_occurrences

feature -- Resizing :

   resize(new_count1 , new_count2: INTEGER) is
      require
         new_count1 > 0;
         new_count2 > 0
      local
         tmp: like Current;
         l, c: INTEGER;
      do
         !!tmp.make(new_count1, new_count2);
         -- It may be possible to avoid this ceation when :
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
               if tmp.valid_index(l,c) then
                  tmp.put(item(l,c),l,c);
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
         count = new_count1 * new_count2
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
         
   transpose is
         -- Transpose the Current array
      local
         i,j : INTEGER;
         oldu1 , oldu2 : INTEGER;
      do
         oldu1 := upper1;
         oldu2 := upper2;
         resize(upper2.max(upper1),upper2.max(upper1));
         from  
            i := 0;
         until 
            i > upper1 - 1
         loop
            from  
               j := i + 1;
            until 
               j > upper2
            loop
               swap(i,j,j,i);
               j := j + 1;
            end;
            i := i + 1;
         end;
         resize(oldu2,oldu1);
      end;

   to_external: POINTER is
         -- Gives C access to the internal `storage' (may be dangerous).
      do
         Result := storage.to_external;
      end;
   
feature {COLLECTION2}

   same_as(other: COLLECTION2[E]): BOOLEAN is
      do
         Result := other.same_as_fixed_array2(Current);
      end;

   same_as_array2(other: ARRAY2[E]): BOOLEAN is
      do
         Result := standard_same_as(other);
      end;

   same_as_fixed_array2(other: FIXED_ARRAY2[E]): BOOLEAN is
      do
         Result := standard_same_as(other);
      end;

invariant

   count1 = upper1 + 1;
   
   count2 = upper2 + 1;

   count = count1 * count2;

   capacity >= count;

end -- FIXED_ARRAY2[E]
