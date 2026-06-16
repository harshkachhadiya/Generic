@IsTest
private with sharing class OrgExceptionTest {
    
    @IsTest
    static void testExceptionMessage() {
        
        Test.startTest();
        
        String errorNessage = 'Something went wrong.';
        OrgException ex = new OrgException(errorNessage);
        
        System.assertEquals(errorNessage, ex.getMessage());
        
        ex.validate();
        
        Test.stopTest();
    }
}