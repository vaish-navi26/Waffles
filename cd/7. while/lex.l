%{
#include "yacc.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int line_num = 1;
%}

%%

while       { printf("Line %-4d | %-15s | WHILE        | -\n", line_num, yytext); return WHILE; }
\(          { printf("Line %-4d | %-15s | LPAREN       | -\n", line_num, yytext); return LPAREN; }
\)          { printf("Line %-4d | %-15s | RPAREN       | -\n", line_num, yytext); return RPAREN; }
\{          { printf("Line %-4d | %-15s | LBRACE       | -\n", line_num, yytext); return LBRACE; }
\}          { printf("Line %-4d | %-15s | RBRACE       | -\n", line_num, yytext); return RBRACE; }
=           { printf("Line %-4d | %-15s | ASSIGN       | -\n", line_num, yytext); return ASSIGN; }
\+          { printf("Line %-4d | %-15s | ADD          | -\n", line_num, yytext); return ADD; }
\-          { printf("Line %-4d | %-15s | SUB          | -\n", line_num, yytext); return SUB; }
\*          { printf("Line %-4d | %-15s | MUL          | -\n", line_num, yytext); return MUL; }
\/          { printf("Line %-4d | %-15s | DIV          | -\n", line_num, yytext); return DIV; }
\&          { printf("Line %-4d | %-15s | AND          | -\n", line_num, yytext); return AND; }
\|          { printf("Line %-4d | %-15s | OR           | -\n", line_num, yytext); return OR; }
\~          { printf("Line %-4d | %-15s | NOT          | -\n", line_num, yytext); return NOT; }
\^          { printf("Line %-4d | %-15s | XOR          | -\n", line_num, yytext); return XOR; }
\>          { printf("Line %-4d | %-15s | GT           | -\n", line_num, yytext); return GT; }
\<          { printf("Line %-4d | %-15s | LT           | -\n", line_num, yytext); return LT; }
\>=         { printf("Line %-4d | %-15s | GE           | -\n", line_num, yytext); return GE; }
\<=         { printf("Line %-4d | %-15s | LE           | -\n", line_num, yytext); return LE; }
==          { printf("Line %-4d | %-15s | EQ           | -\n", line_num, yytext); return EQ; }
!=          { printf("Line %-4d | %-15s | NE           | -\n", line_num, yytext); return NE; }
[0-9]+      { printf("Line %-4d | %-15s | NUMBER       | %s\n", line_num, yytext, yytext); yylval.string = strdup(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]*   { printf("Line %-4d | %-15s | IDENTIFIER   | %s\n", line_num, yytext, yytext); yylval.string = strdup(yytext); return ID; }
\;          { printf("Line %-4d | %-15s | SEMICOLON    | -\n", line_num, yytext); return SEMICOLON; }
\n          { line_num++; }
[ \t]       ;   // Ignore spaces and tabs
.           { printf("Line %-4d | %-15s | ERROR        | -\n", line_num, yytext); printf("Lexical Error: Unexpected character '%s'\n", yytext); }

%%

int yywrap() { return 1; }