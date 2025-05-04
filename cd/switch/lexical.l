%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>

#ifndef strdup
char *strdup(const char *s) {
    char *d = malloc(strlen(s) + 1);
    if (d == NULL) return NULL;
    strcpy(d, s);
    return d;
}
#endif
%}

%%

"switch"      { return SWITCH; }
"case"        { return CASE; }
"default"     { return DEFAULT; }
"break"       { return BREAK; }
"{"           { return LBRACE; }
"}"           { return RBRACE; }
":"           { return COLON; }
";"           { return SEMICOLON; }
"="           { return ASSIGN; }
"("           { return '('; }
")"           { return ')'; }
[0-9]+        { yylval.str = strdup(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return ID; }
[ \t\n]+      { /* ignore whitespace */ }
<<EOF>>       { return 0; }  /* Add EOF handling */
.             { return yytext[0]; }

%%

int yywrap() { return 1; }