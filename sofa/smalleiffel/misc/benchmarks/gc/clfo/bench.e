class BENCH

creation make

feature
   
   s1, s2: STRING;
   
   make is
      local
   	 i: INTEGER;
      do
	 !!s1.make(64_000);
	 from
	    i := 50_000;
	 until
	    i = 0
	 loop
	    !!s2.make(64_000);
	    i := i - 1;
	 end;
      end;
end
