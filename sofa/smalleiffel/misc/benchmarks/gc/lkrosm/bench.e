class BENCH

creation make 

feature

   s: STRING

   make is
      local
	 i, j: INTEGER;
      do
	 from
	    i := 350_000;
	 until
	    i = 0
	 loop
	    from
	       j := 80;
	    until
	       j = 40
	    loop
	       !!s.make(j);
	       j := j - 1;
	    end;	 
	    i := i - 1;
	 end;
      end;

end

