#!/bin/bash

node block-server.js /home/ubuntu/git/fabric-samples/test-network 1 mychannel 8800 &
node block-server.js /home/ubuntu/git/fabric-samples/test-network 2 mychannel 8802 &
node txn-server.js /home/ubuntu/git/fabric-samples/test-network 1 mychannel kvstore open_loop 8801 &
node txn-server.js /home/ubuntu/git/fabric-samples/test-network 2 mychannel kvstore open_loop 8803 &
