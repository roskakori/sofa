class BENCH

creation make
   
feature
   
   make is
      local
	 i: INTEGER;
      do
	 from
	    i := 9;
	 until
	    i = 0
	 loop
	    -- recurse(50_000); -- large config
	    recurse(20_000);    -- small config
	    i := i - 1;
	 end
      end
   
   recurse (i: INTEGER) is
      local
	 p: POINT
	 j: INTEGER
      do
	 if i /= 0 then
	    recurse(i-1);
	 else
	    -- trigger the GC
	    from
	       j := 7_000_000
	    until
	       j < 0
	    loop
	       !!p.make(1.0, 2.0)
	       j := j - 1
	    end
	 end
      end
   
   end
