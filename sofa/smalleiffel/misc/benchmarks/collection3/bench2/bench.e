deferred class BENCH
--
-- ARRAY3 vs. FIXED_ARRAY3 for `swap'.
--
   
feature {NONE}

   tuning: INTEGER is 1000; -- 10_000_000 for me.

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
	 i, j, k, l, m, n, v, x : INTEGER;
         random: STD_RAND;
      do
         !!random.with_seed(256);
	 from until
	    i > upper1
	 loop
	    from until
	       j > upper2
	    loop
	       from until
	          k > upper3
	       loop
                  v := random.last_integer(4096);
                  random.next;
                  c3.put(v,i,j,k);
	          k := k + 1;
	       end;
               j := j + 1;
            end;
            i := i + 1;
	 end; 
	 from
            i := 0; j := 0; k:= 0;
	    x := tuning;
	 until
	    x = 0
	 loop
            l := random.last_integer(upper1);
            random.next;
            m := random.last_integer(upper2);
            random.next;
            n := random.last_integer(upper3);
            random.next;
            c3.swap(i,j,k,l,m,n);
            i := l;
            j := m;
            j := n;
            x := x - 1;
	 end; 
      end

   upper1, upper2, upper3: INTEGER is 50;

end
