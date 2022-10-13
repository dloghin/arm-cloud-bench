#!/bin/bash

TPCC_HOME="/home/elwing/git/tpcc-mysql"

if ! [ -d "$TPCC_HOME" ]; then
	echo "No such folder: $TPCC_HOME"
	exit 1
fi

REPS=3

CONNS="1 4 8 10 16 20 24 30"

# prepare
sudo mysql < prepare.sql
mysql -utest -pTest1234 tpcc < $TPCC_HOME/create_table.sql
mysql -utest -pTest1234 tpcc < $TPCC_HOME/add_fkey_idx.sql
$TPCC_HOME/tpcc_load -h127.0.0.1 -dtpcc -utest -pTest1234 -w 10

TSTP=`date +%F-%H-%M-%S`
LOGD="logs-tpcc-$TSTP"
mkdir $LOGD

# run
for REP in `seq 1 $REPS`; do
	for CONN in $CONNS; do
		$TPCC_HOME/tpcc_start -h127.0.0.1 -P3306 -dtpcc -utest -pTest1234 -w10 -c$CONN -r10 -l60 | tee $LOGD/log-tpcc-$CONN-$REP.txt
	done
done
tar cjf $LOGD.tar.bz2 $LOGD
