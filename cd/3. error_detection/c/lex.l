%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int line_num = 1;
int unterminated_string = 0;
%}

DIGIT       [0-9]
LETTER      [a-zA-Z]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT}|_)*
INTEGER     {DIGIT}+
REAL        {DIGIT}+"."{DIGIT}*
OPERATOR    "+"|"-"|"*"|"/"|"="|"=="|"!="|"<"|">"|"<="|">="|"&&"|"||"|"!"
SEPARATOR   ";"|","|"("|")"|"{"|"}"|"["|"]"
COMMENT     "/*"([^*]|"*"+[^*/])*"*"+"/"|"//".*
WHITESPACE  [ \t\n]
STRING      \"([^"\\\n]|\\.)*\"

%%

{WHITESPACE}   { if (yytext[0] == '\n') line_num++; }
{COMMENT}      { /* Ignore comments */ }

"#include"     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "PREPROCESSOR", yytext); }
"#define"      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "PREPROCESSOR", yytext); }

"int"          { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"float"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"char"         { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"void"         { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"if"           { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"else"         { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"while"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"for"          { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"return"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"break"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"continue"     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }

{IDENTIFIER}   { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "IDENTIFIER", yytext); }
{INTEGER}      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "INTEGER", yytext); }
{REAL}         { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "REAL", yytext); }
{OPERATOR}     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "OPERATOR", yytext); }
{SEPARATOR}    { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "SEPARATOR", yytext); }

\"[^"\n]*$     { 
                 printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "ERROR", "Unterminated string"); 
                 unterminated_string = 1;
               }

{STRING}       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "STRING", yytext); }

.              { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "ERROR", "Undefined token"); }

%%

int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        perror("Error opening file");
        return 1;
    }

    yyin = input;
    
    // Print table header
    printf("%-8s%-20s%-15s%-15s\n", "Line", "Lexeme", "Token", "Token Value");
    printf("-------------------------------------------------\n");
    
    yylex();
    
    if (unterminated_string) {
        fprintf(stderr, "Error: Unterminated string found in the file.\n");
    }
    
    fclose(input);
    return 0;
}