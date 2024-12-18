#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define SIZE 10

double get_clock() {
        struct timeval tv;
        int ok;
        ok = gettimeofday(&tv, (void *) 0);
        if (ok<0) {
                printf("gettimeofday error");
        }
        return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

int max(int* input, int size){
        int m = input[0];
        for(int i =0; i < size; i++){
                if(m < input[i]){
                        m = input[i];
                }
        }
        return m;
}

int add(int* input, int size){
        int s = 0;
        for(int i = 0; i <size; i++){
                s +=input[i];
        }
        return s;
}

int min(int* input, int size){
        int n = input[0];
        for(int i = 0; i < size; i++){
                if(n > input[i]){
                        n = input[i];
                }
        }
        return n;
}

int mult(int*input, int size){
        int p = 1;
        for(int i = 0; i < size; i++){
                p*=input[i];
        }
        return p;
}

int main() {
        double t0 = get_clock();


        // allocate memory
        int* input = malloc(sizeof(int) * SIZE);
        //int* output = malloc(sizeof(int) * SIZE);

                int length = 0;
        // initialize inputs
        //srand(123);
        for (int i = 0; i < SIZE; i++) {
                //input[i] = rand() % 10;
                input[i] = i;
                length++;
        }

        // get number of iterations
        //int divisions = length / 2;


                int num = max(input, length);
                printf("%d \n", num);

                int sum = add(input, length);
                printf("%d \n", sum);

                int num1 = min(input, length);
                printf("%d \n", num1);

                int prod = mult(input, length);
                printf("%d \n", prod);

                //printf("%d\n", length);
                //printf("%d\n", divisions);

        //for (int i = 0; i < SIZE; i++) {
        //int value = 0;
        //for (int j = 0; j <= i; j++) {
        //value += input[j]; // prefix sum
        //}
    //output[i] = value;
      //  }

        // check results
        for (int i = 0; i < SIZE; i++) {
        printf("%d ", input[i]);
        }
        printf("\n");

        // free mem
        free(input);
        //free(output);

        double t1 = get_clock();
        printf("time per call: %f s\n", ((t1-t0)) );

        return 0;
}
