class BENCH

creation make
   
feature
   
   array_int: ARRAY[INTEGER];



   make is
      local 
	 random: STD_RAND;
	 size: INTEGER;
	 i: INTEGER;
      do
	 !!random.with_seed(74363);
	 from
	    i := 150;
	 until
	    i = 0
	 loop
	    from
	       size := 0
	    until
	       size = 5000
	    loop
	       !!array_int.make(0,random.last_integer(5000));
	       random.next;
	       size := size + 1
	    end
	    i := i - 1
	 end
      end

end
