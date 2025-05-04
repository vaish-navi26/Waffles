%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();
void print_indent(int level);
int indent = 0;
%}

%union {
    char* str;
}
%token <str> ID NUMBER
%token SWITCH CASE DEFAULT BREAK LBRACE RBRACE COLON SEMICOLON ASSIGN

%%

program:
    switch_stmt {
        printf("\nParse tree complete. Exiting...\n");
        exit(0);  // Terminate after successful parse
    }
    ;

switch_stmt:
    SWITCH '(' expr ')' LBRACE case_list RBRACE {
        print_indent(indent); printf("|-- switch_stmt\n");
        indent++;
        print_indent(indent); printf("|-- SWITCH\n");
        print_indent(indent); printf("|-- (\n");
        print_indent(indent); printf("|-- expr\n");
        indent++;
        // expr prints itself
        indent--;
        print_indent(indent); printf("|-- )\n");
        print_indent(indent); printf("|-- LBRACE\n");
        print_indent(indent); printf("|-- case_list\n");
        indent++;
        // case_list prints itself
        indent--;
        print_indent(indent); printf("|-- RBRACE\n");
        indent--;
    }
    ;

/* Rest of your grammar rules remain the same */
/* ... */

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    exit(1);  // Exit on error
}

void print_indent(int level) {
    for (int i = 0; i < level; i++) printf("    ");
}

int main() {
    printf("Enter a switch statement (Ctrl+D to end input):\n");
    yyparse();
    return 0;
}