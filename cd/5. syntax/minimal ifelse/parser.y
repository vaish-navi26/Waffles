%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>  

void yyerror(const char *s);
int yylex();
void print_indent(int level);
void print_condition(const char* op);
void print_stmt(const char* stmt);
char* concat(const char* s1, const char* s2, const char* s3);
int indent = 0;
%}

%union {
    char* str;
    const char* op;
}

%token <str> ID NUMBER
%token IF ELSE LPAREN RPAREN LBRACE RBRACE EQ LT GT PLUS MINUS MUL DIV SEMICOLON ASSIGN

%type <op> condition
%type <str> expr stmt_list
%type <str> stmt

%left PLUS MINUS
%left MUL DIV
%left LT GT EQ

%%

program:
    if_else_stmt { }
    ;

if_else_stmt:
    IF LPAREN condition RPAREN LBRACE stmt_list RBRACE ELSE LBRACE stmt_list RBRACE {
        print_indent(indent);
        printf("if-else\n");
        indent++;
            print_indent(indent);
            printf("condition: ");
            print_condition($3);
            print_indent(indent);
            printf("if-block:\n");
            indent++;
                print_stmt($6);
            indent--;
            print_indent(indent);
            printf("else-block:\n");
            indent++;
                print_stmt($10);
            indent--;
        indent--;
        free($6);
        free($10);
    }
    ;

condition:
    expr LT expr { $$ = "<"; free($1); free($3); }
    | expr GT expr { $$ = ">"; free($1); free($3); }
    | expr EQ expr { $$ = "=="; free($1); free($3); }
    ;

stmt_list:
    stmt { $$ = $1; }
    | stmt_list stmt { 
        $$ = concat($1, "\n", $2);
        free($1);
        free($2);
      }
    ;

stmt:
    ID ASSIGN expr SEMICOLON {
        $$ = concat($1, " = ", $3);
        free($1);
        free($3);
    }
    ;

expr:
    expr PLUS expr { $$ = concat($1, " + ", $3); }
    | expr MINUS expr { $$ = concat($1, " - ", $3); }
    | expr MUL expr { $$ = concat($1, " * ", $3); }
    | expr DIV expr { $$ = concat($1, " / ", $3); }
    | ID { $$ = strdup($1); }
    | NUMBER { $$ = strdup($1); }
    ;

%%

void print_condition(const char* op) {
    printf("%s\n", op);
}

void print_stmt(const char* stmt) {
    print_indent(indent);
    printf("%s\n", stmt);
}

char* concat(const char* s1, const char* s2, const char* s3) {
    char* result = malloc(strlen(s1) + strlen(s2) + strlen(s3) + 1);
    strcpy(result, s1);
    strcat(result, s2);
    strcat(result, s3);
    return result;
}

void print_indent(int level) {
    for (int i = 0; i < level; i++) {
        printf("  ");
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Enter an if-else statement:\n");
    yyparse();
    return 0;
}