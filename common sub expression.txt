#include <stdio.h>
#include <string.h>

#define MAX 50
typedef struct {
    char op[3];
    char arg1[10];
    char arg2[10];
    char result[10];
} quadrapuls;

quadrapuls mainQuad[MAX], optimizedQuad[MAX];
int n;

int isEqual(int index){
    for(int i = 0; i<index; i++){
        if(strcmp(mainQuad[i].op,mainQuad[index].op) == 0 && 
        strcmp(mainQuad[i].arg1,mainQuad[index].arg1) == 0 &&
        strcmp(mainQuad[i].arg2,mainQuad[index].arg2) == 0) {
            return i;
        }
    }
    return -1;
}

int main() {
    int k = 0;
    printf("Enter the number of quadrapuls.\n");
    scanf("%d",&n);

    printf("Ehter the quadrapuls in operator Arg1 Arg2 Ressult. Format:\n");
    for(int i=0; i<n; i++) {
        scanf("%s %s %s %s",mainQuad[i].op, mainQuad[i].arg1, mainQuad[i].arg2, mainQuad[i].result);
    }

    for(int i = 0; i< n; i++) {
        int check = isEqual(i);
        if(check != -1) {
            strcpy(optimizedQuad[i].op,"=");
            strcpy(optimizedQuad[i].arg1, mainQuad[check].result);
            strcpy(optimizedQuad[i].arg2, "-");
            strcpy(optimizedQuad[i].result, mainQuad[i].result);       
        } else {
            optimizedQuad[i] = mainQuad[i];
        }
        k++;
    }
    printf("Quadruples:\n");
        printf("OP\tArg1\tArg2\tResult\n");
        for(int i = 0; i<n; i++) {
            printf("%s\t%s\t%s\t%s\n",mainQuad[i].op,mainQuad[i].arg1, mainQuad[i].arg2,mainQuad[i].result);
        }
    printf("Optimized Quadruples:\n");
        printf("OP\tArg1\tArg2\tResult\n");
        for(int i = 0; i<k; i++) {
            printf("%s\t%s\t%s\t%s\n",optimizedQuad[i].op,optimizedQuad[i].arg1, optimizedQuad[i].arg2,optimizedQuad[i].result);
        }

    return 0;
}