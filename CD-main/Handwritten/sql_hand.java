import java.util.*;
import java.util.regex.*;
import java.nio.file.*;
public class sql_hand {
    public static void main(String[] args) {
        if (args.length >0){
            try {
                String code = Files.readString(Path.of(args[0]));
                String regex = "(?<KEY>\\bSELECT\\b|\\bFROM\\b|\\bWHERE\\b|\\bINSERT\\b|\\bINTO\\b|\\bVALUES\\b|\\bUPDATE\\b|\\bSET\\b|\\bDELETE\\b|\\bJOIN\\b|\\bON\\b|\\bAS\\b|\\bAND\\b|\\bOR\\b)"
                     + "|(?<ID>[a-zA-z_][a-zA-z0-9]*)" + "|(?<NUM>[0-9]+)" + "|(?<OP>[=+\\-*/])" + "|(?<DIL>[(){};])";
                Pattern pattern = Pattern.compile(regex);
                Matcher matcher = pattern.matcher(code);
                while (matcher.find()) {
                    if (matcher.group("KEY")!=null) System.out.println("KEY\t"+matcher.group());
                    else if(matcher.group("ID") != null) System.out.println("ID\t"+matcher.group());
                    else if(matcher.group("NUM") != null) System.out.println("NUM\t"+matcher.group());
                    else if(matcher.group("OP") != null) System.out.println("OP\t"+matcher.group());
                    else if(matcher.group("DIL") != null) System.out.println("DIL\t"+matcher.group());
                }
            } catch (Exception e) {
                // TODO: handle exception
            }
        }
    }
}
