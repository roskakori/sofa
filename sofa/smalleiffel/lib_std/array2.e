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
class ARRAY2[E]
   --
   -- General prurpose, resizable, two dimensional array.
   --

inherit COLLECTION2[E];
   
creation 
   make, copy, from_collection2, from_collection, from_model

feature 
   
   lower1, lower2, upper1, upper2: INTEGER;
   
feature {ARRAY2}
   
   storage: NATIVE_ARRAY[E];
         -- To store elements line by line.
   
   capacity: INTEGER;
         -- Number of elements in `storage'.
   
feature -- Creation / modification :
   
   make(line_min, line_max, column_min, column_max: INTEGER) is
         -- Reset all bounds `line_minimum' / `line_maximum' / `column_minimum' and
         -- `column_maximum' using arguments as new values.
         -- All elements are set to the default value of type E.
      require
         line_min <= line_max;
         column_min <= column_max
      do
         lower1 := line_min;
         upper1 := line_max;
         lower2 := column_min;
         upper2 := column_max;
         if capacity >= count then
            storage.clear_all(count - 1);
         else
            capacity := count;
            storage := storage.calloc(count);
         end;
      ensure
         line_minimum = line_min;
         line_maximum = line_max;
         column_minimum = column_min;
         column_maximum = column_max;
      end;
   
   from_collection2(model: COLLECTION2[like item]) is
      local
         i, j: INTEGER;
      do
         make(model.line_minimum,
              model.line_maximum,
              model.column_minimum,
              model.column_maximum);
         from
            i := line_minimum;
         until
            i > line_maximum
         loop
            from
               j := column_minimum;
            until
               j > column_maximum
            loop
               put(model.item(i,j),i,j);
               j := j + 1;
            end;
            i := i + 1;
         end;
      ensure then
         lower1 = model.lower1;
         lower2 = model.lower2
      end;
   
   from_collection(contents: COLLECTION[E];
                   line_min, line_max, column_min, column_max: INTEGER) is
         --  Reset all bounds using `line_min', `line_max', `column_min',
         --  and `column_max' .
         --  Copy all elements of `contents', line by line into Current.
      require
         line_min <= line_max;
         column_min <= column_max;      
         contents.count = (line_max - line_min + 1) * (column_max - column_min +1)
      local
         i: INTEGER 
      do
         make(line_min,line_max,column_min,column_max)
         from 
            i := 0  
         until
            i >= count
         loop
            storage.put(contents.item(contents.lower + i),i);
            i := i + 1; 
         end
      ensure
         line_minimum = line_min;
         line_maximum = line_max;
         column_minimum = column_min;
         column_maximum = column_max;
         count = contents.count
      end

   from_model(model: COLLECTION[COLLECTION[E]]) is
         -- The `model' is used to fill line by line the COLLECTION2.
         -- Assume all sub-collections of `model' have the same indexing.
      local
         line, column: INTEGER;
      do
         make(model.lower,
              model.upper,
              model.first.lower,
              model.first.upper);
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
               put(model.item(line).item(column),line,column);
               column := column + 1;
            end;
            line := line + 1;
         end;
      ensure
         line_minimum = model.lower;
         line_maximum = model.upper;
         column_minimum = model.first.lower;
         column_maximum = model.first.upper
      end;
   
feature -- Resizing :

   resize(line_min, line_max, column_min, column_max: INTEGER) is
         -- Resize bounds of the Current array
      require
         line_max >= line_min;
         column_max >= column_min;
      local
         tmp: like Current;
         l, c: INTEGER;
      do
         !!tmp.make(line_min, line_max, column_min, column_max);
         -- It may be possible to avoid this ceation when :
         --    new `capacity' <= old `capacity'
         from
            l := lower1;
         until
            l > line_maximum
         loop
            from
               c := lower2;
            until
               c > column_maximum
            loop
               if tmp.valid_index(l,c) then
                  tmp.put(item(l,c),l,c);
               end;
               c := c + 1;
            end;
            l := l + 1;
         end;
         standard_copy(tmp);
      ensure
         line_minimum = line_min;
         line_maximum = line_max;
         column_minimum = column_min;
         column_maximum = column_max;
      end;
   
feature -- Implementation of others feature from COLLECTION2 :
   
   item(line, column: INTEGER): E is
      do
         Result := storage.item((line - lower1) * count2 + column - lower2);
      end;

   put(element: like item; line, column: INTEGER) is
      do
         storage.put(element,(line - lower1) * count2 + column - lower2);
      end;
   
   count1: INTEGER is
      do
         Result := upper1 - lower1 + 1;
      end;
   
   count2: INTEGER is
      do
         Result := upper2 - lower2 + 1;
      end;

   count: INTEGER is
      do
         Result := count1 * count2;
      end;
   
   force(x: like item; line, column: INTEGER) is
      require
         true
      do
         if not valid_index(line,column) then
            resize(line.min(lower1),
                   line.max(upper1),
                   column.min(lower2),
                   column.max(upper2));
         end;
         put(x,line,column);
      end;
   
   set_all_with(element: E) is
      do
         storage.set_all_with(element,count - 1);
      end;
   
   replace_all(old_value, new_value: like item) is
      do
         storage.replace_all(old_value,new_value,count - 1);
      end;
         
   fast_replace_all(old_value, new_value: like item) is
      do
         storage.fast_replace_all(old_value,new_value,count - 1);
      end;
         
   sub_collection2(line_min, line_max, column_min, column_max: INTEGER): like Current is
      require  
         valid_index(line_min,line_max) 
         valid_index(column_min,column_max)
      local
         i, j, k: INTEGER;
      do
         !!Result.make(line_min,line_max,column_min,column_max);
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
               Result.storage.put(item(i,j),k);
               j := j + 1;
               k := k + 1;
            end;
            i := i + 1;
         end;
      ensure
         Result.lower1 = line_min; 
         Result.lower2 = column_min; 
         Result.upper1 = line_max;
         Result.upper2 = column_max;
      end;

feature --  Looking and comparison :

   nb_occurrences(elt: E): INTEGER is
         -- Number of occurrences using `equal'.
         -- See also `fast_nb_occurrences' to chose
         -- the apropriate one.
      do
         Result := storage.nb_occurrences(elt,count - 1);
      ensure
         Result >= 0;
      end;
   
   fast_nb_occurrences(elt: E): INTEGER is
         -- Number of occurrences using `='.
      do
         Result := storage.fast_nb_occurrences(elt,count - 1);
      ensure
         Result >= 0;
      end;

   has(x: like item): BOOLEAN is
         -- Search if a element x is in the array using `equal'.
         -- See also `fast_has' to chose the apropriate one.
      do
         Result := storage.index_of(x,count - 1) <= count - 1;
      end;
   
   fast_has(x: like item): BOOLEAN is
         --  Search if a element x is in the array using `='.
      do
         Result := storage.fast_index_of(x,count - 1) <= count -1;
      end;
   
   all_default: BOOLEAN is
      do
         result := storage.all_default(count - 1);
      end;

   swap(line1, column1, line2, column2 : INTEGER) is
      local
         tmp: like item;
         c2, index1, index2: INTEGER;
      do
         c2 := count2;
         index1 := (line1 - lower1) * c2 + column1 - lower2;
         index2 := (line2 - lower1) * c2 + column2 - lower2;
         tmp := storage.item(index1);
         storage.put(storage.item(index2),index1);
         storage.put(tmp,index2);
      end

   copy(other: like Current) is
      do
         lower1 := other.lower1;
         upper1 := other.upper1;
         lower2 := other.lower2;
         upper2 := other.upper2;
         if capacity < count then
            capacity := count;
            storage := storage.calloc(count);
         end;
         storage.copy_from(other.storage, count - 1);
      end;
   
   is_equal(other: like Current): BOOLEAN is
      do
         if other = Current then
            Result := true;
         elseif lower1 /= other.lower1 then
         elseif lower2 /= other.lower2 then
         elseif upper1 /= other.upper1 then
         elseif upper2 /= other.upper2 then
         else
            Result := storage.memcmp(other.storage,count);
         end;
      end;

feature -- Only for ARRAY2 :

   transpose is
         -- Transpose the Current array
      local
         i,j : INTEGER;
         oldu1,oldu2 : INTEGER;
         oldl1,oldl2 : INTEGER;
      do
         oldu1 := line_maximum;
         oldu2 := column_maximum;
         oldl1 := lower1;
         oldl2 := lower2;
         resize(lower1.min(lower2),
                line_maximum.max(column_maximum),
                lower1.min(lower2),
                line_maximum.max(column_maximum));
         from
            i := lower1;
         until 
            i > line_maximum
         loop
            from 
               j := i + 1;
            until 
               j > column_maximum
            loop
               swap(i,j,j,i);
               j := j + 1;
            end;
            i := i + 1;
         end;
         resize(oldl2,oldu2,oldl1,oldu1);
      ensure
         line_minimum = old column_minimum; 
         column_minimum = old line_minimum;
         line_maximum = old column_maximum; 
         column_maximum = old line_maximum;
         count = old count;
      end;

   to_external: POINTER is
         -- Gives C access to the internal `storage' (may be dangerous).
      do
         Result := storage.to_external;
      end;

feature {COLLECTION2}

   same_as(other: COLLECTION2[E]): BOOLEAN is
      do
         Result := other.same_as_array2(Current);
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

   count2 = upper2 - lower2 + 1;

   capacity >= count

end -- ARRAY2[E]
