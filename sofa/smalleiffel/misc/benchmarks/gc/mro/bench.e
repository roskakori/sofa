class BENCH

creation
   make
   
feature
   
   array_of_array: ARRAY[ARRAY[INTEGER]];
   
   -- timing: INTEGER is 5_000_000;   -- large config
   timing: INTEGER is 200_000;        -- small config  

   make is
      local
	 i, limit: INTEGER;
      do
	 -- limit := 7_000_000        -- large config 
	 limit := 500_000             -- small config
	 !!array_of_array.make(1, limit)
	 from
	    i := 1
	 until
	    i > limit
	 loop
	    array_of_array.put(<<i,2*i>>, i)
	    i := i + 1
	 end
	 from
	    i := timing;
	 until
	    i = 0
	 loop
	    array_of_array.put(Void,i)
	    i := i - 1;
	 end;
      end
end
