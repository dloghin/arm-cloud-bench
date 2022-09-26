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
cd lmbench
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

- Storage

- Network

### TPC-H

We use TPC-H V3.0.1

We modified the code from https://github.com/sjp38/tpch-mariadb

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
redis-benchmark -n 1000000 -t set,get -q -P 10
```

## License

lmbench is under GNU GENERAL PUBLIC LICENSE Version 2

