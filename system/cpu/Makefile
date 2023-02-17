CC = gcc

ipc: ipc.c
	$(CC) -O0 $^ -o $@

avx-o1: avx.c
	$(CC) -O1 $^ -o $@ -lm

avx-o3: avx.c
	$(CC) -O3 -unroll-loops -omit-frame-pointer -Winline -march=native -mtune=native -mno-vzeroupper $^ -o $@ -lm
