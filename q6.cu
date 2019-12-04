#include <iostream>
#include <stdio.h>
#include <cstdio>


__global__ void minplus(int N, int* a, int *b)
//multiply a and b, store result in c, copy result back to a after
//min plus is c(i, j) = min from k = 1 to k = n (a(i,k) + b(k,j))
{
  // printf("N= %d\n", N);
  int j = threadIdx.y + (blockIdx.y * blockDim.y); //get the row
	int i= threadIdx.x + (blockIdx.x * blockDim.x); //get the col
	if (i < N and j < N){
		for (int k = 0; k < N; k++){
			a[i*N + j] = min(a[i*N + j], b[i*N + k] + b[k * N + j]);
		}
	}
}

int main(void)
{
  std::cout << "started " << '\n';
  int N = 4;
  int *a, *b, *d_a, *d_b;
  a = (int*)malloc(N*sizeof(int));
  b = (int*)malloc(N*sizeof(int));
  cudaMalloc(&d_a, N*sizeof(int));
  cudaMalloc(&d_b, N*sizeof(int));

  for (int i = 0; i < N; i++) {
    int ran = rand();
    a[i] = ran;
    b[i] = ran;
  }
  std::cout << "a before cuda" << '\n';
  // int maxError = 0.0f;
  for (int i = 0; i < N; i++){
    for (int j = 0; j < N; j++){
      std::cout << a[i*N + j] << '\n';
    }
  }

  cudaMemcpy(d_a, a, N*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, b, N*sizeof(int), cudaMemcpyHostToDevice);

  std::cout << "called cuda" << '\n';

  // Perform minplus
	for (int i = 0; i < N; i++){
		  minplus<<<(N+255)/256, 256>>>(N, d_a, d_b);
	}


  cudaMemcpy(a, d_a, N*sizeof(int), cudaMemcpyDeviceToHost);

  std::cout << "a after cuda" << '\n';

  // int maxError = 0.0f;
  for (int i = 0; i < N; i++){
    for (int j = 0; j < N; j++){
      std::cout << a[i*N + j] << '\n';
    }
  }
    // maxError = max(maxError, abs(y[i]-4.0f));

		// printf(a[i]);
	// printf("Max error: %f\n", maxError);


  cudaFree(d_a);
  cudaFree(d_b);
  free(a);
  free(b);

  std::cout << "fnished" << '\n';
}
