#!/bin/bash

killall -9 node

cd /home/$USER/git/fabric-samples/test-network
./network.sh down
