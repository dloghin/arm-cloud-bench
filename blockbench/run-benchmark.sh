#!/bin/bash

set -x

DRIVER="/home/$USER/git/blockbench/src/macro/kvstore/driver"
WORKLOAD="/home/$USER/git/blockbench/src/macro/kvstore/workloads/workloada.spec"
TXRATES="100"
DURATION=120
DRIVERS_PER_CLIENT=4
PEER="127.0.0.1"

TSTAMP=`date +%F-%H-%M-%S`
LOGDIR="fabric-logs-$TSTAMP"

mkdir $LOGDIR
cd $LOGDIR
for TXR in $TXRATES; do
	mkdir logs-$TXR
	cd logs-$TXR
	for M in `seq 1 $DRIVERS_PER_CLIENT`; do
		$DRIVER -db fabric-v2.2 -threads 1 -P $WORKLOAD -txrate $TXR -endpoint $PEER:8800,$PEER:8801 -wl ycsb -wt 20 > client-peer1-driver-$M.log 2>&1 &
		$DRIVER -db fabric-v2.2 -threads 1 -P $WORKLOAD -txrate $TXR -endpoint $PEER:8802,$PEER:8803 -wl ycsb -wt 20 > client-peer2-driver-$M.log 2>&1 &
	done
	sleep $DURATION
	killall -9 driver
	cd ..
done
cd ..
tar cjf $LOGDIR.tar.bz2 $LOGDIR
