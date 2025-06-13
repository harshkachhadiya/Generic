@IsTest
public with sharing class GenericExceptionTest {
    
    @IsTest
    static void genericExceptionTest() {

        Test.startTest();

        try {
            GenericException.genericExceptionTest();

        } catch(Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage())); 
        }
        
        Test.stopTest();
    }
}