%{
#include <stdio.h>
#include <stdlib.h>
#include "ass7.tab.h"  // Correctly declares yylval as YYSTYPE
%}

%%

[0-9]+      { yylval.val = atoi(yytext); return NUMBER; }
[\t ]+      ;                 // Ignore whitespace
\n          return 0;         // End input on newline
.           return yytext[0]; // Return single characters

%%

int yywrap() {
    return 1;
}
