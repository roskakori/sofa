class BENCH

creation
   make
   
feature
   
   make is
      local
	 apple: APPLE
	 apple_array: ARRAY[APPLE]
	 i, limit: INTEGER
      do
	 -- limit := 20_000_000    -- large config
	 limit := 2_000_000        -- small config
	 !!apple_array.make(1, limit)
	 from
	    i := 1
	 until
	    i > limit
	 loop
	    !!apple.make(i)
	    apple_array.put(apple, i)
	    i := i + 1
	 end
      end
end
