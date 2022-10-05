#!/bin/bash

REPS=3
DISTRS="uniform zipfian"
WORKLOADS="workloada workloadb workloadc"

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
echo "# Rep; Distribution; Workload; Throughput; Read Average Latency; Write Average Latency;" > $OUTF
for DISTR in $DISTRS; do
	for WORKLOAD in $WORKLOADS; do
		for REP in `seq 1 $REPS`; do
			FILE="$LOGD/log-run-$REP-$DISTR-$WORKLOAD.txt"
			TH=`cat $FILE | grep Throughput | cut -d ' ' -f 3`
			WAVGLAT=`cat $FILE | grep "\[UPDATE\], AverageLatency" | cut -d ' ' -f 3`
			RAVGLAT=`cat $FILE | grep "\[READ\], AverageLatency" | cut -d ' ' -f 3`
			echo "$REP;$DISTR;$WORKLOAD;$TH;$RAVGLAT;$WAVGLAT;" >> $OUTF
		done
		echo ";" >> $OUTF
	done
done

