%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

// Language modes
#define MODE_SQL 0
#define MODE_C 1
#define MODE_PYTHON 2
#define MODE_ENGLISH 3
#define MODE_JAVA 4

int current_mode = MODE_SQL;
int line_num = 1;
int column_num = 1;

// For English analysis
int noun_count = 0;
int pronoun_count = 0;
int adjective_count = 0;
int verb_count = 0;
int adverb_count = 0;

// Arrays to store words
char nouns[100][50];
char pronouns[100][50];
char adjectives[100][50];
char verbs[100][50];
char adverbs[100][50];

// Keyword lists
const char *sqlKeywords[] = {
    "SELECT", "FROM", "WHERE", "INSERT", "UPDATE", "DELETE",
    "CREATE", "DROP", "TABLE", "VALUES", "INTO", "SET", NULL
};

const char *cKeywords[] = {
    "auto", "break", "case", "char", "const", "continue",
    "default", "do", "double", "else", "enum", "extern",
    "float", "for", "goto", "if", "int", "long",
    "register", "return", "short", "signed", "sizeof", "static",
    "struct", "switch", "typedef", "union", "unsigned", "void",
    "volatile", "while", NULL
};

const char *pythonKeywords[] = {
    "False", "None", "True", "and", "as", "assert",
    "async", "await", "break", "class", "continue", "def",
    "del", "elif", "else", "except", "finally", "for",
    "from", "global", "if", "import", "in", "is",
    "lambda", "nonlocal", "not", "or", "pass", "raise",
    "return", "try", "while", "with", "yield", NULL
};

const char *javaKeywords[] = {
    "abstract", "assert", "boolean", "break", "byte", "case",
    "catch", "char", "class", "const", "continue", "default",
    "do", "double", "else", "enum", "extends", "final",
    "finally", "float", "for", "goto", "if", "implements",
    "import", "instanceof", "int", "interface", "long", "native",
    "new", "package", "private", "protected", "public", "return",
    "short", "static", "strictfp", "super", "switch", "synchronized",
    "this", "throw", "throws", "transient", "try", "void",
    "volatile", "while", NULL
};

const char *englishPronouns[] = {
    "I", "you", "he", "she", "it", "we", "they",
    "me", "him", "her", "us", "them",
    "my", "your", "his", "its", "our", "their",
    "mine", "yours", "hers", "ours", "theirs",
    "myself", "yourself", "himself", "herself",
    "itself", "ourselves", "yourselves", "themselves", NULL
};

const char *englishAdjectives[] = {
    "good", "bad", "big", "small", "happy", "sad",
    "beautiful", "ugly", "fast", "slow", "young", "old",
    "new", "old", "right", "wrong", "strong", "weak",
    "true", "false", "clever", "stupid", "rich", "poor",
    "hot", "cold", "warm", "cool", "soft", "hard", NULL
};

const char *englishAdverbs[] = {
    "quickly", "slowly", "well", "badly", "easily", "hard",
    "fast", "slow", "very", "really", "almost", "always",
    "never", "often", "sometimes", "usually", "early", "late",
    "here", "there", "now", "then", "today", "tomorrow",
    "yesterday", "soon", "already", "yet", "still", "even", NULL
};

// Function to check if a string is in a keyword list
int isInList(const char *word, const char **list) {
    for (int i = 0; list[i] != NULL; i++) {
        if (strcasecmp(word, list[i]) == 0) return 1;
    }
    return 0;
}

// Function to get token type based on current mode
const char* getTokenType(const char *value) {
    switch(current_mode) {
        case MODE_SQL:
            if (isInList(value, sqlKeywords)) return "KEYWORD";
            break;
        case MODE_C:
            if (isInList(value, cKeywords)) return "KEYWORD";
            break;
        case MODE_PYTHON:
            if (isInList(value, pythonKeywords)) return "KEYWORD";
            break;
        case MODE_JAVA:
            if (isInList(value, javaKeywords)) return "KEYWORD";
            break;
        case MODE_ENGLISH:
            if (isInList(value, englishPronouns)) return "PRONOUN";
            if (isInList(value, englishAdjectives)) return "ADJECTIVE";
            if (isInList(value, englishAdverbs)) return "ADVERB";
            if (strlen(value) > 2 && 
                (value[strlen(value)-1] == 's' || 
                 strstr(value, "ing") || 
                 strstr(value, "ed"))) {
                return "VERB";
            }
            return "NOUN";
    }

    if (isdigit(value[0])) {
        return "NUMBER";
    } else if (value[0] == '\'') {
        return "STRING";
    } else if (strcmp(value, ";") == 0 || strcmp(value, ",") == 0 ||
               strcmp(value, "(") == 0 || strcmp(value, ")") == 0 ||
               strcmp(value, "{") == 0 || strcmp(value, "}") == 0 ||
               strcmp(value, "[") == 0 || strcmp(value, "]") == 0) {
        return "SYMBOL";
    } else if (strcmp(value, "=") == 0 || strcmp(value, ">") == 0 || 
               strcmp(value, "<") == 0 || strcmp(value, "!=") == 0 ||
               strcmp(value, ">=") == 0 || strcmp(value, "<=") == 0 ||
               strcmp(value, "+") == 0 || strcmp(value, "-") == 0 ||
               strcmp(value, "*") == 0 || strcmp(value, "/") == 0 ||
               strcmp(value, "==") == 0 || strcmp(value, "++") == 0 ||
               strcmp(value, "--") == 0 || strcmp(value, "+=") == 0 ||
               strcmp(value, "-=") == 0 || strcmp(value, "*=") == 0 ||
               strcmp(value, "/=") == 0) {
        return "OPERATOR";
    } else if (isalpha(value[0]) || value[0] == '_') {
        return "IDENTIFIER";
    } else {
        return "UNKNOWN";
    }
}

void countEnglishWord(const char *word) {
    const char *type = getTokenType(word);
    if (strcmp(type, "NOUN") == 0) {
        strcpy(nouns[noun_count++], word);
    }
    else if (strcmp(type, "PRONOUN") == 0) {
        strcpy(pronouns[pronoun_count++], word);
    }
    else if (strcmp(type, "ADJECTIVE") == 0) {
        strcpy(adjectives[adjective_count++], word);
    }
    else if (strcmp(type, "VERB") == 0) {
        strcpy(verbs[verb_count++], word);
    }
    else if (strcmp(type, "ADVERB") == 0) {
        strcpy(adverbs[adverb_count++], word);
    }
}

void print_english_table() {
    printf("\n+------------+------------+--------------+--------+---------+\n");
    printf("| %-10s | %-10s | %-12s | %-6s | %-7s |\n", 
           "Nouns", "Pronouns", "Adjectives", "Verbs", "Adverbs");
    printf("+------------+------------+--------------+--------+---------+\n");
    
    int max_rows = noun_count;
    if (pronoun_count > max_rows) max_rows = pronoun_count;
    if (adjective_count > max_rows) max_rows = adjective_count;
    if (verb_count > max_rows) max_rows = verb_count;
    if (adverb_count > max_rows) max_rows = adverb_count;
    
    for (int i = 0; i < max_rows; i++) {
        printf("| %-10s | %-10s | %-12s | %-6s | %-7s |\n",
               i < noun_count ? nouns[i] : "-",
               i < pronoun_count ? pronouns[i] : "-",
               i < adjective_count ? adjectives[i] : "-",
               i < verb_count ? verbs[i] : "-",
               i < adverb_count ? adverbs[i] : "-");
    }

    printf("+------------+------------+--------------+--------+---------+\n");
    printf("| %-10d | %-10d | %-12d | %-6d | %-7d |\n", 
           noun_count, pronoun_count, adjective_count, verb_count, adverb_count);
    printf("+------------+------------+--------------+--------+---------+\n");
}
%}

%option noyywrap

DIGIT       [0-9]
LETTER      [a-zA-Z]
ID          ({LETTER}|_)({LETTER}|{DIGIT}|_)*
NUMBER      {DIGIT}+
STRING      \'[^\']*\'|\"[^\"]*\"
OPERATOR    "="|">"|"<"|"!="|">="|"<="|"+"|"-"|"*"|"/"|"=="|"++"|"--"|"+="|"-="|"*="|"/="
SYMBOL      [;(),{}[\]]
WHITESPACE  [ \t]+
NEWLINE     \n
COMMENT     --.*|"/*"([^*]|"*"+[^*/])*"*"+"/"|"//".*
WORD        [a-zA-Z]+

%%

{COMMENT}   { 
                char *p = yytext;
                while (*p) {
                    if (*p == '\n') line_num++;
                    p++;
                }
                column_num = 1;
            }

{WHITESPACE} { column_num += yyleng; }

{NEWLINE}    { line_num++; column_num = 1; }

{STRING}     {
                if (current_mode == MODE_ENGLISH) {
                    countEnglishWord(yytext);
                } else {
                    printf("| %-6d | %-6d | %-15s | %-10s | %-12s |\n", 
                           column_num, line_num, yytext, "STRING", yytext);
                }
                column_num += yyleng;
            }

{OPERATOR}   {
                if (current_mode != MODE_ENGLISH) {
                    printf("| %-6d | %-6d | %-15s | %-10s | %-12s |\n", 
                           column_num, line_num, yytext, "OPERATOR", yytext);
                }
                column_num += yyleng;
            }

{SYMBOL}     {
                if (current_mode != MODE_ENGLISH) {
                    printf("| %-6d | %-6d | %-15s | %-10s | %-12s |\n", 
                           column_num, line_num, yytext, "SYMBOL", yytext);
                }
                column_num += yyleng;
            }

{NUMBER}     {
                if (current_mode != MODE_ENGLISH) {
                    printf("| %-6d | %-6d | %-15s | %-10s | %-12s |\n", 
                           column_num, line_num, yytext, "NUMBER", yytext);
                }
                column_num += yyleng;
            }

{ID}         {
                if (current_mode == MODE_ENGLISH) {
                    countEnglishWord(yytext);
                } else {
                    const char *type = getTokenType(yytext);
                    printf("| %-6d | %-6d | %-15s | %-10s | %-12s |\n", 
                           column_num, line_num, yytext, type, yytext);
                }
                column_num += yyleng;
            }

{}       {
                if (current_mode == MODE_ENGLISH) {
                    countEnglishWord(yytext);
                }
                column_num += yyleng;
            }

.            {
                if (current_mode != MODE_ENGLISH) {
                    printf("| %-6d | %-6d | %-15s | %-10s | %-12s |\n", 
                           column_num, line_num, yytext, "ERROR", yytext);
                }
                column_num += yyleng;
            }

%%

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <filename> [mode]\n", argv[0]);
        fprintf(stderr, "Modes: sql (default), c, python, java, english\n");
        return 1;
    }

    // Determine mode from filename extension or explicit mode
    char *ext = strrchr(argv[1], '.');
    if (ext != NULL) {
        ext++;
        if (strcmp(ext, "c") == 0) current_mode = MODE_C;
        else if (strcmp(ext, "py") == 0) current_mode = MODE_PYTHON;
        else if (strcmp(ext, "java") == 0) current_mode = MODE_JAVA;
        else if (strcmp(ext, "sql") == 0) current_mode = MODE_SQL;
        else if (strcmp(ext, "txt") == 0) current_mode = MODE_ENGLISH;
    }

    // Override with explicit mode if provided
    if (argc > 2) {
        if (strcmp(argv[2], "c") == 0) current_mode = MODE_C;
        else if (strcmp(argv[2], "python") == 0) current_mode = MODE_PYTHON;
        else if (strcmp(argv[2], "java") == 0) current_mode = MODE_JAVA;
        else if (strcmp(argv[2], "sql") == 0) current_mode = MODE_SQL;
        else if (strcmp(argv[2], "english") == 0) current_mode = MODE_ENGLISH;
    }

    if (current_mode != MODE_ENGLISH) {
        printf("| %-6s | %-6s | %-15s | %-10s | %-12s |\n", 
               "Column", "Line", "Lexeme", "Token", "Token Value");
        printf("|--------|--------|-----------------|------------|--------------|\n");
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Error opening file: %s\n", argv[1]);
        return 1;
    }

    yylex();

    if (current_mode == MODE_ENGLISH) {
        print_english_table();
    }

    fclose(yyin);
    return 0;
}

