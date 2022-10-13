#!/bin/bash

REPS=3

CONNS="1 4 8 10 16 20 24 30"

if [ $# -lt 1 ]; then
	echo "Usage: $0 <logs folder>"
	exit 1
fi
LOGD=$1
if ! [ -d $LOGD ]; then
	echo "Not a folder: $1"
	exit 1
fi

OUTF="data-$LOGD.csv"
echo "# Rep; Connections; Throughput;" > $OUTF
for CONN in $CONNS; do
	for REP in `seq 1 $REPS`; do
		FILE="$LOGD/log-tpcc-$CONN-$REP.txt"
		TH=`cat $FILE | grep " TpmC" | tr -d ' ' | cut -d 'T' -f 1`
		echo "$REP;$CONN;$TH;" >> $OUTF
	done
	echo ";" >> $OUTF
done

