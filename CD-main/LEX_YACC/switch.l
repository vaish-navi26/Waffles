%{
#include<stdio.h>
#include"switch.tab.h"
extern int lineno;

%}
%option noyywrap

ID [a-zA-Z_][a-zA-Z0-9_]*
NUM [0-9]+|[0-9]+[.0-9]+
OPERATOR  "="|"+"|"-"|"*"|"/"
CONDI_OP "=="|"<="|">="|">"|"<"
DELIMITER [(){};:]
KEYWORDS "int"|"float"|"char"|"while"
SWITCH "switch"
CASE "case"
DEFAULT "default"
BREAK "break"

%%
\n {lineno++;}
{CASE} {
    printf("%d \tKEY \t%s\n",lineno,yytext);
    return CASE;
}
{DEFAULT} {
    printf("%d \tKEY \t%s\n",lineno,yytext);
    return DEFAULT;
}
{BREAK} {
    printf("%d \tKEY \t%s\n",lineno,yytext);
    return BREAK;
}
{SWITCH} {
    printf("%d \tKEY \t%s\n",lineno,yytext);
    return SWITCH;
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

