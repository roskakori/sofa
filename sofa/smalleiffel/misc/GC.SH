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
un=`uname`
if [ $un = Linux ]
 then
  gc=linux.c
elif [ $un = FreeBSD -o $un = BSD/OS -o $un = NetBSD -o $un = OpenBSD ]
 then
  gc=bsd.c
elif [ $un = SunOS ]
 then
  gc=sparc.c
elif [ $un = OSF1 ]
 then
  gc=alpha.c
elif [ $un = HP-UX ]
 then
  gc=hp-pa.c
elif [ $un = AIX ]
 then
  gc=aix.c
elif [ $un = QNX ]
 then
  gc=qnx.c
else
  echo GC is not supported for this architecture.
  echo Have a look in the SmallEiffel FAQ to try to fix this.
  echo Also read file ${SE}/gc_lib/generic.c to try to fix this.
  gc="NONE"
fi
echo GC for ${gc} selected \(${SE}/sys/gc updated\).
/bin/rm -rf gc
echo ${gc} > gc
