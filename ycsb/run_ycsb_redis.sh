#!/bin/bash

THREADS=20

BASECMD1="python2 ycsb-0.17.0/bin/ycsb load redis -threads $THREADS -s"
BASECMD2="python2 ycsb-0.17.0/bin/ycsb run redis -threads $THREADS -s"
CMDSUFFIX="-p redis.host=127.0.0.1 -p redis.port=6379"

REPS=3
DISTRS="uniform zipfian"
WORKLOADS="workloada workloadb workloadc"

TSTP=`date +%F-%H-%M-%S`
LOGD="logs-$TSTP"
mkdir $LOGD

set -x

for REP in `seq 1 $REPS`; do
	for DISTR in $DISTRS; do
		for WORKLOAD in $WORKLOADS; do
			redis-cli flushall
			sleep 3
			$BASECMD1 -P workloads_$DISTR/$WORKLOAD $CMDSUFFIX | tee $LOGD/log-load-$REP-$DISTR-$WORKLOAD.txt
			$BASECMD2 -P workloads_$DISTR/$WORKLOAD $CMDSUFFIX | tee $LOGD/log-run-$REP-$DISTR-$WORKLOAD.txt
		done
	done
done

