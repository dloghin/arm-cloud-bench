#!/bin/bash

if [ $# -lt 1 ]; then
        echo "Usage: $0 <num_threads>!"
        exit 1
fi


NTHREADS=$1

EXEC="openssl speed rsa2048 -multi $NTHREADS"

$EXEC
$EXEC
$EXEC
