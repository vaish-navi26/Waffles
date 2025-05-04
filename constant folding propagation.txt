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

typedef struct {
    char name[10];
    int value;
    int isConst;
} symbol;

quadruples mainq[MAX], optq[MAX];
symbol constTable[MAX];

int n, symCount = 0;

// Check if str is numeric constant
int isConst(char *str){
    for(int i = 0; str[i]; i++) {
        if(!isdigit(str[i])) return 0;
    }
    return 1;
}

// Get constant value of variable from symbol table
int getConstValue(char *name, int *val) {
    for(int i = 0; i < symCount; i++) {
        if(strcmp(constTable[i].name, name) == 0 && constTable[i].isConst) {
            *val = constTable[i].value;
            return 1;
        }
    }
    return 0;
}

// Update or insert constant assignment into symbol table
void setConst(char *name, int val) {
    for(int i = 0; i < symCount; i++) {
        if(strcmp(constTable[i].name, name) == 0) {
            constTable[i].value = val;
            constTable[i].isConst = 1;
            return;
        }
    }
    strcpy(constTable[symCount].name, name);
    constTable[symCount].value = val;
    constTable[symCount].isConst = 1;
    symCount++;
}

// Remove constant status if variable gets a non-constant value
void invalidateConst(char *name) {
    for(int i = 0; i < symCount; i++) {
        if(strcmp(constTable[i].name, name) == 0) {
            constTable[i].isConst = 0;
            return;
        }
    }
}

int main() {
    printf("Enter no. of quads: ");
    scanf("%d", &n);

    printf("Enter quads in format:\nOP Arg1 Arg2 Result\n");
    for(int i = 0; i < n; i++) {
        scanf("%s %s %s %s", mainq[i].op, mainq[i].arg1, mainq[i].arg2, mainq[i].result);
    }

    for(int i = 0; i < n; i++) {
        int val1, val2;
        char newArg1[10], newArg2[10];

        // Copy original args
        strcpy(newArg1, mainq[i].arg1);
        strcpy(newArg2, mainq[i].arg2);

        // Constant propagation
        if(!isConst(mainq[i].arg1) && getConstValue(mainq[i].arg1, &val1)) {
            sprintf(newArg1, "%d", val1);
        }
        if(!isConst(mainq[i].arg2) && getConstValue(mainq[i].arg2, &val2)) {
            sprintf(newArg2, "%d", val2);
        }

        // Constant folding
        if((strcmp(mainq[i].op, "+") == 0 || strcmp(mainq[i].op, "-") == 0 ||
            strcmp(mainq[i].op, "*") == 0 || strcmp(mainq[i].op, "/") == 0) &&
            isConst(newArg1) && isConst(newArg2)) {

            int a = atoi(newArg1);
            int b = atoi(newArg2);
            int res = 0;

            if(strcmp(mainq[i].op, "+") == 0) res = a + b;
            else if(strcmp(mainq[i].op, "-") == 0) res = a - b;
            else if(strcmp(mainq[i].op, "*") == 0) res = a * b;
            else if(strcmp(mainq[i].op, "/") == 0) res = a / b;

            strcpy(optq[i].op, "=");
            sprintf(optq[i].arg1, "%d", res);
            strcpy(optq[i].arg2, "-");
            strcpy(optq[i].result, mainq[i].result);

            setConst(mainq[i].result, res);  // Store folded result
        } else if(strcmp(mainq[i].op, "=") == 0 && isConst(newArg1)) {
            // Constant assignment like = 5 - x
            strcpy(optq[i].op, "=");
            strcpy(optq[i].arg1, newArg1);
            strcpy(optq[i].arg2, "-");
            strcpy(optq[i].result, mainq[i].result);

            setConst(mainq[i].result, atoi(newArg1));
        } else {
            // General case with propagation
            strcpy(optq[i].op, mainq[i].op);
            strcpy(optq[i].arg1, newArg1);
            strcpy(optq[i].arg2, newArg2);
            strcpy(optq[i].result, mainq[i].result);

            invalidateConst(mainq[i].result);  // Not a constant anymore
        }
    }

    printf("\nOptimized Quads (Folding + Propagation):\n");
    for(int i = 0; i < n; i++) {
        printf("%s\t%s\t%s\t%s\n", optq[i].op, optq[i].arg1, optq[i].arg2, optq[i].result);
    }

    return 0;
}