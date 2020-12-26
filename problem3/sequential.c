#include <stdio.h>
#include<sys/time.h>
#include <time.h>
#include <stdlib.h> 
#define SIZE 300000
int main(){
    srand(time(NULL));
    int n[SIZE];
    int s = 0;
    int maxi = -1; 
    float start,end,elapsed; 

	struct timeval t1,t2;
    for(int i = 0; i< SIZE; i++ )
        n[i] = rand()%10000;


	gettimeofday(&t1, NULL);
    for(int i =0; i<SIZE; i++){
        if(maxi < n[i])
            maxi = n[i];
    }

	gettimeofday(&t2, NULL);
    elapsed = (t2.tv_sec - t1.tv_sec) * 1000.0f + (t2.tv_usec - t1.tv_usec) / 1000.0f;


    printf("Maximum : %d\n", maxi);
    printf("Execution time : %lf ms\n", elapsed);
}