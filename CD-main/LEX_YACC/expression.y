%{
#include<stdio.h>
#include<stdlib.h>
int lineno = 1;
int yylex();
void yyerror(const char *s);
extern FILE *yyin;
%}

%token ID NUM
%left '+' '-'
%left '*' '/'
%right '^'
%%

S:E
E: ID | NUM
| E '+' E
| E '-' E
| E '*' E
| E '/' E
| E '^' E
| '(' E ')'
%%
void yyerror(const char *s){
    printf("Syntax Error at line %d : %s",lineno,s);
    exit(1);
}

int main(int argc,char **argv){
    if (argc>1){
        yyin = fopen(argv[1],"r");
    
    yyparse();
    printf("Syntax Valid");
    }
}