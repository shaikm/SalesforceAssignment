trigger InvoiceTrigger on Invoice__c (after insert, after update, after delete, after undelete) {
    
    Set<Id> oppIds = new Set<Id>();
    List<Invoice__c> invoiceList = new List<Invoice__c> ();
    
    if ( Trigger.isDelete ) {
        invoiceList = Trigger.Old;
    } else {
        invoiceList = Trigger.New;
    }
    
    if (!invoiceList.isEmpty()) {       
        for (Invoice__c invoice: invoiceList) {
            oppIds.add(invoice.Opportunity__c);
            
            if ( Trigger.isUpdate ) {
                Invoice__c oldInvoice = (Invoice__c)Trigger.oldMap.get(invoice.Id);
                if ( oldInvoice.Opportunity__c != invoice.Opportunity__c ) {
                    oppIds.add(oldInvoice.Opportunity__c);
                }
            }
        }
        
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        
        for (Id oppId : oppIds) {
            opportunityMap.put(oppId, new Opportunity(Id= oppId, Count_of_Invoices__c=0, Sum_of_Invoices__c=0));
        }
        
        for (AggregateResult ar: [SELECT Opportunity__c, count(Id) invoiceCount, SUM(Amount__c) invoiceSum FROM Invoice__c where Opportunity__c in :oppIds group by Opportunity__c]) {
            Id oppId = (ID)ar.get('Opportunity__c');
            Decimal invoiceCount = (Decimal) ar.get('invoiceCount');
            Decimal invoiceTotal = (Decimal) ar.get('invoiceSum');
            if (opportunityMap.containsKey(oppId)) {
                Opportunity opp = opportunityMap.get(oppId);
                opp.Count_of_Invoices__c = invoiceCount;
                opp.Sum_of_Invoices__c = invoiceTotal;
            }
        }
        
        try {
            update opportunityMap.values();
        } catch(Exception e) {
            System.debug('Exception::: '  + e.getMessage());
        }
    }
}