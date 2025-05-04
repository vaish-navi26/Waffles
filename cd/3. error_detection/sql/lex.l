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
OPERATOR    "="|"!="|"<>"|"<"|">"|"<="|">="|"+"|"-"|"*"|"/"|"%"
SEPARATOR   ","|"("|")"|";"
WHITESPACE  [ \t\n]
STRING      \'([^\'\\\n]|\\.)*\'
COMMENT     "--".*|"/*"([^*]|"*"+[^*/])*"*"+"/"

%%

{WHITESPACE}   { if (yytext[0] == '\n') line_num++; }
{COMMENT}      { /* Ignore comments */ }

"SELECT"     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"FROM"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"WHERE"      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"INSERT"     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"INTO"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"VALUES"     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"UPDATE"     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"DELETE"     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"CREATE"     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"TABLE"      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"ALTER"      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"DROP"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"JOIN"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"INNER"      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"OUTER"      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"LEFT"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"RIGHT"      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"GROUP BY"   { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"ORDER BY"   { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"HAVING"     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"AND"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"OR"         { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"NOT"        { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }
"NULL"       { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "KEYWORD", yytext); }

{IDENTIFIER} { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "IDENTIFIER", yytext); }
{INTEGER}    { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "INTEGER", yytext); }
{FLOAT}      { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "FLOAT", yytext); }
{OPERATOR}   { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "OPERATOR", yytext); }
{SEPARATOR}  { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "SEPARATOR", yytext); }

\'[^'\n]*$   { 
               printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "ERROR", "Unterminated string");
               unterminated_string = 1;
             }

{STRING}     { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "STRING", yytext); }

.            { printf("%-8d%-20s%-15s%-15s\n", line_num, yytext, "ERROR", "Undefined token"); }

%%

int yywrap() { return 1; }

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file.sql>\n", argv[0]);
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