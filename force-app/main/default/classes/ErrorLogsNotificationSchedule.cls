public with sharing class ErrorLogsNotificationSchedule implements Schedulable {
    
    public void execute(SchedulableContext context) {
        
        EmailTemplate emailTemp = [SELECT Id, Subject, HtmlValue 
                                   FROM EmailTemplate
                                   WHERE Name = 'Error Logs Notification'
                                   LIMIT 1];
        
        String errorsDetails = '';
        
        List<AggregateResult> aResults = new List<AggregateResult>();
        
        if(Test.isRunningTest()) {
            aResults = [SELECT ApexClassName__c, COUNT(Id) cnt
                        FROM LogEntry__c
                        WHERE OriginType__c = 'Apex'
                        AND LoggingLevel__c = 'ERROR'
                        GROUP BY ApexClassName__c];
            
        } else {
            aResults = [SELECT ApexClassName__c, COUNT(Id) cnt
                        FROM LogEntry__c
                        WHERE OriginType__c = 'Apex'
                        AND LoggingLevel__c = 'ERROR'
                        AND CreatedDate = YESTERDAY
                        GROUP BY ApexClassName__c];
        }
        
        if(!aResults.isEmpty()) {
            
            errorsDetails += '<h2>Apex Errors</h2><table>'
                + '<tr><th width="60%">Class Name</th><th width="40%">Numbe Of Errors</th></tr>';
            
            for(AggregateResult aResult : aResults) {
                errorsDetails += '<tr><td>' 
                    + (aResult.get('ApexClassName__c') != null ? aResult.get('ApexClassName__c') : '--EMPTY--') 
                    + '</td><td>' 
                    + aResult.get('cnt') 
                    + '</td></tr>';
            }
            
            errorsDetails += '</table>';
        }
        
        if(String.isNotBlank(errorsDetails)) {
            errorsDetails += '</br>';
        }
        
        aResults = new List<AggregateResult>();
        
        if(Test.isRunningTest()) {
            aResults = [SELECT OriginLocation__c, COUNT(Id) cnt
                        FROM LogEntry__c
                        WHERE OriginType__c = 'Flow'
                        AND LoggingLevel__c = 'ERROR'
                        GROUP BY OriginLocation__c];
            
        } else {
            aResults = [SELECT OriginLocation__c, COUNT(Id) cnt
                        FROM LogEntry__c
                        WHERE OriginType__c = 'Flow'
                        AND LoggingLevel__c = 'ERROR'
                        AND CreatedDate = YESTERDAY
                        GROUP BY OriginLocation__c];
        }
        
        if(!aResults.isEmpty()) {
            
            errorsDetails += '<h2>Flow Errors</h2><table>'
                + '<tr><th width="60%">Location</th><th width="40%">Numbe Of Errors</th></tr>';
            
            for(AggregateResult aResult : aResults) {
                errorsDetails += '<tr><td>' 
                    + (aResult.get('OriginLocation__c') != null ? aResult.get('OriginLocation__c') : '--EMPTY--') 
                    + '</td><td>' 
                    + aResult.get('cnt') 
                    + '</td></tr>';
            }
            
            errorsDetails += '</table>';
        }
        
        if(String.isBlank(errorsDetails)) {
            return;
        }
        
        Organization org = [SELECT Id, IsSandbox
                            FROM Organization
                            LIMIT 1];
        
        String orgName = org.IsSandbox 
            ? System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName().toUpperCase() 
            : 'PRODUCTION';
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(emailTemp.Subject
                         .replace('DATE', Date.today().addDays(-1).format())
                         .replace('ORGNAME', orgName));
        email.setHtmlBody(emailTemp.HtmlValue
                          .replace('ORGNAME', orgName)
                          .replace('ORGID', org.Id)
                          .replace('ERRORSDETAILS', errorsDetails));
        email.setToAddresses(Label.ErrorLogsNotification_Emails.split(','));
        email.setSaveAsActivity(false);
        
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email}, false);
    }
}