public with sharing class ApexUtils {
    
    private static final String DEFAULT_DELIMITER = ';';
    
    public static Set<String> splitValues(String values) {
        
        return splitValues(values, DEFAULT_DELIMITER);
    }
    
    public static Set<String> splitValues(String values, String delimiter) {
        
        Set<String> result = new Set<String>();
        
        if (String.isNotBlank(values)
            && String.isNotBlank(delimiter)) 
        {
            for (String value : values.split(Pattern.quote(delimiter))) {
                if (String.isNotBlank(value)) {
                    
                    result.add(value.trim());
                }
            }
        }
        
        return result;
    }
}