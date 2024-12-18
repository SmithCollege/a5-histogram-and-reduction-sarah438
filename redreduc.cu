#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 10

// used resource: chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://developer.download.nvidia.com/assets/cuda/files/reduction.pdf

double get_clock() {
        struct timeval tv;
        int ok;
        ok = gettimeofday(&tv, (void *) 0);
        if (ok<0) {
                printf("gettimeofday error");
        }
        return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}


__global__ void reducMax(int*input, int*output){
        __shared__ int partialMax[2*BLOCK_SIZE];
        unsigned int t = threadIdx.x;
        unsigned int i = blockIdx.x*blockDim.x+threadIdx.x;
        partialMax[t] = input[i];
        __syncthreads();
        for(unsigned int stride = 1; stride <=blockDim.x; stride *=2){
                        __syncthreads();
                        int indexM = 2*stride*t;
                if(indexM<blockDim.x){
                        if(partialMax[indexM] < partialMax[indexM+stride]){
                                partialMax[indexM] = partialMax[indexM+stride];
                        }
                }
        }
        if(t==0){
                output[blockIdx.x] = partialMax[0];
        }
}

__global__ void reducMin(int*input, int*output){
        __shared__ int partialMin[2*BLOCK_SIZE];
        unsigned int t = threadIdx.x;
        unsigned int i = blockIdx.x*blockDim.x+threadIdx.x;
        partialMin[t] = input[i];
        __syncthreads();
        for(unsigned int stride = 1; stride<=blockDim.x; stride*=2){
                __syncthreads();
                int indexm = 2*stride*t;
                if(indexm<blockDim.x){
                        if (partialMin[indexm] < partialMin[indexm+stride]){
                                partialMin[indexm] = partialMin[indexm+stride];
                        }
                }
        }
        if(t==0){
                output[blockIdx.x] = partialMin[0];
        }
}


__global__ void reducMult(int*input, int * output){
        __shared__ int partialProd[2*BLOCK_SIZE];
        unsigned int t = threadIdx.x;
        unsigned int i = blockIdx.x*blockDim.x+threadIdx.x;
        partialProd[t] = input[i];
        __syncthreads();
        for(unsigned int stride = 1; stride<=blockDim.x; stride*=2){
                __syncthreads();
                int indexP = 2*stride*t;
                if(indexP<blockDim.x){
                        partialProd[indexP] += partialProd[indexP+stride];
                }
        }
        if(t==0){
                output[blockIdx.x] = partialProd[0];
        }

}

__global__ void reducSum(int * input, int * output){
        __shared__ int partialSum[2*BLOCK_SIZE];

        //printf("%d \n", 3);
        //each thrad loads one element from global to shared memory
        unsigned int t = threadIdx.x;
        unsigned int i = blockIdx.x*blockDim.x+threadIdx.x;
        partialSum[t] = input[i];
        __syncthreads();
        //do reduction in shared memory
        for(unsigned int stride=1; stride<=blockDim.x; stride*=2){
                //if(tid%(2*s)==0){
                __syncthreads();
                int indexS = 2*stride*t;
                if(indexS<blockDim.x){
                        partialSum[indexS] += partialSum[indexS+stride];
                        //printf("%d \n", 7);
                }
        }
        //write result for this block to global memory
        if(t==0){
                output[blockIdx.x] = partialSum[0];
        }

}

__global__ void histo_kernal(unsigned int *input, int size, unsigned int *histo){
        int i = threadIdx.x + blockIdx.x*blockDim.x;

        // stride is the total number of threads
        int stride = blockDim.x * gridDim.x;

        // All threads in the grid collectively handle blockDim.x*gridDim.x consecutive elements
        while (i<size){
                atomicAdd(&(histo[input[i]]),1);
                i+=stride;
        }
}

int main() {
        double t0 = get_clock();

        int * input;
        int * output;
        int * histo;
        // allocate memory
        cudaMallocManaged(&input,sizeof(int)*BLOCK_SIZE);
        cudaMallocManaged(&output, sizeof(int)*BLOCK_SIZE);
        cudaMallocManaged(&output, sizeof(int)*BLOCK_SIZE);
        //int* input = malloc(sizeof(int) * SIZE);
        //int* output = malloc(sizeof(int) * SIZE);

        int length = 0;
        // initialize inputs
        //srand(123);
        for (int i = 0; i < BLOCK_SIZE; i++) {
                //input[i] = rand() % 10;
                input[i] = i;
                length++;
        };

                reducSum<<<1,BLOCK_SIZE>>>(input, output);
                printf("%d \n", output[0]);
        // check results
        for (int i = 0; i < BLOCK_SIZE; i++) {
        printf("%d ", input[i]);
        }
        printf("\n");

        // free mem
        cudaFree(input);
        cudaFree(output);
        cudaFree(histo);
        //free(output);

        double t1 = get_clock();
        printf("time per call: %f s\n", ((t1-t0)) );

        return 0;
}
