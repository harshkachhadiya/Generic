public without sharing class QueueableUtility implements Queueable, Database.AllowsCallouts {
    
    public String identifier;
    public Map<String, Object> arguments = new Map<String, Object>();
    
    public QueueableUtility(String identifier, Map<String, Object> arguments) {
        this.identifier = identifier;
        
        if(arguments != null) {
            this.arguments = arguments;
        }
    }
    
    public void execute(QueueableContext context) {
        Callable helperClass = (Callable) Type.forName('QueueableHelper').newInstance();
        helperClass.call(identifier, arguments);
    }
}

/*
 * How To Use This Class:
=========================================================================
Map<String, Object> arguments = new Map<String, Object>();
arguments.put('arg1', arg1Value);
System.enqueueJob(new QueueableUtility('ClassName.methodName', arguments));
=========================================================================
*/