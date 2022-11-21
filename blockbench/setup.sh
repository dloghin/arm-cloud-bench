#!/bin/bash

# 1. Install Go
cd /home/$USER
mkdir tools
cd tools
wget https://go.dev/dl/go1.18.7.linux-arm64.tar.gz
tar xf go1.18.7.linux-arm64.tar.gz 
mkdir gopath
export GOROOT=/home/ubuntu/tools/go
export GOPATH=/home/ubuntu/tools/gopath
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# 2. Install nvm and the latest nodejs:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
npm install node
cd /home/$USER/git/arm-cloud-bench/blockbench
npm install

# 3. Configure Fabric
cd /home/$USER
mkdir -p git
cd git
git clone https://github.com/hyperledger/fabric.git
cd fabric
git checkout v2.4.7
git apply < ../arm-cloud-bench/blockbench/fabric-arm64.patch
make clean-all docker native GO_TAGS=noplugin
cd ..
git clone https://github.com/hyperledger/fabric-samples.git
cd fabric-samples
git checkout v2.2.9
git apply < ../arm-cloud-bench/blockbench/fabric-samples.patch
mkdir bin
mkdir config
cp ../fabric/build/bin/* bin/

# 4. Compile Blockbench
cd /home/$USER/git
git clone https://github.com/dloghin/blockbench.git
cd blockbench
git checkout analysis2021
cd ..
git clone https://github.com/mrtazz/restclient-cpp.git
cd restclient-cpp
patch -p4 < ../blockbench/benchmark/parity/patch_restclient
./autogen.sh
sudo make install
cd ../blockbench/src/macro/kvstore
make
cd /home/$USER/git/blockbench/benchmark/fabric2/chaincodes/kvstore
go mod init blockbench.org/benchmark/fabric2/chaincodes/kvstore
go mod tidy
