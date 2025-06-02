@IsTest
public with sharing class TriggerHandlerTest {
    
    @IsTest
    static void runTest() {
        
        Test.startTest();
        
        TriggerHandler handler = new TriggerHandler(true);
        
        handler.run();
        
        Test.stopTest();
    }
}