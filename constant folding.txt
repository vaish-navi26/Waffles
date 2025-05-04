#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define MAX 50

typedef struct {
    char op[3];
    char arg1[10];
    char arg2[10];
    char result[10];
} quadruples;

int n;
quadruples mainq[MAX], optq[MAX];

int isConst(char *str){
    for(int i = 0; str[i]; i++){
    if(!isdigit(str[i])){
        return 0;
    }
}
    return 1;
}



int main() {
   printf("Enter no. of quads: ");
   scanf("%d",&n);
   printf("Enter quads in format:\nOP Arg1 Arg2 Result\n");
   for(int i = 0;i<n; i++) {
    scanf("%s %s %s %s",mainq[i].op,mainq[i].arg1,mainq[i].arg2,mainq[i].result);
   }
   for(int i = 0; i<n; i++) {
    if( ( strcmp(mainq[i].op,"+") == 0 
        ||strcmp(mainq[i].op,"-") == 0
        ||strcmp(mainq[i].op,"*") == 0
        ||strcmp(mainq[i].op,"/") == 0) && isConst(mainq[i].arg1) && isConst(mainq[i].arg2)) {
            int a;
            int b; 
            int res;
            a = atoi(mainq[i].arg1);
            b = atoi(mainq[i].arg2);
            if(strcmp(mainq[i].op,"+") == 0 ) {
                res = a+b;
            } else if(strcmp(mainq[i].op,"-") == 0){
                res = a-b;
            } else if(strcmp(mainq[i].op,"*") == 0){
                res = a*b;
            } else if(strcmp(mainq[i].op,"/") == 0){
                res = a/b;
            }

            strcpy(optq[i].op,"=");
            strcpy(optq[i].result,mainq[i].result);
            sprintf(optq[i].arg1,"%d", res);
            strcpy(optq[i].arg2,"-");
        } else {
            optq[i] = mainq[i];
        }
   }
   printf("\nOprimized quads:\n");
   for(int i = 0; i<n; i++) {
    printf("%s %s %s %s\n",optq[i].op ,optq[i].arg1 ,optq[i].arg2 ,optq[i].result);
   }
  return 0;
}