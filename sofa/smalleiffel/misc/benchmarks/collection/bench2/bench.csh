#!/bin/csh -f
#
# Run this file to have a comparison 
#
foreach b (*_bench.e)
   set cmd="compile -clean $b make -no_split -boost -O3"
   $cmd 
   echo "$b : "
   time a.out 
   /bin/rm -f a.out
end
