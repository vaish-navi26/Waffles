import java.util.*;
import java.util.regex.*;
import java.nio.file.*;
public class java_hand {
    public static void main(String[] args) {
        if(args.length > 0){
            try {
                String code = Files.readString(Path.of(args[0]));
                String regex =
                    "(?<NEWLINE>\\n)" +
                    "|(?<WS>[ \\t\\r]+)" +  // whitespace excluding newline
                    "|(?<KEY>\\b(int|float|if|public|static|void|String)\\b)" +
                    "|(?<ID>[a-zA-Z_][a-zA-Z0-9_]*)" +
                    "|(?<NUM>[0-9]+)" +
                    "|(?<OP>==|=|[-+*/])" +  // order matters
                    "|(?<DIL>[(){};])" +
                    "|(?<UNKNOWN>.)";  // any unmatched single character
                    
                Pattern pattern = Pattern.compile(regex);
                Matcher matcher = pattern.matcher(code);
                while(matcher.find()){
                    if(matcher.group("KEY") != null) System.out.println("KEY\t"+matcher.group());
                    else if(matcher.group("ID") != null) System.out.println("ID\t"+matcher.group());
                    else if(matcher.group("NUM") != null) System.out.println("NUM\t"+matcher.group());
                    else if(matcher.group("OP") != null) System.out.println("OP\t"+matcher.group());
                    else if(matcher.group("DIL") != null) System.out.println("DIL\t"+matcher.group());
                    else if (matcher.group("UNKNOWN") != null) System.out.println("UNKNOWN\t" + matcher.group());
                }
            } catch (Exception e) {
                System.err.println("Error reading file: " + e.getMessage());
            }
        }
    }
}
