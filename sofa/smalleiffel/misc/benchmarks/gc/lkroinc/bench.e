class BENCH

creation
   make
   
feature
   
   array_int: ARRAY[INTEGER]

   make is
      local 
	 size: INTEGER
	 i: INTEGER
      do
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
	       !!array_int.make(0,size)
	       size := size + 1
	    end
	    i := i - 1
	 end
      end
   
end
