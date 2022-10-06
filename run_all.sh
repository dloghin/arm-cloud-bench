#!/bin/bash

cd system/memory
./run-lmbench.sh
./run-lmbench.sh
./run-lmbench.sh
cd ../disk
sudo ./run-disk-bench.sh
sudo ./run-disk-bench.sh
sudo ./run-disk-bench.sh
cd ../../ycsb
./run_ycsb.sh redis
./run_ycsb.sh memcached
cd ../../byte-unixbench/UnixBench/
./Run
./Run
./Run
