#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
#include <cstdlib>

using namespace std;

const int MAX_QUADS = 500;
const int MAX_STR = 100;

class Quadruple {
public:
    string op;
    string arg1;
    string arg2;
    string result;
    bool eliminated;
    bool is_leader;

    Quadruple() : eliminated(false), is_leader(false) {}
};

class QuadrupleOptimizer {
private:
    vector<Quadruple> quad_list;

    bool isConstant(const string& s) {
        if(s.empty()) return false;
        size_t start = (s[0] == '+' || s[0] == '-') ? 1 : 0;
        if(start == s.length()) return false;
        return s.find_first_not_of("0123456789", start) == string::npos;
    }

    int evaluateExpression(const string& op, int c1, int c2) {
        if(op == "+") return c1 + c2;
        if(op == "-") return c1 - c2;
        if(op == "*") return c1 * c2;
        if(op == "/") return c2 != 0 ? c1 / c2 : 0;
        return 0;
    }

public:
    bool readQuadsFromFile(const string& filename) {
        ifstream file(filename);
        if (!file.is_open()) {
            cerr << "Error opening Quad input file" << endl;
            return false;
        }
        cout << "Reading Quads from " << filename << "..." << endl;

        string line;
        while (getline(file, line) && quad_list.size() < MAX_QUADS) {
            if(line.empty()) continue;

            istringstream iss(line);
            Quadruple quad;
            iss >> quad.op;
            iss >> quad.arg1;
            iss >> quad.arg2;
            iss >> quad.result;

            if(quad.arg1 == "-") quad.arg1 = "";
            if(quad.arg2 == "-") quad.arg2 = "";
            if(quad.result == "-") quad.result = "";

            quad_list.push_back(quad);
        }

        file.close();
        cout << "Read " << quad_list.size() << " quads." << endl;
        return true;
    }

    void printQuads(const string& title, bool show_eliminated) {
        cout << "\n--- " << title << " ---" << endl;
        cout << "Nr | Op              | Arg1                      | Arg2                      | Result                    | " 
             << (show_eliminated ? "Status" : "") << endl;
        cout << "---|-----------------|---------------------------|---------------------------|---------------------------|--------" << endl;

        if (quad_list.empty()) {
            cout << "(No Quads)" << endl;
            return;
        }

        int displayed_count = 0;
        for (size_t i = 0; i < quad_list.size(); i++) {
            if (!quad_list[i].eliminated || show_eliminated) {
                displayed_count++;
                printf("%03d| %-15s | %-25s | %-25s | %-25s | %s\n", 
                       (int)i + 1,
                       quad_list[i].op.c_str(),
                       quad_list[i].arg1.c_str(),
                       quad_list[i].arg2.c_str(),
                       quad_list[i].result.c_str(),
                       show_eliminated ? (quad_list[i].eliminated ? "(Elim)" : "") : "");
            }
        }

        if (displayed_count == 0 && !show_eliminated) {
            cout << "(No quads remaining after optimization)" << endl;
        }
        cout << string(95, '-') << endl;
    }

    void commonSubexpressionElimination() {
        cout << "\nPerforming Common Subexpression Elimination..." << endl;
        bool eliminated_found = false;

        for (size_t i = 0; i < quad_list.size(); i++) {
            if (quad_list[i].eliminated) continue;
            if (quad_list[i].op == "=") continue;

            for (size_t j = 0; j < i; j++) {
                if (quad_list[j].eliminated) continue;
                if (quad_list[j].op == "=") continue;

                if (quad_list[i].op == quad_list[j].op &&
                    quad_list[i].arg1 == quad_list[j].arg1 &&
                    quad_list[i].arg2 == quad_list[j].arg2)
                {
                    cout << "  Found potential CSE: Quad " << i + 1 
                         << " (" << quad_list[i].op << " " << quad_list[i].arg1 << " " 
                         << quad_list[i].arg2 << " " << quad_list[i].result << ") same as Quad "
                         << j + 1 << " (" << quad_list[j].op << " " << quad_list[j].arg1 << " "
                         << quad_list[j].arg2 << " " << quad_list[j].result << ")" << endl;
                    cout << "    Eliminating Quad " << i + 1 << ". Uses of '" 
                         << quad_list[i].result << "' should be replaced by '" 
                         << quad_list[j].result << "'" << endl;

                    quad_list[i].eliminated = true;
                    eliminated_found = true;
                    break;
                }
            }
        }
        if (!eliminated_found) cout << "  No common subexpressions identified for elimination." << endl;
        cout << string(40, '-') << endl;
    }

    void constantFoldingOptimization() {
        cout << "\nPerforming Constant Folding..." << endl;
        bool changed = false;

        for (size_t i = 0; i < quad_list.size(); i++) {
            if ((quad_list[i].op == "+" || quad_list[i].op == "-" ||
                 quad_list[i].op == "*" || quad_list[i].op == "/") &&
                isConstant(quad_list[i].arg1) && isConstant(quad_list[i].arg2))
            {
                string orig_op = quad_list[i].op;
                string orig_arg1 = quad_list[i].arg1;
                string orig_arg2 = quad_list[i].arg2;

                int c1 = stoi(quad_list[i].arg1);
                int c2 = stoi(quad_list[i].arg2);

                if (quad_list[i].op == "/" && c2 == 0) continue;

                int result_val = evaluateExpression(quad_list[i].op, c1, c2);
                
                cout << "  Folding Quad " << i + 1 << " (" << quad_list[i].result 
                     << " = " << orig_arg1 << " " << orig_op << " " << orig_arg2 
                     << ") -> (" << quad_list[i].result << " = " << result_val << ")" << endl;

                quad_list[i].op = "=";
                quad_list[i].arg1 = to_string(result_val);
                quad_list[i].arg2 = "";
                changed = true;
            }
        }
        if (!changed) cout << "  No constant folding opportunities found." << endl;
        cout << string(40, '-') << endl;
    }

    void constantPropagationOptimization() {
        cout << "\nPerforming Constant Propagation (and Folding)..." << endl;
        bool changed_prop = false;
        bool changed_fold = false;

        // Constant Propagation
        for (size_t i = 0; i < quad_list.size(); i++) {
            if (quad_list[i].op == "=" && isConstant(quad_list[i].arg1) && quad_list[i].arg2.empty()) {
                string var_to_prop = quad_list[i].result;
                string const_val = quad_list[i].arg1;

                for (size_t j = i + 1; j < quad_list.size(); j++) {
                    bool propagated_here = false;
                    if ((quad_list[j].op == "+" || quad_list[j].op == "-" ||
                         quad_list[j].op == "*" || quad_list[j].op == "/")) {
                        
                        if (quad_list[j].arg1 == var_to_prop) {
                            quad_list[j].arg1 = const_val;
                            propagated_here = true;
                        }
                        if (quad_list[j].arg2 == var_to_prop) {
                            quad_list[j].arg2 = const_val;
                            propagated_here = true;
                        }
                    }
                    if (propagated_here) {
                        cout << "  Propagated '" << var_to_prop << " = " << const_val 
                             << "' from Quad " << i + 1 << " into Quad " << j + 1 << endl;
                        changed_prop = true;
                    }
                }
            }
        }
        if (!changed_prop) cout << "  No constant propagation opportunities found." << endl;

        // Follow-up Constant Folding
        cout << "  Running follow-up Constant Folding..." << endl;
        for (size_t i = 0; i < quad_list.size(); i++) {
            if ((quad_list[i].op == "+" || quad_list[i].op == "-" ||
                 quad_list[i].op == "*" || quad_list[i].op == "/") &&
                isConstant(quad_list[i].arg1) && isConstant(quad_list[i].arg2))
            {
                string orig_op = quad_list[i].op;
                string orig_arg1 = quad_list[i].arg1;
                string orig_arg2 = quad_list[i].arg2;

                int c1 = stoi(quad_list[i].arg1);
                int c2 = stoi(quad_list[i].arg2);

                if (quad_list[i].op == "/" && c2 == 0) continue;

                int result_val = evaluateExpression(quad_list[i].op, c1, c2);
                
                cout << "    Folding Quad " << i + 1 << " (" << quad_list[i].result 
                     << " = " << orig_arg1 << " " << orig_op << " " << orig_arg2 
                     << ") -> (" << quad_list[i].result << " = " << result_val << ")" << endl;

                quad_list[i].op = "=";
                quad_list[i].arg1 = to_string(result_val);
                quad_list[i].arg2 = "";
                changed_fold = true;
            }
        }
        if (!changed_fold) cout << "    No further folding opportunities found." << endl;
        cout << string(40, '-') << endl;
    }

    void deadCodeElimination() {
        cout << "\nPerforming Dead Code Elimination..." << endl;
        bool changed = false;
        vector<bool> used(quad_list.size(), false);
        // Mark variables that are used as arguments in non-eliminated quads
        for (size_t i = 0; i < quad_list.size(); i++) {
            if (quad_list[i].eliminated) continue;
            if (!quad_list[i].arg1.empty()) {
                for (size_t j = 0; j < quad_list.size(); j++) {
                    if (quad_list[j].result == quad_list[i].arg1) used[j] = true;
                }
            }
            if (!quad_list[i].arg2.empty()) {
                for (size_t j = 0; j < quad_list.size(); j++) {
                    if (quad_list[j].result == quad_list[i].arg2) used[j] = true;
                }
            }
        }
        // Eliminate assignments whose result is never used
        for (size_t i = 0; i < quad_list.size(); i++) {
            if (quad_list[i].eliminated) continue;
            if (!quad_list[i].result.empty() && !used[i]) {
                quad_list[i].eliminated = true;
                changed = true;
                cout << "  Eliminated dead code at Quad " << i+1 << " (" << quad_list[i].op << " " << quad_list[i].arg1 << " " << quad_list[i].arg2 << " " << quad_list[i].result << ")" << endl;
            }
        }
        if (!changed) cout << "  No dead code found." << endl;
        cout << string(40, '-') << endl;
    }

    void copyPropagation() {
        cout << "\nPerforming Copy Propagation..." << endl;
        bool changed = false;
        for (size_t i = 0; i < quad_list.size(); i++) {
            if (quad_list[i].eliminated) continue;
            if (quad_list[i].op == "=" && !quad_list[i].arg1.empty() && quad_list[i].arg2.empty()) {
                string src = quad_list[i].arg1;
                string dest = quad_list[i].result;
                for (size_t j = i + 1; j < quad_list.size(); j++) {
                    if (quad_list[j].eliminated) continue;
                    if (quad_list[j].arg1 == dest) {
                        quad_list[j].arg1 = src;
                        changed = true;
                        cout << "  Propagated copy from Quad " << i+1 << " to Quad " << j+1 << " (arg1)" << endl;
                    }
                    if (quad_list[j].arg2 == dest) {
                        quad_list[j].arg2 = src;
                        changed = true;
                        cout << "  Propagated copy from Quad " << i+1 << " to Quad " << j+1 << " (arg2)" << endl;
                    }
                }
            }
        }
        if (!changed) cout << "  No copy propagation opportunities found." << endl;
        cout << string(40, '-') << endl;
    }
};

int main(int argc, char* argv[]) {
    string quad_filename = "music_score1quads";
    if (argc > 1) {
        quad_filename = argv[1];
    }

    cout << "--- Quadruple Optimizer (C++ Version) ---" << endl;

    QuadrupleOptimizer optimizer;
    if (!optimizer.readQuadsFromFile(quad_filename)) {
        cerr << "Failed to read quadruples from " << quad_filename << ". Exiting." << endl;
        return 1;
    }

    optimizer.printQuads("Initial Quads Loaded", false);

    int option = 0;
    while (option < 1 || option > 5) {
        cout << "\nSelect optimization technique:" << endl;
        cout << "  1. Common Subexpression Elimination (CSE)" << endl;
        cout << "  2. Constant Folding" << endl;
        cout << "  3. Constant Propagation (includes Folding)" << endl;
        cout << "  4. Dead Code Elimination" << endl;
        cout << "  5. Copy Propagation" << endl;
        cout << "Enter your choice (1-5): ";
        cin >> option;

        if (cin.fail() || option < 1 || option > 5) {
            cin.clear();
            cin.ignore(10000, '\n');
            cout << "Invalid choice. Please enter 1, 2, 3, 4, or 5." << endl;
            option = 0;
        }
    }

    switch(option) {
        case 1:
            optimizer.commonSubexpressionElimination();
            break;
        case 2:
            optimizer.constantFoldingOptimization();
            break;
        case 3:
            optimizer.constantPropagationOptimization();
            break;
        case 4:
            optimizer.deadCodeElimination();
            break;
        case 5:
            optimizer.copyPropagation();
            break;
    }

    optimizer.printQuads("Optimized Quadruples", false);
    return 0;
} 