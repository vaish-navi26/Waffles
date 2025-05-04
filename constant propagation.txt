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
} Quad;

typedef struct {
    char name[10];
    int value;
    int isConst;
} Symbol;

Quad input[MAX], output[MAX];
Symbol constTable[MAX];
int n, symCount = 0;

// Check if string is a numeric constant
int isConst(char *str) {
    for(int i = 0; str[i]; i++) {
        if(!isdigit(str[i])) return 0;
    }
    return 1;
}

// Get constant value of a variable
int getConstValue(char *name, int *val) {
    for(int i = 0; i < symCount; i++) {
        if(strcmp(constTable[i].name, name) == 0 && constTable[i].isConst) {
            *val = constTable[i].value;
            return 1;
        }
    }
    return 0;
}

// Store constant assignment
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

// Invalidate constant status
void invalidateConst(char *name) {
    for(int i = 0; i < symCount; i++) {
        if(strcmp(constTable[i].name, name) == 0) {
            constTable[i].isConst = 0;
            return;
        }
    }
}

int main() {
    printf("Enter number of quads: ");
    scanf("%d", &n);

    printf("Enter quads (OP ARG1 ARG2 RESULT):\n");
    for(int i = 0; i < n; i++) {
        scanf("%s %s %s %s", input[i].op, input[i].arg1, input[i].arg2, input[i].result);
    }

    for(int i = 0; i < n; i++) {
        int val;
        char newArg1[10], newArg2[10];

        // Propagate constants
        strcpy(newArg1, input[i].arg1);
        strcpy(newArg2, input[i].arg2);

        if(!isConst(input[i].arg1) && getConstValue(input[i].arg1, &val)) {
            sprintf(newArg1, "%d", val);
        }

        if(!isConst(input[i].arg2) && getConstValue(input[i].arg2, &val)) {
            sprintf(newArg2, "%d", val);
        }

        // Copy to output
        strcpy(output[i].op, input[i].op);
        strcpy(output[i].arg1, newArg1);
        strcpy(output[i].arg2, newArg2);
        strcpy(output[i].result, input[i].result);

        // Update constant table if it's a constant assignment
        if(strcmp(input[i].op, "=") == 0 && isConst(newArg1)) {
            setConst(input[i].result, atoi(newArg1));
        } else {
            invalidateConst(input[i].result);
        }
    }

    printf("\nQuads after Constant Propagation:\n");
    for(int i = 0; i < n; i++) {
        printf("%s\t%s\t%s\t%s\n", output[i].op, output[i].arg1, output[i].arg2, output[i].result);
    }

    return 0;
}
