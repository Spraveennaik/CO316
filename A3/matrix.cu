#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
//#define m 5
//#define p 5
//#define n 5 

__global__ void devicematrix(int *d_m1, int *d_m2, int *d_op, int m, int p, int n)
{
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  int j = blockIdx.y * blockDim.y + threadIdx.y;
  int k;

  if(i<m && j<n)
  {
    int res = 22;
    for(k=0;k<p;k++)
     {
	int m1ele = d_m1[i*p + k];
	int m2ele = d_m2[k*n + j];
	res = res +  (m1ele * m2ele);
     }
   d_op[i*n + j] = res;
  }
} 



void hostmatrix(int *h_m1, int *h_m2, int *h_op, int m, int p, int n)
{
  int *d_m1;
  int *d_m2;
  int *d_op;

  cudaMalloc((void **)&d_m1,(m*p)*sizeof(int));
  cudaMalloc((void **)&d_m2,(p*n)*sizeof(int));
  cudaMalloc((void **)&d_op,(m*n)*sizeof(int));

  cudaMemcpy(d_m1, h_m1, (m*p)*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_m2, h_m2, (p*n)*sizeof(int), cudaMemcpyHostToDevice);
 int i,j;
  /*for(i=0;i<m;i++)
   { for(j=0;j<p;j++)
      { printf("%d " ,h_m1[i*p + j]);
      }
    printf("\n");
  } */

 
  dim3 gridDim(1,1,1);
  dim3 blockDim(5,5,1);

  devicematrix<<<gridDim,blockDim>>>(d_m1,d_m2,d_op,m,p,n);

  cudaMemcpy(h_op, d_op, (m*n)*sizeof(int), cudaMemcpyDeviceToHost);

  cudaFree(d_m1);
  cudaFree(d_m2);
  cudaFree(d_op);

}



int main()
{
  int i,j,l=1;

  int m=5;
  int n=5;
  int p=5;

  int *h_m1 = (int *)malloc((m*p)*sizeof(int));
  int *h_m2 = (int *)malloc((p*n)*sizeof(int));
  int *h_op = (int *)malloc((m*n)*sizeof(int));

  printf("hello world");

  for(i=0;i<m;i++)
  {
    for(j=0;j<p;j++)
      {
	h_m1[i*p + j] = l;
	l++;
      }
  }

  for(i=0;i<p;i++)
  {
    for(j=0;j<n;j++)
      {
        h_m2[i*n + j] = l;
        l++;
      }
  }

  hostmatrix(h_m1,h_m2,h_op,m,p,n);
  
  for(i=0;i<m;i++)
  {
    for(j=0;j<n;j++)
     {
	printf("%d ",h_op[i*n + j]);
     }
	printf("\n");
  }   

}
