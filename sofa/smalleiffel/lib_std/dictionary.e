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
class DICTIONARY[V,K->HASHABLE]
   --
   -- Associative memory. 
   -- Values of type `V' are stored using Keys of type `K'.
   --

inherit SAFE_EQUAL[V] redefine is_equal, copy end;

creation make, with_capacity

feature {DICTIONARY}
   
   buckets: NATIVE_ARRAY[DICTIONARY_NODE[V,K]];
	 -- The `buckets' storage area is the primary hash table of `capacity'
	 -- elements. To search some key, the first access is done in `buckets' 
	 -- using the remainder of the division of the key `hash_code' by 
	 -- `capacity'. In order to try to avoid clashes, `capacity' is always a 
	 -- prime number.
             
feature 

   Default_size: INTEGER is 193;
         -- Default size for the storage area in muber of items.

feature -- Counting :

   capacity: INTEGER;
	 -- Of the storage area.

   count: INTEGER;
         -- Actual `count' of stored elements.

   is_empty: BOOLEAN is
	 -- Is it empty ?
      do
         Result := count = 0;
      ensure
         Result = (count = 0)
      end;
      
   empty: BOOLEAN is
      obsolete "The new name of this feature is `is_empty'."
      do
	 Result := is_empty;
      end;
      
feature -- Basic access :

   has(k: K): BOOLEAN is
         -- Is there an item currently associated with key `k' ?
      local
	 idx: INTEGER;
	 node: like cache_node;
      do
	 from
	    idx := k.hash_code \\ capacity;
	    node := buckets.item(idx);
	 until
	    node = Void or else node.key.is_equal(k)
	 loop
	    node := node.next;
	 end;
	 Result := node /= Void;
      end;
   
   at, infix "@" (k: K): V is
         -- Return the item stored at key `k'.
      require
         has(k)
      local
	 idx: INTEGER;
	 node: like cache_node;
      do
	 from
	    idx := k.hash_code \\ capacity;
	    node := buckets.item(idx);
	 until
	    node.key.is_equal(k)
	 loop
	    node := node.next;
	 end;
	 Result := node.item;
      end;
   
feature

   put(v: V; k: K) is
	 -- Change some existing entry or `add' the new one. If there is 
	 -- as yet no key `k' in the dictionary, enter it with item `v'. 
	 -- Otherwise overwrite the item associated with key `k'.
      local
	 h, idx: INTEGER;
	 node: like cache_node;
      do
	 cache_user := -1;
	 from
	    h := k.hash_code;
	    idx := h \\ capacity;
	    node := buckets.item(idx);
	 until
	    node = Void or else node.key.is_equal(k)
	 loop
	    node := node.next;
	 end;
	 if node = Void then
	    if capacity = count then
	       increase_capacity;
	       idx := h \\ capacity;
	    end;
	    !!node.make(v,k,buckets.item(idx));
	    buckets.put(node,idx);
	    count := count + 1;
	 else
	    node.set_item(v);
	 end;
      ensure
         v = at(k)
      end;

   add(v: V; k: K) is
         -- To add a new entry `k' with its associated value `v'. Actually, this 
         -- is equivalent to call `put', but may run a little bit faster.
      require
	 not has(k)
      local
	 idx: INTEGER;
	 node: like cache_node;
      do
	 cache_user := -1;
	 if capacity = count then
	    increase_capacity;
	 end;
	 idx := k.hash_code \\ capacity;
	 !!node.make(v,k,buckets.item(idx));
	 buckets.put(node,idx);
	 count := count + 1;
      ensure
	 count = 1 + old count
         v = at(k)
      end;

feature -- Looking and Searching :

   nb_occurrences(v: V): INTEGER is
         -- Number of occurrences using `equal'. See also `fast_nb_occurrences' to 
         -- chose the apropriate one.
      local
         i: INTEGER;
      do
         from
            i := 1
         until
            i > count
         loop
            if safe_equal(v,item(i)) then
               Result := Result + 1;
            end;
            i := i + 1;
         end;
      ensure
         Result >= 0
      end;
      
   fast_nb_occurrences(v: V): INTEGER is
         -- Number of occurrences using `='. See also `nb_occurrences' to 
         -- chose the apropriate one.
      local
         i: INTEGER;
      do
         from
            i := 1
         until
            i > count
         loop
            if v = item(i) then
               Result := Result + 1;
            end;
            i := i + 1;
         end;
      ensure
         Result >= 0;
      end;

   key_at(v: V): K is
         -- Retrieve the key used for value `v' using `equal' for comparison. 
      require
         nb_occurrences(v) = 1
      local
         i: INTEGER;
      do
         from  
            i := 1;
         until
            safe_equal(v,item(i))
         loop
            i := i + 1;
         end;
         Result := cache_node.key;
      ensure
         equal(at(Result),v)
      end;
   
   fast_key_at(v: V): K is
         -- Retrieve the key used for value `v' using `=' for comparison. 
      require
         fast_nb_occurrences(v) = 1
      local
         i: INTEGER;
      do
         from  
            i := 1;
         until
            v = item(i)
         loop
            i := i + 1;
         end;
         Result := cache_node.key;
      ensure
         at(Result) = v
      end;

feature -- Removing :

   remove(k: K) is
         -- Remove entry `k' (which may exist or not before this call).
      local
         h, idx: INTEGER;
         node, previous_node: like cache_node;
      do
	 cache_user := -1;
	 h := k.hash_code;
	 idx := h \\ capacity;
	 node := buckets.item(idx);
	 if node /= Void then
	    if node.key.is_equal(k) then
	       count := count - 1;
	       node := node.next;
	       buckets.put(node,idx);
	    else
	       from
		  previous_node := node;
		  node := node.next;
	       until
		  node = Void or else node.key.is_equal(k)
	       loop
		  previous_node := node;
		  node := node.next;
	       end;
	       if node /= Void then
		  count := count - 1;
		  previous_node.set_next(node.next);
	       end;
	    end;
	 end;
      ensure
         not has(k)
      end;

   clear is
         -- Discard all items.
      do
         buckets.set_all_with(Void,capacity - 1);
         cache_user := -1;
         count := 0;
      ensure
         is_empty;
	 capacity = old capacity
      end;

feature -- To provide iterating facilities :

   lower: INTEGER is 1;

   upper: INTEGER is
      do
         Result := count;
      ensure
         Result = count
      end;

   valid_index(index: INTEGER): BOOLEAN is
      do
         Result := (1 <= index) and then (index <= count);
      ensure
         Result =  (1 <= index and index <= count);
      end;
   
   item(index: INTEGER): V is
      require
         valid_index(index)
      do
         set_cache_user(index);
         Result := cache_node.item;
      ensure
         Result = at(key(index))
      end;
   
   key(index: INTEGER): K is
      require
         valid_index(index)
      do
         set_cache_user(index);
         Result := cache_node.key;
      ensure
         at(Result) = item(index)
      end;

   get_new_iterator_on_items: ITERATOR[V] is
      do
         !ITERATOR_ON_DICTIONARY_ITEMS[V]!Result.make(Current);
      end;

   get_new_iterator_on_keys: ITERATOR[K] is
      do
         !ITERATOR_ON_DICTIONARY_KEYS[K]!Result.make(Current);
      end;

   key_map_in(buffer: COLLECTION[K]) is
	 -- Append in `buffer', all available keys (this may be useful to 
	 -- speed up the traversal).
      require
	 buffer /= Void
      local
	 node: like cache_node;
	 i, idx: INTEGER;
      do
	 from
	    i := count;
	    node := buckets.item(idx);
	 until
	    i <= 0
	 loop
	    from
	    until
	       node /= Void 
	    loop
	       idx := idx + 1;
	       check idx < capacity end;
	       node := buckets.item(idx);
	    end;
	    buffer.add_last(node.key);
	    node := node.next;
	    i := i - 1;
	 end;
      ensure
	 buffer.count = count + old buffer.count
      end;

   item_map_in(buffer: COLLECTION[V]) is
	 -- Append in `buffer', all available items (this may be useful to 
	 -- speed up the traversal).
      require
	 buffer /= Void
      local
	 node: like cache_node;
	 i, idx: INTEGER;
      do
	 from
	    i := count;
	    node := buckets.item(idx);
	 until
	    i <= 0
	 loop
	    from
	    until
	       node /= Void 
	    loop
	       idx := idx + 1;
	       check idx < capacity end;
	       node := buckets.item(idx);
	    end;
	    buffer.add_last(node.item);
	    node := node.next;
	    i := i - 1;
	 end;
      ensure
	 buffer.count = count + old buffer.count
      end;

feature
   
   is_equal(other: like current): BOOLEAN is
	 -- Do both dictionaries have the same set of associations?
	 -- Keys are compared with `is_equal' and values are comnpared
	 -- with the basic = operator. See also `is_equal_map'.
      local
	 i: INTEGER;
      do
         if Current = other then
            Result := true;
         elseif count = other.count then
	    from
	       Result := true;
	       i := 1;
	    until
	       not Result or else i > count
	    loop
	       if other.has(key(i)) then
		  if other.at(key(i)) /= item(i) then
		     Result := false;
		  else
		     i := i + 1;
		  end;
	       else
		  Result := false;
	       end;
	    end;
         end;
      ensure
	 Result implies count = other.count
      end;

   is_equal_map(other: like current): BOOLEAN is
	 -- Do both dictionaries have the same set of associations?
	 -- Both keys and values are compared with `is_equal'. See also `is_equal'.
      local
	 i: INTEGER;
         k: K;
      do
         if Current = other then
            Result := true;
         elseif count = other.count then
	    from
	       Result := true;
	       i := 1;
	    until
	       not Result or else i > count
	    loop
	       k := key(i);
	       if other.has(k) then
		  if not safe_equal(other.at(k),item(i)) then
		     Result := false;
		  else
		     i := i + 1;
		  end;
	       else
		  Result := false;
	       end;
	    end;
         end;
      end;

   copy(other: like current) is
	 -- Reinitialize by copying all associations of `other'.
      local
	 i: INTEGER;
      do
	 -- Note: this is a naive implementation because we should 
	 -- recycle already allocated nodes of `Current'.
	 from
	    if capacity = 0 then
	       with_capacity(other.count + 1);
	    else
	       clear;
	    end;
	    i := 1;
	 until
	    i > other.count
	 loop
	    put(other.item(i),other.key(i));
	    i := i + 1;
	 end;
      end;

feature {NONE} 
   
   increase_capacity is
         -- There is no more free slots: the dictionary must grow.
      require
	 capacity = count
      local
	 i, idx, new_capacity: INTEGER;
	 old_buckets: like buckets;
	 node1, node2: like cache_node;
      do
	 from
	    new_capacity := prime_number_for(capacity + 1);
	    old_buckets := buckets;
	    buckets := buckets.calloc(new_capacity);
	    capacity := new_capacity;
	    i := count - 1;
	 until
	    i < 0
	 loop
	    from
	       node1 := old_buckets.item(i);
	    until
	       node1 = Void
	    loop
	       node2 := node1.next;
	       idx := node1.key.hash_code \\ capacity;
	       node1.set_next(buckets.item(idx));
	       buckets.put(node1,idx);
	       node1 := node2;
	    end;
	    i := i - 1;
	 end;
	 cache_user := -1;
      ensure
	 capacity > old capacity;
	 count = old count;
      end;

   prime_number_for(lo: INTEGER): INTEGER is
	 -- Gives the prime number immediately greater or equal to `lo'.
      do
	 if lo <= 53 then
	    Result := 53;
	 elseif lo <= 97 then
	    Result := 97;
	 elseif lo <= 193 then
	    Result := 193;
	 elseif lo <= 389 then
	    Result := 389;
	 elseif lo <= 769 then
	    Result := 769;
	 elseif lo <= 1543 then
	    Result := 1543;
	 elseif lo <= 3079 then
	    Result := 3079;
	 elseif lo <= 6151 then
	    Result := 6151;
	 elseif lo <= 12289 then
	    Result := 12289;
	 elseif lo <= 24593 then
	    Result := 24593;
	 elseif lo <= 49157 then
	    Result := 49157;
	 elseif lo <= 98317 then
	    Result := 98317;
	 elseif lo <= 196613 then
	    Result := 196613;
	 elseif lo <= 393241 then
	    Result := 393241;
	 elseif lo <= 786433 then
	    Result := 786433;
	 elseif lo <= 1572869 then
	    Result := 1572869;
	 elseif lo <= 3145739 then
	    Result := 3145739;
	 elseif lo <= 6291469 then
	    Result := 6291469;
	 elseif lo <= 12582917 then
	    Result := 12582917;
	 elseif lo <= 25165843 then
	    Result := 25165843;
	 elseif lo <= 50331653 then
	    Result := 50331653;
	 elseif lo <= 100663319 then
	    Result := 100663319;
	 elseif lo <= 201326611 then
	    Result := 201326611;
	 elseif lo <= 402653189 then
	    Result := 402653189;
	 elseif lo <= 805306457 then
	    Result := 805306457;
	 else
	    Result := 1610612741;
	 end;
      ensure
	 Result >= lo
      end;

   set_cache_user(index: INTEGER) is
	 -- Set the internal memory cache (`cache_user', `cache_node' and 
	 -- `cache_buckets') to the appropriate valid value.
      require
         valid_index(index)
      do
         if index = cache_user + 1 then
	    from
	       cache_user := index;
	       cache_node := cache_node.next;
	    until
	       cache_node /= Void
	    loop
	       cache_buckets := cache_buckets + 1;
	       cache_node := buckets.item(cache_buckets);
	    end;
         elseif index = cache_user then
	 elseif index = 1 then
	    from
	       cache_user := 1;
	       cache_buckets := 0;
	       cache_node := buckets.item(cache_buckets);
	    until
	       cache_node /= Void 
	    loop
	       cache_buckets := cache_buckets + 1;
	       cache_node := buckets.item(cache_buckets);
	    end;
	 else
	    from
	       set_cache_user(1);
	    until
	       cache_user = index 
	    loop
	       set_cache_user(cache_user + 1);
	    end;
         end;
      ensure
         cache_user = index;
         cache_buckets.in_range(0,capacity - 1);
         cache_node /= Void;
      end;
   
   cache_user: INTEGER;
         -- The last user's external index in range [1 .. `count'] (see `item' 
         -- and `valid_index' for example) may be saved in `cache_user' otherwise 
         -- -1 to indicate that the cache is not active. When the cache is 
         -- active, the corresponding index in `buckets' is save in 
         -- `cache_buckets' and the corresponding node in `cache_node'.

   cache_node: DICTIONARY_NODE[V,K];
	 -- Meaningful only when `cache_user' is not -1.

   cache_buckets: INTEGER;
	 -- Meaningful only when `cache_user' is not -1.

   make is
         -- Internal initial storage size of the dictionary is set to the 
         -- `Default_size' value. Then, tuning of needed storage `capacity' is 
         -- performed automatically according to usage. If you are really 
         -- sure that your dictionary is always really bigger than 
         -- `Default_size', you may consider to use `with_capacity' to save some 
         -- execution time.
      do
         with_capacity(Default_size);
      ensure
         is_empty;
         capacity = Default_size
      end;
   
   with_capacity(medium_size: INTEGER) is
         -- May be used to save some execution time if one is sure that 
         -- storage size will rapidly become really bigger than `Default_size'. 
         -- When first `remove' occurs, storage size may naturally become 
         -- smaller than `medium_size'. Afterall, tuning of storage size is 
         -- done automatically according to usage.
      require
         medium_size > 0
      local
	 new_capacity: INTEGER;
      do
	 new_capacity := prime_number_for(medium_size);
         buckets := buckets.calloc(new_capacity);
	 capacity := new_capacity;
         cache_user := -1;
         count := 0;
      ensure
         is_empty;
         capacity >= medium_size
      end;

invariant

   capacity > 0;

   capacity >= count;

   cache_user.in_range(-1,count);

   cache_user > 0 implies cache_node /= Void;

   cache_user > 0 implies cache_buckets.in_range(0,capacity - 1);

end -- DICTIONARY[V,K->HASHABLE]

