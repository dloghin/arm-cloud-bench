#!/bin/bash

. ./conf.sh

MYSQL="$MYSQLEXE -u$USER"
if [ ! -z $PASSWORD ]
then
	MYSQL="$MYSQL -p$PASSWORD"
fi
MYSQL="$MYSQL $DBNAME"

TSTP=`date +%F-%H-%M-%S`
LOGD="logs-tpch-$TSTP"
mkdir $LOGD

$MYSQL < prepare_db.sql
./loadtest.sh
./powertest.sh 2>&1 | tee $LOGD/run1.txt

$MYSQL < prepare_db.sql
./loadtest.sh
./powertest.sh 2>&1 | tee $LOGD/run2.txt

$MYSQL < prepare_db.sql
./loadtest.sh
./powertest.sh 2>&1 | tee $LOGD/run3.txt

tar cjf $LOGD.tar.bz2 $LOGD
