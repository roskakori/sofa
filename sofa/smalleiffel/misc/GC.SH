#!/bin/sh
#
# Try to choose automatically the good SmallEiffel/sys/gc_lib/*.c
# file for the Garbage Collector on a Unix system.
#
sed=${SmallEiffel:=1}
if [ ${sed} = 1 ];  then 
   echo Please set the environment Variable \'SmallEiffel\' with
   echo the absolute path of file SmallEiffel/sys/system.se
   exit 1
fi
if [ -d ${SmallEiffel} ]; then 
   echo Since release -0.79 the value of the environment
   echo variable SmallEiffel should be the absolute path of
   echo file SmallEiffel/sys/system.se
   echo Trying to fix this automatically.
   SmallEiffel=${SmallEiffel}/sys/system.se
fi
if [ ! -f ${SmallEiffel} ]; then
   echo File ${SmallEiffel} not found.
   echo Please check the value of the environment Variable
   echo \'SmallEiffel\' wich must be the absolute path of 
   echo the file SmallEiffel/sys/system.se
   exit 1
fi
SE=`dirname $SmallEiffel`
SE=`dirname $SE`
if [ -f ${SE} ]; then
   echo ${SE} "not found."
   exit 1
fi
cd ${SE}/sys
if [ `uname` = Linux ]
 then
  gc=linux.c
elif [ `uname` = FreeBSD ]
 then
  gc=freebsd.c
elif [ `uname` = SunOS ]
 then
  gc=sparc.c
elif [ `uname` = OSF1 ]
 then
  gc=alpha.c
elif [ `uname` = HP-UX ]
 then
  gc=hp-pa.c
elif [ `uname` = AIX ]
 then
  gc=aix.c
else
  echo GC is not supported for this architecture.
  echo Read file ${SE}/sys/gc to try to fix this.
  gc="NONE"
fi
echo GC for ${gc} selected \(${SE}/sys/gc updated\).
/bin/rm -rf gc_tmp
echo ${gc} > gc_tmp
cat gc >> gc_tmp
mv -f gc_tmp gc
