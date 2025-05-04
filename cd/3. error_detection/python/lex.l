%{
#include <stdio.h>
#include <stdlib.h>

int line_num = 1;
int unterminated_string = 0;
%}

DIGIT       [0-9]
LETTER      [a-zA-Z_]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*
INTEGER     {DIGIT}+
FLOAT       {DIGIT}+"."{DIGIT}*
OPERATOR    "+"|"-"|"*"|"**"|"/"|"//"|"%"|"@"|"="|"=="|"!="|"<"|">"|"<="|">="|"and"|"or"|"not"|"is"|"in"
SEPARATOR   ":"|","|"("|")"|"["|"]"|"{"|"}"|"."|";"
COMMENT     "#".*
WHITESPACE  [ \t\n]
STRING      \"([^"\\\n]|\\.)*\"|\'([^'\\\n]|\\.)*\'
TRIPLE_STRING \"\"\"([^\\]|\\.)*\"\"\"|\'\'\'([^\\]|\\.)*\'\'\'

%%

{WHITESPACE}   { if (yytext[0] == '\n') line_num++; }
{COMMENT}      { /* Ignore comments */ }

"def"         { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"class"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"if"          { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"elif"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"else"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"while"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"for"         { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"try"         { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"except"      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"finally"     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"return"      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"import"      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"from"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"as"          { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"pass"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"break"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"continue"    { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"None"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"True"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"False"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }

{IDENTIFIER}  { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "IDENTIFIER", yytext); }
{INTEGER}     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "INTEGER", yytext); }
{FLOAT}       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "FLOAT", yytext); }
{OPERATOR}    { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "OPERATOR", yytext); }
{SEPARATOR}   { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "SEPARATOR", yytext); }

\"\"\"[^\"]*$  { 
                printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "ERROR", "Unterminated triple-quoted string");
                unterminated_string = 1;
              }
\'\'\'[^\']*$  { 
                printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "ERROR", "Unterminated triple-quoted string");
                unterminated_string = 1;
              }
\"[^"\n]*$    { 
                printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "ERROR", "Unterminated string");
                unterminated_string = 1;
              }
\'[^'\n]*$    { 
                printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "ERROR", "Unterminated string");
                unterminated_string = 1;
              }

{STRING}      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "STRING", yytext); }
{TRIPLE_STRING} { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "STRING", yytext); }

.             { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "ERROR", "Undefined token"); }

%%

int yywrap() { return 1; }

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file.py>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        perror("Error opening file");
        return 1;
    }

    yyin = input;
    
    printf("%-8s%-20s%-15s%-15s\n", "Line", "Lexeme", "Token", "Token Value");
    printf("-------------------------------------------------\n");
    
    yylex();
    
    if (unterminated_string) {
        fprintf(stderr, "Error: Unterminated string found in the file.\n");
    }
    
    fclose(input);
    return 0;
}