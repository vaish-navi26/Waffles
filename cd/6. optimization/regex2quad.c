#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define MAX_TOKENS 100
#define MAX_TAC 200
#define MAX_QUADS 200
#define MAX_STR 32

// Node types for regex syntax tree
typedef enum { CHAR, CONCAT, UNION, STAR } NodeType;

// Syntax tree node
typedef struct RegexNode {
    NodeType type;
    char value; // valid if type == CHAR
    struct RegexNode *left, *right;
} RegexNode;

// TAC and Quadruple structures
typedef struct {
    char op[MAX_STR];
    char arg1[MAX_STR];
    char arg2[MAX_STR];
    char result[MAX_STR];
} Quadruple;

// Globals for TAC/Quadruple generation
char tac[MAX_TAC][MAX_STR];
int tac_count = 0;
Quadruple quads[MAX_QUADS];
int quad_count = 0;
int temp_var = 0;

// For combining all quadruples from all regexes
typedef struct {
    char op[MAX_STR];
    char arg1[MAX_STR];
    char arg2[MAX_STR];
    char result[MAX_STR];
} CombinedQuadruple;
CombinedQuadruple combined_quads[MAX_QUADS * 10];
int combined_quad_count = 0;

// --- Optimizer Functions (from 3.c) ---

// Add eliminated field to Quadruple for optimization
typedef struct OptQuadruple {
    char op[MAX_STR];
    char arg1[MAX_STR];
    char arg2[MAX_STR];
    char result[MAX_STR];
    bool eliminated;
} OptQuadruple;

OptQuadruple quad_list[MAX_QUADS];
int opt_quad_count = 0;

bool isConstant(const char *s) {
    if(s == NULL || *s == '\0' || strcmp(s, "") == 0) return false;
    int i = 0;
    if(s[0]=='-' || s[0]=='+') { if (s[1] == '\0') return false; i++; }
    for(; s[i] != '\0'; i++) if(!isdigit(s[i])) return false;
    return i > 0 && s[i-1] != '-' && s[i-1] != '+';
}

void printOptQuads(const char* title) {
    printf("\n--- %s ---\n", title);
    printf("Nr | %-10s | %-10s | %-10s | %-10s | %s\n", "Op", "Arg1", "Arg2", "Result", "Status");
    printf("---|------------|------------|------------|------------|--------\n");
    int displayed_count = 0;
    for (int i = 0; i < opt_quad_count; i++) {
        if (!quad_list[i].eliminated) {
            displayed_count++;
            printf("%03d| %-10s | %-10s | %-10s | %-10s | %s\n", i+1, quad_list[i].op, quad_list[i].arg1, quad_list[i].arg2, quad_list[i].result, "");
        }
    }
    if (displayed_count == 0) printf("(No quads remaining after optimization)\n");
    printf("-------------------------------------------------------------\n");
}

void commonSubexpressionElimination() {
    printf("\nPerforming Common Subexpression Elimination...\n");
    bool eliminated_found = false;
    for (int i = 0; i < opt_quad_count; i++) {
        if (quad_list[i].eliminated) continue;
        if (strcmp(quad_list[i].op, "=") == 0) continue;
        for (int j = 0; j < i; j++) {
            if (quad_list[j].eliminated) continue;
            if (strcmp(quad_list[j].op, "=") == 0) continue;
            if (strcmp(quad_list[i].op, quad_list[j].op) == 0 && strcmp(quad_list[i].arg1, quad_list[j].arg1) == 0 && strcmp(quad_list[i].arg2, quad_list[j].arg2) == 0) {
                printf("  Found potential CSE: Quad %d (%s %s %s %s) same as Quad %d (%s %s %s %s)\n", i+1, quad_list[i].op, quad_list[i].arg1, quad_list[i].arg2, quad_list[i].result, j+1, quad_list[j].op, quad_list[j].arg1, quad_list[j].arg2, quad_list[j].result);
                printf("    Eliminating Quad %d. Uses of '%s' should be replaced by '%s'\n", i+1, quad_list[i].result, quad_list[j].result);
                quad_list[i].eliminated = true;
                eliminated_found = true;
                break;
            }
        }
    }
    if (!eliminated_found) printf("  No common subexpressions identified for elimination.\n");
    printf("----------------------------------------\n");
}

void constantFoldingOptimization() {
    printf("\nPerforming Constant Folding...\n");
    bool changed = false;
    char buffer[MAX_STR];
    char orig_arg1[MAX_STR], orig_arg2[MAX_STR], orig_op[20];
    for (int i = 0; i < opt_quad_count; i++) {
        strcpy(orig_arg1, quad_list[i].arg1); strcpy(orig_arg2, quad_list[i].arg2); strcpy(orig_op, quad_list[i].op);
        if ((strcmp(quad_list[i].op, "+") == 0 || strcmp(quad_list[i].op, "-") == 0 || strcmp(quad_list[i].op, "*") == 0 || strcmp(quad_list[i].op, "/") == 0) && isConstant(quad_list[i].arg1) && isConstant(quad_list[i].arg2)) {
            int c1 = atoi(quad_list[i].arg1); int c2 = atoi(quad_list[i].arg2);
            if (strcmp(quad_list[i].op, "/") == 0 && c2 == 0) { continue; }
            int result_val = 0;
            if (strcmp(quad_list[i].op, "+") == 0) result_val = c1 + c2;
            else if (strcmp(quad_list[i].op, "-") == 0) result_val = c1 - c2;
            else if (strcmp(quad_list[i].op, "*") == 0) result_val = c1 * c2;
            else if (strcmp(quad_list[i].op, "/") == 0) result_val = c1 / c2;
            sprintf(buffer, "%d", result_val);
            printf("  Folding Quad %d (%s = %s %s %s) -> (%s = %s)\n", i+1, quad_list[i].result, orig_arg1, orig_op, orig_arg2, quad_list[i].result, buffer);
            strcpy(quad_list[i].op, "="); strcpy(quad_list[i].arg1, buffer); quad_list[i].arg2[0] = '\0';
            changed = true;
        }
    }
    if (!changed) printf("  No constant folding opportunities found.\n");
    printf("----------------------------------------\n");
}

void constantPropagationOptimization() {
    printf("\nPerforming Constant Propagation (and Folding)...\n");
    bool changed_prop = false;
    bool changed_fold = false;
    for (int i = 0; i < opt_quad_count; i++) {
        if (strcmp(quad_list[i].op, "=") == 0 && isConstant(quad_list[i].arg1) && quad_list[i].arg2[0] == '\0') {
            char* var_to_prop = quad_list[i].result;
            char* const_val = quad_list[i].arg1;
            if (strlen(var_to_prop) == 0) continue;
            for (int j = i + 1; j < opt_quad_count; j++) {
                bool propagated_here = false;
                if ((strcmp(quad_list[j].op, "+") == 0 || strcmp(quad_list[j].op, "-") == 0 || strcmp(quad_list[j].op, "*") == 0 || strcmp(quad_list[j].op, "/") == 0) && strcmp(quad_list[j].arg1, var_to_prop) == 0) {
                    strcpy(quad_list[j].arg1, const_val); propagated_here = true;
                }
                if ((strcmp(quad_list[j].op, "+") == 0 || strcmp(quad_list[j].op, "-") == 0 || strcmp(quad_list[j].op, "*") == 0 || strcmp(quad_list[j].op, "/") == 0) && strcmp(quad_list[j].arg2, var_to_prop) == 0) {
                    strcpy(quad_list[j].arg2, const_val); propagated_here = true;
                }
                if (propagated_here) {
                    printf("  Propagated '%s = %s' from Quad %d into Quad %d\n", var_to_prop, const_val, i+1, j+1);
                    changed_prop = true;
                }
            }
        }
    }
    if (!changed_prop) printf("  No constant propagation opportunities found.\n");
    printf("  Running follow-up Constant Folding...\n");
    char buffer[MAX_STR]; char orig_arg1[MAX_STR], orig_arg2[MAX_STR], orig_op[20];
    for (int i = 0; i < opt_quad_count; i++) {
        strcpy(orig_arg1, quad_list[i].arg1); strcpy(orig_arg2, quad_list[i].arg2); strcpy(orig_op, quad_list[i].op);
        if ((strcmp(quad_list[i].op, "+") == 0 || strcmp(quad_list[i].op, "-") == 0 || strcmp(quad_list[i].op, "*") == 0 || strcmp(quad_list[i].op, "/") == 0) && isConstant(quad_list[i].arg1) && isConstant(quad_list[i].arg2)) {
            int c1 = atoi(quad_list[i].arg1); int c2 = atoi(quad_list[i].arg2);
            if (strcmp(quad_list[i].op, "/") == 0 && c2 == 0) { continue; }
            int result_val = 0;
            if (strcmp(quad_list[i].op, "+") == 0) result_val = c1 + c2;
            else if (strcmp(quad_list[i].op, "-") == 0) result_val = c1 - c2;
            else if (strcmp(quad_list[i].op, "*") == 0) result_val = c1 * c2;
            else if (strcmp(quad_list[i].op, "/") == 0) result_val = c1 / c2;
            sprintf(buffer, "%d", result_val);
            printf("    Folding Quad %d (%s = %s %s %s) -> (%s = %s)\n", i+1, quad_list[i].result, orig_arg1, orig_op, orig_arg2, quad_list[i].result, buffer);
            strcpy(quad_list[i].op, "="); strcpy(quad_list[i].arg1, buffer); quad_list[i].arg2[0] = '\0';
            changed_fold = true;
        }
    }
    if (!changed_fold) printf("    No further folding opportunities found.\n");
    printf("----------------------------------------\n");
}

void deadCodeElimination() {
    printf("\nPerforming Dead Code Elimination...\n");
    bool changed = false;
    bool used[MAX_QUADS] = {false};
    for (int i = 0; i < opt_quad_count; i++) {
        if (quad_list[i].eliminated) continue;
        if (strlen(quad_list[i].arg1) > 0) {
            for (int j = 0; j < opt_quad_count; j++) {
                if (strcmp(quad_list[j].result, quad_list[i].arg1) == 0) used[j] = true;
            }
        }
        if (strlen(quad_list[i].arg2) > 0) {
            for (int j = 0; j < opt_quad_count; j++) {
                if (strcmp(quad_list[j].result, quad_list[i].arg2) == 0) used[j] = true;
            }
        }
    }
    for (int i = 0; i < opt_quad_count; i++) {
        if (quad_list[i].eliminated) continue;
        if (strlen(quad_list[i].result) > 0 && !used[i]) {
            quad_list[i].eliminated = true;
            changed = true;
            printf("  Eliminated dead code at Quad %d (%s %s %s %s)\n", i+1, quad_list[i].op, quad_list[i].arg1, quad_list[i].arg2, quad_list[i].result);
        }
    }
    if (!changed) printf("  No dead code found.\n");
    printf("----------------------------------------\n");
}

void copyPropagation() {
    printf("\nPerforming Copy Propagation...\n");
    bool changed = false;
    for (int i = 0; i < opt_quad_count; i++) {
        if (quad_list[i].eliminated) continue;
        if (strcmp(quad_list[i].op, "=") == 0 && strlen(quad_list[i].arg1) > 0 && strlen(quad_list[i].arg2) == 0) {
            char* src = quad_list[i].arg1;
            char* dest = quad_list[i].result;
            for (int j = i + 1; j < opt_quad_count; j++) {
                if (quad_list[j].eliminated) continue;
                if (strcmp(quad_list[j].arg1, dest) == 0) {
                    strcpy(quad_list[j].arg1, src);
                    changed = true;
                    printf("  Propagated copy from Quad %d to Quad %d (arg1)\n", i+1, j+1);
                }
                if (strcmp(quad_list[j].arg2, dest) == 0) {
                    strcpy(quad_list[j].arg2, src);
                    changed = true;
                    printf("  Propagated copy from Quad %d to Quad %d (arg2)\n", i+1, j+1);
                }
            }
        }
    }
    if (!changed) printf("  No copy propagation opportunities found.\n");
    printf("----------------------------------------\n");
}

// --- Regex Parsing ---
// Forward declarations
RegexNode* parse_regex(const char **s);
RegexNode* parse_term(const char **s);
RegexNode* parse_factor(const char **s);

// Utility: create a new node
RegexNode* new_node(NodeType type, char value, RegexNode* left, RegexNode* right) {
    RegexNode* n = (RegexNode*)malloc(sizeof(RegexNode));
    n->type = type; n->value = value; n->left = left; n->right = right;
    return n;
}

// Parse factor: CHAR or (regex) or factor*
RegexNode* parse_factor(const char **s) {
    if (**s == '(') {
        (*s)++;
        RegexNode* n = parse_regex(s);
        if (**s == ')') (*s)++;
        // Handle star
        if (**s == '*') { (*s)++; n = new_node(STAR, 0, n, NULL); }
        return n;
    } else if ((**s >= 'a' && **s <= 'z') || (**s >= 'A' && **s <= 'Z')) {
        RegexNode* n = new_node(CHAR, **s, NULL, NULL);
        (*s)++;
        // Handle star
        if (**s == '*') { (*s)++; n = new_node(STAR, 0, n, NULL); }
        return n;
    }
    return NULL;
}

// Parse term: factor (factor ...)
RegexNode* parse_term(const char **s) {
    RegexNode* left = parse_factor(s);
    while (**s && **s != ')' && **s != '|') {
        RegexNode* right = parse_factor(s);
        left = new_node(CONCAT, 0, left, right);
    }
    return left;
}

// Parse regex: term ('|' term)*
RegexNode* parse_regex(const char **s) {
    RegexNode* left = parse_term(s);
    while (**s == '|' || **s == '+' || **s == '-') {
        (*s)++;
        RegexNode* right = parse_term(s);
        left = new_node(UNION, 0, left, right);
    }
    return left;
}

// --- TAC Generation ---
// Returns the name of the result temp variable
char* gen_TAC(RegexNode* node) {
    static char buf[MAX_STR];
    if (!node) return NULL;
    if (node->type == CHAR) {
        snprintf(buf, MAX_STR, "'%c'", node->value);
        return buf;
    }
    char left[MAX_STR], right[MAX_STR];
    char *l = NULL, *r = NULL;
    if (node->left) l = gen_TAC(node->left);
    if (node->right) r = gen_TAC(node->right);
    char t[MAX_STR];
    snprintf(t, MAX_STR, "t%d", temp_var++);
    if (node->type == CONCAT) {
        snprintf(tac[tac_count++], MAX_STR, "%s = CONCAT %s %s", t, l, r);
    } else if (node->type == UNION) {
        snprintf(tac[tac_count++], MAX_STR, "%s = UNION %s %s", t, l, r);
    } else if (node->type == STAR) {
        snprintf(tac[tac_count++], MAX_STR, "%s = STAR %s", t, l);
    }
    strcpy(buf, t);
    return buf;
}

// --- TAC to Quadruple ---
void tac_to_quads() {
    quad_count = 0;
    for (int i = 0; i < tac_count; i++) {
        char op[MAX_STR], arg1[MAX_STR], arg2[MAX_STR], result[MAX_STR];
        int n = sscanf(tac[i], "%s = %s %s %s", result, op, arg1, arg2);
        if (n == 4) {
            strcpy(quads[quad_count].op, op);
            strcpy(quads[quad_count].arg1, arg1);
            strcpy(quads[quad_count].arg2, arg2);
            strcpy(quads[quad_count].result, result);
        } else if (n == 3) {
            strcpy(quads[quad_count].op, op);
            strcpy(quads[quad_count].arg1, arg1);
            quads[quad_count].arg2[0] = '\0';
            strcpy(quads[quad_count].result, result);
        }
        quad_count++;
    }
}

// --- Print Functions ---
void print_TAC() {
    printf("\n--- TAC ---\n");
    for (int i = 0; i < tac_count; i++) printf("%s\n", tac[i]);
}
void print_quads() {
    printf("\n--- Quadruples ---\n");
    printf("%-10s | %-10s | %-10s | %-10s\n", "Op", "Arg1", "Arg2", "Result");
    for (int i = 0; i < quad_count; i++) {
        printf("%-10s | %-10s | %-10s | %-10s\n", quads[i].op, quads[i].arg1, quads[i].arg2, quads[i].result);
    }
}

// --- Main ---
int main() {
    int n;
    printf("Enter number of regular expressions: ");
    scanf("%d", &n);
    getchar(); // consume newline
    quad_count = 0; // combined quadruple count
    combined_quad_count = 0;
    for (int i = 0; i < n; i++) {
        char regex[128];
        printf("Enter regular expression %d (a-z, +, -, |, *, parentheses; +, -, | all mean alternation): ", i+1);
        scanf("%127s", regex);
        const char* p = regex;
        RegexNode* root = parse_regex(&p);
        if (*p != '\0') { printf("Parse error at: %s\n", p); continue; }
        tac_count = 0; temp_var = 0;
        gen_TAC(root);
        tac_to_quads();
        for (int k = 0; k < quad_count; k++) {
            combined_quads[combined_quad_count].op[0] = '\0';
            strcpy(combined_quads[combined_quad_count].op, quads[k].op);
            strcpy(combined_quads[combined_quad_count].arg1, quads[k].arg1);
            strcpy(combined_quads[combined_quad_count].arg2, quads[k].arg2);
            strcpy(combined_quads[combined_quad_count].result, quads[k].result);
            combined_quad_count++;
        }
        quad_count = 0;
    }
    opt_quad_count = combined_quad_count;
    for (int k = 0; k < opt_quad_count; k++) {
        strcpy(quad_list[k].op, combined_quads[k].op);
        strcpy(quad_list[k].arg1, combined_quads[k].arg1);
        strcpy(quad_list[k].arg2, combined_quads[k].arg2);
        strcpy(quad_list[k].result, combined_quads[k].result);
        quad_list[k].eliminated = false;
    }
    // Print all quadruples before optimization
    printf("\n--- Combined Quadruples Before Optimization ---\n");
    printf("Nr | %-10s | %-10s | %-10s | %-10s\n", "Op", "Arg1", "Arg2", "Result");
    printf("---|------------|------------|------------|------------\n");
    for (int i = 0; i < opt_quad_count; i++) {
        printf("%03d| %-10s | %-10s | %-10s | %-10s\n", i+1, quad_list[i].op, quad_list[i].arg1, quad_list[i].arg2, quad_list[i].result);
    }
    int option = 0;
    while (option < 1 || option > 5) {
        printf("\nSelect optimization technique for all expressions:\n");
        printf("  1. Common Subexpression Elimination (CSE)\n");
        printf("  2. Constant Folding\n");
        printf("  3. Constant Propagation (includes Folding)\n");
        printf("  4. Dead Code Elimination\n");
        printf("  5. Copy Propagation\n");
        printf("Enter your choice (1-5): ");
        scanf("%d", &option);
        if (option < 1 || option > 5) {
            printf("Invalid choice. Please enter 1, 2, 3, 4, or 5.\n");
            option = 0;
        }
    }
    switch(option) {
        case 1:
            commonSubexpressionElimination();
            break;
        case 2:
            constantFoldingOptimization();
            break;
        case 3:
            constantPropagationOptimization();
            break;
        case 4:
            deadCodeElimination();
            break;
        case 5:
            copyPropagation();
            break;
    }
    printOptQuads("Optimized Quadruples");
    return 0;
} 