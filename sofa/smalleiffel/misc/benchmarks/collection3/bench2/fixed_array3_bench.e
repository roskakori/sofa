class FIXED_ARRAY3_BENCH

inherit BENCH;

creation make
   
feature

   make is
      local
         c3: FIXED_ARRAY3[INTEGER];
      do
         !!c3.make(upper1 + 1, upper2 + 1, upper3 + 1);
         do_test_for(c3);
      end;

end

