#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "/usr/local/opt/libomp/include/omp.h"

char * getReverse(char * str){
    char * reversed = (char*) malloc(sizeof(char)* strlen(str));
    int i = 0;
    int j = strlen(str)-1;
    for(int i = 0; i < strlen(str); i++){
        reversed[strlen(str)-1-i] = str[i]; 
    }
    return reversed;
}
int main(int argc, char * argv[]){
    FILE *in;
    FILE *out; 
    int NUM_THREAD;
    double start, end;
    char word[100]; 
    char correct[30000][100];
    char words[30000][100];
    char * ans;
    int num = 0;
    if(argc < 4){
        printf("Usage : %s <NUM_THREAD> <input_file> <output_file>\n", argv[0]);
        return 0;
    }
    in = fopen(argv[2],"r");
    out = fopen(argv[3], "w");
    if(in == NULL || out == NULL){
        printf("failed to read file\n");
        return 0;
    }
    while(fscanf(in,"%s", word) == 1){
        strcpy(words[num++],word); 
    }
    start = omp_get_wtime();
    for(int i = 0; i < num; i++){
        ans = getReverse(words[i]);
        for(int j = 0; j < num; j++){
            if(strcmp(words[j], ans) == 0){
                printf("%s\n",ans);
            }
        }
    }
    end = omp_get_wtime();
    printf("Execution time : %f\n", end-start);
}