#!/bin/bash

# Do loadtest of TPC-H

. ./conf.sh

BINDIR=`dirname $0`

pushd $BINDIR/tpch-kit/dbgen

if [ $# -eq 2 ]
then
	USER=$1
	PASSWORD=$2
fi

MYSQL="$MYSQLEXE -u$USER"
if [ ! -z $PASSWORD ]
then
	MYSQL="$MYSQL -p$PASSWORD"
fi

MYSQL="$MYSQL $DBNAME"

TOTAL_SECS=0

SECONDS=0
$MYSQL < ./dss.ddl
echo "Table-Creation: $SECONDS secs"
TOTAL_SECS=$(($TOTAL_SECS + $SECONDS))

SECONDS=0
for table in customer lineitem nation orders partsupp part region supplier
do
	$MYSQL -e "LOAD DATA LOCAL INFILE '$BINDIR/$table.tbl' INTO TABLE $table FIELDS TERMINATED BY '|';"
done
echo "Load-Tables: $SECONDS secs"
TOTAL_SECS=$(($TOTAL_SECS + $SECONDS))

SECONDS=0
$MYSQL < ./dss.ri
echo "Create-Indexes-and-Constraints: $SECONDS secs"
TOTAL_SECS=$(($TOTAL_SECS + $SECONDS))

echo "Total: $TOTAL_SECS secs"

popd
