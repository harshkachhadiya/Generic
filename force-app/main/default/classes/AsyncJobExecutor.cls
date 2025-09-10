public without sharing class AsyncJobExecutor implements Queueable, Database.AllowsCallouts {
    
    public String identifier;
    public Map<String, Object> arguments = new Map<String, Object>();
    
    public AsyncJobExecutor(String identifier, Map<String, Object> arguments) {
        this.identifier = identifier;
        
        if(arguments != null) {
            this.arguments = arguments;
        }
    }
    
    public void execute(QueueableContext context) {
        Callable helperClass = (Callable) Type.forName('AsyncJobDispatcher').newInstance();
        helperClass.call(identifier, arguments);
    }
}

/*
 * How To Use This Class:
=========================================================================
Map<String, Object> arguments = new Map<String, Object>();
arguments.put('arg1', arg1Value);
System.enqueueJob(new AsyncJobExecutor('ClassName.methodName', arguments));
=========================================================================
*/