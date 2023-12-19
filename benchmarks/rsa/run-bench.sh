#!/bin/bash

if [ $# -lt 1 ]; then
        echo "Usage: $0 <num_threads>!"
        exit 1
fi
NTHREADS=$1

dateuid=`date +%F-%H-%M-%S`
OFILEPREFIX="rsa-log-$NTHREADS-threads-$dateuid"

EXEC="openssl speed -multi $NTHREADS rsa2048"

$EXEC | tee "$OFILEPREFIX-1.txt"
$EXEC | tee "$OFILEPREFIX-2.txt"
$EXEC | tee "$OFILEPREFIX-3.txt"
