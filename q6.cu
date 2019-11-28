#include <stdio.h>

__global__ void minplus(int N, int* a, int *b)
//multiply a and b, store result in c, copy result back to a after
//min plus is c(i, j) = min from k = 1 to k = n (a(i,k) + b(k,j))
{
  int j = threadIdx.y + (blockId.y * blockDim.y); //get the row
	int i= threadIdx.x + (blockId.x * blockDim.x); //get the col
	if (i < N and j < N){
		for (int k = 0; k < N; k++){
			a[i][j] = min(a[i][j], b[i][k] + b[k][j]);
		}
	}
}

int main(void)
{
  int N = 32;
  int *a, *b, *d_a, *d_b;
  a = (int*)malloc(N*sizeof(int));
  b = (int*)malloc(N*sizeof(int));
  cudaMalloc(&d_a, N*sizeof(int));
  cudaMalloc(&d_b, N*sizeof(int));

  for (int i = 0; i < N; i++) {
    a[i] = rand();
    b[i] = a[i];
  }

  cudaMemcpy(d_a, a, N*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, b, N*sizeof(int), cudaMemcpyHostToDevice);

  // Perform minplus
	for (int i = 0; i < N; i++){
		  minplus<<<(N+255)/256, 256>>>(N, d_a, d_b);
	}


  cudaMemcpy(a, d_a, N*sizeof(int), cudaMemcpyDeviceToHost);

  // int maxError = 0.0f;
  for (int i = 0; i < N; i++)
    // maxError = max(maxError, abs(y[i]-4.0f));
		printf(a[i]);
	printf("Max error: %f\n", maxError);


  cudaFree(d_a);
  cudaFree(d_b);
  free(a);
  free(b);
}
