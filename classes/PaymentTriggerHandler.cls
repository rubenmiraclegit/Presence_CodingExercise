/* 
* PaymentTriggerHandler: 
* UsedBy: PaymentTrigger
* Purpose: Handles Payment record DML
* Project/Deliverable: Coding Exercise for Presence
* Authors:
*   Jay Miracle, JayMiracle@EfficientAutomationLLC.com
* CreateDate: 4/9/2019
* Version: 1.00, 4/9/2019
* Updates: 
*    - 
* Technical Design Notes:
*    - 
* Developer To-Do:
*    - 
* References: 
*    - https://developer.salesforce.com/blogs/2018/05/summer18-rethink-trigger-logic-with-apex-switch.html
* Data Model:
*    -
*/
public with sharing class PaymentTriggerHandler {
    public static void handleTrigger(List<Payment__c> newRecords, List<Payment__c> oldRecords, 
                                    Map<Id,Payment__c> newRecordsMap, Map<Id,Payment__c> oldRecordsMap, 
                                    System.TriggerOperation triggerEvent ) {
        PaymentCompletion completePayment = new PaymentCompletion();
        switch on triggerEvent {
            when BEFORE_INSERT {
                completePayment.insertPayments(newRecords);  // This action is in BEFORE_ because it is possible we'll want to edit field values before INSERT (TBD)
            }
            when AFTER_UPDATE {
                completePayment.updatePayments(newRecords, oldRecordsMap);  // This action is in AFTER_ because we want to easily query for latest Last_Payment_Date values of all payments, including this payment.
            }
            when AFTER_DELETE {
                completePayment.deletePayments(oldRecords);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }
    public with sharing class PaymentCompletion {
        // Properties
        List<Payment__c>    newPayments                         {get;set;}
        List<Payment__c>    oldPayments                         {get;set;}
        Map<Id,Payment__c>  newPaymentsMap                      {get;set;}
        Map<Id,Payment__c>  oldPaymentsMap                      {get;set;}
        List<id>            contactIds                          {get;set;}
        List<id>            projectIds                          {get;set;}
        Map<Id, Contact>    contactsMap                         {get;set;}
        Map<Id, Project__c> projectsMap                         {get;set;}
        Map<Id, Date>       latestPaymentDatePerContactMap      {get;set;}
        
        // Constructors
        public PaymentCompletion() {
            contactIds  = new List<id>();   
            projectIds  = new List<id>();
            latestPaymentDatePerContactMap = new Map<ID, Date>();
        }
        
        // Methods
        public void insertPayments(List<Payment__c> newRecords) {
            //integer divideByZero = 1/0;
            newPayments = newRecords;
            getContactIdsAndProjectIdsFromNew();
            getContacts();
            getProjects();
            editContactsAndProjectsForPaymentInsert();
            updateContactsAndProjects();
        }
        public void updatePayments(List<Payment__c> newRecords, Map<Id,Payment__c> oldRecordsMap) {
            //integer divideByZero = 1/0;
            newPayments     = newRecords;
            oldPaymentsMap  = oldRecordsMap;
            getContactIdsAndProjectIdsFromNew();
            getContacts();
            getProjects();
            getLatestPaymentDatePerContact();
            editContactsAndProjectsForPaymentUpdate();
            updateContactsAndProjects();
        }
        public void deletePayments(List<Payment__c> oldRecords) {
            //integer divideByZero = 1/0;
            oldPayments = oldRecords;
            getContactIdsAndProjectIdsFromOld();
            getContacts();
            getProjects();
            getLatestPaymentDatePerContact();
            editContactsAndProjectsForPaymentDelete();
            updateContactsAndProjects();
        }
        public void getContactIdsAndProjectIdsFromNew(){
            for (Payment__c newPayment : newPayments) {
                contactIds.add(newPayment.Contact__c);
                projectIds.add(newPayment.Project__c);
            }
        }
        public void getContactIdsAndProjectIdsFromOld(){
            for (Payment__c oldPayment : oldPayments) {
                contactIds.add(oldPayment.Contact__c);
                projectIds.add(oldPayment.Project__c);
            }
        }
        public void getContacts(){
            contactsMap = new Map<ID, Contact>([SELECT Total_Payments_Amount__c, Last_Payment_Date__c FROM Contact WHERE ID IN: contactIds]);
        }
        public void getProjects(){
            projectsMap = new Map<ID, Project__c>([SELECT Total_Payments_Amount__c FROM Project__c WHERE ID IN: projectIds]);
        }
        public void getLatestPaymentDatePerContact(){
            List<Payment__c> paymentsPerContact = [SELECT Contact__c, Date__c FROM Payment__c WHERE Contact__c IN: contactIds ORDER BY Contact__c, Date__c ASC];
            // Convert into map
            for(Payment__c payment : paymentsPerContact) {
                latestPaymentDatePerContactMap.put(payment.Contact__c, payment.Date__c);
                // If the map previously contained a mapping for a key, the old value is replaced.
                //  Hence, the last payment record for each contact is the Latest payment record, due the the "Date__c ASC" in the SOQL query.
            }
        }
        public void editContactsAndProjectsForPaymentInsert(){
            for (Payment__c newPayment : newPayments) {
                // Compare current lastPaymentDate with new payment date, and act accordingly:
                Date currentLastPaymentDate = contactsMap.get(newPayment.contact__c).Last_Payment_Date__c;
                if(currentLastPaymentDate == null || newPayment.Date__c > currentLastPaymentDate ) contactsMap.get(newPayment.contact__c).Last_Payment_Date__c = newPayment.Date__c;
                
                Decimal totalPaymentsAmtContact = contactsMap.get(newPayment.contact__c).Total_Payments_Amount__c;
                if(totalPaymentsAmtContact == null) contactsMap.get(newPayment.contact__c).Total_Payments_Amount__c = newPayment.Amount__c;
                else contactsMap.get(newPayment.contact__c).Total_Payments_Amount__c = totalPaymentsAmtContact + newPayment.Amount__c;
                
                Decimal totalPaymentsAmtProject = projectsMap.get(newPayment.project__c).Total_Payments_Amount__c;
                if(totalPaymentsAmtProject == null) projectsMap.get(newPayment.project__c).Total_Payments_Amount__c = newPayment.Amount__c;
                else projectsMap.get(newPayment.project__c).Total_Payments_Amount__c = totalPaymentsAmtProject + newPayment.Amount__c;
            }
        }
        public void editContactsAndProjectsForPaymentUpdate(){
            for (Payment__c newPayment : newPayments) {
                // Update Contact.Last_Payment_Date:
                if(latestPaymentDatePerContactMap.get(newPayment.Contact__c) == null) 
                     contactsMap.get(newPayment.contact__c).Last_Payment_Date__c = newPayment.Date__c; // This scenario should not occur, but, just in case...
                else contactsMap.get(newPayment.contact__c).Last_Payment_Date__c = latestPaymentDatePerContactMap.get(newPayment.Contact__c);
                
                // Get payment change/difference between old payment and new payment and apply to Contact and Project:
                Decimal paymentChange = newPayment.Amount__c - oldPaymentsMap.get(newPayment.Id).Amount__c;
                contactsMap.get(newPayment.contact__c).Total_Payments_Amount__c = contactsMap.get(newPayment.contact__c).Total_Payments_Amount__c + paymentChange;
                projectsMap.get(newPayment.project__c).Total_Payments_Amount__c = projectsMap.get(newPayment.project__c).Total_Payments_Amount__c + paymentChange;
            }
        }
        public void editContactsAndProjectsForPaymentDelete(){
            for (Payment__c oldPayment : oldPayments) {
                // Update Contact.Last_Payment_Date:
                if(latestPaymentDatePerContactMap.get(oldPayment.Contact__c) == null) 
                     contactsMap.get(oldPayment.contact__c).Last_Payment_Date__c = null; // This scenario should not occur, but, just in case...
                else contactsMap.get(oldPayment.contact__c).Last_Payment_Date__c = latestPaymentDatePerContactMap.get(oldPayment.Contact__c);
                
                // Subtract the payment amount from Contact and Project records:
                contactsMap.get(oldPayment.contact__c).Total_Payments_Amount__c = contactsMap.get(oldPayment.contact__c).Total_Payments_Amount__c - oldPayment.Amount__c;
                projectsMap.get(oldPayment.project__c).Total_Payments_Amount__c = projectsMap.get(oldPayment.project__c).Total_Payments_Amount__c - oldPayment.Amount__c;
            }
        }
        public void updateContactsAndProjects(){
            List<sobject> recordsForUpdate = new List<sobject>();
            recordsForUpdate.add(contactsMap.values());
            recordsForUpdate.add(projectsMap.values());
            Database.update(recordsForUpdate, false);
        }
    }
}