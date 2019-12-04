#include <iostream>
#include <stdio.h>
#include <cstdio>

// number of threads per block
static int numThreadsPerBlock = 256;

__global__ void minplus(int n, int* x, int *y)
//multiply a and b, store result in c, copy result back to a after
//min plus is c(i, j) = min from k = 1 to k = n (a(i,k) + b(k,j))
{
  // printf("N= %d\n", N);
  int j = threadIdx.y + (blockIdx.y * blockDim.y); //get the row
	int i= threadIdx.x + (blockIdx.x * blockDim.x); //get the col
	if (i < n and j < n){
		for (int k = 0; k < n; k++){
			x[i*n + j] = min(x[i*n + j], y[i*n + k] + y[k * n + j]);
		}
	}
}

int main(void)
{
  std::cout << "started " << '\n';
  int N = 6;
  int *a, *b, *d_a, *d_b;
  a = (int*)malloc(N*sizeof(int));
  b = (int*)malloc(N*sizeof(int));
  cudaMalloc((void**)&d_a, N*sizeof(int));
  cudaMalloc((void**)&d_b, N*sizeof(int));

  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++){
      int ran = rand()%(10-0 + 1) + 0;
      a[i*N + j] = ran;
      b[i*N + j] = ran;
    }

  }
  // std::cout << "a before cuda" << '\n';
  // // int maxError = 0.0f;
  // for (int i = 0; i < N; i++){
  //   for (int j = 0; j < N; j++){
  //     std::cout << a[i*N + j] << '\n';
  //   }
  // }

  cudaMemcpy(d_a, a, N*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, b, N*sizeof(int), cudaMemcpyHostToDevice);

  std::cout << "called cuda" << '\n';

  // Perform minplus
  int numBlocks = (N+numThreadsPerBlock-1) / numThreadsPerBlock;
	for (int i = 0; i < N; i++){
		  minplus<<<numBlocks, numThreadsPerBlock>>>(N, d_a, d_b);
	}

  int *h_z = (int*)malloc(N*sizeof(int));
  cudaMemcpy(h_z, d_a, N*sizeof(int), cudaMemcpyDeviceToHost);

  // std::cout << "a after cuda" << '\n';
  //
  // // int maxError = 0.0f;
  // for (int i = 0; i < N; i++){
  //   for (int j = 0; j < N; j++){
  //     std::cout << a[i*N + j] << '\n';
  //   }
  // }
    // maxError = max(maxError, abs(y[i]-4.0f));

		// printf(a[i]);
	// printf("Max error: %f\n", maxError);


  cudaFree(d_a);
  cudaFree(d_b);
  free(h_z);
  free(a);
  free(b);

  std::cout << "fnished" << '\n';
}
