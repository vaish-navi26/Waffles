%{
#include<stdio.h>
#include"while.tab.h"
extern int lineno;

%}
%option noyywrap

ID [a-zA-Z_][a-zA-Z0-9_]*
NUM [0-9]+|[0-9]+[.0-9]+
OPERATOR  "="|"+"|"-"|"*"|"/"
CONDI_OP "=="|"<="|">="|">"|"<"
DELIMITER [(){};]
KEYWORDS "int"|"float"|"char"|"if"
WHILE "while"

%%
\n {lineno++;}
{WHILE} {
    printf("%d \tKEY \t%s\n",lineno,yytext);
    return WHILE;
}
{KEYWORDS}  {
    printf("%d \tKEY \t%s\n",lineno,yytext);
    return yytext[0];
    }
{ID}    {
    printf("%d \tID \t%s\n",lineno,yytext);
    return ID;
    }
{NUM}   {
    printf("%d \tNUM \t%s\n",lineno,yytext);
    return NUM;
    }
{OPERATOR}    {
    printf("%d \tOP \t%s\n",lineno,yytext);
    return OPERATOR;
    }
{CONDI_OP}    {
    printf("%d \tCOP \t%s\n",lineno,yytext);
    return CONDI_OP;
    }
{DELIMITER}     {
    printf("%d \tDIL \t%s\n",lineno,yytext);
    return yytext[0];
    }
[ \t\r]+    { /* ignore whitespace */ }
.   { printf("%d \tUnknown: \t%s\n",lineno, yytext); }
%%

