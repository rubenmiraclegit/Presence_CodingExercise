({
    getPayments : function(cmp, event, helper) {
        try {            
            var action = cmp.get("c.getPayments");        
            action.setParams({
                
            });
            //REFERENCE for Stringify: https://developer.salesforce.com/forums/?id=9060G000000Xe5lQAC
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    //console.log('apex call has returned');
                    cmp.set("v.apexObject",response.getReturnValue());
                }
                else {
                    console.log('cmp notValid OR state != SUCCESS (c.updateRecords)');
                    cmp.set('v.msgFromJavascript', 'Apex call unsuccessful');   
                    cmp.set('v.msgFromJavascriptExists', true);                
                }
            });
            
            $A.enqueueAction(action);
        }
        catch(err) {
            cmp.set('v.showSpinner', false);
            console.log('JS:helper.createOrder: error: ' + err);  
            cmp.set("v.msgFromJavascript", "Javascript " + err);
            cmp.set("v.msgFromJavascriptExists", true);           
        }      
    },
    isValidDate: function(cmp, event, helper, paymentDate) {        
        // REFERENCE: http://www.javascriptkit.com/script/script2/validatedate.shtml
        var dateVal =  paymentDate.get("v.value"); 
        // Check for missing value
        if (dateVal == null || dateVal == "") {
            paymentDate.setCustomValidity("Payment Date is required");
            paymentDate.reportValidity();   
            return false;
        }
        
        // Check for invalid date format
        var validformat=/^\d{1,2}\/\d{1,2}\/\d{4}$/;
        if (!validformat.test(dateVal)) {
            paymentDate.setCustomValidity("Date must be in M/D/YYYY format");
            paymentDate.reportValidity();   
            return false;
        }
        
        // Check for invalid date ranges
        var monthfield=dateVal.split("/")[0];
        var dayfield=dateVal.split("/")[1];
        var yearfield=dateVal.split("/")[2];
        var dayobj = new Date(yearfield, monthfield-1, dayfield);
        if ((dayobj.getMonth()+1!=monthfield) || (dayobj.getDate()!=dayfield) || (dayobj.getFullYear()!=yearfield) 
            || dayobj.getFullYear() < 1700 || dayobj.getFullYear() > 4000)   // For Salesforce date range limits
        {
            // REFERENCE: https://help.salesforce.com/articleView?id=000240801&type=1
            paymentDate.setCustomValidity("Invalid Day, Month, or Year");
            paymentDate.reportValidity();   
            return false;
        }
        
        // Date validated successfully
        return true;        
    },
    isValidAmt: function(cmp, event, helper, paymentAmt) {
        var amtVal =  paymentAmt.get("v.value");    
        if (amtVal == null || amtVal == "") {
            paymentAmt.setCustomValidity("Payment Amount required");
            paymentAmt.reportValidity();        
            return false;
        }     
        return true;
    },
    isValidProject: function(cmp, event, helper, paymentProject) {
        var projectId =  paymentProject.get("v.value");          
        if (projectId == null || projectId == "") {      
            //paymentProject.setCustomValidity("Project is required");
            //paymentProject.reportValidity();    
            //paymentProject.set("v.label","Project is Required");
            cmp.set("v.msgFromJavascript", "Project is Required");
            cmp.set("v.msgFromJavascriptExists", true);    
            return false;
        }     
        return true;
    },
    updatePayment : function(cmp, event, helper, paymentRecordId, paymentDate, paymentAmt) {
        try {            
            //alert("updatePayment:begin");
            var action = cmp.get("c.updatePayment");        
            action.setParams({
                "paymentId"		: paymentRecordId,
                "newPaymentDate": paymentDate.get("v.value"),
                "newPaymentAmt"	: paymentAmt.get("v.value")                
            });
            //REFERENCE for Stringify: https://developer.salesforce.com/forums/?id=9060G000000Xe5lQAC
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    //console.log('apex call has returned');
                    cmp.set("v.apexObject",response.getReturnValue());
                }
                else {
                    console.log('cmp notValid OR state != SUCCESS (c.updateRecords)');
                    cmp.set('v.msgFromJavascript', 'Apex call unsuccessful');   
                    cmp.set('v.msgFromJavascriptExists', true);                
                }
                cmp.set('v.showSpinner', false);
            });            
            cmp.set('v.showSpinner', true);
            $A.enqueueAction(action);            
            //alert("updatePayment:end");
        }
        catch(err) {
            cmp.set('v.showSpinner', false);
            console.log('JS:helper.createOrder: error: ' + err);  
            cmp.set("v.msgFromJavascript", "Javascript " + err);
            cmp.set("v.msgFromJavascriptExists", true);           
        }      
    },
    deletePayment : function(cmp, event, helper, paymentRecordId) {
        try {            
            //alert("updatePayment:begin");
            var action = cmp.get("c.deletePayment");        
            action.setParams({
                "paymentId"		: paymentRecordId              
            });
            //REFERENCE for Stringify: https://developer.salesforce.com/forums/?id=9060G000000Xe5lQAC
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    //console.log('apex call has returned');
                    cmp.set("v.apexObject",response.getReturnValue());
                }
                else {
                    console.log('cmp notValid OR state != SUCCESS (c.updateRecords)');
                    cmp.set('v.msgFromJavascript', 'Apex call unsuccessful');   
                    cmp.set('v.msgFromJavascriptExists', true);                
                }
                cmp.set('v.showSpinner', false);
            });         
            cmp.set('v.showSpinner', true);
            $A.enqueueAction(action);            
            //alert("updatePayment:end");
        }
        catch(err) {
            cmp.set('v.showSpinner', false);
            console.log('JS:helper.createOrder: error: ' + err);  
            cmp.set("v.msgFromJavascript", "Javascript " + err);
            cmp.set("v.msgFromJavascriptExists", true);           
        }      
    },
    insertPayment : function(cmp, event, helper, personRecordId, paymentProject, paymentAmt, paymentDate) {
        try {            
            //alert("updatePayment:begin");
            var action = cmp.get("c.insertPayment");        
            action.setParams({
                "personId"		: personRecordId,
                "projectId"		: paymentProject.get("v.value"),
                "paymentDate"	: paymentDate.get("v.value"),
                "paymentAmt"	: paymentAmt.get("v.value")                
            });
            //REFERENCE for Stringify: https://developer.salesforce.com/forums/?id=9060G000000Xe5lQAC
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    //console.log('apex call has returned');
                    cmp.set("v.apexObject",response.getReturnValue());
                    helper.closeInsert(cmp, event, helper);
                }
                else {
                    console.log('cmp notValid OR state != SUCCESS (c.updateRecords)');
                    cmp.set('v.msgFromJavascript', 'Apex call unsuccessful');   
                    cmp.set('v.msgFromJavascriptExists', true);                
                }                
                cmp.set('v.showSpinner', false);
            });                        
            cmp.set('v.showSpinner', true);
            $A.enqueueAction(action);            
            //alert("updatePayment:end");
        }
        catch(err) {
            cmp.set('v.showSpinner', false);
            console.log('JS:helper.createOrder: error: ' + err);  
            cmp.set("v.msgFromJavascript", "Javascript " + err);
            cmp.set("v.msgFromJavascriptExists", true);           
        }      
    },
    clearFieldMessage : function(cmp, event, helper, paymentDate) {
        paymentDate.setCustomValidity("");
        paymentDate.reportValidity();   
        //paymentAmt.setCustomValidity("");
        //paymentAmt.reportValidity();   
        //paymentProject.setCustomValidity("");
        //paymentProject.reportValidity();                
    },
    closeInsert : function(cmp, event, helper) {
        cmp.set("v.createPaymentClicked", false);      
        cmp.set("v.createPaymentPersonId", "");  
    }
})