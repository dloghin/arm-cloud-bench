#include <arm_sve.h>
#include <sys/time.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

struct timeval tv1, tv2;

#define N 64000000 // Number of tests

// linear function
float linear[N];
inline void normal_sqrt()
{
    for (int i = 0; i < N; ++i)
        linear[i] = sqrtf(linear[i]);
}

int main()
{
    // Data initialization
    for (int i = 0; i < N; ++i)
    {
        linear[i] = ((float)i) + 0.1335f;
    }

    // Normal sqrt benchmarking. 20*64 Million Sqrts
    gettimeofday(&tv1, NULL);
    for (int i = 0; i < 20; ++i)
        normal_sqrt();
    gettimeofday(&tv2, NULL);
    printf("Normal SQRT time = %f seconds\n",
           (double)(tv2.tv_usec - tv1.tv_usec) / 1000000 +
               (double)(tv2.tv_sec - tv1.tv_sec));

    return 0;
}
