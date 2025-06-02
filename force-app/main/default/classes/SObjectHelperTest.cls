@IsTest
public with sharing class SObjectHelperTest {
    
    @IsTest
    static void getSObjectApiNameByIdTest() {
        
        Test.startTest();
        
        String objectApiName = SObjectHelper.getSObjectApiNameById(UserInfo.getUserId());
        
        System.assertEquals('User', objectApiName);
        
        Test.stopTest();
    }
    
    @IsTest
    static void getRecordTypeIdByNameTest() {
        
        Test.startTest();
        
        try {
            Id result = SObjectHelper.getRecordTypeIdByName('Account', 'Test');
            
        } catch(Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        
        Test.stopTest();        
    }
    
    @IsTest
    static void getPickListValuesTest() {
        
        Test.startTest();
        
        List<SObjectHelper.PicklistValueWapper> result = SObjectHelper.getPicklistValues('Account', 'Type');
        
        System.assert(!result.isEmpty());
        
        Test.stopTest();
    }
    
    @IsTest
    static void getSobjectDetailsByIdTest() {
        
        Test.startTest();
        
        SObject result = SObjectHelper.getSobjectDetailsById(UserInfo.getUserId());
        
        Test.stopTest();
        
        System.assert(String.isNotBlank(result.Id));
    }
    
    @IsTest
    static void getSobjectDetailsByIdsTest() {
        
        Test.startTest();
        
        List<SObject> result = SObjectHelper.getSobjectDetailsByIds(new Set<Id>{UserInfo.getUserId()});
        
        Test.stopTest();
        
        System.assert(!result.isEmpty());
    }
}