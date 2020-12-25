#include <stdio.h>
#include <stdlib.h>
#define SIZE 1024
#define TILE_WIDTH 32
__global__ void Multiply(float* A, float* B, float* C, int width)
{
    int row = blockDim.y * TILE_WIDTH + threadIdx.y;
    int col = blockDim.x * TILE_WIDTH + threadIdx.x;
    __shared__ float sA[TILE_WIDTH][TILE_WIDTH];
    __shared__ float sB[TILE_WIDTH][TILE_WIDTH];
    int tx = threadIdx.x,ty = threadIdx.y;
    float s = 0;
    for (int i = 0; i < width/TILE_WIDTH; i++) {
    sA[ty][tx] = A[row*width + (i*TILE_WIDTH + tx)];
    sB[ty][tx] = B[col + (i*TILE_WIDTH + ty)*width];
    __syncthreads();
    for (int j = 0; j < TILE_WIDTH; j++)
    s += sA[ty][j] * sB[j][tx];
    __syncthreads();
    }
    C[row*width+col] = s;
}
int main(){
    float A[SIZE*SIZE];
    float B[SIZE*SIZE];
    float C[SIZE*SIZE]; 
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    float * d_A, * d_B, *d_C; 
    int BLOCKSIZE;
    printf("Choose block size : ");
    scanf("%d",&BLOCKSIZE);
    int GRIDSIZE = int(SIZE/BLOCKSIZE);
    dim3 dimBlock(BLOCKSIZE,BLOCKSIZE); // 20
    dim3 dimGrid(GRIDSIZE,GRIDSIZE);

    size_t size = SIZE*SIZE*sizeof(float);
    
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            A[i*SIZE+j] = rand()%10;
            B[i*SIZE+j] = rand()%10;
            C[i*SIZE+j] = 0;
        } // 30
    }  

    cudaEventRecord(start);
    cudaMalloc((void **)&d_A, size);
    cudaMemcpy(d_A,A,size,cudaMemcpyHostToDevice); 
    cudaMalloc((void **)&d_B, size);
    cudaMemcpy(d_B,B,size,cudaMemcpyHostToDevice); 
    cudaMalloc((void **)&d_C, size);
    cudaMemcpy(d_C,C,size,cudaMemcpyHostToDevice); 
	Multiply<<<dimGrid,dimBlock>>>(d_A, d_B,d_C,64);
    cudaEventRecord(stop);
    cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
    cudaEventSynchronize(stop);
    float elapsed = 0;
    cudaEventElapsedTime(&elapsed, start, stop);
    printf("Using Grid Size [%d, %d] and Block Size [%d, %d]..\n",  dimGrid.x, dimGrid.y,dimBlock.x, dimBlock.y);
    printf("Execution time : %f miliseconds\n", elapsed);
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
}