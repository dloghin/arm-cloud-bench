#!/bin/bash

set -x 

DB="redis"
DB="memcached"
DB="rocksdb"

if [ $# -gt 0 ]; then
	DB=$1
fi

THREADS=20

BASECMD1="python2 ycsb-0.17.0/bin/ycsb load $DB -threads $THREADS -s"
BASECMD2="python2 ycsb-0.17.0/bin/ycsb run $DB -threads $THREADS -s"

if [ "$DB" == "redis" ]; then
	CMDSUFFIX="-p redis.host=127.0.0.1 -p redis.port=6379"
	CMDCLEAN="redis-cli flushall"
elif [ "$DB" == "memcached" ]; then
	CMDSUFFIX="-p memcached.hosts=127.0.0.1"
	CMDCLEAN="echo 'flush_all' | netcat -q 1 localhost 11211"
elif [ "$DB" == "rocksdb" ]; then
	CMDSUFFIX="-p rocksdb.dir=ycsb-rocksdb-data"
	CMDCLEAN="rm -rf ycsb-rocksdb-data"
else
	echo "Unknown db: $DB"
	exit 1
fi

# PERF_CMD="sudo perf record -p 990"

REPS=3
DISTRS="uniform zipfian"
# DISTRS="uniform"
WORKLOADS="workloada workloadb workloadc"

TSTP=`date +%F-%H-%M-%S`
LOGD="logs-$DB-$THREADS-threads-$TSTP"
mkdir $LOGD

set -x

for REP in `seq 1 $REPS`; do
	for DISTR in $DISTRS; do
		for WORKLOAD in $WORKLOADS; do
			$CMDCLEAN
			sleep 3
			$BASECMD1 -P workloads_$DISTR/$WORKLOAD $CMDSUFFIX | tee $LOGD/log-load-$REP-$DISTR-$WORKLOAD.txt
			if ! [ -z "$PERF_CMD" ]; then
				$PERF_CMD &
			fi
			$BASECMD2 -P workloads_$DISTR/$WORKLOAD $CMDSUFFIX | tee $LOGD/log-run-$REP-$DISTR-$WORKLOAD.txt
			if ! [ -z "$PERF_CMD" ]; then
				sudo killall -SIGINT perf
				sleep 1
				sudo chown ubuntu:ubuntu perf.data
				mv perf.data $LOGD/perf-$REP-$DISTR-$WORKLOAD.data
                        fi
		done
	done
done
tar cjf $LOGD.tar.bz2 $LOGD
