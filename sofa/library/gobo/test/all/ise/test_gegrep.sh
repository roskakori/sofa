#!/bin/sh

mkdir gegrep
cd gegrep
if [ "$1" = "-finalize" ]; then
	cp $GOBO/example/lexical/gegrep/ise.ace Ace.ace
	es4 -finalize | grep -v "\(Degree\|Generation of auxiliary files\|You must now run\|EIFGEN[\\/]F_code$\|Features done:\)"
	cd EIFGEN/F_code
	finish_freezing -silent > tmp11.txt 2>&1
else
	sed "s/--assertion (all)/assertion (all)/g" $GOBO/example/lexical/gegrep/ise.ace > Ace.ace
	es4 | grep -v "\(Degree\|Generation of auxiliary files\|You must now run\|EIFGEN[\\/]W_code$\)"
	cd EIFGEN/W_code
	finish_freezing -silent > tmp11.txt 2>&1
fi

if [ -x gegrep ]; then
	$GOBO/test/all/common/test_gegrep.sh > tmp12.txt 2>&1
	if [ -s tmp12.txt ]; then
		cat tmp12.txt
		echo "Test failed"
	else
		echo "Test successful"
	fi
else
	cat tmp11.txt
	echo "Test failed"
fi
