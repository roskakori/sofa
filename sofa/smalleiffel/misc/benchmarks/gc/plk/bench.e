class BENCH

creation
   make
   
feature
   
   peach: PEACH;

   apple: APPLE;

   make is
      local
	 i, limit: INTEGER
      do
	 limit := 70_000_000
	 from
	    i := 0
	 until
	    i > limit
	 loop
	    !!apple.make(i)
	    i := i + 1
	 end
	 apple := Void
	 from
	    i := 0
	 until
	    i > limit
	 loop
	    !!peach.make(i)
	    i := i + 1
	 end
      end
   
end
