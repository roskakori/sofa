class BENCH

creation make

feature

   -- tuning : INTEGER is 4_000_000;   -- large config
   tuning : INTEGER is 1_000_000;      -- small config

   link1, link2 : LINK[INTEGER];

   make is
      local
	 i,j : INTEGER;
      do
	 from
	    j := 0;
	 until
	    j > 12
	 loop
	    link1 := Void;
	    link2 := Void;
	    from
	       i := 1;
	    until
	       i > tuning
	    loop
	       link2 := link1;
	       !!link1.make(i,link2);
	       i := i + 1;
	    end
	    j := j + 1;
	 end
      end;
   
end
