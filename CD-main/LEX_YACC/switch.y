%{
#include<stdio.h>
#include<stdlib.h>
int lineno = 1;
int yylex();
void yyerror(const char *s);
extern FILE *yyin;
%}

%token ID NUM CONDI_OP OPERATOR SWITCH CASE BREAK DEFAULT
//Note to use single quotes only

%%
start : switch_smt ;

switch_smt : SWITCH '(' expression ')' '{' case_list default '}' 
{
    printf("SWTICH Statment Syntax Valid")
}

case_list : | case_list case_smt

case_smt : CASE NUM ':' statement_list BREAK ';'

default : DEFAULT ':' statement_list BREAK ';'

statement_list : | statement_list statement

statement : ID OPERATOR expression ';' | NUM OPERATOR expression ';' | expression ';' 

expression : ID | NUM | expression OPERATOR expression ;
%%


void yyerror(const char *s){
    fprintf(stderr, "Syntax error at line %d: %s\n", lineno, s);
    exit(1);}

int main (int argc, char **argv){
    if (argc >1 ){
        yyin = fopen(argv[1],"r");
    }
    return yyparse();

}