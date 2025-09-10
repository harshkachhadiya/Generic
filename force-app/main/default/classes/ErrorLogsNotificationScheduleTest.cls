@IsTest
public with sharing class ErrorLogsNotificationScheduleTest {
    
    @IsTest
    static void executeTest() {
        
        Log__c log = new Log__c();
        insert log;
        
        LogEntry__c apexLogEntry = new LogEntry__c();
        apexLogEntry.Log__c = log.Id;
        apexLogEntry.OriginType__c = 'Apex';
        apexLogEntry.LoggingLevel__c = 'ERROR';
        insert apexLogEntry;
        
        LogEntry__c flowLogEntry = new LogEntry__c();
        flowLogEntry.Log__c = log.Id;
        flowLogEntry.OriginType__c = 'Flow';
        flowLogEntry.LoggingLevel__c = 'ERROR';
        insert flowLogEntry;
        
        DateTime yesterdayDateTime = DateTime.now().addDays(-1);
        
        Test.setCreatedDate(apexLogEntry.Id, yesterdayDateTime);
        Test.setCreatedDate(flowLogEntry.Id, yesterdayDateTime);
        
        Test.startTest();
        
        Id jobId = System.schedule('Test ErrorLogsNotificationSchedule', '0 0 1 * * ?', new ErrorLogsNotificationSchedule());
        
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, TimesTriggered
                          FROM CronTrigger 
                          WHERE Id = :jobId];
        
        System.assert(ct != null);
    }
}