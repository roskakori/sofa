class ARRAY3_BENCH

inherit BENCH;

creation make
   
feature

   make is
      local
         c3: ARRAY3[INTEGER];
      do
         !!c3.make(0,upper1,0,upper2,0,upper3);
         do_test_for(c3);
      end;

end

