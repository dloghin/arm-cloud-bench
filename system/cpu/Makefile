CC = gcc-11

ipc: ipc.c
	$(CC) -O0 $^ -o $@

avx-o1: avx.c
	$(CC) -O1 $^ -o $@ -lm

neon-o1: neon.c
	$(CC) -O1 $^ -o $@ -lm

sve-o1: sve.c
	$(CC) -O1 -mcpu=neoverse-v1 $^ -o $@ -lm

sve-o3: sve.c
	$(CC) -O3 -mcpu=neoverse-v1 $^ -o $@ -lm

sve-av-o1: sve-linear.c
	$(CC) -O1 -mcpu=neoverse-v1 $^ -o $@ -lm

sve-av-o3: sve-linear.c
	$(CC) -O3 -ffast-math -mcpu=neoverse-v1 $^ -o $@

avx-o3: avx.c
	$(CC) -O3 -unroll-loops -omit-frame-pointer -Winline -march=native -mtune=native -mno-vzeroupper $^ -o $@ -lm
