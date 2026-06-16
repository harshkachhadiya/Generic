public without sharing class SObjectSchemaUtils {
    
    public class PicklistOption {
        
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public Boolean isSelected {get; set;}
        
        public PicklistOption(String label, String value, Boolean isSelected) {
            this.label = label;
            this.value = value;
            this.isSelected = isSelected;
        }
    }
    
    private static Map<String, Schema.SObjectType> globalDescribe {
        
        get {
            if (globalDescribe == null) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            
            return globalDescribe;
        }
        
        private set;
    }
    
    @AuraEnabled
    public static String getSObjectApiNameById(Id recordId) {
        
        if (recordId == null) {
            throw new OrgException('Record Id must not be empty.');
        }
        
        return recordId.getSObjectType()
            .getDescribe()
            .getName();
    }
    
    public static Id getRecordTypeIdByName(String sObjectApiName, String recordTypeName) {
        
        if (String.isBlank(sObjectApiName) 
            || String.isBlank(recordTypeName)) 
        {
            throw new OrgException('Object Name and Record Type Name must not be empty.');
        }
        
        Schema.SObjectType sObjectType = globalDescribe.get(sObjectApiName);
        
        if (sObjectType == null) {
            throw new OrgException('Object not found: ' + sObjectApiName);
        }
        
        Schema.RecordTypeInfo recordTypeInfo = sObjectType.getDescribe()
            .getRecordTypeInfosByName()
            .get(recordTypeName);
        
        return recordTypeInfo != null 
            ? recordTypeInfo.getRecordTypeId() 
            : null;
    }
    
    public static Id getRecordTypeIdByDeveloperName(String sObjectApiName, String recordTypeDeveloperName) {
        
        if (String.isBlank(sObjectApiName) 
            || String.isBlank(recordTypeDeveloperName)) 
        {
            throw new OrgException('Object Name and Record Type DeveloperName must not be empty.');
        }
        
        Schema.SObjectType sObjectType = globalDescribe.get(sObjectApiName);
        
        if (sObjectType == null) {
            throw new OrgException('Object not found: ' + sObjectApiName);
        }
        
        Schema.RecordTypeInfo recordTypeInfo = sObjectType.getDescribe()
            .getRecordTypeInfosByDeveloperName()
            .get(recordTypeDeveloperName);
        
        return recordTypeInfo != null 
            ? recordTypeInfo.getRecordTypeId() 
            : null;
    }
    
    public static String getRecordTypeNameById(String sObjectApiName, Id recordTypeId) {
        
        if (String.isBlank(sObjectApiName) 
            || String.isBlank(recordTypeId)) 
        {
            throw new OrgException('Object Name and Record Type Id must not be empty.');
        }
        
        Schema.SObjectType sObjectType = globalDescribe.get(sObjectApiName);
        
        if (sObjectType == null) {
            throw new OrgException('Object not found: ' + sObjectApiName);
        }
        
        Schema.RecordTypeInfo recordTypeInfo = sObjectType.getDescribe()
            .getRecordTypeInfosById()
            .get(recordTypeId);
        
        return recordTypeInfo != null
            ? recordTypeInfo.getDeveloperName()
            : null;
    }
    
    @AuraEnabled
    public static List<PicklistOption> getPicklistValues(String sObjectApiName, String fieldApiName) {
        
        if (String.isBlank(sObjectApiName) 
            || String.isBlank(fieldApiName)) 
        {
            throw new OrgException('Object Name and Field Name must not be empty.');
        }
        
        Schema.SObjectType sObjectType = globalDescribe.get(sObjectApiName);
        
        if (sObjectType == null) {
            throw new OrgException('Object not found: ' + sObjectApiName);
        }
        
        Schema.SObjectField sObjectField = sObjectType.getDescribe()
            .fields.getMap()
            .get(fieldApiName);
        
        if (sObjectField == null) {
            throw new OrgException('Field not found: ' + fieldApiName);
        }
        
        Map<String, String> picklistValues = new Map<String, String>();
        
        for (Schema.PicklistEntry entry : sObjectField.getDescribe()
             .getPicklistValues()) 
        {
            if (entry.isActive()) {
                picklistValues.put(entry.getValue(), entry.getLabel());
            }
        }
        
        return preparePicklistValues(picklistValues, null);
    }
    
    private static List<PicklistOption> preparePicklistValues(Map<String, String> picklistValues, Set<String> selectedValues) {
        
        if (picklistValues == null 
            || picklistValues.isEmpty()) 
        {
            return new List<PicklistOption>();
        }
        
        List<PicklistOption> result = new List<PicklistOption>();
        
        for (String value : picklistValues.keySet()) {
            
            String label = picklistValues.get(value);
            Boolean isSelected = selectedValues != null 
                && selectedValues.contains(value);
            
            result.add(new PicklistOption(label, value, isSelected));
        }
        
        return result;
    }
    
    private static Set<String> getSObjectAllFields(String sObjectApiName) {
        
        if (String.isBlank(sObjectApiName)) {
            throw new OrgException('Object Name must not be empty.');
        }
        
        Schema.SObjectType objectType = globalDescribe.get(sObjectApiName);
        
        if (objectType == null) {
            throw new OrgException('Object not found: ' + sObjectApiName);
        }
        
        return new Set<String>(objectType.getDescribe()
                               .fields.getMap()
                               .keySet());
    }
    
    public static String prepareSObjectQuery(String sObjectApiName, List<String> additionalFields) {
        
        Set<String> fields = getSObjectAllFields(sObjectApiName);
        
        if (additionalFields != null 
            && !additionalFields.isEmpty()) 
        {
            fields.addAll(additionalFields);
        }
        
        return 'SELECT ' + String.join(new List<String>(fields), ', ') 
            + ' FROM ' + sObjectApiName;
    }
    
    public static String prepareSObjectQuery(String sObjectApiName) {
        
        return prepareSObjectQuery(sObjectApiName, null);
    }
    
    @AuraEnabled
    public static SObject getSObjectDetailsById(Id recordId, List<String> additionalFields) {
        
        if (recordId == null) {
            throw new OrgException('Record Id must not be empty.');
        }
        
        String sObjectApiName = getSObjectApiNameById(recordId);
        String query = prepareSObjectQuery(sObjectApiName, additionalFields) + ' WHERE Id = :recordId';
        
        return Database.query(query);
    }
    
    public static SObject getSObjectDetailsById(Id recordId) {
        
        return getSObjectDetailsById(recordId, null);
    }
    
    public static List<SObject> getSObjectDetailsByIds(List<Id> recordIds, List<String> additionalFields) {
        
        if (recordIds == null 
            || recordIds.isEmpty()) 
        {
            return new List<SObject>();
        }
        
        String sObjectApiName = getSObjectApiNameById(recordIds[0]);
        String query = prepareSObjectQuery(sObjectApiName, additionalFields) + ' WHERE Id IN :recordIds';
        
        return Database.query(query);
    }
    
    public static List<SObject> getSObjectDetailsByIds(List<Id> recordIds) {
        
        return getSObjectDetailsByIds(recordIds, null);
    }
    
    @AuraEnabled
    public static void updateSObject(SObject record) {
        
        if (record == null) {
            throw new OrgException('Record must not be empty.');
        }
        
        try {
            update record;
            
        } catch (DmlException ex) {
            throw new OrgException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void upsertSObject(SObject record) {
        
        if (record == null) {
            throw new OrgException('Record must not be empty.');
        }
        
        try {
            upsert record;
            
        } catch (DmlException ex) {
            throw new OrgException(ex.getMessage());
        }
    }
}