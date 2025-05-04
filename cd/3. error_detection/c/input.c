#include <stdio.h>

#define MAX 100

int main() {
    int num1 = 10, num2 = 20;
    float result;

    if (num1 > num2) {
        result = num1 * 1.5;
    } else {
        result = num2 / 2.0;
    }
    
    printf("Result: %.2f\n", result);
    return 0;
}