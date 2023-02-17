// Code taken from: https://www.codingame.com/playgrounds/283/sse-avx-vectorization/first-avx-code-sqrt-calculation
// #pragma GCC optimize("O3","unroll-loops","omit-frame-pointer","inline") //Optimization flags
// #pragma GCC option("arch=native","tune=native","no-zeroupper") //Enable AVX
#pragma GCC target("avx") // Enable AVX
#include <x86intrin.h>
#include <sys/time.h>
#include <math.h>
#include <stdio.h>

struct timeval tv1, tv2;

#define N 64000000 // Number of tests
#define V N / 8    // Vectorized size

// linear function,
float linear[N];
// __attribute__((optimize("no-tree-vectorize"))) // Force disable auto-vectorization
inline void normal_sqrt()
{
    for (int i = 0; i < N; ++i)
        linear[i] = sqrtf(linear[i]);
}

__m256 __attribute__((aligned(32))) vectorized[V]; // Vectorized array
inline void avx_sqrt()
{
    for (int i = 0; i < V; ++i)
        vectorized[i] = _mm256_sqrt_ps(vectorized[i]);
}

int main()
{
    // Data initialization
    for (int i = 0; i < N; ++i)
    {
        linear[i] = ((float)i) + 0.1335f;
    }
    for (int i = 0; i < V; ++i)
    {
        for (int v = 0; v < 8; ++v)
        {
            vectorized[i][v] = ((float)(i * 8 + v)) + 0.1335f;
        }
    }

    // Normal sqrt benchmarking. 20*64 Million Sqrts
    gettimeofday(&tv1, NULL);
    for (int i = 0; i < 20; ++i)
        normal_sqrt();
    gettimeofday(&tv2, NULL);
    printf("Normal SQRT time = %f seconds\n",
           (double)(tv2.tv_usec - tv1.tv_usec) / 1000000 +
               (double)(tv2.tv_sec - tv1.tv_sec));

    // AVX vectorized sqrt benchmarking. 20*8*8 Million Sqrts
    gettimeofday(&tv1, NULL);
    for (int i = 0; i < 20; ++i)
        avx_sqrt();
    gettimeofday(&tv2, NULL);
    printf("Vectorized SQRT time = %f seconds\n",
           (double)(tv2.tv_usec - tv1.tv_usec) / 1000000 +
               (double)(tv2.tv_sec - tv1.tv_sec));

    // Check values
    for (int i = 0; i < V; ++i)
    {
        for (int v = 0; v < 8; ++v)
        {
            if (abs(linear[i * 8 + v] - vectorized[i][v]) > 0.00001f)
            {
                printf("ERROR: AVX sqrt is not the same as linear: %lf vs. %lf\n",
                       linear[i * 8 + v], vectorized[i][v]);
                return -1;
            }
        }
    }

    return 0;
}
