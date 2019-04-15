({
    init: function(cmp, event, helper) {
        cmp.set("v.rows", [
            {Name: "A",
             expanded: false,
             children: [
                 { Name: "A1" },
                 { Name: "A2" }
             ]},
            {Name: "B",
             expanded: false,
             children: [
                 { Name: "B1" },
                 { Name: "B2" }
             ]},
            {Name: "C",
             expanded: false,
             children: [
                 { Name: "C1" },
                 { Name: "C2" }
             ]}
        ]);
        
        //alert("TP00");  
        helper.getPayments(cmp, event, helper);
    },
    toggle: function(cmp, event, helper) {
        return;  // DISABLING THIS FEATURE -- TO AVOID USER EXPERIENCE CONFUSION
        var personsPayments = cmp.get("v.apexObject.personsPayments");
        //alert("event.target.dataset.index: " + event.target.dataset.index);
        personsPayments[event.target.dataset.index].expanded = !personsPayments[event.target.dataset.index].expanded;
        cmp.set("v.apexObject.personsPayments", personsPayments);
    },
    handleDateChange: function(cmp, event, helper) {     
        //var dateVal = event.getSource().get("v.value"); 
        var paymentDate = event.getSource(); 
        helper.isValidDate(cmp, event, helper, paymentDate);
    },
    clearJsMessage: function(cmp, event, helper) { 
        cmp.set("v.msgFromJavascript", "");
        cmp.set("v.msgFromJavascriptExists", false);
    },
    clearMessage: function(cmp, event, helper) { 
        var paymentDate = event.getSource();
        //cmp.set("v.msgFromJavascript", "");
        //cmp.set("v.msgFromJavascriptExists", false);
        helper.clearFieldMessage(cmp, event, helper, paymentDate);
    },
    handleUpdateClick: function(cmp, event, helper) { 
        try {            
            //alert("handleUpdatePaymentClick:begin");
            var paymentRecordId = event.getSource().get("v.value"); 
            //alert("paymentRecordId: " + paymentRecordId);              
            var paymentAmounts 	= cmp.find("paymentAmount");              
            var paymentDates 	= cmp.find("paymentDate");             
            
            var paymentAmt;        
            for(var comp in paymentAmounts ){
                //alert("2: " + paymentAmounts[comp].get("v.name") ); 
                if(paymentAmounts[comp].get("v.name") == paymentRecordId) paymentAmt = paymentAmounts[comp];
            }
            //alert("paymentAmt.get('v.name')  : " 	+ paymentAmt.get("v.name")  ); 
            //alert("paymentAmt.get('v.value')  : " 	+ paymentAmt.get("v.value")  ); 
            
            var paymentDate;        
            for(var comp in paymentDates ){
                //alert("2: " + paymentAmounts[comp].get("v.name") ); 
                if(paymentDates[comp].get("v.name") == paymentRecordId) paymentDate = paymentDates[comp];
            }
            //alert("paymentDate.get('v.name')  : " 	+ paymentDate.get("v.name")  ); 
            //alert("paymentDate.get('v.value')  : " 	+ paymentDate.get("v.value")  );
            ///var paymentDateVal =  paymentDate.get("v.value");        
            
            //alert("handleUpdatePaymentClick:mid0200");
            if(!helper.isValidDate(cmp, event, helper, paymentDate) ) return;
            //alert("handleUpdatePaymentClick:mid030");
            helper.updatePayment(cmp, event, helper, paymentRecordId, paymentDate, paymentAmt);
            //alert("handleUpdatePaymentClick:end");
        }
        catch(err) {
            cmp.set('v.showSpinner', false);
            console.log('JS:helper.createOrder: error: ' + err);  
            cmp.set("v.msgFromJavascript", "Javascript " + err);
            cmp.set("v.msgFromJavascriptExists", true);           
        }         
    },
    handleDeleteClick : function(cmp, event, helper) {  
        try {            
            //alert("handleDeletePaymentClick:begin");
            var paymentRecordId = event.getSource().get("v.value");          
            //alert("handleDeletePaymentClick:mid030");

            helper.deletePayment(cmp, event, helper, paymentRecordId);
            //alert("handleDeletePaymentClick:end");
        }
        catch(err) {
            cmp.set('v.showSpinner', false);
            console.log('JS:helper.createOrder: error: ' + err);  
            cmp.set("v.msgFromJavascript", "Javascript " + err);
            cmp.set("v.msgFromJavascriptExists", true);           
        }         
    },
    handleCreateClick: function(cmp, event, helper) { 
        try {            
            //alert("handleUpdatePaymentClick:begin");
            var personRecordId = event.getSource().get("v.value"); 
            //alert("paymentRecordId: " + paymentRecordId);   
            cmp.set("v.createPaymentClicked", true);      
            cmp.set("v.createPaymentPersonId", personRecordId);            
        }
        catch(err) {
            cmp.set('v.showSpinner', false);
            console.log('JS:helper.createOrder: error: ' + err);  
            cmp.set("v.msgFromJavascript", "Javascript " + err);
            cmp.set("v.msgFromJavascriptExists", true);           
        }         
    },
    handleInsertClick: function(cmp, event, helper) { 
        try {            
            //alert("handleUpdatePaymentClick:begin");
            var personRecordId = event.getSource().get("v.value"); 
            //alert("paymentRecordId: " + paymentRecordId);                
            var paymentProject	= cmp.find("insertPaymentProject");
            var paymentAmt 		= cmp.find("insertPaymentAmount");           
            var paymentDate 	= cmp.find("insertPaymentDate");             
            
            //alert("handleUpdatePaymentClick:mid0200");
            //alert("handleUpdatePaymentClick:mid030");
            if(!helper.isValidDate(cmp, event, helper, paymentDate) ) return;
            if(!helper.isValidAmt(cmp, event, helper, paymentAmt) ) return;
            if(!helper.isValidProject(cmp, event, helper, paymentProject) ) return;
            helper.insertPayment(cmp, event, helper, personRecordId, paymentProject, paymentAmt, paymentDate);
            //alert("handleUpdatePaymentClick:end");
        }
        catch(err) {
            cmp.set('v.showSpinner', false);
            console.log('JS:helper.createOrder: error: ' + err);  
            cmp.set("v.msgFromJavascript", "Javascript " + err);
            cmp.set("v.msgFromJavascriptExists", true);           
        }         
    },
    handleInsertCancel: function(cmp, event, helper) { 
        try {
            //var personRecordId = event.getSource().get("v.value");
            helper.closeInsert(cmp, event, helper);         
        }
        catch(err) {
            cmp.set('v.showSpinner', false);
            console.log('JS:helper.createOrder: error: ' + err);  
            cmp.set("v.msgFromJavascript", "Javascript " + err);
            cmp.set("v.msgFromJavascriptExists", true);           
        }         
    }
    
})