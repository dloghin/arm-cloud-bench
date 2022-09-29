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

### TPC-H

We use TPC-H V3.0.1. Make sure you unzip and move the resulting folder into ``tpch-kit`` under ``tpch``.

We modified the code from https://github.com/sjp38/tpch-mariadb

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
cd tpch
./modify_src.sh
./build.sh
./dbgen.sh 1
./loadtest.sh
./mkqueries.sh 1
./powertest.sh
```

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

### Redis

```
sudo apt install redis
redis-server --version
redis-benchmark -n 10000000 -t set,get -q -P 40
```

## License

lmbench is under GNU GENERAL PUBLIC LICENSE Version 2

