%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex();
%}

%union {
    char* str;
}

%token <str> ARTICLE NOUN VERB ADJECTIVE
%type <str> sentence opt_adj


%%

sentence:
    ARTICLE opt_adj NOUN VERB NOUN {
        printf("Valid sentence structure:\n");
        printf("Article: %s\n", $1);
        if ($2) printf("Adjective: %s\n", $2);
        printf("Subject: %s\n", $3);
        printf("Verb: %s\n", $4);
        printf("Object: %s\n", $5);
    }
    ;

opt_adj:
    /* empty */    { $$ = NULL; }
    | ADJECTIVE    { $$ = $1; }
    ;

%%

void yyerror(const char *s) {
    printf("Syntax error: %s\n", s);
}

int main() {
    printf("Enter a sentence:\n");
    yyparse();
    return 0;
}
