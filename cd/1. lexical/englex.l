%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define MODE_ENGLISH 4

int line_num = 1;
int column_num = 1;

const char *englishStopwords[] = {
    "a", "an", "and", "are", "as", "at", "be", "but", "by", "for", "if", "in",
    "into", "is", "it", "no", "not", "of", "on", "or", "such", "that", "the",
    "their", "then", "there", "these", "they", "this", "to", "was", "will", "with", NULL
};

int isInList(const char *word, const char **list) {
    for (int i = 0; list[i] != NULL; i++) {
        if (strcasecmp(word, list[i]) == 0) return 1;
    }
    return 0;
}

const char* getTokenType(const char *value) {
    if (isInList(value, englishStopwords)) return "STOPWORD";
    if (isdigit(value[0])) return "NUMBER";
    if (value[0] == '\'' || value[0] == '"') return "STRING";
    if (ispunct(value[0])) return "PUNCTUATION";
    if (isalpha(value[0])) return "WORD";
    return "UNKNOWN";
}
%}

%option noyywrap

DIGIT       [0-9]
LETTER      [a-zA-Z]
WORD        {LETTER}+
NUMBER      {DIGIT}+(\.{DIGIT}+)?
PUNCT       [.,!?;:\"'()-]
WHITESPACE  [ \t]+
NEWLINE     \n
%%

{WHITESPACE} { column_num += yyleng; }

{NEWLINE}    { line_num++; column_num = 1; }

{WORD}       {
    const char *type = getTokenType(yytext);
    printf("| %-6d | %-6d | %-15s | %-12s | %-12s |\n",
           column_num, line_num, yytext, type, yytext);
    column_num += yyleng;
}

{NUMBER}     {
    printf("| %-6d | %-6d | %-15s | %-12s | %-12s |\n",
           column_num, line_num, yytext, "NUMBER", yytext);
    column_num += yyleng;
}

{PUNCT}      {
    printf("| %-6d | %-6d | %-15s | %-12s | %-12s |\n",
           column_num, line_num, yytext, "PUNCTUATION", yytext);
    column_num += yyleng;
}

.            {
    printf("| %-6d | %-6d | %-15s | %-12s | %-12s |\n",
           column_num, line_num, yytext, "UNKNOWN", yytext);
    column_num += yyleng;
}

%%

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    printf("| %-6s | %-6s | %-15s | %-12s | %-12s |\n",
           "Column", "Line", "Lexeme", "Token", "Token Value");
    printf("|--------|--------|-----------------|--------------|--------------|\n");

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Error opening file: %s\n", argv[1]);
        return 1;
    }

    yylex();
    fclose(yyin);
    return 0;
}
