# Bechmarking ARM-based Cloud Instances

## Prerequisites

Ubuntu 20.04

gcc, g++, make, 


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

## License

lmbench is under GNU GENERAL PUBLIC LICENSE Version 2

