%{
#include <stdio.h>
#include <stdlib.h>

int line_num = 1;
int unterminated_string = 0;
%}

DIGIT       [0-9]
LETTER      [a-zA-Z_]
INTEGER     -?{DIGIT}+
FLOAT       -?{DIGIT}+"."{DIGIT}+([eE][+-]?{DIGIT}+)?
WHITESPACE  [ \t\n\r]
STRING      \"([^"\\\n]|\\.)*\"

%%

{WHITESPACE}   { if (yytext[0] == '\n') line_num++; }

"true"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "LITERAL", "true"); }
"false"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "LITERAL", "false"); }
"null"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "LITERAL", "null"); }

"{"           { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "PUNCTUATION", "{"); }
"}"           { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "PUNCTUATION", "}"); }
"["           { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "PUNCTUATION", "["); }
"]"           { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "PUNCTUATION", "]"); }
":"           { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "PUNCTUATION", ":"); }
","           { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "PUNCTUATION", ","); }

{INTEGER}     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "NUMBER", yytext); }
{FLOAT}       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "NUMBER", yytext); }

\"[^"\n]*$    { 
                printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "ERROR", "Unterminated string");
                unterminated_string = 1;
              }

{STRING}      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "STRING", yytext); }

.             { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "ERROR", "Undefined token"); }

%%

int yywrap() { return 1; }

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file.json>\n", argv[0]);
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