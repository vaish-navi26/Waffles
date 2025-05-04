import java.util.*;

public class cse {
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
        List<Quadruple> inputList = new ArrayList<>();

        System.out.println("Enter quadruples (op arg1 arg2 result), type 'end' to finish:");
        while (true) {
            String line = sc.nextLine().trim();
            if (line.equalsIgnoreCase("end")) break;
            String[] parts = line.split(" ");
            if (parts.length != 4) {
                System.out.println("Invalid, expected: op arg1 arg2 result");
                continue;
            }
            inputList.add(new Quadruple(parts[0], parts[1], parts[2], parts[3]));
        }

        Map<String, String> exprMap = new HashMap<>();
        Map<String, String> varMap  = new HashMap<>();
        List<Quadruple> optimized   = new ArrayList<>();

        for (Quadruple q : inputList) {
            // replace args by their original if previously mapped
            String a1 = varMap.getOrDefault(q.arg1, q.arg1);
            String a2 = varMap.getOrDefault(q.arg2, q.arg2);
            String res = q.result;
            String key = q.op + " " + a1 + " " + a2;

            if (exprMap.containsKey(key)) {
                String orig = exprMap.get(key);
                varMap.put(res, orig);
                // emit assignment to reuse orig
                //optimized.add(new Quadruple("=", orig, "_", res));
                System.out.println("CSE: " + res + " matches " + orig);
            } else {
                exprMap.put(key, res);
                optimized.add(new Quadruple(q.op, q.arg1, q.arg2, res));
            }
        }

        System.out.println("\nOptimized Quadruples:");
        for (Quadruple q : optimized) {
            System.out.println(q);
        }
    }
}
