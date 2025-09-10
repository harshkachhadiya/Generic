public with sharing class ApplicationException extends Exception {

    public static void applicationExceptionTest() {

        try {
            Id recordId = '';
            
        } catch(Exception ex) {
            throw new ApplicationException(ex.getMessage()); 
        }
    }
}