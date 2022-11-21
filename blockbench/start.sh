#!/bin/bash

cd /home/$USER/git/fabric-samples/test-network
./network.sh down
./network.sh up createChannel
./network.sh deployCC -c mychannel -ccn kvstore -ccl go -ccp /home/$USER/git/blockbench/benchmark/fabric2/chaincodes/kvstore -cci InitLedger

cd /home/$USER/git/arm-cloud-bench/blockbench
./run-node-servers.sh
