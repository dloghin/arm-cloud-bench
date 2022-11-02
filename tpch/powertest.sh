#!/bin/bash

# Do Power Test of TPC-H

. ./conf.sh

TSTP=`date +%F-%H-%M-%S`
BINDIR=`dirname $0`

if [ $# -eq 2 ]
then
	USER=$1
	PASSWORD=$2
fi

function msecs() {
	echo $((`date +%s%N` / 1000000))
}

function msec_to_sec() {
	MSECS=$1
	SECS=$(($MSECS / 1000))
	MSECS=$(($MSECS - $SECS * 1000))
	printf %d.%03d $SECS $MSECS
}

MYSQL="$MYSQLEXE -u$USER"
if [ ! -z $PASSWORD ]
then
	MYSQL="$MYSQL -p$PASSWORD"
fi

MYSQL="$MYSQL $DBNAME"

TOTAL_MSECONDS=0
for q in {1..22}
do
	START=`msecs`
	./runquery.sh $q $USER $PASSWORD > /dev/null
	END=`msecs`
	DURATION=$(( $END - $START))
	printf "%d: \t%16s secs\n" $q `msec_to_sec $DURATION`
	TOTAL_MSECONDS=$(($TOTAL_MSECONDS + $DURATION))
done

printf "Total: \t%16s secs\n" `msec_to_sec $TOTAL_MSECONDS`

if ! [ -z "$PERFCMD" ]; then
	mv perf-logs perf-logs-$TSTP
fi
