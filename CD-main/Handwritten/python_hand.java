import java.util.*;
import java.util.regex.*;
import java.nio.file.*;
public class python_hand {
    public static void main(String[] args) {
        if (args.length >0){
            try {
                String code = Files.readString(Path.of(args[0]));
                String regex = "(?<KEY>\\bdef\\b|\\bimport\\b)" + "|(?<ID>[a-zA-z_][a-zA-z0-9]*)" + "|(?<NUM>[0-9]+)" + "|(?<OP>[=+\\-*/])" + "|(?<DIL>[(){};])"                     
                + "|(?<WS>\\s+)" + "(?<ERR>\\b\\d+[a-zA-Z_]+[a-zA-Z0-9_]*\\b)";
                Pattern pattern = Pattern.compile(regex);
                Matcher matcher = pattern.matcher(code);
                
                while (matcher.find()) {
                    
                    if (matcher.group("KEY")!=null) System.out.println("KEY\t"+matcher.group());
                    else if(matcher.group("ID") != null) System.out.println("ID\t"+matcher.group());
                    else if(matcher.group("NUM") != null) System.out.println("NUM\t"+matcher.group());
                    else if(matcher.group("OP") != null) System.out.println("OP\t"+matcher.group());
                    else if(matcher.group("DIL") != null) System.out.println("DIL\t"+matcher.group());
                    else if(matcher.group("ERR") != null) System.out.println("ERROR\t"+matcher.group());
                    
                }
            } catch (Exception e) {
                // TODO: handle exception
            }
        }
    }
}
