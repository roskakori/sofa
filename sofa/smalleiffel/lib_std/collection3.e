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
deferred class COLLECTION3[E]
   -- 
   -- Abstract definition of a 3 dimensional collection of elements
   -- of type E. 
   -- 
   -- The SmallEiffel standard library (lib_std) provides two
   -- implementations : ARRAY3[E] and FIXED_ARRAY3[E].
   -- All implementations have exactly the same behavior. Switching 
   -- from one implementation to another only change the memory used
   -- and the execution time.
   --
   -- Initially written by Jean-Philippe Caillaut in Mai 1999
   --

inherit
   SAFE_EQUAL[E]
      undefine copy, is_equal
      redefine fill_tagged_out_memory
      end;
   
feature -- Indexing :
   
   lower1: INTEGER is
	 -- Lower index bound for dimension 1.
      deferred
      end;
   
   lower2: INTEGER is
	 -- Lower index bound for dimension 2.
      deferred
      end;
   
   lower3: INTEGER is
	 -- Lower index bound for dimension 3.
      deferred
      end;
   
   frozen line_minimum: INTEGER is
	 -- Equivalent of `lower1'.
      do
	 Result := lower1;
      end;
   
   frozen column_minimum: INTEGER is
	 -- Equivalent of `lower2'.
      do
	 Result := lower2;
      end;

   frozen depth_minimum: INTEGER is
         -- Equivalent of `lower3'.
      do
         Result := lower3;
      end;
   
   upper1: INTEGER is
	 -- Upper index bound for dimension 1.
      deferred
      end;
   
   upper2: INTEGER is
	 -- Upper index bound for dimension 2.
      deferred
      end;
   
   upper3: INTEGER is
	 -- Upper index bound for dimension 3.
      deferred
      end;
   
   frozen line_maximum: INTEGER is
	 -- Equivalent of `upper1'.
      do
	 Result := upper1;
      end;

   frozen column_maximum: INTEGER is
	 -- Equivalent of `upper2'.
      do
	 Result := upper2;
      end;
   
   frozen depth_maximum: INTEGER is
         -- Equivalent of `upper3'.
      do
         Result := upper3;
      end;
   
feature -- Reading :
   
   item(line, column, depth: INTEGER): E is
      require
         valid_index(line,column,depth);
      deferred
      end;
   
feature -- Writing :
   
   put(element: like item; line, column, depth: INTEGER) is
      require
         valid_index(line,column,depth)
      deferred
      ensure
         item(line,column,depth) = element
      end;

   force(element: like item; line, column, depth: INTEGER) is
         -- Put `element' at position (`line',`column',`depth').
         -- Collection is resized first when (`line',`column',`depth')
         -- is not inside current bounds. 
         -- New bounds are initialized with default values.
      require
	 line >= 0;
         column >= 0;
         depth >= 0
      deferred
      ensure
         item(line,column,depth) = element;
	 count >= old count
      end;

feature -- Index validity :
   
   frozen valid_line, valid_index1(line: INTEGER): BOOLEAN is
      do
	 Result := lower1 <= line and then line <= upper1;
      ensure
	 Result = (lower1 <= line and line <= upper1)
      end;
    
   frozen valid_column, valid_index2(column: INTEGER): BOOLEAN is
      do
	 Result := lower2 <= column and then column <= upper2;
      ensure
	 Result = (lower2 <= column and column <= upper2)
      end;

   frozen valid_depth, valid_index3(depth: INTEGER): BOOLEAN is
      do
         Result := lower3 <= depth and then depth <= upper3;
      ensure
         Result = (lower3 <= depth and depth <= upper3)
      end;
   
   frozen valid_index(line, column, depth: INTEGER): BOOLEAN is
      do
	 Result := ((lower1 <= line) and then (line <= upper1) 
		    and then
                    (lower2 <= column) and then (column <= upper2)
		    and then
                    (lower3 <= depth) and then (depth <= upper3)); 
      ensure
         Result = (valid_line(line) and valid_column(column)
                        and valid_depth(depth))
      end;

feature -- Counting :

   count1: INTEGER is
	 -- Size of the first dimension.
      deferred
      ensure
	 Result = upper1 - lower1 + 1;
      end;
   
   frozen line_count: INTEGER is
	 -- Equivalent of `count1'.
      do
	 Result := count1;
      end;
   
   count2: INTEGER is
	 -- Size of the second dimension.
      deferred
      ensure
	 Result = upper2 - lower2 + 1;
      end;
   
   frozen column_count: INTEGER is
      do
	 Result := count2;
      end;
   
   count3: INTEGER is
         -- Size of the third dimension.
      deferred
      ensure
         Result = upper3 - lower3 + 1;
      end;
   
   frozen depth_count: INTEGER is
      do
         Result := count3;
      end;
   
   count: INTEGER is
	 -- Total number of elements.
      deferred
      ensure
         Result = line_count * column_count * depth_count
      end;

feature 
   
   swap(line1, column1, depth1, line2, column2, depth2: INTEGER) is
         -- Swap the element at index (`line1',`column1',`depth1')
         -- with the element at index (`line2',`column2',`depth2').
      require
         valid_index(line1,column1,depth1);
         valid_index(line2,column2,depth2)
      deferred
      ensure
         item(line1,column1,depth1) = old item(line2,column2,depth2);
         item(line2,column2,depth2) = old item(line1,column1,depth1);
	 count = old count
      end;
   
   set_all_with(v: like item) is
	 -- Set all item with value `v'.
      deferred
      ensure
	 count = old count
      end;
   
   frozen clear_all is
	 -- Set all items to default values.
      local
	 value: like item;
      do
	 set_all_with(value);
      ensure
	 count = old count;
      end;

feature -- Creating or initializing :

   from_collection3(model: COLLECTION3[like item]) is
	 --  Uses `model' to initialize Current.
      require
	 model /= Void
      deferred
      ensure
	 count1 = model.count1;
         count2 = model.count2;
         count3 = model.count3
      end;

   from_model(model: COLLECTION[COLLECTION[COLLECTION[E]]]) is
	 -- The `model' is used to fill line by line Current.
         -- Assume all sub-collections have the same
         -- dimension.
      require
	 model /= Void
      deferred
      ensure
	 count1 = model.count;
         count2 > 0 implies count2 = model.first.count;
         count3 > 0 implies count3 = model.first.first.count
      end;

feature -- Looking and comparison :
   
   all_default: BOOLEAN is
         -- Do all items have their type's default value?
      deferred
      end;

   frozen all_cleared: BOOLEAN is
      obsolete "The new name of this feature is `all_default'."
      do
	 Result := all_default;
      end;

   same_as(other: COLLECTION3[E]): BOOLEAN is
	 -- Unlike `is_equal', this feature can be used to compare
         -- distinct implementation of COLLECTION3.
      require
	 other /= Void
      deferred
      ensure
	 Result implies standard_same_as(other)
      end;

feature -- Printing :
   
   frozen fill_tagged_out_memory is
      local
         line, column, depth: INTEGER;
	 v: like item;
      do
	 tagged_out_memory.append("lower1: "); 
	 lower1.append_in(tagged_out_memory);
	 tagged_out_memory.append(" upper1: "); 
	 upper1.append_in(tagged_out_memory);
	 tagged_out_memory.append(" lower2: "); 
	 lower2.append_in(tagged_out_memory);
	 tagged_out_memory.append(" upper2: "); 
         upper2.append_in(tagged_out_memory);
         tagged_out_memory.append(" lower3: "); 
         lower3.append_in(tagged_out_memory);
         tagged_out_memory.append(" upper3: ");
         upper3.append_in(tagged_out_memory);
	 tagged_out_memory.append(" [%N");
	 from
	    line := lower1;
	 until
	    line > upper1
	       or else
	    tagged_out_memory.count > 4096
	 loop
	    tagged_out_memory.append("line ");
	    line.append_in(tagged_out_memory);
	    tagged_out_memory.append("%T: ");
	    from
	       column := lower2;
	    until
	       column > upper2
	    loop
               tagged_out_memory.append("column ");
               column.append_in(tagged_out_memory);
               tagged_out_memory.append("%T: ");
               from
                  depth := lower3;
               until
                  depth > upper3
               loop
                  tagged_out_memory.append("depth ");
                  depth.append_in(tagged_out_memory);
                  tagged_out_memory.append("%T: ");
                  v := item(line,column,depth);
                  if v = Void then
                     tagged_out_memory.append("Void");
                  else
                     v.out_in_tagged_out_memory;
                  end;
                  tagged_out_memory.extend(' ');
                  depth := depth + 1;
               end;
               tagged_out_memory.extend('%N');
   	       column := column + 1;
	    end;
	    tagged_out_memory.extend('%N');
	    line := line + 1;
	 end;
	 if valid_line(line) then
	    tagged_out_memory.append("......%N"); 
	 end;
      end;

feature -- Miscellaneous features :

   nb_occurrences(elt: E): INTEGER is
	 -- Number of occurrences using `equal'.
         -- See also `fast_nb_occurrences' to choose
	 -- the apropriate one.
      deferred
      ensure
	 Result >= 0
      end;
   
   fast_nb_occurrences(elt: E): INTEGER is
	 -- Number of occurrences using `='.
      deferred
      ensure
	 Result >= 0
      end;

   has(x: like item): BOOLEAN is
	 -- Search if a element x is in the array using `equal'.
         -- See also `fast_has' to choose the apropriate one.
      deferred
      end;
   
   fast_has(x: like item): BOOLEAN is
	 --  Search if a element x is in the array using `='.
      deferred
      end;
   
   replace_all(old_value, new_value: like item) is
      	 -- Replace all occurences of the element `old_value' by `new_value' 
	 -- using `equal' for comparison.
	 -- See also `fast_replace_all' to choose the apropriate one.
      deferred
      ensure
	 count = old count;
	 nb_occurrences(old_value) = 0
      end;
   
   fast_replace_all(old_value, new_value: like item) is
      	 -- Replace all occurences of the element `old_value' by `new_value' 
	 -- using operator `=' for comparison.
	 -- See also `replace_all' to choose the apropriate one.
      deferred
      ensure
	 count = old count;
	 fast_nb_occurrences(old_value) = 0
      end;

   sub_collection3(line_min, line_max, column_min, column_max,
                depth_min, depth_max: INTEGER): like Current is
	 -- Create a new object using selected area of `Current'.
      require
         valid_index(line_min,column_min,depth_min);
         valid_index(line_max,column_max,depth_max)
      deferred
      ensure
	 Result /= Void
      end;

   set_area(element: like item; line_min, line_max, column_min, column_max,
                depth_min, depth_max: INTEGER) is
	 -- Set all the elements of the selected area rectangle with `element'.
      require
         valid_index(line_min,column_min,depth_min);
         valid_index(line_max,column_max,depth_max)
      local
         line, column, depth : INTEGER;
      do
	 from
	    line := line_min;
	 until
	    line > line_max
	 loop
	    from
	       column := column_min
	    until
	       column > column_max
	    loop
               from
                  depth := depth_min
               until
                  depth > depth_max
               loop
                  put(element,line,column,depth);
                  depth := depth + 1;
               end;
               column := column + 1;
	    end;
	    line := line + 1;
	 end;
      ensure
	 count = old count;
      end;

feature {COLLECTION3} -- For `same_as' implementation :

   frozen standard_same_as(other: COLLECTION3[E]): BOOLEAN is
      require
	 generating_type /= other.generating_type
      local
         line, column, depth: INTEGER;
      do
         if lower1 /= other.lower1 then
         elseif upper1 /= other.upper1 then
	 elseif lower2 /= other.lower2 then
	 elseif upper2 /= other.upper2 then
         elseif lower3 /= other.lower3 then
         elseif upper3 /= other.upper3 then
	 else
	    from
	       Result := true;
	       line := upper1;
	    until
	       not Result or else line < lower1
	    loop
	       from
		  column := upper2;
	       until
		  not Result or else column < lower2
	       loop
                  from
                     depth := upper3;
                  until
                     not Result or else depth < lower3
                  loop
                     Result := safe_equal(item(line,column,depth),
                                          other.item(line,column,depth));
                     depth := depth - 1;
                  end;
                  column := column - 1;
	       end;
	       line := line - 1;
	    end;
	 end;
      end;

   same_as_array3(other: ARRAY3[E]): BOOLEAN is
      require
	 other /= Void
      deferred
      end;
   
   same_as_fixed_array3(other: FIXED_ARRAY3[E]): BOOLEAN is
      require
	 other /= Void
      deferred
      end;
   
end -- COLLECTION3[E]
