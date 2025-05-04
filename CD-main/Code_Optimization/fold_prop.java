import java.util.*;

public class fold_prop {

    static class Quadruple {
        String op, arg1, arg2, result;
        Quadruple(String op, String arg1, String arg2, String result) {
            this.op = op; this.arg1 = arg1;
            this.arg2 = arg2; this.result = result;
        }
        public String toString() {
            return op + " " + arg1 + " " + arg2 + " " + result;
        }
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        List<Quadruple> in = new ArrayList<>();

        System.out.println("Enter quadruples (op arg1 arg2 result), type 'end' to finish:");
        while (true) {
            String line = sc.nextLine().trim();
            if (line.equalsIgnoreCase("end")) break;
            String[] p = line.split("\\s+");
            if (p.length != 4) {
                System.out.println("Invalid, expected: op arg1 arg2 result");
                continue;
            }
            in.add(new Quadruple(p[0], p[1], p[2], p[3]));
        }

        // Map var -> constant value
        Map<String,String> constMap = new HashMap<>();
        List<Quadruple> out = new ArrayList<>();

        for (Quadruple q : in) {
            // Propagate any known constants
            String a1 = constMap.getOrDefault(q.arg1, q.arg1);
            String a2 = constMap.getOrDefault(q.arg2, q.arg2);

            if (q.op.equals("=") && isInteger(a1)) {
                // simple assignment of constant: t = c
                constMap.put(q.result, a1);
                out.add(new Quadruple("=", a1, "_", q.result));
                System.out.println("Propagate: " + q.result + " = " + a1);
            }
            else if (isInteger(a1) && isInteger(a2) && !q.op.equals("=")) {
                // both operands constant => fold into a single assignment
                String val = evaluate(q.op, a1, a2);
                constMap.put(q.result, val);
                out.add(new Quadruple("=", val, "_", q.result));
                System.out.println("Fold: " + a1 + " " + q.op + " " + a2 + " => " + val);
            }
            else {
                // no folding: emit with propagated operands
                out.add(new Quadruple(q.op, a1, a2, q.result));
            }
        }

        System.out.println("\nOptimized Quadruples:");
        for (Quadruple q : out) {
            System.out.println(q);
        }
    }

    static boolean isInteger(String s) {
        try { Integer.parseInt(s); return true; }
        catch (Exception e) { return false; }
    }

    static String evaluate(String op, String x, String y) {
        int a = Integer.parseInt(x), b = Integer.parseInt(y), r = 0;
        switch (op) {
          case "+": r = a + b; break;
          case "-": r = a - b; break;
          case "*": r = a * b; break;
          case "/": r = b!=0 ? a/b : 0; break;
          default: throw new RuntimeException("Bad op: "+op);
        }
        return String.valueOf(r);
    }
}
