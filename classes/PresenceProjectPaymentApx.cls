/* 
* PresenceProjectPaymentApx: 
* UsedBy: PresenceProjectPayment.cmp
* Purpose: Retrieves data for lightning UI
* Project/Deliverable: Coding Exercise for Presence
* Authors:
*   Jay Miracle, JayMiracle@EfficientAutomationLLC.com
* CreateDate: 4/11/2019
* Version: 1.00, 4/11/2019
* Updates: 
*    - 
* Technical Design Notes:
*    - 
* Developer To-Do:
*    - 
* References: 
*    - 
* Data Model:
*    -
*/
public with sharing class PresenceProjectPaymentApx {
    // Properties
    public static string localControllerName        { get {return 'PresenceProjectPaymentApx'; }} // To insert into debug posts, differentiates between this class and any shared classes
    
    // Classes
    public with sharing class ProjectPayment {
        // Properties
        @AuraEnabled public boolean			success 				{get;set;}
        @AuraEnabled public List<string>	messages                {get;set;}
        @AuraEnabled public boolean			messagesExist           {get;set;}
        List<Database.SaveResult> 	        saveResultLst		    {get;set;}
        List<Database.DeleteResult> 	    deleteResultLst		    {get;set;}
        //Set<id>                             contactIds              {get;set;}
        Payment__c                          payment                 {get;set;}
        List<Payment__c>                    payments                {get;set;}
        Map<Id,PersonPayments>              personsPaymentsMap      {get;set;}
        @AuraEnabled List<PersonPayments>   personsPayments         {get;set;}
        @AuraEnabled string                 todaysDateTime          {get;set;}
        @AuraEnabled integer                numPayers               {get;set;}
        @AuraEnabled integer                numPayments             {get;set;}
        boolean                             isExceptionTest         {get;set;}  
        
        // Constructors
        public ProjectPayment() {  
            isExceptionTest = false;
        }
        public ProjectPayment(boolean exceptionTest) {  
            if(exceptionTest == true) isExceptionTest = exceptionTest;
        }
        
        // Methods        
        public string initialize(){
            try { 
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling      
                success 					= false;
                messages 					= new List<string>();
                messagesExist 				= false;
                saveResultLst               = new List<Database.SaveResult>();
                //contactIds                  = new Set<id>();   
                personsPaymentsMap          = new Map<Id,PersonPayments>();
                todaysDateTime              = datetime.now().format();
                numPayers                   = -1;
                numPayments                 = -1;
                return 'Success';
            }
            catch (Exception e) 
            {
                postExceptionMsgs(e, localControllerName, messages);
                messagesExist = true;
                return 'Failure';
            }
        }
        public string getPayments(){
            try {  
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling     
                payments = [SELECT Id,  Amount__c, Date__c, DateString__c,
                                        Contact__r.Id, Contact__r.Name, Contact__r.Last_Payment_Date__c,Contact__r.Total_Payments_Amount__c,
                                        Project__r.Id, Project__r.Name, Project__r.Project_Name__c, Project__r.Total_Payments_Amount__c 
                                        FROM Payment__c ORDER BY Contact__r.Name ASC, Date__c DESC];
                if(payments.isEmpty()) {
                    messages.add('No Payments record found');
                    messagesExist = true;                    
                    return 'Failure';
                }
                return 'Success';
            }
            catch (Exception e) 
            {
                postExceptionMsgs(e, localControllerName, messages);                 
                messagesExist = true;
                return 'Failure';
            }
        }
        public string getPayment(string paymentId){
            try { 
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling      
                payments = [SELECT Id,  Amount__c, Date__c, DateString__c,
                                        Contact__r.Id, Contact__r.Name, Contact__r.Last_Payment_Date__c,Contact__r.Total_Payments_Amount__c,
                                        Project__r.Id, Project__r.Name, Project__r.Project_Name__c, Project__r.Total_Payments_Amount__c 
                                        FROM Payment__c WHERE Id =: paymentId];
                if(payments.isEmpty()) {
                    messages.add('No Payment record found');
                    messagesExist = true;                    
                    return 'Failure';
                }
                payment = payments[0];
                return 'Success';
            }
            catch (Exception e) 
            {
                postExceptionMsgs(e, localControllerName, messages);                 
                messagesExist = true;
                return 'Failure';
            }
        }
        public string editPayment(string newPaymentDate, decimal newPaymentAmt){
            try {   
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling    
                payment.Amount__c   = newPaymentAmt;
                payment.Date__c     = date.parse(newPaymentDate);
                return 'Success';
            }
            catch (Exception e) 
            {
                postExceptionMsgs(e, localControllerName, messages);                 
                messagesExist = true;
                return 'Failure';
            }
        }
        public string createPayment(string personId, string projectId, string paymentDate, string paymentAmt){
            try {  
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling   
                payment = new Payment__c();
                payment.Contact__c  = personId;
                payment.Project__c  = projectId;
                payment.Amount__c   = decimal.valueOf(paymentAmt);
                payment.Date__c     = date.parse(paymentDate);
                return 'Success';
            }
            catch (Exception e) 
            {
                postExceptionMsgs(e, localControllerName, messages);                 
                messagesExist = true;
                return 'Failure';
            }
        }
        public string insertPayment(list<sobject> sobjLst){
            try {
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling
                saveResultLst = Database.insert(sobjLst, false);
                return 'Success';
            }
            catch (Exception e) 
            {
                postExceptionMsgs(e, localControllerName, messages);                 
                messagesExist = true;
                return 'Failure';
            }
        }
        public string updatePayment(list<sobject> sobjLst){
            try {
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling
                saveResultLst = Database.update(sobjLst, false);
                return 'Success';
            }
            catch (Exception e) 
            {
                postExceptionMsgs(e, localControllerName, messages);                 
                messagesExist = true;
                return 'Failure';
            }
        }        
        public string deletePayment(List<string> recordIds){
            try {
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling
                deleteResultLst = Database.delete(recordIds);
                return 'Success';
            }
            catch (Exception e) 
            {
                postExceptionMsgs(e, localControllerName, messages);                 
                messagesExist = true;
                return 'Failure';
            }
        }
        public string validateSave() {
            try {
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling
                Boolean dmlErrorEncountered = false;
                for (Database.SaveResult sr : saveResultLst) {
                    if (sr.isSuccess()) { continue; }           
                    for(Database.Error err : sr.getErrors()) {
                        if(dmlErrorEncountered == false) {
                            messages.add('Error(s) occurred during the record insert/update:');
                        }                        
                        messages.add('Fields causing the error(s): ' + err.getFields());
                        messages.add('  ' + err.getStatusCode() + ': ' + err.getMessage());
                        messagesExist = true;
                        dmlErrorEncountered = true;
                    }
                }
                if(dmlErrorEncountered) { return 'Failure'; }
            }
            catch (Exception e) {
                postExceptionMsgs(e, localControllerName, messages);                 
                messagesExist = true;
                return 'Failure';
            }
            return 'Success';
        }  
        public string validateDelete() {
            try {
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling
                Boolean dmlErrorEncountered = false;
                for (Database.DeleteResult dr : deleteResultLst) {
                    if (dr.isSuccess()) { continue; }           
                    for(Database.Error err : dr.getErrors()) {
                        if(dmlErrorEncountered == false) {
                            messages.add('Error(s) occurred during the record insert/update:');
                        }                        
                        messages.add('Fields causing the error(s): ' + err.getFields());
                        messages.add('  ' + err.getStatusCode() + ': ' + err.getMessage());
                        messagesExist = true;
                        dmlErrorEncountered = true;
                    }
                }
                if(dmlErrorEncountered) { return 'Failure'; }
            }
            catch (Exception e) {
                postExceptionMsgs(e, localControllerName, messages);                 
                messagesExist = true;
                return 'Failure';
            }
            return 'Success';
        }     
        public string parsePayments(){
            try {
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling
                PersonPayments personPayments;
                for (Payment__c payment : payments) {
                    personPayments = personsPaymentsMap.get(payment.Contact__c);
                    if(personPayments == null) personPayments = new PersonPayments();
                    personPayments.person = payment.Contact__r;
                    personPayments.payments.add(payment);
                    personsPaymentsMap.put(payment.Contact__c, personPayments);
                }
                numPayments = payments.size(); 
                numPayers = personsPaymentsMap.keySet().size();
                return 'Success';
            }
            catch (Exception e) 
            {
                postExceptionMsgs(e, localControllerName, messages);                 
                messagesExist = true;
                return 'Failure';
            }
        }  
        public string convertMapToList(){
            try {
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling
                personsPayments = personsPaymentsMap.values();
                return 'Success';
            }
            catch (Exception e) 
            {
                postExceptionMsgs(e, localControllerName, messages);                 
                messagesExist = true;
                return 'Failure';
            }
        }
    }
    public with sharing class PersonPayments {
        // Properties
        @AuraEnabled Contact             person              {get;set;}
        @AuraEnabled List<Payment__c>    payments            {get;set;}
        @AuraEnabled boolean             expanded            {get;set;}
        // Constructors
        public PersonPayments() {
            payments            = new List<Payment__c>();
            expanded            = true;
        }
    }
    // Constructors
    // Methods (static entry methods)
    @AuraEnabled 
    public static ProjectPayment getPayments(boolean isExceptionTest) {
        ProjectPayment pp = new ProjectPayment();
        try {       // Outer TryCatch will handle exceptions crudely by sending an email directly from this Apex
            try {   // Inner TryCatch will handle exceptions gracefully by logging them to the SystemEvent log
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling
                If(         false   // Developer trick -- makes moving the steps around in this list easier.
                   ||  pp.initialize()  != 'Success'
                   ||  pp.getPayments() != 'Success'
                   ||  pp.parsePayments() != 'Success'
                   ||  pp.convertMapToList() != 'Success'
                  )
                {
                    // Failure Path
                    pp.success = false;
                }
                else {
                    // Success Path
                    pp.success = true;
                }
                //pp.messages.add('Success?: '+ pp.success);
                //pp.messages.add('personsPayments: '+ pp.personsPayments);
                //op.messages.add('orderItems: '+ op.orderItems);
                //pp.messagesExist = true;
            }
            catch (Exception e) 
            {
                // Inner TryCatch will handle exceptions gracefully by logging them to the SystemEvent log
                postExceptionMsgs(e, localControllerName, pp.messages);                 
                pp.messagesExist = true;
            }
        }
        catch (Exception e) 
        {
            // Outer TryCatch will handle exceptions occuring during the inner TryCatch and send an email directly from this Apex
            //sendEmail(adminEmailAddresses, 'An error has occured...'); 
        }  
        return pp;
    }
    public static ProjectPayment getPayments() { return getPayments(false); }
    @AuraEnabled 
    public static ProjectPayment insertPayment(string personId, string projectId, string paymentDate, string paymentAmt, boolean isExceptionTest) {
        ProjectPayment pp = new ProjectPayment();
        try {       // Outer TryCatch will handle exceptions crudely by sending an email directly from this Apex
            try {   // Inner TryCatch will handle exceptions gracefully by logging them to the SystemEvent log
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling
                If(         false   // Developer trick -- makes moving the steps around in this list easier.
                   ||  pp.initialize()  != 'Success'
                   ||  pp.createPayment(personId, projectId, paymentDate, paymentAmt) != 'Success'
                   ||  pp.insertPayment(new List<sobject>{pp.payment}) != 'Success'
                   ||  pp.validateSave()  != 'Success'
                   // Re-query for updated payments
                   //||  pp.initialize()  != 'Success'
                   ||  pp.getPayments() != 'Success'
                   ||  pp.parsePayments() != 'Success'
                   ||  pp.convertMapToList() != 'Success'
                  )
                {
                    // Failure Path
                    pp.success = false;
                }
                else {
                    // Success Path
                    pp.success = true;
                }
                //pp.messages.add('Success?: '+ pp.success);
                //pp.messages.add('personsPayments: '+ pp.personsPayments);
                //op.messages.add('orderItems: '+ op.orderItems);
                //pp.messagesExist = true;
            }
            catch (Exception e) 
            {
                // Inner TryCatch will handle exceptions gracefully by logging them to the SystemEvent log
                postExceptionMsgs(e, localControllerName, pp.messages);                 
                pp.messagesExist = true;
            }
        }
        catch (Exception e) 
        {
            // Outer TryCatch will handle exceptions occuring during the inner TryCatch and send an email directly from this Apex
            //sendEmail(adminEmailAddresses, 'An error has occured...'); 
        }  
        return pp;
    }
    public static ProjectPayment insertPayment(string personId, string projectId, string paymentDate, string paymentAmt) { return insertPayment(personId, projectId, paymentDate, paymentAmt, false); }
    @AuraEnabled 
    public static ProjectPayment updatePayment(string paymentId, string newPaymentDate, decimal newPaymentAmt, boolean isExceptionTest) {
        ProjectPayment pp = new ProjectPayment();
        try {       // Outer TryCatch will handle exceptions crudely by sending an email directly from this Apex
            try {   // Inner TryCatch will handle exceptions gracefully by logging them to the SystemEvent log
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling
                If(         false   // Developer trick -- makes moving the steps around in this list easier.
                   ||  pp.initialize()  != 'Success'
                   ||  pp.getPayment(paymentId) != 'Success'
                   ||  pp.editPayment(newPaymentDate, newPaymentAmt) != 'Success'
                   ||  pp.updatePayment(new List<sobject>{pp.payment}) != 'Success'
                   ||  pp.validateSave()  != 'Success'
                   // Re-query for updated payments
                   //||  pp.initialize()  != 'Success'
                   ||  pp.getPayments() != 'Success'
                   ||  pp.parsePayments() != 'Success'
                   ||  pp.convertMapToList() != 'Success'
                  )
                {
                    // Failure Path
                    pp.success = false;
                }
                else {
                    // Success Path
                    pp.success = true;
                }
                //pp.messages.add('Success?: '+ pp.success);
                //pp.messages.add('personsPayments: '+ pp.personsPayments);
                //op.messages.add('orderItems: '+ op.orderItems);
                //pp.messagesExist = true;
            }
            catch (Exception e) 
            {
                // Inner TryCatch will handle exceptions gracefully by logging them to the SystemEvent log
                postExceptionMsgs(e, localControllerName, pp.messages);                 
                pp.messagesExist = true;
            }
        }
        catch (Exception e) 
        {
            // Outer TryCatch will handle exceptions occuring during the inner TryCatch and send an email directly from this Apex
            //sendEmail(adminEmailAddresses, 'An error has occured...'); 
        }  
        return pp;
    }
    public static ProjectPayment updatePayment(string paymentId, string newPaymentDate, decimal newPaymentAmt) { return updatePayment(paymentId, newPaymentDate, newPaymentAmt, false); }
    @AuraEnabled 
    public static ProjectPayment deletePayment(string paymentId, boolean isExceptionTest) {
        ProjectPayment pp = new ProjectPayment();
        try {       // Outer TryCatch will handle exceptions crudely by sending an email directly from this Apex
            try {   // Inner TryCatch will handle exceptions gracefully by logging them to the SystemEvent log
                if(isExceptionTest) integer divideByZero = 1/0;  // Test of exception handling
                If(         false   // Developer trick -- makes moving the steps around in this list easier.
                   ||  pp.initialize()  != 'Success'
                   ||  pp.deletePayment(new List<string>{paymentId}) != 'Success'
                   ||  pp.validateDelete()  != 'Success'
                   // Re-query for updated payments
                   //||  pp.initialize()  != 'Success'
                   ||  pp.getPayments() != 'Success'
                   ||  pp.parsePayments() != 'Success'
                   ||  pp.convertMapToList() != 'Success'
                  )
                {
                    // Failure Path
                    pp.success = false;
                }
                else {
                    // Success Path
                    pp.success = true;
                }
                //pp.messages.add('Success?: '+ pp.success);
                //pp.messages.add('personsPayments: '+ pp.personsPayments);
                //op.messages.add('orderItems: '+ op.orderItems);
                //pp.messagesExist = true;
            }
            catch (Exception e) 
            {
                // Inner TryCatch will handle exceptions gracefully by logging them to the SystemEvent log
                postExceptionMsgs(e, localControllerName, pp.messages);                 
                pp.messagesExist = true;
            }
        }
        catch (Exception e) 
        {
            // Outer TryCatch will handle exceptions occuring during the inner TryCatch and send an email directly from this Apex
            //sendEmail(adminEmailAddresses, 'An error has occured...'); 
        }  
        return pp;
    }
    public static ProjectPayment deletePayment(string paymentId) { return deletePayment(paymentId, false); }
                      
    // Methods (static, non-entry)
    // Methods (non-static class methods)
    public static void postExceptionMsgs(Exception e, String callingControllerName, List<string> messages) {
        try {
            messages.add('Salesforce Apex Issue: ' + callingControllerName + ': Line# ' + (string.valueof(e.getLineNumber())).leftPad(5, '_') + ', ' + e.getMessage());
            //o.messagesExist = true;
            System.Debug(LoggingLevel.ERROR, 'Salesforce Apex Issue: ' + callingControllerName + ': Line# ' + (string.valueof(e.getLineNumber())).leftPad(5, '_') + ', ' + e.getMessage());
            //o.Exception_Salesforce += '\r\nSalesforce Apex Issue: ' + callingControllerName + ': Line# ' + (string.valueof(e.getLineNumber())).leftPad(5, '_') + ', ' + e.getMessage();
        } 
        catch (Exception eLocal) {
            System.Debug('ExceptException: ' + localControllerName + ': postExceptionMsgs: Line# ' + (string.valueof(e.getLineNumber())).leftPad(5, '_') + ', ' + eLocal.getMessage());
        }
    }
    

}