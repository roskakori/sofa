class BENCH

creation
   make
   
feature
   
   make is
      local
	 i: INTEGER
      do
	 from
	    i := 350;
	 until
	    i < 0
	 loop
	    -- recurse(50_000);   -- large config
	    recurse(30_000);      -- small config
	    i := i - 1;
	 end
      end
   
   recurse (i: INTEGER) is
      local
	 p: POINT
      do
	 !!p.make(1.0, 2.0);
	 if i /= 0 then
	    recurse(i-1);
	 end
      end
end

