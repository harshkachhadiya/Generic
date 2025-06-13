public without sharing class QueueableHelper implements Callable {
    
    public Object call(String identifier, Map<String, Object> arguments) {
        
        switch on identifier {
    
            when 'ClassName.methodName' {
                /* ClassName.methodName(
                    (List<String>) arguments.get('arg1')
                ); */
            }
        }
        
        return null;
    }
}