#!/bin/bash

. ./conf.sh

BINDIR=`dirname $0`

if [ $# -lt 1 ]
then
	echo "Usage: $0 <query number> [username [password]]"
	exit 1
fi

NUM_Q=$1

if [ $# -gt 1 ]
then
	USER=$2
	PASSWORD=$3
fi

MYSQL="$MYSQLEXE -u $USER"
if [ ! -z $PASSWORD ]
then
	MYSQL="$MYSQL -p$PASSWORD"
fi

if ! [ -z "$PERFCMD" ]; then
	mkdir -p perf-logs
	$PERFCMD 2>&1 | tee perf-logs/perf-stat-query-`printf %02d $NUM_Q`.txt &
fi	
$MYSQL $DBNAME < ./tpch-kit/dbgen/queries/query-`printf %02d $NUM_Q`.sql
if ! [ -z "$PERFCMD" ]; then
	sudo killall -SIGINT perf
fi
