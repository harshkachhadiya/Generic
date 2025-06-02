public with sharing virtual class TriggerHandler {
    
    Boolean bypass = false;
    
    public TriggerHandler() {
        
    }
    
    public TriggerHandler(Boolean bypass) {
        this.bypass = bypass;
    }
    
    public void run() {
        if(bypass || Trigger.isBefore && Trigger.isInsert) {
            this.beforeInsert();
        } 
        
        if(bypass || (Trigger.isBefore && Trigger.isUpdate)) {
            this.beforeUpdate();
        } 
        
        if(bypass || (Trigger.isBefore && Trigger.isDelete)) {
            this.beforeDelete();
        }
        
        if(bypass || (Trigger.isAfter && Trigger.isInsert)) {
            this.afterInsert();
        }
        
        if(bypass || (Trigger.isAfter && Trigger.isUpdate)) {
            this.afterUpdate();
        }
        
        if(bypass || (Trigger.isAfter && Trigger.isDelete)) {
            this.afterDelete();
        } 
        
        if(bypass || (Trigger.isAfter && Trigger.isUndelete)) {
            this.afterUndelete();
        }
    }
    
    @TestVisible 
    protected virtual void beforeInsert() {
        
    }
    
    @TestVisible 
    protected virtual void beforeUpdate() {
        
    }
    
    @TestVisible 
    protected virtual void beforeDelete() {
        
    }
    
    @TestVisible 
    protected virtual void afterInsert() {
        
    }
    
    @TestVisible 
    protected virtual void afterUpdate() {
        
    }
    
    @TestVisible 
    protected virtual void afterDelete() {
        
    }
    
    @TestVisible 
    protected virtual void afterUndelete() {
        
    }
}