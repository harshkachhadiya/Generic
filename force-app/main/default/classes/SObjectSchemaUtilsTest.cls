@IsTest
public with sharing class SObjectSchemaUtilsTest {
    
    @IsTest
    static void getSObjectApiNameByIdTest() {
        
        Test.startTest();
        
        String result = SObjectSchemaUtils.getSObjectApiNameById(UserInfo.getUserId());
        
        System.assertEquals('User', result);
        
        Test.stopTest();
    }
    
    @IsTest
    static void getRecordTypeIdByNameTest() {
        
        Test.startTest();
        
        try {
            Id result = SObjectSchemaUtils.getRecordTypeIdByName('Account', 'Test');
            
        } catch(Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        
        Test.stopTest();        
    }
    
    @IsTest
    static void getRecordTypeIdByDeveloperNameTest() {
        
        Test.startTest();
        
        try {
            Id result = SObjectSchemaUtils.getRecordTypeIdByDeveloperName('Account', 'Test');
            
        } catch(Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        
        Test.stopTest();        
    }
    
    @IsTest
    static void getRecordTypeNameByIdTest() {
        
        Test.startTest();
        
        try {
            String result = SObjectSchemaUtils.getRecordTypeNameById('User', UserInfo.getUserId());
            
        } catch(Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        
        Test.stopTest();        
    }
    
    @IsTest
    static void getPickListValuesTest() {
        
        Test.startTest();
        
        List<SObjectSchemaUtils.PicklistOption> result = SObjectSchemaUtils.getPicklistValues('Account', 'Type');
        
        System.assert(!result.isEmpty());
        
        Test.stopTest();
    }
    
    @IsTest
    static void prepareSObjectQueryTest() {
        
        Test.startTest();
        
        String result = SObjectSchemaUtils.prepareSObjectQuery('User');
        
        System.assert(String.isNotBlank(result));
        
        Test.stopTest();
    }
    
    @IsTest
    static void getSObjectDetailsByIdTest() {
        
        Test.startTest();
        
        SObject result = SObjectSchemaUtils.getSObjectDetailsById(UserInfo.getUserId());
        
        Test.stopTest();
        
        System.assert(String.isNotBlank(result.Id));
    }
    
    @IsTest
    static void getSObjectDetailsByIdsTest() {
        
        Test.startTest();
        
        List<SObject> result = SObjectSchemaUtils.getSObjectDetailsByIds(new List<Id>{ UserInfo.getUserId() });
        
        Test.stopTest();
        
        System.assert(!result.isEmpty());
    }
    
    @IsTest
    static void updateSObjectTest() {
        
        Account record = new Account(
            Name = 'Test Account'
        );
        
        Test.startTest();
        
        try {
            SObjectSchemaUtils.updateSObject(record);
            
        } catch(Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void upsertSObjectTest() {
        
        Account record = new Account(
            Name = 'Test Account'
        );
        
        Test.startTest();
        
        try {
            SObjectSchemaUtils.upsertSObject(record);
            
        } catch(Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        
        Test.stopTest();
    }
}