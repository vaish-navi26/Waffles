import java.io.*;
import java.util.*;

class Quadruple {
    String op;
    String arg1;
    String arg2;
    String result;
    boolean eliminated;
    boolean isLeader;

    public Quadruple() {
        eliminated = false;
        isLeader = false;
    }
}

public class Optimizer {
    private static final int MAX_QUADS = 500;
    private ArrayList<Quadruple> quadList;

    public Optimizer() {
        quadList = new ArrayList<>();
    }

    private boolean isConstant(String s) {
        if (s == null || s.isEmpty()) return false;
        int start = (s.charAt(0) == '+' || s.charAt(0) == '-') ? 1 : 0;
        if (start == s.length()) return false;
        for (int i = start; i < s.length(); i++) {
            if (!Character.isDigit(s.charAt(i))) return false;
        }
        return true;
    }

    private int evaluateExpression(String op, int c1, int c2) {
        switch (op) {
            case "+": return c1 + c2;
            case "-": return c1 - c2;
            case "*": return c1 * c2;
            case "/": return c2 != 0 ? c1 / c2 : 0;
            default: return 0;
        }
    }

    public boolean readQuadsFromFile(String filename) {
        try (BufferedReader reader = new BufferedReader(new FileReader(filename))) {
            System.out.println("Reading Quads from " + filename + "...");
            String line;
            while ((line = reader.readLine()) != null && quadList.size() < MAX_QUADS) {
                if (line.trim().isEmpty()) continue;

                String[] parts = line.trim().split("\\s+");
                if (parts.length >= 1) {
                    Quadruple quad = new Quadruple();
                    quad.op = parts[0];
                    quad.arg1 = parts.length > 1 && !parts[1].equals("-") ? parts[1] : "";
                    quad.arg2 = parts.length > 2 && !parts[2].equals("-") ? parts[2] : "";
                    quad.result = parts.length > 3 && !parts[3].equals("-") ? parts[3] : "";
                    quadList.add(quad);
                }
            }
            System.out.println("Read " + quadList.size() + " quads.");
            return true;
        } catch (IOException e) {
            System.err.println("Error reading file: " + e.getMessage());
            return false;
        }
    }

    public void printQuads(String title, boolean showEliminated) {
        System.out.println("\n--- " + title + " ---");
        System.out.printf("%-3s| %-15s | %-25s | %-25s | %-25s | %s%n",
                "Nr", "Op", "Arg1", "Arg2", "Result", showEliminated ? "Status" : "");
        System.out.println("-".repeat(95));

        if (quadList.isEmpty()) {
            System.out.println("(No Quads)");
            return;
        }

        int displayedCount = 0;
        for (int i = 0; i < quadList.size(); i++) {
            Quadruple quad = quadList.get(i);
            if (!quad.eliminated || showEliminated) {
                displayedCount++;
                System.out.printf("%03d| %-15s | %-25s | %-25s | %-25s | %s%n",
                        i + 1, quad.op, quad.arg1, quad.arg2, quad.result,
                        showEliminated ? (quad.eliminated ? "(Elim)" : "") : "");
            }
        }

        if (displayedCount == 0 && !showEliminated) {
            System.out.println("(No quads remaining after optimization)");
        }
        System.out.println("-".repeat(95));
    }

    public void commonSubexpressionElimination() {
        System.out.println("\nPerforming Common Subexpression Elimination...");
        boolean eliminatedFound = false;

        for (int i = 0; i < quadList.size(); i++) {
            if (quadList.get(i).eliminated) continue;
            if (quadList.get(i).op.equals("=")) continue;

            for (int j = 0; j < i; j++) {
                if (quadList.get(j).eliminated) continue;
                if (quadList.get(j).op.equals("=")) continue;

                Quadruple qi = quadList.get(i);
                Quadruple qj = quadList.get(j);

                if (qi.op.equals(qj.op) &&
                    qi.arg1.equals(qj.arg1) &&
                    qi.arg2.equals(qj.arg2))
                {
                    System.out.printf("  Found potential CSE: Quad %d (%s %s %s %s) same as Quad %d (%s %s %s %s)%n",
                            i + 1, qi.op, qi.arg1, qi.arg2, qi.result,
                            j + 1, qj.op, qj.arg1, qj.arg2, qj.result);
                    System.out.printf("    Eliminating Quad %d. Uses of '%s' should be replaced by '%s'%n",
                            i + 1, qi.result, qj.result);

                    qi.eliminated = true;
                    eliminatedFound = true;
                    break;
                }
            }
        }
        if (!eliminatedFound) System.out.println("  No common subexpressions identified for elimination.");
        System.out.println("-".repeat(40));
    }

    public void constantFoldingOptimization() {
        System.out.println("\nPerforming Constant Folding...");
        boolean changed = false;

        for (int i = 0; i < quadList.size(); i++) {
            Quadruple quad = quadList.get(i);
            if ((quad.op.equals("+") || quad.op.equals("-") ||
                 quad.op.equals("*") || quad.op.equals("/")) &&
                isConstant(quad.arg1) && isConstant(quad.arg2))
            {
                String origOp = quad.op;
                String origArg1 = quad.arg1;
                String origArg2 = quad.arg2;

                int c1 = Integer.parseInt(quad.arg1);
                int c2 = Integer.parseInt(quad.arg2);

                if (quad.op.equals("/") && c2 == 0) continue;

                int resultVal = evaluateExpression(quad.op, c1, c2);
                
                System.out.printf("  Folding Quad %d (%s = %s %s %s) -> (%s = %d)%n",
                        i + 1, quad.result, origArg1, origOp, origArg2, quad.result, resultVal);

                quad.op = "=";
                quad.arg1 = String.valueOf(resultVal);
                quad.arg2 = "";
                changed = true;
            }
        }
        if (!changed) System.out.println("  No constant folding opportunities found.");
        System.out.println("-".repeat(40));
    }

    public void constantPropagationOptimization() {
        System.out.println("\nPerforming Constant Propagation (and Folding)...");
        boolean changedProp = false;
        boolean changedFold = false;

        // Constant Propagation
        for (int i = 0; i < quadList.size(); i++) {
            Quadruple quad = quadList.get(i);
            if (quad.op.equals("=") && isConstant(quad.arg1) && quad.arg2.isEmpty()) {
                String varToProp = quad.result;
                String constVal = quad.arg1;

                for (int j = i + 1; j < quadList.size(); j++) {
                    Quadruple qj = quadList.get(j);
                    boolean propagatedHere = false;

                    if (qj.op.equals("+") || qj.op.equals("-") ||
                        qj.op.equals("*") || qj.op.equals("/"))
                    {
                        if (qj.arg1.equals(varToProp)) {
                            qj.arg1 = constVal;
                            propagatedHere = true;
                        }
                        if (qj.arg2.equals(varToProp)) {
                            qj.arg2 = constVal;
                            propagatedHere = true;
                        }
                    }

                    if (propagatedHere) {
                        System.out.printf("  Propagated '%s = %s' from Quad %d into Quad %d%n",
                                varToProp, constVal, i + 1, j + 1);
                        changedProp = true;
                    }
                }
            }
        }
        if (!changedProp) System.out.println("  No constant propagation opportunities found.");

        // Follow-up Constant Folding
        System.out.println("  Running follow-up Constant Folding...");
        for (int i = 0; i < quadList.size(); i++) {
            Quadruple quad = quadList.get(i);
            if ((quad.op.equals("+") || quad.op.equals("-") ||
                 quad.op.equals("*") || quad.op.equals("/")) &&
                isConstant(quad.arg1) && isConstant(quad.arg2))
            {
                String origOp = quad.op;
                String origArg1 = quad.arg1;
                String origArg2 = quad.arg2;

                int c1 = Integer.parseInt(quad.arg1);
                int c2 = Integer.parseInt(quad.arg2);

                if (quad.op.equals("/") && c2 == 0) continue;

                int resultVal = evaluateExpression(quad.op, c1, c2);
                
                System.out.printf("    Folding Quad %d (%s = %s %s %s) -> (%s = %d)%n",
                        i + 1, quad.result, origArg1, origOp, origArg2, quad.result, resultVal);

                quad.op = "=";
                quad.arg1 = String.valueOf(resultVal);
                quad.arg2 = "";
                changedFold = true;
            }
        }
        if (!changedFold) System.out.println("    No further folding opportunities found.");
        System.out.println("-".repeat(40));
    }

    public void deadCodeElimination() {
        System.out.println("\nPerforming Dead Code Elimination...");
        boolean changed = false;
        boolean[] used = new boolean[quadList.size()];
        // Mark variables that are used as arguments in non-eliminated quads
        for (int i = 0; i < quadList.size(); i++) {
            Quadruple q = quadList.get(i);
            if (q.eliminated) continue;
            if (!q.arg1.isEmpty()) {
                for (int j = 0; j < quadList.size(); j++) {
                    if (quadList.get(j).result.equals(q.arg1)) used[j] = true;
                }
            }
            if (!q.arg2.isEmpty()) {
                for (int j = 0; j < quadList.size(); j++) {
                    if (quadList.get(j).result.equals(q.arg2)) used[j] = true;
                }
            }
        }
        // Eliminate assignments whose result is never used
        for (int i = 0; i < quadList.size(); i++) {
            Quadruple q = quadList.get(i);
            if (q.eliminated) continue;
            if (!q.result.isEmpty() && !used[i]) {
                q.eliminated = true;
                changed = true;
                System.out.printf("  Eliminated dead code at Quad %d (%s %s %s %s)\n", i+1, q.op, q.arg1, q.arg2, q.result);
            }
        }
        if (!changed) System.out.println("  No dead code found.");
        System.out.println("-".repeat(40));
    }

    public void copyPropagation() {
        System.out.println("\nPerforming Copy Propagation...");
        boolean changed = false;
        for (int i = 0; i < quadList.size(); i++) {
            Quadruple qi = quadList.get(i);
            if (qi.eliminated) continue;
            if (qi.op.equals("=") && !qi.arg1.isEmpty() && qi.arg2.isEmpty()) {
                String src = qi.arg1;
                String dest = qi.result;
                for (int j = i + 1; j < quadList.size(); j++) {
                    Quadruple qj = quadList.get(j);
                    if (qj.eliminated) continue;
                    if (qj.arg1.equals(dest)) {
                        qj.arg1 = src;
                        changed = true;
                        System.out.printf("  Propagated copy from Quad %d to Quad %d (arg1)\n", i+1, j+1);
                    }
                    if (qj.arg2.equals(dest)) {
                        qj.arg2 = src;
                        changed = true;
                        System.out.printf("  Propagated copy from Quad %d to Quad %d (arg2)\n", i+1, j+1);
                    }
                }
            }
        }
        if (!changed) System.out.println("  No copy propagation opportunities found.");
        System.out.println("-".repeat(40));
    }

    public static void main(String[] args) {
        String quadFilename = "music_score1quads";
        if (args.length > 0) {
            quadFilename = args[0];
        }

        System.out.println("--- Quadruple Optimizer (Java Version) ---");

        Optimizer optimizer = new Optimizer();
        if (!optimizer.readQuadsFromFile(quadFilename)) {
            System.err.println("Failed to read quadruples from " + quadFilename + ". Exiting.");
            System.exit(1);
        }

        optimizer.printQuads("Initial Quads Loaded", false);

        Scanner scanner = new Scanner(System.in);
        int option = 0;
        while (option < 1 || option > 5) {
            System.out.println("\nSelect optimization technique:");
            System.out.println("  1. Common Subexpression Elimination (CSE)");
            System.out.println("  2. Constant Folding");
            System.out.println("  3. Constant Propagation (includes Folding)");
            System.out.println("  4. Dead Code Elimination");
            System.out.println("  5. Copy Propagation");
            System.out.print("Enter your choice (1-5): ");
            try {
                option = scanner.nextInt();
                if (option < 1 || option > 5) {
                    System.out.println("Invalid choice. Please enter 1, 2, 3, 4, or 5.");
                    option = 0;
                }
            } catch (InputMismatchException e) {
                System.out.println("Invalid input. Please enter a number between 1 and 5.");
                scanner.nextLine();
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
    }
} 