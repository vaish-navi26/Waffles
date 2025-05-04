%{
#include<stdio.h>
int lineno = 1;
%}
%option noyywrap

ID [a-zA-Z_][a-zA-Z0-9_]*
NUM [0-9]+|[0-9]+[.0-9]+
OPERATOR  "="|"+"|"-"|"*"|"/"
CONDI_OP "=="|"<="|">="|">"|"<"
DELIMITER [(){};\[\]]
KEYWORDS "class"|"public"|"private"|"static"|"void"|"int"|"String"|"if"|"else"

%%
\n {lineno++;}
{KEYWORDS}  {printf("%d \tKEY \t%s\n",lineno,yytext);}
{ID}    {printf("%d \tID \t%s\n",lineno,yytext);}
{NUM}   {printf("%d \tNUM \t%s\n",lineno,yytext);}
{OPERATOR}    {printf("%d \tOP \t%s\n",lineno,yytext);}
{CONDI_OP}    {printf("%d \tCOP \t%s\n",lineno,yytext);}
{DELIMITER}     {printf("%d \tDIL \t%s\n",lineno,yytext);}
[ \t\r]+    { /* ignore whitespace */ }
.   { printf("%d \tUnknown: \t%s\n",lineno, yytext); }
%%

int main(int argc, char **argv){
    if(argc > 1){
        yyin = fopen(argv[1],"r");
    }
    printf("Line\tToken\tLexeme\n");
    yylex();
    return 0;
}
