#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <omp.h>
int num = 0;
char words[30000][100];
int isPalindromic(char * str){
    char * reversed = (char*) malloc(sizeof(char)* strlen(str));
    int i = 0;
    int j = strlen(str)-1;
    for(int i = 0; i < strlen(str); i++){
        reversed[strlen(str)-1-i] = str[i]; 
    }
    if(strcmp(str,reversed) == 0){
        return 1;
    }
    for(int i = 0; i < num; i++){
        if(strcmp(words[i],reversed)==0){
            return 1;
        }
    }
    return 0;
}
int main(int argc, char * argv[]){
    FILE *in;
    FILE *out; 
    int NUM_THREAD;
    double start, end;
    char word[100]; 
    char words[30000][100];
    char * ans;
    if(argc < 4){
        printf("Usage : %s <NUM_THREAD> <input_file> <output_file>\n", argv[0]);
        return 0;
    }
    in = fopen(argv[2],"r");
    out = fopen(argv[3], "w");
    NUM_THREAD = strtol(argv[1], NULL, 10);
    if(in == NULL || out == NULL){
        printf("failed to read file\n");
        return 0;
    }

    omp_set_num_threads(NUM_THREAD);
    start = omp_get_wtime();
    while(fscanf(in,"%s",word) == 1){
            strcpy(words[num++],word); 
    
    }
    int k = 0;
    #pragma omp parallel for
    for(int i = 0; i < num; i++){
        if(isPalindromic(words[i])){
            fprintf(out,"%s\n",words[i]);
            k++;
        }
    }
    end = omp_get_wtime();
    printf("Using %d threads...\n", NUM_THREAD);
    printf("Processed %d words and got %d number of palindromic words..\n",num,k);
    printf("Execution time : %f seconds\n", end-start);
}
