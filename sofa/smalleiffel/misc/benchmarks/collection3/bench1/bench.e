deferred class BENCH
--
-- ARRAY3 vs. FIXED_ARRAY3 for `item'/`put'.
--

feature {NONE}

   -- Features `upper1', `upper2' and `upper3' may be changed 
   -- according to the power of your computer.

   upper1, upper2, upper3: INTEGER is 20; -- 150 for me;

   do_test_for(c3: COLLECTION3[INTEGER]) is
      require
         c3.lower1 = 0;
         c3.lower2 = 0;
         c3.lower2 = 0;
         c3.upper1 = upper1;
         c3.upper2 = upper2;
         c3.upper3 = upper3;
         c3.count1 = upper1 + 1;
         c3.count2 = upper2 + 1;
         c3.count3 = upper3 + 1
      local
	 i, j, k, v, max: INTEGER;
         random: STD_RAND;
      do
         !!random.with_seed(256);
	 from 
            i := c3.upper1;
         until
	    i < c3.lower1
	 loop
	    from
               j := c3.upper2;
            until
	       j < c3.lower2
	    loop
	       from 
                  k := c3.upper3;
               until
	          k < c3.lower3
	       loop
                  v := random.last_integer(4096);
                  random.next;
                  c3.put(v,i,j,k);
	          k := k - 1;
	       end;
               j := j - 1;
            end;
            i := i - 1;
	 end; 
	 from
	    i := c3.upper1;
	 until
	    i < c3.lower1
	 loop
	    from
	       j := c3.upper2;
	    until
	       j < c3.lower2
	    loop
	       from
	          k := c3.upper3;
	       until
	          k < c3.lower3
	       loop
                  v := c3.item(i,j,k);
                  max := max.max(v);
	          k := k - 1;
	       end;
               j := j - 1;
            end;
            i := i - 1;
	 end; 
      end

end
