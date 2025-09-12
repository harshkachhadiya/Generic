@IsTest
public with sharing class SObjectUtilTest {
    
    @IsTest
    static void isSandboxTest() {
        
        Test.startTest();
        
        Boolean isSandbox = SObjectUtil.isSandbox();
        
        System.assertEquals(isSandbox, System.URL.getOrgDomainUrl().toExternalForm().contains('sandbox'));
        
        Test.stopTest();
    }
    
    @IsTest
    static void getSObjectApiNameByIdTest() {
        
        Test.startTest();
        
        String objectApiName = SObjectUtil.getSObjectApiNameById(UserInfo.getUserId());
        
        System.assertEquals('User', objectApiName);
        
        Test.stopTest();
    }
    
    @IsTest
    static void getRecordTypeIdByNameTest() {
        
        Test.startTest();
        
        try {
            Id result = SObjectUtil.getRecordTypeIdByName('Account', 'Test');
            
        } catch(Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        
        Test.stopTest();        
    }
    
    @IsTest
    static void getPickListValuesTest() {
        
        Test.startTest();
        
        List<SObjectUtil.PicklistOption> result = SObjectUtil.getPicklistValues('Account', 'Type');
        
        System.assert(!result.isEmpty());
        
        Test.stopTest();
    }
    
    @IsTest
    static void getSObjectDetailsByIdTest() {
        
        Test.startTest();
        
        SObject result = SObjectUtil.getSObjectDetailsById(UserInfo.getUserId());
        
        Test.stopTest();
        
        System.assert(String.isNotBlank(result.Id));
    }
    
    @IsTest
    static void getSObjectDetailsByIdsTest() {
        
        Test.startTest();
        
        List<SObject> result = SObjectUtil.getSObjectDetailsByIds(new List<Id>{ UserInfo.getUserId() });
        
        Test.stopTest();
        
        System.assert(!result.isEmpty());
    }
}