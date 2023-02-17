#include <stdio.h>
#include <stdlib.h>

#define LOOPS 100000000

int main() {

int *a, *b, *c;
a = (int*)malloc(LOOPS * sizeof(int));
b = (int*)malloc(LOOPS * sizeof(int));
c = (int*)malloc(LOOPS * sizeof(int));

register int s1 = 0, s2 = 0, s3 = 0, s4 = 0, s5 = 0, s6 = 0, s7 = 0, s8 = 0;

for (int i = 0; i < LOOPS; i++) {
    a[i] = i;
    b[i] = 3 * i;
    c[i] = 7 * i;
}

for (int i = 0; i < LOOPS; i++) {
    s1 = a[i] + b[i];
    s2 = b[i] + c[i];
    s3 = a[i] + c[i];
    s4 = a[i] - b[i];
    s5 = b[i] - c[i];
    s6 = a[i] - c[i];
    s7 = a[i] << 2;
    s8 = b[i] >> 2;
}

free(a);
free(b);
free(c);

return s1 + s2 + s3 + s4 + s5 +6;
}