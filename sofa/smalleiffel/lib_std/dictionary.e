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

inherit ANY redefine is_equal, copy end;

creation make, with_capacity

feature 

   Default_size: INTEGER is 32;
         -- Minimum size for storage in muber of items.

feature {DICTIONARY}
   
   keys: FIXED_ARRAY[K];
         -- Storage for keys of type `K'.

   store: FIXED_ARRAY[V];
         -- Storage for values of type `V'.
    
   modulus: INTEGER;
         -- To compute a hash value in range [0 .. `modulus'-1].

   buckets: FIXED_ARRAY[INTEGER];
         -- Valid index range is always [0 .. `modulus'-1].
         -- Contents is a hash code value in range [0 .. `keys.upper'] to 
         -- acess `keys', `store' and `chain' as well.
    
   chain: FIXED_ARRAY[INTEGER]; 
         -- Used to chain both free slots and hash-code clash.
         -- Value -1 mark the end of a list.
    
   first_free_slot: INTEGER;
         -- First element of the free-slot list or -1 when no more
         -- free slot are available.

feature {DICTIONARY}  -- Internal cache handling :
    
   cache_keys_idx: INTEGER;
         -- Contents is -1 or caches the last visited entry using : `has',
         -- `at', `item', or `key'.

   cache_user_idx: INTEGER;
         -- Contents is -1 or in range [1 .. `count']. When not -1, it 
         -- caches the last user's index used with `item' or `key'.

   cache_buckets_idx: INTEGER;
         -- Contents means nothing when `cache_user_idx' is -1.
         -- Otherwise, gives the current position in `buckets' during 
         -- traversal.

feature {NONE}

   buckets_keys_ratio: INTEGER is 3;
         -- To compute `modulus' as `ratio' * `capacity'.

   make is
         -- Internal initial storage size of the dictionary is set to
         -- the default `Default_size' value. Then, tuning of needed storage 
         -- size is done automatically according to usage. 
         -- If you are really sure that your dictionary is always really
         -- bigger than `Default_size', you may use `with_capacity' to save some 
         -- execution time.
      do
         with_capacity(Default_size);
      ensure
         is_empty;
         capacity = Default_size
      end;
   
   with_capacity(medium_size: INTEGER) is
         -- May be used to save some execution time if one is sure 
         -- that storage size will rapidly become really bigger than
         -- `Default_size'. When first `remove' occurs, storage size may 
         -- naturally become smaller than `medium_size'. Afterall, 
         -- tuning of storage size is done automatically according to
         -- usage.
      require
         medium_size > 0
      local
         i: INTEGER;
      do
         !!keys.make(medium_size);
         !!store.make(medium_size);
         modulus := buckets_keys_ratio * medium_size;
         !!buckets.make(modulus);
         buckets.set_all_with(-1);
         from
            !!chain.make(medium_size);
            i := chain.upper;
            first_free_slot := i;
         until
            i < 0
         loop
            chain.put(i - 1, i);
            i := i - 1;
         end;
         cache_keys_idx := -1;
         cache_user_idx := -1;
         count := 0;
      ensure
         is_empty;
         capacity = medium_size
      end;

feature -- Counting :

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
      do
         if cache_keys_idx < 0 or else k /= keys.item(cache_keys_idx) then
            from
               cache_user_idx := -1;
               cache_keys_idx := buckets.item(k.hash_code \\ modulus);
            until
               cache_keys_idx < 0 or else
               k.is_equal(keys.item(cache_keys_idx))
            loop
               cache_keys_idx := chain.item(cache_keys_idx);
            end;
         end;
         Result := (cache_keys_idx >= 0);
      end;
   
   at, infix "@" (k: K): V is
         -- Return the item stored at key `k'.
      require
         has(k)
      do
         if cache_keys_idx < 0 or else k /= keys.item(cache_keys_idx) then
            from
               cache_user_idx := -1;
               cache_keys_idx := buckets.item(k.hash_code \\ modulus);
            until
               k.is_equal(keys.item(cache_keys_idx))
            loop
               cache_keys_idx := chain.item(cache_keys_idx);
            end;
         end;
         Result := store.item(cache_keys_idx);
      end;
   
feature -- The only way to add or to change an entry :

   put(v: V; k: K) is
         -- If there is as yet no key `k' in the dictionary, enter 
         -- it with item `v'. Otherwise overwrite the item associated
         -- with key `k'.
      local
         h: INTEGER;
      do
         if cache_keys_idx < 0 or else k /= keys.item(cache_keys_idx) then
            from
               cache_user_idx := -1;
               h := k.hash_code \\ modulus;
               cache_keys_idx := buckets.item(h);
            until
               cache_keys_idx < 0 or else 
               k.is_equal (keys.item (cache_keys_idx))
            loop
               cache_keys_idx := chain.item (cache_keys_idx);
            end;
            if cache_keys_idx < 0 then
               if first_free_slot < 0 then
                  expand;
                  h := k.hash_code \\ modulus;
               end;
               keys.put(k,first_free_slot);
               store.put(v,first_free_slot);
               cache_keys_idx := first_free_slot;
               first_free_slot := chain.item(first_free_slot);
               chain.put(buckets.item(h),cache_keys_idx);
               buckets.put(cache_keys_idx,h);
               count := count + 1;
            else
               store.put(v,cache_keys_idx);
            end;
         else
            store.put(v,cache_keys_idx);
         end;
      ensure
         v = at(k)
      end;

feature -- Looking and Searching :

   nb_occurrences(v: V): INTEGER is
         -- Number of occurrences using `equal'.
         -- See also `fast_nb_occurrences' to chose
         -- the apropriate one.
      local
         i: INTEGER;
      do
         from
            i := 1
         until
            i > count
         loop
            if equal_like(v,item(i)) then
               Result := Result + 1;
            end;
            i := i + 1;
         end;
      ensure
         Result >= 0
      end;
      
   fast_nb_occurrences(v: V): INTEGER is
         -- Number of occurrences using `='.
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
            equal_like(v,item(i))
         loop
            i := i + 1;
         end;
         Result := keys.item(cache_keys_idx);
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
         Result := keys.item(cache_keys_idx);
      ensure
         at(Result) = v
      end;

   capacity: INTEGER is
      do
         Result := keys.count;
      end;

feature -- Removing :

   remove(k: K) is
         -- Remove entry `k' (which may exist or not before this call).
      local
         h, keys_idx, keys_next_idx: INTEGER;
      do
         h := k.hash_code \\ modulus;
         keys_idx := buckets.item(h);
         if keys_idx < 0 then
         elseif keys.item(keys_idx).is_equal(k) then
            buckets.put(chain.item(keys_idx),h);
            chain.put(first_free_slot,keys_idx);
            first_free_slot := keys_idx;
            cache_user_idx := -1;
            cache_keys_idx := -1;
            count := count - 1;
         else
            from
               keys_next_idx := chain.item(keys_idx);
            until
               keys_next_idx < 0 or else
               keys.item(keys_next_idx).is_equal(k)
               loop
                  keys_idx := keys_next_idx;
                  keys_next_idx := chain.item(keys_next_idx);
               end;
               if keys_next_idx >= 0 then
                  chain.put(chain.item(keys_next_idx),keys_idx);
                  chain.put(first_free_slot,keys_next_idx);
                  first_free_slot := keys_next_idx;
                  cache_user_idx := -1;
                  cache_keys_idx := -1;
                  count := count - 1;
               end;
            end;
      ensure
         not has(k)
      end;

   clear is
         -- Discard all items.
      local
         i: INTEGER;
      do
         buckets.set_all_with(-1);
         from
            i := chain.upper;
            first_free_slot := i;
         until
            i < 0
         loop
            chain.put(i - 1, i);
            i := i - 1;
         end;
         cache_keys_idx := -1;
         cache_user_idx := -1;
         count := 0;
      ensure
         is_empty;
      end;

feature -- To provide iterating facilities :

   lower: INTEGER is 1;

   upper: INTEGER is
      do
         Result := count;
      ensure
         Result = count
      end;

   valid_index(idx: INTEGER): BOOLEAN is
      do
         Result := (1 <= idx) and then (idx <= count);
      ensure
         Result =  (1 <= idx and then idx <= count);
      end;
   
   item(idx: INTEGER): V is
      require
         valid_index(idx)
      do
         set_cache_user_idx(idx);
         Result := store.item(cache_keys_idx);
      ensure
         Result = at(key(idx))
      end;
   
   key(idx: INTEGER): K is
      require
         valid_index(idx)
      do
         set_cache_user_idx(idx);
         Result := keys.item(cache_keys_idx);
      ensure
         at(Result) = item(idx)
      end;

   get_new_iterator_on_items: ITERATOR[V] is
      do
         !ITERATOR_ON_DICTIONARY_ITEMS[V]!Result.make(Current);
      end;

   get_new_iterator_on_keys: ITERATOR[K] is
      do
         !ITERATOR_ON_DICTIONARY_KEYS[K]!Result.make(Current);
      end;

feature
   
   is_equal(other: like current): BOOLEAN is
	 -- Do both dictionaries have the same set of associations?
	 -- Keys are compared with `is_equal' and values are comnpared
	 -- with the basic = operator.
	 -- See also `is_equal_map'.
      local
         buckets_idx, keys_idx: INTEGER;
         k: K;
         v1, v2: V;
      do
         if Current = other then
            Result := true;
         elseif count = other.count then
            from
               Result := true;
               buckets_idx := 0;
            until
               not Result or else buckets_idx > buckets.upper
            loop
               keys_idx := buckets.item(buckets_idx); 
               if keys_idx >= 0 then
                  from
                  until
                     not Result or else keys_idx < 0
                  loop
                     k := keys.item(keys_idx);
                     if other.has(k) then
                        v1 := store.item(keys_idx);
                        v2 := other.at(k);
                        Result := v1 = v2;
                     else
                        Result := false;
                     end;
                     keys_idx := chain.item(keys_idx);
                  end;
               end;
               buckets_idx := buckets_idx + 1;
            end;
         end;
      ensure
	 Result implies count = other.count
      end;

   is_equal_map(other: like current): BOOLEAN is
	 -- Do both dictionaries have the same set of associations?
	 -- Both keys and values are compared with `is_equal'.
	 -- See also `is_equal'.
      local
         buckets_idx, keys_idx: INTEGER;
         k: K;
         v1, v2: V;
      do
         if Current = other then
            Result := true;
         elseif count = other.count then
            from
               Result := true;
               buckets_idx := 0;
            until
               not Result or else buckets_idx > buckets.upper
            loop
               keys_idx := buckets.item(buckets_idx); 
               if keys_idx >= 0 then
                  from
                  until
                     not Result or else keys_idx < 0
                  loop
                     k := keys.item(keys_idx);
                     if other.has(k) then
                        v1 := store.item(keys_idx);
                        v2 := other.at(k);
                        Result := equal_like(v1,v2);
                     else
                        Result := false;
                     end;
                     keys_idx := chain.item(keys_idx);
                  end;
               end;
               buckets_idx := buckets_idx + 1;
            end;
         end;
      end;

   copy(other: like current) is
	 -- Reinitialize by copying all associations of `other'.
      do
         count := other.count;
         modulus := other.modulus;
         first_free_slot := other.first_free_slot;
         cache_keys_idx := other.cache_keys_idx;
         cache_user_idx := other.cache_user_idx;
         cache_buckets_idx := other.cache_buckets_idx;
         if buckets = Void then
            buckets := other.buckets.twin;
            keys := other.keys.twin;
            store := other.store.twin;
            chain := other.chain.twin;
         else
            buckets.copy(other.buckets);
            keys.copy(other.keys);
            store.copy(other.store);
            chain.copy(other.chain);
         end;
      end;

feature {NONE} 
   
   expand is
         -- The dictionary must grow.
      local
         i: INTEGER;
      do
         from
            i := keys.count;
            resize_buckets(i * 2 * buckets_keys_ratio);
         until
            i = 0
         loop
            chain.add_last(first_free_slot);
            first_free_slot := chain.upper;
            i := i - 1;
         end;
         keys.resize(chain.count);
         store.resize(chain.count);
      ensure
         first_free_slot >= 0
      end;

   resize_buckets(new_modulus: INTEGER) is
      local
         h, i: INTEGER;
      do
         modulus := new_modulus;
         buckets.resize(new_modulus);
         buckets.set_all_with(-1);
         from
         until
            first_free_slot < 0
         loop
            i := chain.item(first_free_slot);
            chain.put(-2,first_free_slot);
            first_free_slot := i;
         end;
         check 
            first_free_slot = -1;
         end;
         from
            i := chain.upper;
         until
            i < 0
         loop
            if chain.item(i) = -2 then
               chain.put(first_free_slot,i);
               first_free_slot := i;
            else
               h := keys.item(i).hash_code \\ new_modulus;
               chain.put(buckets.item(h),i);
               buckets.put(i,h);
            end;
            i := i - 1;
         end;
      end;

   equal_like(v1, v2: V): BOOLEAN is
         -- Note: to avoid calling `equal' :-(
         -- Because SmallEiffel is not yet able to infer 
         -- arguments types.
      do
         if v1.is_expanded_type then
            Result := v1 = v2 or else v1.is_equal(v2);
         elseif v1 = v2 then
            Result := true;
         elseif v1 = Void or else v2 = Void then
         else
            Result := v1.is_equal(v2);
         end;
      end;

   set_cache_user_idx(idx: INTEGER) is
      require
         valid_index(idx)
      local
         i: INTEGER;
      do
         if idx = cache_user_idx + 1 then
            cache_user_idx := idx;
            if chain.item(cache_keys_idx) < 0 then
               from
                  cache_buckets_idx := cache_buckets_idx + 1;
               until
                  buckets.item(cache_buckets_idx) >= 0
               loop
                  cache_buckets_idx := cache_buckets_idx + 1;
               end;
               cache_keys_idx := buckets.item(cache_buckets_idx);
            else
               cache_keys_idx := chain.item(cache_keys_idx);
            end;
         elseif idx = cache_user_idx - 1 then
            cache_user_idx := idx;
            if cache_keys_idx = buckets.item(cache_buckets_idx) then
               from
                  cache_buckets_idx := cache_buckets_idx - 1;
               until
                  buckets.item(cache_buckets_idx) >= 0
               loop
                  cache_buckets_idx := cache_buckets_idx - 1;
               end;
               from
                  cache_keys_idx := buckets.item(cache_buckets_idx);
               until
                  chain.item(cache_keys_idx) < 0
               loop
                  cache_keys_idx := chain.item(cache_keys_idx);
               end;
            else
               from
                  i := buckets.item(cache_buckets_idx);
               until
                  chain.item(i) = cache_keys_idx
               loop
                  i := chain.item(i);
               end;
               cache_keys_idx := i;
            end;
         elseif idx = cache_user_idx then
         elseif idx = 1 then
            cache_user_idx := 1;
            from
               cache_buckets_idx := 0;
            until
               buckets.item(cache_buckets_idx) >= 0
            loop
               cache_buckets_idx := cache_buckets_idx + 1;
            end;
            cache_keys_idx := buckets.item(cache_buckets_idx);
         elseif idx = count then
            cache_user_idx := idx;
            from
               cache_buckets_idx := buckets.upper;
            until
               buckets.item(cache_buckets_idx) >= 0
            loop
               cache_buckets_idx := cache_buckets_idx - 1;
            end;
            from
               cache_keys_idx := buckets.item(cache_buckets_idx);
            until
               chain.item(cache_keys_idx) < 0
            loop
               cache_keys_idx := chain.item(cache_keys_idx);
            end;
         else
            from
	       cache_user_idx := 1;
	       from
		  cache_buckets_idx := 0;
	       until
		  buckets.item(cache_buckets_idx) >= 0
	       loop
		  cache_buckets_idx := cache_buckets_idx + 1;
	       end;
	       cache_keys_idx := buckets.item(cache_buckets_idx);
            until
               cache_user_idx = idx
            loop
               set_cache_user_idx(cache_user_idx + 1);
            end;
         end;
      ensure
         cache_user_idx = idx;
         buckets.valid_index(cache_buckets_idx);
         keys.valid_index(cache_keys_idx);
      end;
   
invariant

   (keys.upper = store.upper) and (store.upper = chain.upper);

   buckets.upper = modulus - 1;

   -1 <= first_free_slot and first_free_slot <= chain.upper;
   
end -- DICTIONARY[V,K->HASHABLE]

