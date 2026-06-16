@IsTest
private with sharing class ApexUtilsTest {
    
    @IsTest
    static void splitValuesTest() {  
        
        Test.startTest();
        
        Set<String> result = ApexUtils.splitValues('a;b');
        
        Test.stopTest();
        
        System.assertEquals(2, result.size());
    }
}