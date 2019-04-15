@isTest
private class PaymentTriggerTest {
    @isTest static void TestPaymentInsert() {
        // Test data setup
        Contact contact = new Contact(LastName='Test Payer LastName');
        insert contact;
        
        Project__c project = new Project__c(Project_Name__c='Test Project',
                                            Total_Payments_Amount__c = 3);
        insert project;
        
        Date todayDate = date.today();
        Payment__c payment = new Payment__c();
        payment.Amount__c = 1;
        payment.Contact__c = contact.Id;
        payment.Date__c = todayDate;
        payment.Project__c = project.id;
        
        
        // Test payment insert
        Test.startTest();
        Database.SaveResult result = Database.insert(payment, false);
        Test.stopTest();
        // Verify
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
        System.assert([SELECT Last_Payment_Date__c FROM Contact].Last_Payment_Date__c == todayDate);
    }
    
    
    
    @isTest static void TestPaymentUpdate() {
        // Test data setup
        Contact contact = new Contact(LastName='Test Payer LastName');
        insert contact;
        
        Project__c project = new Project__c(Project_Name__c='Test Project',
                                            Total_Payments_Amount__c = 3);
        insert project;
        
        Date todayDate = date.today();
        Payment__c payment = new Payment__c();
        payment.Amount__c = 1;
        payment.Contact__c = contact.Id;
        payment.Date__c = todayDate;
        payment.Project__c = project.id;
        
        insert payment;
        
        System.debug(LoggingLevel.ERROR, 'Last_Payment_Date__c(should be 4): ' + [SELECT Total_Payments_Amount__c FROM Project__c].Total_Payments_Amount__c );

        // Test payment update
        payment.Amount__c = 10;
        Test.startTest();
        Database.SaveResult result = Database.update(payment, false);
        Test.stopTest();
        // Verify
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
        System.debug(LoggingLevel.ERROR, 'Last_Payment_Date__c: ' + [SELECT Total_Payments_Amount__c FROM Project__c].Total_Payments_Amount__c );
        System.assert([SELECT Total_Payments_Amount__c FROM Project__c].Total_Payments_Amount__c == 13);
    }
    
    @isTest static void TestPaymentDelete() {
        // Test data setup
        Contact contact = new Contact(LastName='Test Payer LastName');
        insert contact;
        
        Project__c project = new Project__c(Project_Name__c='Test Project',
                                            Total_Payments_Amount__c = 3);
        insert project;
        
        
        Payment__c payment = new Payment__c();
        payment.Amount__c = 1;
        payment.Contact__c = contact.Id;
        payment.Date__c = date.today();
        payment.Project__c = project.id;

        insert payment;
        
        // Perform test
        System.assert([SELECT Id FROM Payment__c].size() == 1);
        Test.startTest();
        Database.DeleteResult result = Database.delete(payment, false);
        Test.stopTest();
        // Verify
        //System.debug(LoggingLevel.ERROR, 'DML results: ' + result.getErrors());
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
        System.assert([SELECT Id FROM Payment__c].size() == 0);
    }
    
}