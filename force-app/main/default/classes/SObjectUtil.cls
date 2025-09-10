public without sharing class SObjectUtil {

    @AuraEnabled
    public static Boolean isSandbox() {
        return System.URL.getOrgDomainUrl().toExternalForm().contains('sandbox');
    }
    
    @AuraEnabled
    public static String getSObjectApiNameById(Id recordId) {
        return recordId.getSObjectType().getDescribe().getName();
    }
    
    public static Id getRecordTypeIdByName(String sObjectApiName, String recordTypeName) {
        
        if(String.isBlank(sObjectApiName) || String.isBlank(recordTypeName)) {
            throw new IllegalArgumentException('Object Name and Record Type Name must not be empty.');
        }
        
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectApiName);
        
        if(sObjectType == null) {
            throw new IllegalArgumentException('Object not found: ' + sObjectApiName);
        }
        
        for(Schema.RecordTypeInfo recordTypeInfo : sObjectType.getDescribe().getRecordTypeInfos()) {
            if(recordTypeInfo.getName() == recordTypeName) {
                return recordTypeInfo.getRecordTypeId();
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public static List<PicklistValueWrapper> getPicklistValues(String sObjectApiName, String fieldApiName) {
        
        Map<String, String> picklistValues = new Map<String, String>();
        
        for(Schema.PicklistEntry picklistEntry : Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPicklistValues()) {
            picklistValues.put(picklistEntry.getValue(), picklistEntry.getLabel());
        }
        
        return preparePicklistValues(picklistValues, null);
    }
    
    public static List<PicklistValueWrapper> preparePicklistValues(Map<String, String> picklistValues, Set<String> selectedValues) {
        
        List<PicklistValueWrapper> result = new List<PicklistValueWrapper>();
        
        for(String value : picklistValues.keySet()) {
            result.add(new PicklistValueWrapper(picklistValues.get(value), value, selectedValues != null && selectedValues.contains(value)));
        }
        
        return result;
    }
    
    public static Set<String> getSObjectAllFields(String sObjectApiName) {
        
        Set<String> fields = new Set<String>();
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(sObjectApiName);
        
        if(objectType != null) {
            
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            
            for (String field : fieldMap.keySet()) {
                fields.add(field);
            }
        }
        
        return fields;
    }
    
    public static String prepareSObjectQueryString(String sObjectApiName, String extraFields) {
        
        String queryString = 'SELECT ' + String.join(new List<String>(getSObjectAllFields(sObjectApiName)), ', ');
        
        if(String.isNotBlank(extraFields)) {
            queryString += ', ' + extraFields; 
        }
        
        queryString += ' FROM ' + sObjectApiName;
        
        return queryString;
    }
    
    public static String prepareSObjectQueryString(String sObjectApiName) {
        
        return prepareSObjectQueryString(sObjectApiName, null);
    }
    
    @AuraEnabled
    public static SObject getSObjectDetailsById(Id recordId, String extraFields) {
        
        return Database.query(String.escapeSingleQuotes(prepareSObjectQueryString(getSObjectApiNameById(recordId), extraFields) + ' WHERE Id = :recordId'));
    }
    
    public static SObject getSObjectDetailsById(Id recordId) {
        
        return getSObjectDetailsById(recordId, null);
    }
    
    public static List<SObject> getSObjectDetailsByIds(Set<Id> recordIds, String extraFields) {
        
        return Database.query(String.escapeSingleQuotes(prepareSObjectQueryString(getSObjectApiNameById(new List<Id>(recordIds)[0]), extraFields) + ' WHERE Id IN :recordIds'));
    }
    
    public static List<SObject> getSObjectDetailsByIds(Set<Id> recordIds) {
        
        return getSObjectDetailsByIds(recordIds, null);
    }
    
    @AuraEnabled
    public static void updateSObject(SObject record) {
        update record;
    }

    @AuraEnabled
    public static void upsertSObject(SObject record) {
        upsert record;
    }
    
    public class PicklistValueWrapper {
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public Boolean isSelected {get; set;}
        
        public PicklistValueWrapper(String label, String value, Boolean isSelected) {
            this.label = label;
            this.value = value;
            this.isSelected = isSelected;
        }
    }
}