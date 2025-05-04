#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#define MAX_TOKEN_LEN 100
#define SYMBOL_TABLE_SIZE 100
#define OUTPUT_FILENAME "symbol_table.txt"

typedef enum {
    TOKEN_IDENTIFIER,
    TOKEN_CONSTANT,
    TOKEN_KEYWORD,
    TOKEN_OPERATOR,
    TOKEN_DELIMITER,
    TOKEN_EOF,
    TOKEN_UNKNOWN
} TokenType;

typedef struct {
    TokenType type;
    char value[MAX_TOKEN_LEN];
    int line_number;
    int symbol_index;
} Token;

typedef struct {
    int index;
    char name[MAX_TOKEN_LEN];
    int first_line;
    int last_line;
    int count;
} SymbolEntry;

SymbolEntry symbol_table[SYMBOL_TABLE_SIZE];
int symtab_size = 0;
int current_line = 1;
char current_char = ' ';

void initialize_lexer();
char get_next_char(FILE *input);
void skip_whitespace(FILE *input);
void skip_comments(FILE *input);
int is_keyword(const char *str);
int find_or_add_symbol(const char *name, int line);
Token scan_identifier(FILE *input);
Token scan_number(FILE *input);
Token scan_operator(FILE *input);
Token get_token(FILE *input);
void write_symbol_table_to_file();
void print_token(Token token, FILE *output);
void lexical_analyze(FILE *input, FILE *output);

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        perror("Error opening input file");
        return 1;
    }

    FILE *output = fopen("lexer_output.txt", "w");
    if (!output) {
        perror("Error creating output file");
        fclose(input);
        return 1;
    }

    initialize_lexer();
    lexical_analyze(input, output);

    fclose(input);
    fclose(output);
    write_symbol_table_to_file();

    printf("\nLexical analysis complete. Results written to:\n");
    printf("  - Token stream: lexer_output.txt\n");
    printf("  - Symbol table: %s\n", OUTPUT_FILENAME);

    return 0;
}

void initialize_lexer() {
    current_line = 1;
    current_char = ' ';
    symtab_size = 0;
}

char get_next_char(FILE *input) {
    current_char = fgetc(input);
    if (current_char == '\n') current_line++;
    return current_char;
}

void skip_whitespace(FILE *input) {
    while (isspace(current_char)) {
        get_next_char(input);
    }
}

void skip_comments(FILE *input) {
    if (current_char == '/') {
        get_next_char(input);
        if (current_char == '/') {
            while (current_char != '\n' && current_char != EOF)
                get_next_char(input);
        } else if (current_char == '*') {
            get_next_char(input);
            while (1) {
                if (current_char == '*' && get_next_char(input) == '/') {
                    get_next_char(input);
                    break;
                } else if (current_char == EOF) {
                    break;
                } else {
                    get_next_char(input);
                }
            }
        } else {
            ungetc(current_char, input);
            current_char = '/';
        }
    }
}

int is_keyword(const char *str) {
    const char *keywords[] = {
        "if", "else", "while", "for", "return",
        "int", "float", "char", "void"
    };
    for (int i = 0; i < 9; i++) {
        if (strcmp(str, keywords[i]) == 0) return 1;
    }
    return 0;
}

int find_or_add_symbol(const char *name, int line) {
    for (int i = 0; i < symtab_size; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            symbol_table[i].last_line = line;
            symbol_table[i].count++;
            return symbol_table[i].index;
        }
    }
    if (symtab_size < SYMBOL_TABLE_SIZE) {
        symbol_table[symtab_size].index = symtab_size;
        strcpy(symbol_table[symtab_size].name, name);
        symbol_table[symtab_size].first_line = line;
        symbol_table[symtab_size].last_line = line;
        symbol_table[symtab_size].count = 1;
        return symtab_size++;
    }
    return -1;
}

Token scan_identifier(FILE *input) {
    Token token;
    int i = 0;
    token.line_number = current_line;
    token.symbol_index = -1;

    while (isalnum(current_char) || current_char == '_') {
        if (i < MAX_TOKEN_LEN - 1)
            token.value[i++] = current_char;
        get_next_char(input);
    }
    token.value[i] = '\0';

    if (is_keyword(token.value)) {
        token.type = TOKEN_KEYWORD;
    } else {
        token.type = TOKEN_IDENTIFIER;
        token.symbol_index = find_or_add_symbol(token.value, current_line);
    }
    return token;
}

Token scan_number(FILE *input) {
    Token token;
    int i = 0, has_dot = 0;
    token.type = TOKEN_CONSTANT;
    token.line_number = current_line;
    token.symbol_index = -1;

    while (isdigit(current_char) || (current_char == '.' && !has_dot)) {
        if (current_char == '.') has_dot = 1;
        if (i < MAX_TOKEN_LEN - 1)
            token.value[i++] = current_char;
        get_next_char(input);
    }
    token.value[i] = '\0';
    return token;
}

Token scan_operator(FILE *input) {
    Token token;
    token.line_number = current_line;
    token.symbol_index = -1;
    token.type = TOKEN_OPERATOR;
    token.value[0] = current_char;
    token.value[1] = '\0';

    char prev = current_char;
    get_next_char(input);

    if ((prev == '=' || prev == '!' || prev == '<' || prev == '>') && current_char == '=') {
        token.value[1] = current_char;
        token.value[2] = '\0';
        get_next_char(input);
    }

    return token;
}

Token get_token(FILE *input) {
    Token token;
    skip_whitespace(input);
    skip_comments(input);

    if (current_char == EOF) {
        token.type = TOKEN_EOF;
        strcpy(token.value, "EOF");
        token.line_number = current_line;
        token.symbol_index = -1;
        return token;
    }

    if (isalpha(current_char) || current_char == '_') return scan_identifier(input);
    if (isdigit(current_char)) return scan_number(input);
    if (strchr("+-*/%=!<>", current_char)) return scan_operator(input);
    if (strchr(";,(){}[]", current_char)) {
        token.type = TOKEN_DELIMITER;
        token.value[0] = current_char;
        token.value[1] = '\0';
        token.line_number = current_line;
        token.symbol_index = -1;
        get_next_char(input);
        return token;
    }

    token.type = TOKEN_UNKNOWN;
    token.value[0] = current_char;
    token.value[1] = '\0';
    token.line_number = current_line;
    token.symbol_index = -1;
    get_next_char(input);
    return token;
}

void print_token(Token token, FILE *output) {
    const char *type_str;
    switch (token.type) {
        case TOKEN_IDENTIFIER: type_str = "IDENTIFIER"; break;
        case TOKEN_CONSTANT:   type_str = "CONSTANT";   break;
        case TOKEN_KEYWORD:    type_str = "KEYWORD";    break;
        case TOKEN_OPERATOR:   type_str = "OPERATOR";   break;
        case TOKEN_DELIMITER:  type_str = "DELIMITER";  break;
        case TOKEN_EOF:        type_str = "EOF";        break;
        default:               type_str = "UNKNOWN";    break;
    }

    // Print to terminal
    printf("%-6d | %-27s | %-16s | %-11s |\n",
           token.line_number,
           type_str,
           token.value,
           (token.symbol_index != -1) ? (char[12]){0} : "");

    if (token.symbol_index != -1)
        printf("%-6d | %-27s | %-16s | sym#%-7d |\n",
               token.line_number, type_str, token.value, token.symbol_index);

    // Print to file
    fprintf(output, "%-6d | %-27s | %-16s |", token.line_number, type_str, token.value);
    if (token.symbol_index != -1)
        fprintf(output, " sym#%-7d |\n", token.symbol_index);
    else
        fprintf(output, " %-11s |\n", "");
}

void lexical_analyze(FILE *input, FILE *output) {
    Token token;
    get_next_char(input);

    printf("\nLine   | Lexeme/Token Type          | Token  Value     | Symbol Ref |\n");
    printf("|------|-----------------------------|------------------|-------------|\n");

    fprintf(output, "\nLine   | Lexeme/Token Type          | Token  Value     | Symbol Ref |\n");
    fprintf(output, "|------|-----------------------------|------------------|-------------|\n");

    do {
        token = get_token(input);
        print_token(token, output);
    } while (token.type != TOKEN_EOF);
}

void write_symbol_table_to_file() {
    FILE *file = fopen(OUTPUT_FILENAME, "w");
    if (!file) {
        perror("Error creating symbol table file");
        return;
    }

    fprintf(file, "Symbol Table (Indexed):\n");
    fprintf(file, "%-8s %-20s %-12s %-12s %s\n", "Index", "Identifier", "First Line", "Last Line", "Count");
    fprintf(file, "------------------------------------------------------------\n");

    for (int i = 0; i < symtab_size; i++) {
        fprintf(file, "%-8d %-20s %-12d %-12d %d\n",
                symbol_table[i].index,
                symbol_table[i].name,
                symbol_table[i].first_line,
                symbol_table[i].last_line,
                symbol_table[i].count);
    }

    fclose(file);
}

/*
commands:
gcc 4th.c -o lex4
./lex4 input4.c
*/