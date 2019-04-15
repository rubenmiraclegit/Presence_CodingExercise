/* 
* PaymentTrigger: 
* UsedBy: Payment record DML
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

trigger PaymentTrigger on Payment__c (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete,
    after undelete) {
        
        PaymentTriggerHandler.handleTrigger(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.operationType);
        
    }