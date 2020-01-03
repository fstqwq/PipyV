#!/bin/sh
for f in ./testcase/*.c
do
	echo ${f%.*}
	if [ ! -f ${f%.*}.in ]; then
		bash ./myr.sh $f > tmp.ans
		./makeans
		diff tmp.ans ${f%.*}.ans
	fi
done
