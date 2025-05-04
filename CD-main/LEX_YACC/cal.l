%{
#include<stdio.h>
#include"cal.tab.h"
extern int lineno;    
%}
%option noyywrap

%%
[0-9] {
    yylval = atoi(yytext);
    return NUM;
}
[ \t]+ {}
[\+\-\*\/\^] {
    return yytext[0];
}
[\n] {
    lineno++;
}
[\(\)] {return yytext[0];}
%%