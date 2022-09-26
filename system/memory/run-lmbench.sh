#!/bin/bash

dateuid=`date +%F-%H-%M-%S`
sys=`cat /etc/hostname`

if ! [ -d "lmbench/bin" ]; then
	echo "No lmbench folder or bin folder!"
	exit 1
fi

EXEC="`pwd`/lmbench/bin/bw_mem"
if ! [ -e $EXEC ]; then
	echo "lmbench executable not found: $EXEC"
	exit 1
fi

TYPE_LIST="rd wr rdwr"
SIZE_LIST="1k 2k 4k 8k 16k 32k 64k 128k 256k 512k 1m 2m 4m 8m 16m 32m 64m 128m 256m 512m 1024m 2048m 4096m"

FILE_LIST=""
for TYPE in $TYPE_LIST; do
	FILE="lmbench-$sys-$dateuid-$TYPE.csv"
	if [ -z "$PERF" ]; then
		echo "#Size;ActualSize[MB];BW[MB/s];Type;" > $FILE
	else
		echo "#Size;ActualSize[MB];BW[MB/s];Type;Freq;L1 access;L1 misses;L2 access;L2 misses;" > $FILE
	fi
	for SIZE in $SIZE_LIST; do
		if [ -z "$PERF" ]; then
			$EXEC $SIZE $TYPE 2> tmp
			BW=`cat tmp | tr ' ' ';'`
			echo "$SIZE;$BW;$TYPE" >> $FILE
		else
			PERF_FILE="perf-lmbench-$sys-$dateuid-$TYPE-$SIZE.log"
			$PERF -o $PERF_FILE $EXEC $SIZE $TYPE 2> tmp
			BW=`cat tmp | tr ' ' ';'`
			L1CA=`cat $PERF_FILE | grep r004 | tr -s ' ' | cut -d ' ' -f 2 | tr -d ','`
			L1CM=`cat $PERF_FILE | grep r003 | tr -s ' ' | cut -d ' ' -f 2 | tr -d ','`
			L2CA=`cat $PERF_FILE | grep r016 | tr -s ' ' | cut -d ' ' -f 2 | tr -d ','`
			L2CM=`cat $PERF_FILE | grep r017 | tr -s ' ' | cut -d ' ' -f 2 | tr -d ','`
			FREQ=`cat $PERF_FILE | grep cycles | tr -s ' ' | cut -d ' ' -f 5 | tr -d ','`
			echo "$SIZE;$BW;$TYPE;$FREQ;$L1CA;$L1CM;$L2CA;$L2CM;" >> $FILE
			FILE_LIST="$FILE_LIST $PERF_FILE"
		fi
	done
	FILE_LIST="$FILE_LIST $FILE"
done
tar -cjf lmbench-$sys-$dateuid.tar.bz2 $FILE_LIST
rm tmp
