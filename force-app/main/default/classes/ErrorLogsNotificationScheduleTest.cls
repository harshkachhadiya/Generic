@IsTest
public with sharing class ErrorLogsNotificationScheduleTest {
    
    @IsTest
    static void executeTest() {
        
        Log__c log = new Log__c();
        insert log;
        
        LogEntry__c logEntry = new LogEntry__c();
        logEntry.Log__c = log.Id;
        logEntry.OriginType__c = 'Apex';
        logEntry.LoggingLevel__c = 'ERROR';
        insert logEntry;
        
        Test.startTest();
        
        Id jobId = System.schedule('Test ErrorLogsNotificationSchedule', '0 0 1 * * ?', new ErrorLogsNotificationSchedule());
        
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, TimesTriggered
                          FROM CronTrigger 
                          WHERE Id = :jobId];
        
        System.assert(ct != null);
    }
}