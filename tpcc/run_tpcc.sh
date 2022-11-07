#!/bin/bash

TPCC_HOME="/home/$USER/git/tpcc-mysql"

if ! [ -d "$TPCC_HOME" ]; then
	echo "No such folder: $TPCC_HOME"
	exit 1
fi

# For local MySQL
HOST="127.0.0.1"
PREP_CMD="sudo mysql"
RUN_CMD="mysql -h$HOST -utest -pTest1234 tpcc"

# For AWS Aurora
# r6i
# HOST="database-2.cluster-cfftdnf7trmh.us-west-2.rds.amazonaws.com"
# r6g
# HOST="database-3.cluster-cfftdnf7trmh.us-west-2.rds.amazonaws.com"
# PREP_CMD="mysql -h$HOST -P3306 -utest -pTest1234"
# RUN_CMD="mysql -h$HOST -P3306 -utest -pTest1234 tpcc"

REPS=3

CONNS="1 4 8 10 16 20 24 30"

WAREHOUSES=1000
TIME_WARMUP=10
TIME_BENCHMARK=60

# prepare
$PREP_CMD < prepare.sql
$RUN_CMD < $TPCC_HOME/create_table.sql
$RUN_CMD < $TPCC_HOME/add_fkey_idx.sql
$TPCC_HOME/tpcc_load -h$HOST -dtpcc -utest -pTest1234 -w $WAREHOUSES

TSTP=`date +%F-%H-%M-%S`
LOGD="logs-tpcc-$TSTP"
mkdir $LOGD

# run
for REP in `seq 1 $REPS`; do
	for CONN in $CONNS; do
		$TPCC_HOME/tpcc_start -h$HOST -P3306 -dtpcc -utest -pTest1234 -w$WAREHOUSES -c$CONN -r$TIME_WARMUP -l$TIME_BENCHMARK | tee $LOGD/log-tpcc-$CONN-$REP.txt
	done
done
tar cjf $LOGD.tar.bz2 $LOGD
