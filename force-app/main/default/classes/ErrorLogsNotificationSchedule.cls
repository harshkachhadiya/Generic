public with sharing class ErrorLogsNotificationSchedule implements Schedulable {
    
    public void execute(SchedulableContext context) {
        
        String errorsDetails = buildErrorsDetails();
        
        if (String.isBlank(errorsDetails)) {
            return;
        }
        
        sendNotification(errorsDetails);
    }
    
    private static String buildErrorsDetails() {
        
        List<String> sections = new List<String>();
        
        List<AggregateResult> apexResults = [SELECT ApexClassName__c, COUNT(Id) cnt
                                             FROM LogEntry__c
                                             WHERE CreatedDate = YESTERDAY
                                             AND OriginType__c = 'Apex'
                                             AND LoggingLevel__c = 'ERROR'
                                             GROUP BY ApexClassName__c];
        
        String apexSection = buildErrorTable('Apex Errors', 'Class Name', 'ApexClassName__c', apexResults);
        
        if (String.isNotBlank(apexSection)) {
            sections.add(apexSection);
        }
        
        List<AggregateResult> flowResults = [SELECT OriginLocation__c, COUNT(Id) cnt
                                             FROM LogEntry__c
                                             WHERE CreatedDate = YESTERDAY
                                             AND OriginType__c = 'Flow'
                                             AND LoggingLevel__c = 'ERROR'
                                             GROUP BY OriginLocation__c];
        
        String flowSection = buildErrorTable('Flow Errors', 'Location', 'OriginLocation__c', flowResults);
        
        if (String.isNotBlank(flowSection)) {
            sections.add(flowSection);
        }
        
        return String.join(sections, '</br>');
    }
    
    private static String buildErrorTable(String title, String columnHeader,
                                          String fieldName, List<AggregateResult> results) 
    {
        
        if (results.isEmpty()) {
            return '';
        }
        
        List<String> rows = new List<String>();
        
        for (AggregateResult result : results) {
            
            String cellValue = result.get(fieldName) != null
                ? String.valueOf(result.get(fieldName))
                : '--EMPTY--';
            
            rows.add('<tr><td>' + cellValue + '</td><td>' + result.get('cnt') + '</td></tr>');
        }
        
        return '<h2>' + title + '</h2><table>'
            + '<tr><th width="60%">' + columnHeader + '</th><th width="40%">Number Of Errors</th></tr>'
            + String.join(rows, '')
            + '</table>';
    }
    
    private static void sendNotification(String errorsDetails) {
        
        List<EmailTemplate> templates = [SELECT Id, Subject, HtmlValue
                                         FROM EmailTemplate
                                         WHERE Name = 'Error Logs Notification'
                                         LIMIT 1];
        
        if (templates.isEmpty()) {
            throw new OrgException('Email template "Error Logs Notification" not found.');
        }
        
        EmailTemplate emailTemplate = templates[0];
        
        Id orgWideEmailAddressId = [SELECT Id
                                    FROM OrgWideEmailAddress
                                    WHERE Address = 'no-reply@gmail.com'
                                    LIMIT 1]?.Id;
        
        Organization org = [SELECT Id, IsSandbox
                            FROM Organization
                            LIMIT 1];
        
        String orgName = org.IsSandbox
            ? System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName().toUpperCase()
            : 'PRODUCTION';
        
        String targetDate = Date.today().addDays(-1).format();
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(orgWideEmailAddressId);
        email.setToAddresses(new List<String>(ApexUtils.splitValues(Label.ErrorLogsNotification_Emails)));
        email.setSubject(emailTemplate.Subject
                         .replace('{ORGNAME}', orgName)
                         .replace('{DATE}', targetDate));
        email.setHtmlBody(emailTemplate.HtmlValue
                          .replace('{ORGNAME}', orgName)
                          .replace('{ORGID}', org.Id)
                          .replace('{DATE}', targetDate)
                          .replace('{ERRORSDETAILS}', errorsDetails));
        email.setSaveAsActivity(false);
        
        List<Messaging.SendEmailResult> emailsToSendResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email }, false);
        
        for (Messaging.SendEmailResult ser : emailsToSendResults) {
            if (!ser.isSuccess()) {
                
                Logger.error('Error: ' + ser.getErrors()[0].getMessage());
            }
        }
    }
}