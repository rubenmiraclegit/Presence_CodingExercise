@isTest
private class PresenceProjectPaymentApxTest {
    @isTest static void TestPaymentGetPayments() {
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
        PresenceProjectPaymentApx.getPayments();
        insert payment;
        Test.stopTest();
        PresenceProjectPaymentApx.getPayments();
        // Verify
        System.assert([SELECT Last_Payment_Date__c FROM Contact].Last_Payment_Date__c == todayDate);
    }
    @isTest static void TestPaymentInsert() {
        // Test data setup
        Contact contact = new Contact(LastName='Test Payer LastName');
        insert contact;
        
        Project__c project = new Project__c(Project_Name__c='Test Project', Total_Payments_Amount__c = 3);
        insert project;
        
        
        Date todayDate = date.today();
        
        // Test payment insert
        Test.startTest();
        PresenceProjectPaymentApx.insertPayment(contact.Id, project.id, (todayDate+1).format(), '100.0');
        Test.stopTest();
        // Verify
        System.assert([SELECT Total_Payments_Amount__c FROM Project__c].Total_Payments_Amount__c ==  3 + 100);
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
        
        // Test payment insert
        Test.startTest();
        PresenceProjectPaymentApx.updatePayment(payment.Id, (todayDate+1).format(), 200.0);
        Test.stopTest();
        // Verify
        System.assert([SELECT Total_Payments_Amount__c FROM Project__c].Total_Payments_Amount__c == 3+1+(200-1));
    }
    @isTest static void TestPaymentDelete() {
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
        
        // Test payment insert
        Test.startTest();
        PresenceProjectPaymentApx.deletePayment(payment.Id);
        Test.stopTest();
        // Verify
        System.assert([SELECT Total_Payments_Amount__c FROM Project__c].Total_Payments_Amount__c == 3+1-1);
    }
    @isTest static void TestExceptionHandling() {
        PresenceProjectPaymentApx.ProjectPayment pp = new PresenceProjectPaymentApx.ProjectPayment(true);    // isExceptionTest = true

        // Test payment insert
        Test.startTest();
        
        pp.initialize();
        pp.getPayments();
        pp.getPayment(null);
        pp.editPayment(null,null);
        pp.createPayment(null,null,null,null);
        pp.updatePayment(null);
        pp.insertPayment(null);
        pp.deletePayment(null);
        pp.validateSave();
        pp.validateDelete();
        pp.parsePayments();
        pp.convertMapToList();
        
        PresenceProjectPaymentApx.getPayments(true);
        PresenceProjectPaymentApx.insertPayment(null,null,null,null, true);
        PresenceProjectPaymentApx.updatePayment(null,null,null,true);
        PresenceProjectPaymentApx.deletePayment(null,true);

        Test.stopTest();
        // Verify
    }
    
    @isTest static void TestDmlError() {
        PresenceProjectPaymentApx.ProjectPayment pp = new PresenceProjectPaymentApx.ProjectPayment();    // isExceptionTest = false
        pp.initialize();
        // Test payment insert
        Test.startTest();
        
        pp.getPayment(null);
        pp.insertPayment(null);
        pp.insertPayment(new List<sobject>{new Account()} );
        pp.validateSave();
        
        pp.deletePayment(new List<string>{'12334'});
        pp.validateDelete();

        Test.stopTest();
        // Verify
    }
    
}