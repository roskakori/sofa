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
class SET[E->HASHABLE]
   --
   -- Definition of a mathematical set of hashable objects. All common 
   -- operations on mathematical sets are available.
   --

inherit ANY redefine is_equal, copy end
   
creation make, with_capacity

feature

   Default_size: INTEGER is 32;
	 -- Minimum size for storage in number of items.
   
feature {SET}
   
   keys: FIXED_ARRAY[E]
	 -- Storage for values of type `E'.
   
   modulus: INTEGER;
	 -- To compute a hash value in range [0..`modulus'-1].
   
   buckets: FIXED_ARRAY[INTEGER];
	 -- Valid index range is always [0..`modulus'-1].
	 -- Contents is a hash code value in range [0..`keys.upper'] 
	 -- to access `keys' and `chain' as well.

   chain: FIXED_ARRAY[INTEGER];
	 -- Used to chain both free slots and hash-code clash.
	 -- Value -1 mark the end of a list.

   first_free_slot: INTEGER;
	 -- First element of the free-slot list or -1 when no more 
	 -- free slot are available.

feature {SET} -- Internal cache handling:

   cache_keys_idx: INTEGER;
	 -- Contents is -1 or caches the last visited entry using: 
	 -- `has' or `item'.

   cache_user_idx: INTEGER;
	 -- Contents is -1 or in range [1..`count']. When not -1, it caches 
	 -- the last user's index used with `item'.

   cache_buckets_idx: INTEGER;
	 -- Contents means nothing when `cache_user_idx' is -1. 
	 -- Otherwise, gives the current position in `buckets' during 
	 -- traversal.

feature {NONE}

   buckets_keys_ratio: INTEGER is 3;
	 -- To compute `modulus' as `ratio' * `capacity'.

   make is
	 -- Create an empty set. Internal initial storage size of the 
	 -- set is set to the default `Default_size' value. Then, 
	 -- tuning of needed storage size is done automatically 
	 -- according to usage. If you are really sure that your set 
	 -- is always really bigger than `Default_size', you may use 
	 -- `with_capacity' to save some execution time.
      do
	 with_capacity(Default_size);
      ensure
	 is_empty;
	 capacity = Default_size
      end

   with_capacity(medium_size: INTEGER) is
      -- May be used to save some execution time if one is sure that 
      -- storage size will rapidly become really bigger than 
      -- `Default_size'. When first `remove' occurs, storage size may 
      -- naturally become smaller than `medium_size'. Afterall, tuning 
      -- of storage size is done automatically according to usage.
      require
	 medium_size > 0
      local
	 i: INTEGER;
      do
	 !!keys.make(medium_size);
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
	 -- Cardinal of the set

   capacity: INTEGER is
      do
	 Result := keys.count;
      end;

   is_empty: BOOLEAN is
	 -- Is the set empty ?
      do
	 Result := (count = 0);
      ensure
	 Result = (count = 0);
      end
   
feature -- Constructors and destructors
   
   add(e: like item) is
	 -- Add a new item to the set: the mathematical definition of 
	 -- adding in a set is followed.
      local
	 h: INTEGER;
      do
	 if cache_keys_idx < 0 or else e /= keys.item(cache_keys_idx) then
	    from
	       cache_user_idx := -1;
	       h := e.hash_code \\ modulus;
	       cache_keys_idx := buckets.item(h);
	    until
	       cache_keys_idx < 0 or else
	       e.is_equal(keys.item(cache_keys_idx))
	    loop
	       cache_keys_idx := chain.item(cache_keys_idx);
	    end;
	    if cache_keys_idx < 0 then
	       if first_free_slot < 0 then
		  expand;
		  h := e.hash_code \\ modulus;
	       end;
	       keys.put(e,first_free_slot);
	       cache_keys_idx := first_free_slot;
	       first_free_slot := chain.item(first_free_slot);
	       chain.put(buckets.item(h), cache_keys_idx);
	       buckets.put(cache_keys_idx,h);
	       count := count + 1;
	    else
	       -- `e' is already in the set
	    end;
	 else
	    -- `e' is already in the set
	 end;
      ensure
	 added: has(e) ;
	 not_in_then_added: not(old has(e)) implies count = old count + 1 ;
	 in_then_not_added: old(has(e)) implies count = old count
      end
   
   remove(e: like item) is
	 -- Remove item `e' from the set: the mathematical definition of 
	 -- removing from a set is followed.
      local
	 h, keys_idx, keys_next_idx: INTEGER;
      do
	 h := e.hash_code \\ modulus;
	 keys_idx := buckets.item(h);
	 if keys_idx < 0 then
	    -- nothing
	 elseif keys.item(keys_idx).is_equal(e) then
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
	       keys.item(keys_next_idx).is_equal(e)
	    loop
	       keys_idx := keys_next_idx;
	       keys_next_idx := chain.item(keys_next_idx);
	    end;
	    if keys_next_idx >=0 then
	       chain.put(chain.item(keys_next_idx), keys_idx);
	       chain.put(first_free_slot, keys_next_idx);
	       first_free_slot := keys_next_idx;
	       cache_keys_idx := -1;
	       cache_user_idx := -1;
	       count := count - 1;
	    end;
	 end;
      ensure
	 removed: not has(e) ;
	 not_in_not_removed: not(old has(e)) implies count = old count ;
	 in_then_removed: old has(e) implies count = old count - 1 
      end
   
   clear is
	 -- Empty the current set
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
	 is_empty
      end
   
feature -- Looking and searching :
   
   has(e: like item): BOOLEAN is
	 -- Is `e' in the set ?
      do
	 if cache_keys_idx < 0 or else e /= keys.item(cache_keys_idx)  then
	    from
	       cache_user_idx := -1;
	       cache_keys_idx := buckets.item(e.hash_code \\ modulus);
	    until
	       cache_keys_idx < 0 or else
	       e.is_equal(keys.item(cache_keys_idx))
	    loop
	       cache_keys_idx := chain.item(cache_keys_idx);
	    end;
	 end;
	 Result := (cache_keys_idx >= 0);
      ensure
	 Result implies (not is_empty)
      end

feature -- Accessing

   item(i: INTEGER): E is
	 -- Return the item indexed by `i'
      require
	 valid_index(i)
      do
	 set_cache_user_idx(i);
	 Result := keys.item(cache_keys_idx);
      ensure
	 has(Result)
      end
   
   valid_index(index: INTEGER): BOOLEAN is
      do
	 Result := index.in_range(1,count);
      ensure
	 Result = index.in_range(1,count)
      end
   
   get_new_iterator: ITERATOR[E] is
      do
	 !ITERATOR_ON_SET[E]!Result.make(Current);
      end

feature -- Mathematical operations

   union(other: like Current) is
	 -- Make the union of the current set with `other'
      require
	 other /= Void
      local
	 buckets_idx, keys_idx: INTEGER;
	 k: like item;
      do
	 from
	    buckets_idx := 0;
	 until
	    buckets_idx > other.buckets.upper
	 loop
	    keys_idx := other.buckets.item(buckets_idx);
	    if keys_idx >= 0 then
	       from
	       until
		  keys_idx < 0
	       loop
		  k := other.keys.item(keys_idx);
		  add(k);
		  keys_idx := other.chain.item(keys_idx);
	       end;
	    end;
	    buckets_idx := buckets_idx + 1;
	 end;
      ensure
	 count <= old count + other.count
      end
   
   infix "+" (other: like Current): like Current is
	 -- Return the union of the current set with `other'
      require
	 other /= Void
      do
	 Result := twin ;
	 Result.union(other) ;
      ensure
	 Result.count <= count + other.count;
	 Current.is_subset_of(Result) and then
	 other.is_subset_of(Result)
      end 

   intersection(other: like Current) is
	 -- Make the intersection of the current set with `other'
      require
	 other /= Void
      local
	 buckets_idx, keys_idx: INTEGER;
	 k: like item;
      do
	 from
	    buckets_idx := 0;
	 until
	    buckets_idx > buckets.upper
	 loop
	    keys_idx := buckets.item(buckets_idx);
	    if keys_idx >= 0 then
	       from
	       until
		  keys_idx < 0
	       loop
		  k := keys.item(keys_idx);
		  keys_idx := chain.item(keys_idx);
		  if not other.has(k) then
		     remove(k);
		  end;
	       end;
	    end;
	    buckets_idx := buckets_idx + 1;
	 end;
      ensure
	 count <= other.count.min(old count);
      end

   infix "^" (other: like Current): like Current is
	 -- Return the intersection of the current set with `other'
      require
	 other /= Void
      do
	 Result := twin;
	 Result.intersection(other) ;
      ensure
	 Result.count <= other.count.min(count);
	 Result.is_subset_of(Current) and then
	 Result.is_subset_of(other)
      end

   minus(other: like Current) is
	 -- Make the set `Current' - `other'
      require
	 other /= Void
      local
	 buckets_idx, keys_idx: INTEGER;
	 k: like item;
      do
	 from
	    buckets_idx := 0;
	 until
	    buckets_idx > other.buckets.upper
	 loop
	    keys_idx := other.buckets.item(buckets_idx);
	    if keys_idx >= 0 then
	       from
	       until
		  keys_idx < 0
	       loop
		  k := other.keys.item(keys_idx);
		  remove(k);
		  keys_idx := other.chain.item(keys_idx);
	       end;
	    end;
	    buckets_idx := buckets_idx + 1;
	 end;
      ensure
	 count <= old count
      end

   infix "-" (other: like Current): like Current is
	 -- Return  the set `Current' - `other'
      require
	 other /= Void
      do
	 Result := twin ;
	 Result.minus(other) ;
      ensure
	 Result.count <= count;
	 Result.is_subset_of(Current)
      end

feature -- Comparison:

   is_subset_of(other: like Current): BOOLEAN is
	 -- Is the current set a subset of `other' ?
      require
	 other /= Void
      local
	 buckets_idx, keys_idx: INTEGER;
	 k: like item;
      do
	 If Current = other then
	    Result := true;
	 elseif count <= other.count then
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
		     Result := other.has(k);
		     keys_idx := chain.item(keys_idx);
		  end;
	       end;
	       buckets_idx := buckets_idx + 1;
	    end;
	 end;
      ensure
	 Result implies count <= other.count
      end

   is_disjoint_from(other: like Current): BOOLEAN is
	 -- Is the current set disjoint from `other' ?
      require
	 other /= Void
      local
	 buckets_idx, keys_idx: INTEGER;
	 k: like item;
      do
	 If Current = other then
	    Result := false;
	 else
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
		     Result := not(other.has(k));
		     keys_idx := chain.item(keys_idx);
		  end;
	       end;
	       buckets_idx := buckets_idx + 1;
	    end;
	 end;
      ensure
	 Result = (Current ^ other).is_empty
      end

   is_equal(other: like Current): BOOLEAN is
	 -- Is the current set equal to `other' ?
      local
	 buckets_idx, keys_idx: INTEGER;
	 k: like item;
      do
	 If Current = other then
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
		     Result := other.has(k);
		     keys_idx := chain.item(keys_idx);
		  end;
	       end;
	       buckets_idx := buckets_idx + 1;
	    end;
	 end;
      ensure then
	 double_inclusion: Result = (is_subset_of(other) and
				     other.is_subset_of(Current))
      end

feature 

   copy(other: like Current) is
	 -- Copy 'other' into the current set
      do
	 count := other.count;
	 modulus := other.modulus;
	 first_free_slot := other.first_free_slot;
	 cache_keys_idx := other.cache_keys_idx;
	 cache_user_idx := other.cache_user_idx;
	 cache_buckets_idx := other.cache_buckets_idx;
	 if buckets = Void then
	    buckets :=  other.buckets.twin;
	    keys := other.keys.twin;
	    chain := other.chain.twin;
	 else
	    buckets.copy(other.buckets);
	    keys.copy(other.keys);
	    chain.copy(other.chain);
	 end;
      end

feature {NONE}

   expand is
	 -- The set must grow.
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
      ensure
	 first_free_slot >= 0
      end;

   resize_buckets(new_modulus: INTEGER) is
      local
	 h,i: INTEGER;
      do
	 modulus := new_modulus;
	 buckets.resize(new_modulus);
	 buckets.set_all_with(-1);
	 from
	 until
	    first_free_slot < 0
	 loop
	    i := chain.item(first_free_slot);
	    chain.put(-2, first_free_slot);
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
	       chain.put(first_free_slot, i);
	       first_free_slot := i;
	    else
	       h := keys.item(i).hash_code \\ new_modulus;
	       chain.put(buckets.item(h),i);
	       buckets.put(i,h);
	    end;
	    i := i - 1;
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

   buckets.upper = modulus - 1;
   -1 <= first_free_slot and first_free_slot <= chain.upper;

   emptiness: is_empty implies count = 0;
   not_emptiness: count > 0 implies not is_empty;

end -- SET[E->HASHABLE]
