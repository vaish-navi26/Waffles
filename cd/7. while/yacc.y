%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
void yyerror(const char *msg);

// ✅ Define the parse tree node structure
typedef struct Node {
    char *name;
    struct Node *left, *right;
} Node;

// ✅ Function to create a new node
Node* createNode(const char *name, Node *left, Node *right) {
    Node *node = (Node *)malloc(sizeof(Node));  // Allocate memory for the node
    if (!node) {
        printf("Memory allocation failed!\n");
        exit(1);
    }
    node->name = strdup(name);  // Allocate memory for the name
    node->left = left;
    node->right = right;
    return node;
}

// ✅ Function to print the parse tree (preorder)
void printTree(Node *root, int level) {
    if (!root) return;
    for (int i = 0; i < level; i++) printf("  ");
    printf("|-- %s\n", root->name);
    printTree(root->left, level + 1);
    printTree(root->right, level + 1);
}

Node *root;
%}

%union {
    struct Node *node;
    char *string;
}

%token WHILE LPAREN RPAREN LBRACE RBRACE ASSIGN ADD SUB MUL DIV AND OR NOT XOR GT LT GE LE EQ NE ID NUMBER SEMICOLON
%type <node> program while_stmt condition stmt_list statement expression term factor
%type <string> ID NUMBER

%%

program: while_stmt { 
            root = $1; 
            printf("\n--- PARSE TREE ---\n");
            printTree(root, 0); 
            printf("\nParsing Successful!\n");
        }
       ;

while_stmt: WHILE LPAREN condition RPAREN LBRACE stmt_list RBRACE {
                $$ = createNode("WHILE", $3, $6);
          }
          ;

condition: ID LT NUMBER  { $$ = createNode("<", createNode($1, NULL, NULL), createNode($3, NULL, NULL)); }
         | ID GT NUMBER  { $$ = createNode(">", createNode($1, NULL, NULL), createNode($3, NULL, NULL)); }
         | ID GE NUMBER  { $$ = createNode(">=", createNode($1, NULL, NULL), createNode($3, NULL, NULL)); }
         | ID LE NUMBER  { $$ = createNode("<=", createNode($1, NULL, NULL), createNode($3, NULL, NULL)); }
         | ID EQ NUMBER  { $$ = createNode("==", createNode($1, NULL, NULL), createNode($3, NULL, NULL)); }
         | ID NE NUMBER  { $$ = createNode("!=", createNode($1, NULL, NULL), createNode($3, NULL, NULL)); }
         ;

stmt_list: stmt_list statement { $$ = createNode("STATEMENTS", $1, $2); }
         | statement { $$ = $1; }
         ;

statement: ID ASSIGN expression SEMICOLON { 
                $$ = createNode("ASSIGN", createNode($1, NULL, NULL), $3);
          }
         | WHILE LPAREN condition RPAREN LBRACE stmt_list RBRACE { 
                $$ = createNode("WHILE", $3, $6);
          }
         ;

expression: expression ADD term { $$ = createNode("+", $1, $3); }
          | expression SUB term { $$ = createNode("-", $1, $3); }
          | term { $$ = $1; }
          ;

term: term MUL factor { $$ = createNode("*", $1, $3); }
    | term DIV factor { $$ = createNode("/", $1, $3); }
    | factor { $$ = $1; }
    ;

factor: ID { $$ = createNode($1, NULL, NULL); }
      | NUMBER { $$ = createNode($1, NULL, NULL); }
      ;

%%

// Error handling
void yyerror(const char *msg) {
    printf("Syntax Error: %s\n", msg);
}

int main() {
    setvbuf(stdout, NULL, _IOLBF, 0);  // Line buffering for stdout
    fprintf(stderr, "Enter a while loop statement:\n");  // Prompt to stderr
    fflush(stderr);  // Flush stderr to print immediately
    yyparse();
    return 0;
}
