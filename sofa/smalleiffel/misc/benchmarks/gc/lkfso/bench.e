class BENCH

creation make

feature

   t: TRIANGLE;
	
   p1, p2, p3: POINT;

   make is
      local
	 i: INTEGER;
      do
	 from
	    i := 23_000_000;

	 until
	    i = 0
	 loop
	    !!p1.make(i,i);
	    !!p2.make(i+1,i+1);
	    !!p3.make(i+2,i+2);
	    !!t.make(p1,p2,p3);
	    i := i - 1;
	 end;
      end;

end
