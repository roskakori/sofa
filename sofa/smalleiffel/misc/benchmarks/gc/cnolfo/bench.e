class BENCH

creation make

feature
   
   array: ARRAY[TRIANGLE];
	
   t: TRIANGLE;
	
   p1, p2, p3: POINT;

   many: INTEGER is 2_000;

   make is
      local
   	 i,j: INTEGER;
      do
	 from
	    i := 4000;
	    !!array.make(1,many);
	 until
	    i = 0
	 loop
	    from
	       j := many;
	    until
	       j = 0
	    loop
	       !!p1.make(1.0,1.0);
	       !!p2.make(2.0,2.0);
	       !!p3.make(3.0,3.0);
	       !!t.make(p1,p2,p3);
	       array.put(t,j);
	       j := j - 1;
	    end;
	    i := i - 1;
	 end;
      end;
end
