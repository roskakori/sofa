#!/bin/csh -f
#
# To INSTALL SmallEiffel on UNIX like platforms (including LINUX).
#
# If you have the gcc compiler, simply run this script.
#
if (!($?SmallEiffel)) then
   echo Please set the environment Variable 'SmallEiffel' with
   echo the absolute path of file SmallEiffel/sys/system.se
   exit 1
endif
if (-d $SmallEiffel) then
   echo Since release -0.79 the value of the environment
   echo variable SmallEiffel should be the absolute path of
   echo file SmallEiffel/sys/system.se
   echo Trying to fix this automatically.
   set SmallEiffel=${SmallEiffel}/sys/system.se
endif
if (! -f ${SmallEiffel}) then
   echo File ${SmallEiffel} not found.
   echo Please check the value of the environment Variable
   echo 'SmallEiffel' wich must be the absolute path of 
   echo the file SmallEiffel/sys/system.se
   exit 1
endif
if (`basename $SmallEiffel` != "system.se") then
   echo Please check the value of the environment Variable
   echo 'SmallEiffel' wich must be the absolute path of 
   echo the file SmallEiffel/sys/system.se
   exit 1
endif
set SE=`dirname $SmallEiffel`
set SE=`dirname $SE`
if (! -d ${SE}) then
   echo SmallEiffel home directory ${SE} not found.
   echo Please check the value of the environment Variable
   echo 'SmallEiffel' wich must be the absolute path of 
   echo the file SmallEiffel/sys/system.se
   exit 1
endif
echo "Running the new installation procedure :"
echo "    " cd ${SE}
echo "    " make
echo "    "
cd ${SE}
make
echo Done.
