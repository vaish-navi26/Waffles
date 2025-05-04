%{
#include<stdio.h>
#include"y.tab.h"
extern int lineno;
%}
%option noyywrap
%%
[a-z|A-Z] {return ID;}
[0-9]+ {return NUM;}
[ \t]+ {}
[\n] {lineno++;}
[\(\)] {return yytext[0];}
[\+\-\*\/\^] {return yytext[0];}
%%