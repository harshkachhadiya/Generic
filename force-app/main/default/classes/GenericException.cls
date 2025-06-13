public with sharing class GenericException extends Exception {

    public static void genericExceptionTest() {

        try {
            Id recordId = '';
            
        } catch(Exception ex) {
            throw new GenericException(ex.getMessage()); 
        }
    }
}