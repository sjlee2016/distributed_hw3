#include <stdio.h>
#include <stdlib.h>
#define SIZE 300000
#define BLOCK_SIZE 512
__global__ void reduction(int *A, int *B){
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    __shared__ int data[BLOCK_SIZE];
    data[threadIdx.x] = A[tid]; // load data to shared memory 
    __syncthreads();
    // iterate of log base 2 block dimension. using stride of 2 
    for(int i = blockDim.x/2; i>0; i>>=1){
        if(threadIdx.x < i){
            if(data[threadIdx.x] < data[threadIdx.x + i]){
                data[threadIdx.x] = data[threadIdx.x + i];
            }
        }
        __syncthreads();
    }
    __syncthreads();
    // thread 0 should write the maximum value to main memory 
    if(threadIdx.x == 0 )
        B[blockIdx.x] = data[0]; 
}
int main(){
    int A[SIZE];
    int * B;
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    int * d_A, * d_B; 
	srand(time(NULL));
    size_t size = SIZE*sizeof(int);
    int GRIDSIZE = SIZE / (BLOCK_SIZE<<1);
	if (GRIDSIZE % (BLOCK_SIZE<<1)) 
		GRIDSIZE++;
	B = (int *) malloc(sizeof(int)*GRIDSIZE); 
    dim3 dimBlock(BLOCK_SIZE,1,1); 
    dim3 dimGrid(GRIDSIZE,1,1);

    for(int i = 0; i < SIZE; i++){
            A[i] = rand()%10000;
            if(i<GRIDSIZE)
                B[i] = 0; 
    }  
    cudaEventRecord(start);
    cudaMalloc((void **)&d_A, size);
    cudaMemcpy(d_A,A,size,cudaMemcpyHostToDevice); 
    cudaMalloc((void **)&d_B, GRIDSIZE*sizeof(int));
	reduction<<<dimGrid,dimBlock>>>(d_A, d_B);
    cudaEventRecord(stop);
    cudaMemcpy(B, d_B, GRIDSIZE*sizeof(int), cudaMemcpyDeviceToHost);
    for(int i = 1; i < GRIDSIZE; i++){
        if(B[0] < B[i])
            B[0] = B[i]; 
    }
    cudaEventSynchronize(stop);
    float elapsed = 0;
    cudaEventElapsedTime(&elapsed, start, stop);
    printf("Using Grid Size [%d, %d] and Block Size [%d, %d]..\n",  dimGrid.x, dimGrid.y,dimBlock.x, dimBlock.y);
    printf("maximum : %d\n", B[0]); 
    printf("Execution time : %f ms\n", elapsed);
    cudaFree(d_A);
    cudaFree(d_B);
}
