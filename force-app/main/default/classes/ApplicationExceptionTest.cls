@IsTest
public with sharing class ApplicationExceptionTest {
    
    @IsTest
    static void applicationExceptionTest() {

        Test.startTest();

        try {
            ApplicationException.applicationExceptionTest();

        } catch(Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage())); 
        }
        
        Test.stopTest();
    }
}