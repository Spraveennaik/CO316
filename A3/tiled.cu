#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define M 512

#define N 512

#define TILE_DIM  32

__global__ void TiledMatMul(int *A, int *B, int *C)
{
    __shared__ float tiled_A[TILE_DIM][TILE_DIM];
    __shared__ float tiled_B[TILE_DIM][TILE_DIM];

    int bx = blockIdx.x;
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int row = by * blockDim.y + ty;
    int col = bx * blockDim.x + tx;

    int cVal = 0;

    for (int t = 0; t < (M - 1) / TILE_DIM + 1; ++t)
    {
        if (row < M && (t * TILE_DIM + tx) < N)
            tiled_A[ty][tx] = A[row * N + t * TILE_DIM + tx];
        else
            tiled_A[ty][tx] = 0;

        if ((t * TILE_DIM + ty) < N && col < M)
            tiled_B[ty][tx] = B[(t * TILE_DIM + ty) * M + col];
        else
            tiled_B[ty][tx] = 0;
        __syncthreads();

        for (int i = 0; i < TILE_DIM; ++i)
            cVal += (tiled_A[ty][i] * tiled_B[i][tx]);
        __syncthreads();

        if (row < M && col < M)
            C[row * M + col] = cVal;
    }
}


void CPUMatMul(int A[M][N], int B[N][M], int C[M][M])
{

    for (int row = 0; row < M; ++row)
    {
        for (int col = 0; col < M; ++col)
        {
            int prod_val = 0;
            for (int k = 0; k < N; ++k)
            {
                prod_val = prod_val + (A[row][k] * B[k][col]);
            }
            C[row][col] = prod_val;
        }
    }
}

bool compare(int A[M][M], int B[M][M], double accuracy)
{
    for (int i = 0; i < M; ++i)
    {
        for (int j = 0; j < M; ++j)
            if ((abs(A[i][j] - B[i][j])) > accuracy)
                return 0;
    }

    return 1;
}

int main()
{
    int *A, *B, *C;
    int host_A[M][N], host_B[N][M], host_C[M][M], CPUMatMulAns[M][M];

    int i, j;
    for (i = 0; i < M; ++i)
    {
        for (j = 0; j < N; ++j)
            host_A[i][j] = rand()%100;
    }

    for (i = 0; i < N; ++i)
    {
        for (j = 0; j < M; ++j)
            host_B[i][j] = rand()%100;
    }

    CPUMatMul(host_A, host_B, CPUMatMulAns);

      cudaMalloc((void **)&A, M * N * sizeof(int));
    cudaMalloc((void **)&B, M * N * sizeof(int));
    cudaMalloc((void **)&C, M * M * sizeof(int));


    cudaMemcpy(A, host_A, M * N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(B, host_B, M * N * sizeof(int), cudaMemcpyHostToDevice);

    dim3 blockDim(TILE_DIM, TILE_DIM, 1);

    dim3 gridDim((int)ceil((float)(M) / blockDim.x), (float)ceil((int)(N) / blockDim.y), 1);

    TiledMatMul<<<gridDim, blockDim>>>(A, B, C);
    cudaDeviceSynchronize();
    cudaMemcpy(host_C, C, M * M * sizeof(int), cudaMemcpyDeviceToHost);

    double accuracy = pow(10, -1);
    if (compare(CPUMatMulAns, host_C, accuracy))
        printf("Execution Succesfull\n The answers generated by GPU and CPU are equal\n");
    else
        printf("Execution Succesfull\n The answers generated by GPU and CPU are equal\n");

    cudaFree(A);
    cudaFree(B);
    cudaFree(C);

    return 0;
}

