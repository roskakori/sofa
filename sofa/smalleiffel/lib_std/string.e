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
class STRING
   --
   -- Resizable character STRINGs. 
   --
   
inherit
   HASHABLE;
   COMPARABLE 
      redefine 
         is_equal, copy, compare, three_way_comparison, 
         out_in_tagged_out_memory, fill_tagged_out_memory
      end;
   
creation make, copy, blank, from_external, from_external_copy,
   make_from_string

feature {STRING}
   
   storage: NATIVE_ARRAY[CHARACTER];
         -- The place where characters are stored.
   
feature 
   
   count: INTEGER;
         -- String length.
   
   capacity: INTEGER;
         -- Capacity of the `storage' area.
   
feature -- Creation / Modification :
   
   make(needed_capacity: INTEGER) is
         -- Initialize the string to have at least `needed_capacity'
         -- characters of storage.
      require
          non_negative_size: needed_capacity >= 0;
      do
         if needed_capacity > 0 then
            if capacity < needed_capacity then
               storage := storage.calloc(needed_capacity);
               capacity := needed_capacity;
            end;
         end;
         count := 0;
      ensure
         needed_capacity <= capacity;
         empty_string: count = 0
      end;

   blank(nr_blanks: INTEGER) is
         -- Initialize string with `nr_blanks' blanks.
      require
         nr_blanks >= 0;
      do
         make(nr_blanks);
         count := nr_blanks;
         fill_with(' ');
      ensure
         count = nr_blanks;
         nb_occurrences(' ') = count
      end;

feature -- Testing :
   
   is_empty: BOOLEAN is
         -- Has string length 0 ?
      do
         Result := (count = 0);
      end;

   empty: BOOLEAN is
      obsolete "The new name of this feature is `is_empty'."
      do
         Result := is_empty;
      end;

   item, infix "@" (index: INTEGER): CHARACTER is
         -- Character at position `index'.
      require
         valid_index(index)
      do
         Result := storage.item(index - 1);
      end;

   valid_index(index: INTEGER): BOOLEAN is
         -- True when `index' is valid (i.e., inside actual bounds).
      do
         Result := 1 <= index and then index <= count;
      ensure
         Result = (1 <= index and then index <= count)
      end;
   
   hash_code: INTEGER is
      local
         i: INTEGER;
      do
         i := count;
         if i > 5 then
            Result := i * item(i).code;
            i := 5;
         end;
         from until i <= 0 loop
            Result := Result + item(i).code;
            i := i - 1;
         end;
         Result := Result * count;
      end;

   infix "<" (other: like Current): BOOLEAN is
         -- Is Current less than `other' ?
      local
         i: INTEGER;
      do
         from  
            i := 1;
         until
            count < i or else other.count < i 
            or else item(i) /= other.item(i)
         loop
            i := i + 1;
         end;
         if count < i then
            Result := other.count >= i;
         elseif other.count < i then
            Result := false;
         else
            Result := item(i) < other.item(i);
         end;
      end;

   compare, three_way_comparison(other: like Current): INTEGER is
      local
         i: INTEGER;
      do
         from  
            i := 1;
         until
            count < i or else other.count < i 
            or else item(i) /= other.item(i)
         loop
            i := i + 1;
         end;
         if count < i then
            if other.count < i then
            else
               Result := -1;
            end;
         elseif other.count < i then
            Result := 1;
         elseif item(i) < other.item(i) then
            Result := -1;
         else
            Result := 1;
         end;
      end;

   same_as(other: STRING): BOOLEAN is
         -- Case insensitive `is_equal'.
      require
         other /= Void
      local
         s1, s2: like storage;
         i: INTEGER;
      do
         i := count;
         if i = other.count then
            if storage.fast_memcmp(other.storage,i) then
               Result := true;
            else
               from
                  i := i - 1;
                  s1 := storage;
                  s2 := other.storage;
                  Result := true;
               until
                  i < 0
               loop
                  if s1.item(i).same_as(s2.item(i)) then
                     i := i - 1;
                  else
                     i := -1;
                     Result := false;
                  end;
               end;
            end;
         end;
      end;
   
   is_equal(other: like Current): BOOLEAN is
         -- Has Current the same text as `other' ?
      do
         if count = other.count then
            Result := storage.fast_memcmp(other.storage,count);
         end;
      end;
   
   index_of(ch: CHARACTER): INTEGER is
         -- Gives the index of the first occurrence `ch' or 
         -- `count + 1' if none.
      do
         Result := 1 + storage.fast_index_of(ch,count - 1);
      ensure
         (Result /= count + 1) implies (item(Result) = ch);
      end;
   
   index_of_string(other: STRING): INTEGER is
         -- Position of the first occurrence of `other'
         -- or `count + 1' if none.
      require
         not other.is_empty
      local
         stop: BOOLEAN;
         i1, i2, i3: INTEGER;
      do
         from
            i1 := 1;
            i2 := other.count;
            i3 := i2;
         invariant
            i3 = i2 - i1 + 1; 
         variant
            count - i1 + 1
         until
            Result /= 0
         loop
            if i2 > count then
               Result := count + 1;
            else
               from
                  stop := false;
               invariant
                  i3 = i2 - i1 + 1
               variant
                  (i3 + i2)
               until
                  stop
               loop
                  if i3 = 0 then
                     stop := true;
                     Result := i1;
                  elseif other.item(i3) /= item(i2) then
                     stop := true;
                  end;
                  i3 := i3 - 1;
                  i2 := i2 - 1;
               end;
            end;
            i1 := i1 + 1;
            i3 := other.count;
            i2 := i1 + i3 - 1;
         end;
      end;

   has(ch: CHARACTER): BOOLEAN is
         -- True if `ch' is in the STRING.
      do
         Result := storage.fast_has(ch,count - 1);
      end;

   has_string(other: STRING): BOOLEAN is
         -- True if `other' is in the STRING.
      do
         Result := index_of_string(other) /= (count + 1);
      end;

   nb_occurrences, occurrences_of, occurrences(c: CHARACTER): INTEGER is
         -- Number of times character `c' appears in the string.
      do
         Result := storage.fast_nb_occurrences(c,count - 1);
      ensure
         Result >= 0
      end;
   
   has_suffix(s: STRING): BOOLEAN is
         -- True if suffix of Current is `s'.
      require
         s /= Void
      local
         i1, i2: INTEGER;
      do
         if s.count <= count then
            from  
               i1 := count - s.count + 1;
               i2 := 1;
            until
               i1 > count or else
               i2 > s.count or else
               item(i1) /= s.item(i2)
            loop
               i1 := i1 + 1;
               i2 := i2 + 1;
            end;
            Result := i1 > count; 
         end;
      end;
   
   has_prefix(p: STRING): BOOLEAN is
         -- True if prefix of Current is `p'.
      require
         p /= Void;
      local
         i: INTEGER;
      do
         if p.count <= count then
            from  
               i := p.count;
            until
               i = 0 or else item(i) /= p.item(i)
            loop
               i := i - 1;
            end;
            Result := i = 0; 
         end;
      end;

   replace_all(old_character, new_character: like item) is
         -- Replace all occurrences of the element `old_character' by 
         -- `new_character'.
      do
         storage.fast_replace_all(old_character,new_character,count - 1);
      ensure
         count = old count;
         nb_occurrences(old_character) = 0
      end;

   is_integer: BOOLEAN is
 	 -- Can contents be read as an INTEGER ?
      local
         i, state: INTEGER;
         cc: CHARACTER;
      do
         -- state 0 : nothing read.
         -- state 1 : "+" or "-" read.
         -- state 2 : in the number.
         -- state 3 : after the number.
         -- state 4 : error.
         from
            i := 1;
         until
            i > count or else state = 4
         loop
            cc := item(i);
            inspect 
               state
            when 0 then
               if cc.is_separator then
               elseif cc = '+' then
                  state := 1;
               elseif cc = '-' then
                  state := 1;
               elseif cc.is_digit then
                  state := 2;
                  Result := true;
               else
                  state := 4;
                  Result := false;
               end;
            when 1 then
               if cc.is_separator then
               elseif cc.is_digit then
                  state := 2;
                  Result := true;
               else
                  state := 4;
                  Result := false;
               end;
            when 2 then
               if cc.is_digit then
               elseif cc.is_separator then
                  state := 3;
               else
                  state := 4;
                  Result := false;
               end;
            when 3 then
               if cc.is_separator then
               else 
                  state := 4;
                  Result := false;
               end;
            end;
            i := i + 1;
         end;
      end; 

   is_real: BOOLEAN is
         -- Can contents be read as a REAL ?
      local
         d: DOUBLE;
      do
         if is_double then
            d := to_double
            if Minimum_real <= d and then d <= Maximum_real then
               Result := true
               -- This gives only approximate accuracy; the comparison 
               -- is not accurate to nearly as many significant figures
               -- as are displayed for the limits.
            end
         end
      end

   is_double: BOOLEAN is
         -- Can contents be read as a DOUBLE ?
      local
         i, state: INTEGER;
         cc: CHARACTER;
         begun: BOOLEAN;
      do
         -- state 0 : nothing read.
         -- state 1 : "+" or "-" read.
         -- state 2 : in the number.
         -- state 3 : decimal point read
         -- state 4 : in fractional part
         -- state 5 : read 'E' or 'e' for scientific notation
         -- state 6 : read "-" sign of exponent
         -- state 7 : in exponent
         -- state 8 : after the number.
         -- state 9 : error.
         from
            i := 1;
         until
            i > count or else state = 9
         loop
            cc := item(i);
            inspect 
               state
            when 0 then
               if cc.is_separator then
               elseif cc = '+' then
                  state := 1;
               elseif cc = '-' then
                  state := 1;
               elseif cc.is_digit then
                  state := 2;
                  Result := true;
               elseif cc = '.' then
                  state := 3
               else
                  state := 9;
                  Result := false;
               end;
            when 1 then
               if cc.is_separator then
               elseif cc.is_digit then
                  state := 2;
                  Result := true;
               elseif cc = '.' then
                  state := 3
               else
                  state := 9;
                  Result := false;
               end;
            when 2 then
               if cc.is_digit then
                  begun := true
               elseif cc = '.' then
                  state := 3
               else
                  state := 9;
                  Result := false;
               end;
            when 3 then
               if cc.is_separator then
                  state := 8;
               elseif cc.is_digit then
                  state := 4
                  Result := true;
                  begun := true
               else
                  state := 9
                  Result := false
               end
            when 4 then
               if cc.is_digit then
                  begun := true
               elseif cc.is_separator then
                  state := 8;
               elseif (cc = 'e' or cc = 'E') and begun then
                  state := 5
               else
                  state := 9;
                  Result := false;
               end;
            when 5 then
               if cc = '-' then
                  state := 6
               elseif cc.is_digit then
                  state := 7
               else
                  state := 9;
                  Result := false;
               end;
            when 6 then
               if cc.is_digit then
                  state := 7
               else
                  state := 9;
                  Result := false;
               end;
            when 7 then
               if cc.is_digit then
               elseif cc.is_separator then
                  state := 8
               else
                  state := 9;
                  Result := false;
               end;
            when 8 then
               if cc.is_separator then
               else 
                  state := 9;
                  Result := false;
               end;
            end;
            i := i + 1;
         end;
         if state < 3 then
            -- exclude integers
            Result := false
         end
         -- We should check the value is within the system limits, but
         -- I can't see how to do that without trying to convert it.
      end; 

   is_bit: BOOLEAN is
         -- True when the contents is a sequence of bits (i.e., mixed 
         -- characters `0' and characters `1').
      local
         i: INTEGER;
      do
         from
            i := count;
            Result := true;
         until
            not Result or else i = 0
         loop
            Result := item(i).is_bit;
            i := i - 1;
         end;
      ensure
         Result = (count = nb_occurrences('0') + nb_occurrences('1'))
      end;

feature -- Modification :

   resize(new_count: INTEGER) is
         -- Resize Current. When `new_count' is greater than
         -- `count', new positions are initialized with the
         -- default value of type CHARACTER ('%U').
      require
         new_count >= 0
      local
	 s: like storage;
      do
         if new_count <= count then
            count := new_count;
	 elseif capacity < new_count then
	    if capacity = 0 then
	       storage := storage.calloc(new_count);
	    else
	       storage := storage.realloc(capacity,new_count);
	    end;
	    capacity := new_count;
	    count := new_count;
         else
	    storage.clear(count,new_count - 1);
	    count := new_count
	 end;
      ensure
         count = new_count;
         capacity >= old capacity
      end;
   
   clear, wipe_out is
         -- Clear out the current STRING.
         -- Note : internal `storage' memory is neither released nor shrunk.
      do
         count := 0;
      ensure
         count = 0;
      end;
   
   copy(other: like Current) is
         -- Copy `other' onto Current.
      do
         count := other.count;
         if count > 0 then
            if capacity < count then
               storage := storage.calloc(count);
               capacity := count;
            end;
            storage.copy_from(other.storage,count-1);
         end;
      ensure then
         count = other.count
      end;

   fill, fill_with(c: CHARACTER) is
         -- Replace every character with `c'.
      do
         storage.set_all_with(c,count - 1);
      ensure
         nb_occurrences(c) = count
      end;
   
   fill_blank is 
         -- Fill entire string with blanks
      do  
         fill_with(' ');
      ensure
         nb_occurrences(' ') = count
      end;     

   append, append_string(other: STRING) is
         -- Append `other' to Current.
      require
         other /= Void
      local
         other_count, needed_capacity: INTEGER;
      do
         other_count := other.count;
         needed_capacity := count + other_count;
         if capacity < needed_capacity then
            if capacity = 0 then
               capacity := needed_capacity;
               storage := storage.calloc(capacity);
            else
               storage := storage.realloc(capacity,needed_capacity);
               capacity := needed_capacity;
            end;
         end;
         storage.copy_at(count,other.storage,other_count);
         count := needed_capacity;
      end;

   prepend(other: STRING) is
         -- Prepend `other' to Current
      require
         other /= Void
      local
         i, j: INTEGER;
      do
	 i := count;
	 j := other.count;
	 resize(i + j);
	 if i > 0 and then j > 0 then
	    storage.move(0, i - 1, j);
	 end;
	 storage.copy_from(other.storage, j - 1);
      ensure 
	 Current.is_equal((old other.twin) + (old Current.twin))
      end;

   infix "+" (other: STRING): STRING is
         -- Create a new STRING which is the concatenation of 
         -- `Current' and `other'.
      require
         other /= Void
      do
         !!Result.make(count + other.count);
         Result.append(Current);
         Result.append(other);
      ensure
         Result.count = count + other.count
      end;
   
   put(ch: CHARACTER; index: INTEGER) is
         -- Put `ch' at position `index'.
      require
         valid_index(index)
      do
         storage.put(ch,index - 1);
      ensure
         item (index) = ch
      end;
   
   swap(i1, i2: INTEGER) is
      require
         valid_index(i1);
         valid_index(i2)
      local
         tmp: CHARACTER;
      do
         tmp := item(i1);
         put(item(i2),i1);
         put(tmp,i2);
      ensure
         item(i1) = old item(i2);
         item(i2) = old item(i1);
      end;
   
   insert(ch: CHARACTER; index: INTEGER) is
         -- Insert `ch' after position `index'.
      require
         0 <= index and index <= count;
      local
         i: INTEGER;
      do
         from  
            i := count;
            extend(' ');
         until
            i = index
         loop
            put(item(i),i + 1);
            i := i - 1;
         end;
         put(ch,index + 1);
      ensure
         item (index + 1) = ch
      end;

   shrink(min_index, max_index: INTEGER) is
         -- Keep only the slice [`min_index' .. `max_index'] or nothing
         -- when the slice is empty.
      require
         1 <= min_index;
         max_index <= count;
         min_index <= max_index + 1
      do
         if max_index < min_index then
            count := 0;
         elseif min_index = 1 then
            count := max_index;
         else
	    storage.copy_slice(0,storage,min_index - 1,max_index - 1);
	    count := max_index - min_index + 1
         end;
      ensure
         count = max_index - min_index + 1;
      end;
   
   remove(index: INTEGER) is
         -- Remove character at position `index'.
      require
         valid_index(index)
      do
         remove_between(index,index);
      ensure
         count = (old count) - 1
      end;

   add_first(ch: CHARACTER) is
         -- Add `ch' at first position.
      local
         i: INTEGER;
      do
         from  
            extend(' ');
            i := count;
         until
            i = 1
         loop
            put(item(i - 1),i);
            i := i - 1;
         end;
         put(ch,1);
      ensure
         count = 1 + old count;
         item(1) = ch
      end;

   add_last, extend, append_character(ch: CHARACTER) is
         -- Append `ch' to string
      local
         new_capacity: INTEGER;
      do
         if capacity > count then
         elseif capacity = 0 then
            capacity := 32;
            storage := storage.calloc(capacity);
         else
            new_capacity := 2 * capacity;
            storage := storage.realloc(capacity,new_capacity);
            capacity := new_capacity;
         end;
         storage.put(ch,count);
         count := count + 1;
      ensure
         count = 1 + old count;
         item (count) = ch
      end;

   precede(ch: CHARACTER) is
         -- Prepend `ch' to string
      local
         i: INTEGER;
      do
         from  
            extend(' ');
            i := count;
         until
            i = 1
         loop
            put(item(i-1),i);
            i := i - 1;
         end;
         put(ch,1);
      ensure
         item (1) = ch
      end;

   to_lower is
         -- Convert all characters to lower case.
      local
         i: INTEGER;
      do
         from  
            i := count;
         until
            i = 0
         loop
            put(item(i).to_lower,i);
            i := i - 1;
         end;
      end;
   
   to_upper is
         -- Convert all characters to upper case.
      local
         i: INTEGER;
      do
         from  
            i := count;
         until
            i = 0
         loop
            put(item(i).to_upper,i);
            i := i - 1;
         end;
      end;

   remove_first(nb: INTEGER) is
         -- Remove `nb' first characters.
      require
         nb >= 0; 
         count >= nb;
      do
         if nb > 0 then
            remove_between(1, nb)
         end;
      ensure
         count = (old count) - nb
      end; 
   
   remove_last(nb: INTEGER) is
         -- Remove `nb' last characters.
      require
         0 <= nb;
         nb <= count;
      do
         count := count - nb;
      ensure
         count = old count - nb
      end; 
   
   remove_between(low, up : INTEGER) is
         -- Remove character between positions `low' and `up'.
      require
         valid_index(low);
         valid_index(up);
         low <= up
      local
         i : INTEGER;
      do
         from  
            i := up;
         until
            i >= count
         loop
            put(item(i + 1), low + i - up);
            i := i + 1;
         end;
         count := count - (up - low + 1);
      ensure
         count = (old count) - (up - low + 1)
      end;

   remove_suffix(s: STRING) is
      -- Remove the suffix `s' of current string.
      require
         has_suffix(s);
      do
         remove_last(s.count);
      ensure
         (old Current.twin).is_equal(Current + (old s.twin))
      end;

   remove_prefix(s: STRING) is
      -- Remove the prefix `s' of current string.
      require
         has_prefix(s);
      do
         remove_first(s.count);
      ensure
         (old Current.twin).is_equal((old s.twin) + Current)
      end;

   left_adjust is
         -- Remove leading blanks.
      local
         i: INTEGER;
      do
         from
         until
            i + 1 > count or else item(i + 1) /= ' '
         loop
            i := i + 1;
         end;
         remove_first(i);
      ensure
         stripped: is_empty or else item (1) /= ' '
      end;

   right_adjust is
         -- Remove trailing blanks.
      do
         from
         until
            count = 0 or else item(count) /= ' '
         loop
            count := count - 1;
         end
      ensure
         stripped: is_empty or else item (count) /= ' '
      end;

feature -- Features which don't modify the string

   first: CHARACTER is
      require
         not is_empty
      do
         Result := storage.item(0);
      end;

   last: CHARACTER is
      require
         not is_empty;
      do
         Result := item(count);
      end;

feature -- Conversion :

   to_integer: INTEGER is
         -- Current must looks like an INTEGER.
      require
         is_integer
      local
         i, state: INTEGER;
         cc: CHARACTER;
         minus: BOOLEAN;
      do
         -- state 0 : nothing read.
         -- state 1 : "+" or "-" read.
         -- state 2 : in the number.
         -- state 3 : after the number.
         -- state 4 : error.
         from
            i := 1;
         until
            i > count 
         loop
            cc := item(i);
            inspect 
               state
            when 0 then
               if cc.is_separator then
               elseif cc = '+' then
                  state := 1;
               elseif cc = '-' then
                  minus := true;
                  state := 1;
               else
                  check
                     cc.is_digit
                  end;
                  Result := cc.value;
                  state := 2;
               end;
            when 1 then
               if cc.is_separator then
               else
                  check
                     cc.is_digit
                  end;
                  Result := cc.value;
                  state := 2;
               end;
            when 2 then
               if cc.is_digit then
                  Result := (Result * 10) + cc.value;
               else
                  check
                     cc.is_separator
                  end;
                  state := 3;
               end;
            when 3 then
               check
                  cc.is_separator
               end;
            end;
            i := i + 1;
         end;
         if minus then
            Result := - Result;
         end;
      end; 

   to_real: REAL is
         -- Conversion to the corresponding REAL value. 
         -- The string must looks like a REAL (or like an 
         -- INTEGER because fractionnal part is optional).
      require
         is_integer or is_real
      do
         Result := to_double.to_real;
      end;
   
   to_double: DOUBLE is
         -- Conversion to the corresponding DOUBLE value. 
         -- The string must looks like a DOUBLE, like 
         -- a REAL (or like an INTEGER because fractionnal 
         -- part is optional).
      require
         is_integer or is_real or is_double
      local
         negative: BOOLEAN;
         p: POINTER;
      do
         tmp_string.copy(Current);
         tmp_string.left_adjust;
         if tmp_string.first = '-' then
            negative := true;
            tmp_string.remove_first(1);
         elseif tmp_string.first = '+' then
            tmp_string.remove_first(1);
         end;
         tmp_string.left_adjust;
         p := tmp_string.to_external;
         Result := se_string2double(p);
         if negative then
            Result := -Result;
         end;
      end;

   binary_to_integer: INTEGER is
         -- Assume there is enougth space in the INTEGER to store
         -- the corresponding decimal value.
      require
         is_bit;
         count <= Integer_bits
      local
         i: INTEGER;
      do
         from
            i := 1;
         until
            i > count
         loop
            if item(i) = '1' then
               Result := (2 * Result) + 1;
            else
               Result := 2 * Result;
            end;
            i := i + 1;
         end;
      end;

   to_hexadecimal is
         -- Convert Current bit sequence into the corresponding 
         -- hexadecimal notation.
      require
         is_bit
      local
         i, k, new_count: INTEGER;
         value: INTEGER;
      do
         from
            i := 1;
            k := count \\ 4;
            if k > 0 then
               new_count := 1;
            end;
         until
            k = 0
         loop
            value := value * 2 + item(i).value;
            i := i + 1;
            k := k - 1;
         end;
         if new_count > 0 then
            put(value.hexadecimal_digit,new_count);
         end;
         from
         until
            i > count 
         loop
            from
               value := item(i).value;
               i := i + 1;
               k := 3;
            until
               k = 0
            loop
               value := value * 2 + item(i).value;
               i := i + 1;
               k := k - 1;
            end;
            new_count := new_count + 1;
            put(value.hexadecimal_digit,new_count);
         end;
         count := new_count;
      end;

feature -- Printing :
   
   out_in_tagged_out_memory is
      do
         tagged_out_memory.append(Current); 
      end;
   
   fill_tagged_out_memory is
      do
         tagged_out_memory.append("count: "); 
         count.append_in(tagged_out_memory);
         tagged_out_memory.append("capacity: "); 
         capacity.append_in(tagged_out_memory);
         tagged_out_memory.append("storage: %""); 
         tagged_out_memory.append(Current); 
         tagged_out_memory.extend('%"'); 
      end;
   
feature -- Other features :
   
   substring(min_index, max_index: INTEGER): like Current is
         -- New string consisting of items [`min_index'.. `max_index'].  
      require
         1 <= min_index;
         max_index <= count; 
         min_index <= max_index + 1
      local
	 c: INTEGER;
      do
	 c := max_index - min_index + 1;
	 !!Result.make(c);
	 Result.set_count(c);
         Result.storage.copy_slice(0,storage,min_index - 1, max_index - 1);
      ensure
         Result.count = (max_index - min_index + 1)
      end;
   
   extend_multiple(c: CHARACTER; n: INTEGER) is
         -- Extend Current with `n' times character `c'.
      require
         n >= 0
      local
         i: INTEGER;
      do
         from
            i := n;
         until
            i = 0
         loop
            extend(c);
            i := i - 1;
         end;
      ensure
         count = n + old count
      end;

   precede_multiple(c: CHARACTER; n: INTEGER) is
         -- Prepend `n' times character `c' to Current.
      require
         n >= 0
      local
         old_count: INTEGER;
      do
         if n > 0 then
            old_count := count;
            if old_count = 0 then
               extend_multiple(c,n);
            else
               extend_multiple('%U',n);
               storage.move(0,old_count - 1,n);
               storage.set_all_with(c,n - 1);
            end;
         end;
      ensure
         count = n + old count
      end;

   extend_to_count(c: CHARACTER; needed_count: INTEGER) is
         -- Extend Current with `c' until `needed_count' is reached.
         -- Do nothing if `needed_count' is already greater or equal 
         -- to `count'.
      require
         needed_count >= 0
      local
         offset: INTEGER;
      do
         from
            offset := needed_count - count;
         until
            offset <= 0
         loop
            extend(c);
            offset := offset - 1;
         end;
      ensure
         count >= needed_count
      end;

   precede_to_count(c: CHARACTER; needed_count: INTEGER) is
         -- Prepend `c' to Current until `needed_count' is reached.
         -- Do nothing if `needed_count' is already greater or equal 
         -- to `count'.
      require
         needed_count >= 0
      local
         offset, old_count: INTEGER;
      do
         old_count := count;
         offset := needed_count - old_count;
         if offset > 0 then
            extend_to_count('%U',needed_count);
            storage.move(0,old_count - 1,offset);
            storage.set_all_with(c,offset - 1);
         end;
      ensure
         count >= needed_count
      end;

   reverse is
         -- Reverse the string.
      local
         i1, i2: INTEGER;
      do
         from  
            i1 := 1;
            i2 := count;
         until
            i1 >= i2
         loop
            swap(i1,i2);
            i1 := i1 + 1;
            i2 := i2 - 1;
         end;
      end;
   
   remove_all_occurrences(ch: CHARACTER) is
         -- Remove all occurrences of `ch'.
      local
         i, j: INTEGER;
      do
         from  
            i := 1;
            j := 1;
         until
            i > count
         loop
            if item(i) /= ch then
               put(item(i),j);
               j := j + 1;
            end;
            i := i + 1;
         end;
         count := j - 1; 
      ensure
         count = old count - old nb_occurrences(ch)
      end;

   substring_index(other: STRING; start: INTEGER): INTEGER is
         -- Position of first occurrence of `other' at or after 
         -- `start';
         -- 0 if none.
      require
         start_large_enough: start >= 1;
         start_small_enough: start <= count;
         string_exist: other /= Void
      local
         i, s: INTEGER;
      do
         from
            s := start;
         until
            Result /= 0 or else (s + other.count - 1) > count
         loop
            from
               i := 1;
            until
               i > other.count or else item(s + i - 1) /= other.item(i)
            loop
               i := i + 1;
            end;
            if i > other.count then
               Result := s;
            else
               s := s + 1
            end;
         end;
      end;

feature -- Splitting a STRING :
   
   split: ARRAY[STRING] is
         -- Split the string into an array of words.
         -- Uses `is_separator' of CHARACTER to find words.
         -- Gives Void or a non empty array.
      do
         if count > 0 then
            split_buffer.clear;
            split_in(split_buffer);
            if not split_buffer.is_empty then
               Result := split_buffer.twin;
            end;
         end;
      ensure
         Result /= Void implies not Result.is_empty
      end;

   split_in(words: COLLECTION[STRING]) is
         -- Same jobs as `split' but result is appended in `words'.
      require
         words /= Void
      local 
         state, i: INTEGER;
         -- state = 0 : waiting next word.
         -- state = 1 : inside a new word.
         c: CHARACTER;
      do
         if count > 0 then
            from
               i := 1;
            until
               i > count
            loop
               c := item(i);
               if state = 0 then
                  if not c.is_separator then
                     tmp_string.clear;
                     tmp_string.extend(c);
                     state := 1;
                  end;
               else
                  if not c.is_separator then
                     tmp_string.extend(c);
                  else
                     words.add_last(tmp_string.twin);
                     state := 0;
                  end;
               end;
               i := i + 1;
            end;
            if state = 1 then 
               words.add_last(tmp_string.twin);
            end;
         end;
      ensure
         words.count >= old (words.count)
      end;

feature -- Other feature :

   set_last(ch: CHARACTER) is
      obsolete "Since release -0.77, the new name for this feature %
               %is `extend_unless'. Please update your code."
      do
         extend_unless(ch);
      end;

   extend_unless(ch: CHARACTER) is
         -- Extend `Current' (using `extend') with `ch' unless `ch' is 
         -- already the `last' character.
      do
         if count = 0 or else item(count) /= ch then
            extend(ch);
         end;
      ensure
         last = ch;
         count >= old count
      end;

   get_new_iterator: ITERATOR[CHARACTER] is
      do
         !ITERATOR_ON_STRING!Result.make(Current);
      end;

feature -- Interfacing with C string :
   
   to_external: POINTER is
         -- Gives C access to the internal `storage' (may be dangerous).
         -- To be compatible with C, a null character is added at the end 
         -- of the internal `storage'. This extra null character is not 
         -- part of the Eiffel STRING. 
      do
         if capacity > count then
            count := count + 1;
            if item(count) /= '%U' then
               put('%U',count);
            end;
         else
            extend('%U');
         end;
         count := count - 1;
         Result := storage.to_pointer;
      ensure
         count = old count;
         Result.is_not_null
      end;

   from_external(p: POINTER) is
         -- Internal `storage' is set using `p' (may be dangerous because
         -- the external C string `p' is not duplicated).
         -- Assume `p' has a null character at the end in order to 
         -- compute the Eiffel `count'. This extra null character
         -- is not part of the Eiffel STRING.
         -- Also consider `from_external_copy' to choose the most appropriate. 
      require
         p.is_not_null
      do
         from
            storage := storage.from_pointer(p);
            count := 0;
         until
            storage.item(count) = '%U'
         loop
            count := count + 1;
         end;
         capacity := count + 1;
      ensure
         capacity = count + 1;
         p = to_external
      end;

   from_external_copy(p: POINTER) is
         -- Internal `storage' is set using a copy of `p'.
         -- Assume `p' has a null character at the end in order to 
         -- compute the Eiffel `count'. This extra null character
         -- is not part of the Eiffel STRING.
         -- Also consider `from_external' to choose the most appropriate.
      local
         s: like storage;
         i: INTEGER;
      do
         clear;
         from
            s := s.from_pointer(p);
            i := 0;
         until
            s.item(i) = '%U'
         loop
            extend(s.item(i));
            i := i + 1;
         end;
      end;

feature -- Other feature here for ELKS'95 compatibility :

   make_from_string(model: STRING) is
         -- Initialize from the characters of `model'.
         -- (Useful in proper descendants of class STRING, to 
         -- initialize a string-like object from a manifest string.)
      require
         model /= Void
      do
	 if capacity < model.count then
	    capacity := model.count;
	    storage := storage.calloc(capacity);
	 end;
	 count := model.count;
	 storage.copy_from(model.storage,count - 1);
      ensure
         count = model.count
      end;

   head(n: INTEGER) is
      -- Remove all characters except fo the first `n'.
      -- Do nothing if n >= count.
      require
         n >= 0
      do
         if n < count then
            remove_last(count - n);
         end;
      ensure
         count = n.min(old count)
      end;
   
   tail(n: INTEGER) is
      -- Remove all characters except for the last `n'.
      -- Do nothing if n >= count.
      require
         n >= 0
      do
         if n < count then
            remove_first(count - n);
         end;
      ensure
         count = n.min(old count)
      end;

feature {STRING}

   set_count(new_count: INTEGER) is
      do
	 count := new_count;
      end;

   se_string2double(number_view: POINTER):DOUBLE is
      external "SmallEiffel"
      end; 

feature {NONE}
   
   tmp_string: STRING is 
      once
         !!Result.make(256);
      end;

   split_buffer: ARRAY[STRING] is
      once
         !!Result.with_capacity(4,1);
      end;

invariant

   0 <= count;

   count <= capacity;

   capacity > 0 implies storage.is_not_null;
   
end -- STRING
