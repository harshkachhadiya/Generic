@IsTest
public with sharing class AsyncJobDispatcherTest {
    
    @IsTest
    static void callTest() {

        Test.startTest();

        Map<String, Object> arguments = new Map<String, Object>();
        arguments.put('arg1', 'arg1Value');
        System.enqueueJob(new AsyncJobExecutor('ClassName.methodName', arguments));
        
        Test.stopTest();
    }
}