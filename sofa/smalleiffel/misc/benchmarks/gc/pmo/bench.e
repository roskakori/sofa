class BENCH

creation
   make
   
feature
   
   fruit_array: ARRAY[FRUIT];

   apple: APPLE;
   
   peach: PEACH;

   make is
      local
	 i, limit: INTEGER
      do
	 limit := 2_500_000
	 !!fruit_array.make(1,limit)
	 -- Filling `fruit_array' with apples :
	 from
	    i := 1
	 until
	    i > limit
	 loop
	    !!apple.make(i)
	    fruit_array.put(apple, i)
	    i := i + 1
	 end
	 -- To clear `fruit_array' contents :
	 from
	    i := 1
	 until
	    i > limit
	 loop
	    fruit_array.put(Void, i)
	    i := i + 1
	 end
	 -- Filling `fruit_array' with peaches :
	 from
	    i := 1
	 until
	    i > limit
	 loop
	    !!peach.make(i)
	    fruit_array.put(peach, i)
	    i := i + 1
	 end
      end
end
