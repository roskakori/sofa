#!/bin/sh
#
# To INSTALL SmallEiffel on UNIX like platforms (including LINUX).
#
# If you have the gcc compiler, simply run this script.
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
echo "Running the new installation procedure :"
echo "    " cd ${SE}
echo "    " make
echo "    "
cd ${SE}
make
echo Done.
