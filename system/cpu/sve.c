#include <arm_sve.h>
#include <sys/time.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

struct timeval tv1, tv2;

#define N 64000000 // Number of tests
#define V N / 8    // Vectorized size

// linear function
float linear[N];
// __attribute__((optimize("no-tree-vectorize"))) // Force disable auto-vectorization
inline void normal_sqrt()
{
    for (int i = 0; i < N; ++i)
        linear[i] = sqrtf(linear[i]);
}

// vectorized
float vectorized[N]; // Vectorized array
inline void sve_sqrt()
{
   svbool_t p32_all = svptrue_b32();
   svfloat32_t vec;
    for (int i = 0; i < V; ++i) {
	vec = svld1(p32_all, vectorized + (8*i));
	vec = svsqrt_f32_z(p32_all, vec);
	svst1(p32_all, vectorized + (8*i), vec);
    }
}

int main()
{
    // Data initialization
    for (int i = 0; i < N; ++i)
    {
        linear[i] = ((float)i) + 0.1335f;
	vectorized[i] = ((float)i) + 0.1335f;
    }

    // Normal sqrt benchmarking. 20*64 Million Sqrts
    gettimeofday(&tv1, NULL);
    for (int i = 0; i < 20; ++i)
        normal_sqrt();
    gettimeofday(&tv2, NULL);
    printf("Normal SQRT time = %f seconds\n",
           (double)(tv2.tv_usec - tv1.tv_usec) / 1000000 +
               (double)(tv2.tv_sec - tv1.tv_sec));

    // vectorized sqrt benchmarking. 20*8*8 Million Sqrts
    gettimeofday(&tv1, NULL);
    for (int i = 0; i < 20; ++i)
        sve_sqrt();
    gettimeofday(&tv2, NULL);
    printf("Vectorized SQRT time = %f seconds\n",
           (double)(tv2.tv_usec - tv1.tv_usec) / 1000000 +
               (double)(tv2.tv_sec - tv1.tv_sec));

    // Check values
    for (int i = 0; i < N; ++i)
    {
        if (fabs(linear[i] - vectorized[i]) > 0.00001f)
            {
                printf("ERROR: SVE sqrt is not the same as linear: %lf vs. %lf\n",
                       linear[i], vectorized[i]);
                return -1;
            }
    }

    return 0;
}
