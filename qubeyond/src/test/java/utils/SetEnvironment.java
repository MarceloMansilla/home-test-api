package utils;


public class SetEnvironment {

    public SetEnvironment(){}

    public static String set(String key,String value){
        System.setProperty(key,value);
        return value;
    }

    public static String get(String key){
        return System.getProperty(key);
    }
    
}
