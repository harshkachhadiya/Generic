public without sharing class AsyncJobDispatcher implements Callable {
    
    public Object call(String identifier, Map<String, Object> arguments) {
        
        switch on identifier {
    
            when 'ClassName.methodName' {
                /* ClassName.methodName(
                    (List<String>) arguments.get('arg1')
                ); */
            }
            when else {
                throw new ApplicationException('Unknown identifier: ' + identifier);
            }
        }
        
        return null;
    }
}