# Bechmarking ARM-based Cloud Instances

## Prerequisites

Ubuntu 20.04

gcc, g++, make, mariadb


## Benchmarks

### System

- CPU

- Memory

lmbench (2alpha8 net release)

```
cd system/memory/lmbench
make
```

If ``bin`` contains a folder called ``x86_64-linux-gnu``, move its content to ``bin``:

```
cd bin
mv x86_64-linux-gnu/* .
```

Run the benchmark:

```
./run-lmbench.sh
```

The results are in CSV files with the current date in the filename. E.g., lmbench-graviton-2022-09-26-12-53-51-rdwr.csv

- Disk (storage)

```
cd system/disk
sudo ./run-disk-bench.sh
```

The results are shown on the screen and saved in a file named ``log-disk-<timestamp>.txt``.


- Network

- Unix Bench

https://github.com/kdlucas/byte-unixbench

### TPC-C

We use the code from https://github.com/Percona-Lab/tpcc-mysql.git

```
sudo apt install mariadb-server
sudo apt install libmysqlclient-dev
sudo mysql_secure_installation
sudo mysql
> CREATE USER 'test'@'localhost' IDENTIFIED BY 'Test1234';
> CREATE DATABASE tpcc;
> GRANT ALL PRIVILEGES ON tpcc.* TO 'test'@'localhost';
> FLUSH PRIVILEGES;
> EXIT;
git clone https://github.com/Percona-Lab/tpcc-mysql.git
cd tpcc-mysql/src
make
cd ..
mysql -utest -pTest1234 tpcc < create_table.sql
mysql -utest -pTest1234 tpcc < add_fkey_idx.sql
./tpcc_load -h127.0.0.1 -dtpcc -utest -pTest1234 -w 10
./tpcc_start -h127.0.0.1 -P3306 -dtpcc -utest -pTest1234 -w10 -c1 -r10 -l60
```

To run all the tests:

```
./run_tpcc.sh
./parse_tpcc.sh <log-dir>
```

We use Aurora 2.11.0 (MySQL 5.7).

### TPC-H

We use TPC-H V3.0.1. Make sure you unzip and move the resulting folder into ``tpch-kit`` under ``tpch``.

We modified the code from https://github.com/sjp38/tpch-mariadb

```
sudo apt install mariadb-server
sudo apt install libmysqlclient-dev
sudo mysql_secure_installation
sudo mysql
> CREATE USER 'test'@'localhost' IDENTIFIED BY 'Test1234';
> CREATE DATABASE tpch;
> GRANT ALL PRIVILEGES ON tpch.* TO 'test'@'localhost';
> FLUSH PRIVILEGES;
> EXIT;
cd tpch
./modify_src.sh
./build.sh
./dbgen.sh 1
./loadtest.sh
./mkqueries.sh 1
./powertest.sh
```



### Redis

```
sudo apt install redis
redis-server --version
redis-benchmark -n 10000000 -t set,get -q -P 40
```

### YCSB

We use YCSB 0.17.0: https://github.com/brianfrankcooper/YCSB

```
sudo apt install python2 openjdk-8-jdk
sudo apt install redis
redis-server --version
sudo apt install memcached
memcached --version
cd ycsb
curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.17.0/ycsb-0.17.0.tar.gz
tar xfvz ycsb-0.17.0.tar.gz
./run_ycsb.sh redis
./run_ycsb.sh memcached
```

#### RocksDB with YCSB

We use YCSB 0.17.0 and update RocksDB version to 7.6.0. On both x86-64 and ARM, run:

```
git clone https://github.com/brianfrankcooper/YCSB.git
cd YCSB
git checkout 0.17.0
# vim pom.xml
# <rocksdb.version>7.6.0</rocksdb.version>
mvn -pl site.ycsb:rocksdb-binding -am -DskipTests clean package
# the resulting jars are in rocksdb/target/
# return to this repository, ycsb folder
cd ycsb/ycsb-0.17.0/rocksdb-binding/lib
rm *
cp <path-to-YCSB>/rocksdb/target/dependency/* .
cp <path-to-YCSB>/rocksdb/target/rocksdb-binding-0.17.0.jar .
```

Only on ARM:

```
git clone https://github.com/facebook/rocksdb.git
cd rocksdb
git checkout v7.6.0
make clean
make rocksdbjava
# return to this repository, ycsb folder
cd ycsb/ycsb-0.17.0/rocksdb-binding/lib
cp <path-to-rocksdb>/java/target/librocksdbjni-linux-aarch64.so .
cp <path-to-rocksdb>/java/target/rocksdbjni-7.6.0-linux64.jar .
rm rocksdbjni-7.6.0.jar
ln -s rocksdbjni-7.6.0-linux64.jar rocksdbjni-7.6.0.jar
```

Go to ``ycsb`` and run ``./run_ycsb.sh rocksdb``.

### MLPerf

MLPerf Code: https://github.com/mlcommons/inference
MLPerf 2.0

- Vision (ssd-mobilenet for coco dataset resized to 300x300)
- Language (bert)

Prepare coco dataset:

```
git clone https://github.com/mlcommons/inference.git
cd inference
git checkout v2.0
cd tools/upscale_coco/
python upscale_coco.py --inputs /home/ubuntu/git/arm-cloud-bench/mlperf/coco --outputs /home/ubuntu/git/arm-cloud-bench/mlperf/coco-300 --size 300 300 --format png
```

Prepare Docker:

To install Docker, follow this guide: https://docs.docker.com/engine/install/ubuntu/

```
git clone https://github.com/mlcommons/inference.git
cd inference
git checkout v2.0
git apply < ~/git/arm-cloud-bench/mlperf/mlperf-arm64.patch
# or
git apply < ~/git/arm-cloud-bench/mlperf/mlperf-x86_64.patch
cd vision/classification_and_detection/
cp ~/git/arm-cloud-bench/mlperf/mlperf-arm64.patch .
# or
cp ~/git/arm-cloud-bench/mlperf/mlperf-x86_64.patch
docker build -f Dockerfile.cpu -t mlperf-cpu .
docker run -v /home/$USER/git/arm-cloud-bench/mlperf:/data -it mlperf-cpu
```

In Docker:

```
cd /tmp/inference/vision/classification_and_detection
export DATA_DIR=/data/coco-300
export MODEL_DIR=/data/models/tf_ssd_mobilenet
./run_local.sh tf ssd-mobilenet cpu
export MODEL_DIR=/data/models/pytorch_ssd_mobilenet
./run_local.sh pytorch ssd-mobilenet cpu
export MODEL_DIR=/data/models/onnx_ssd_mobilenet
./run_local.sh onnxruntime ssd-mobilenet cpu
```

### BlockBench and Hyperledger Fabric

Install Go:

```
mkdir tools
cd tools
wget https://go.dev/dl/go1.18.7.linux-arm64.tar.gz
tar xf go1.18.7.linux-arm64.tar.gz 
mkdir gopath
export GOROOT=/home/ubuntu/tools/go
export GOPATH=/home/ubuntu/tools/gopath
export PATH=$PATH:$GOROOT/bin
```

Install nvm and the latest nodejs:

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
npm install node
```

Configure Fabric:

```
git clone https://github.com/hyperledger/fabric.git
cd fabric
git checkout v2.4.7
make clean-all docker native GO_TAGS=noplugin
cd ..
git clone https://github.com/hyperledger/fabric-samples.git
cd fabric-samples
git checkout v2.2.9
mkdir bin
mkdir config
cp ../fabric/build/bin/* bin/
cd test-network
./network.sh up createChannel
./network.sh deployCC -c mychannel -ccn kvstore -ccl go -ccp /home/ubuntu/git/blockbench/benchmark/fabric2/chaincodes/kvstore -cci InitLedger
```

Compile blockbench:

```
sudo apt install libtool libcurl4-openssl-dev jq
cd ~/git
git clone https://github.com/dloghin/blockbench.git
cd blockbench
git checkout analysis2021
cd ..
git clone https://github.com/mrtazz/restclient-cpp.git
cd restclient-cpp
patch -p4 < ../blockbench/benchmark/parity/patch_restclient
./autogen.sh
sudo make install
cd ~/git/blockbench/src/macro/kvstore
make
```

```
node block-server.js /home/ubuntu/git/fabric-samples/test-network 1 mychannel 8800
node txn-server.js /home/ubuntu/git/fabric-samples/test-network 1 mychannel kvstore open_loop 8801
./run-node-servers.sh
./driver -db fabric-v2.2 -threads 1 -P /home/ubuntu/git/blockbench/src/macro/kvstore/workloads/workloada.spec -txrate 50 -endpoint 127.0.0.1:8800,127.0.0.1:8801 -wl ycsb -wt 20
```


## License

lmbench is under GNU GENERAL PUBLIC LICENSE Version 2

