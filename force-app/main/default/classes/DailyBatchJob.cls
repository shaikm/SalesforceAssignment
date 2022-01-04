public class DailyBatchJob implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select Id, Name from Account where SystemModStamp = TODAY');
    }
    
    public void execute(Database.BatchableContext bc, List<Account> newList) {
        for(Account acc : newList) { 
            if (!acc.Name.contains('Updated')) {
                acc.Name = acc.Name + ' Updated';
            }
        }
        try {
            update newList;
        } catch(Exception e) {
            System.debug(e);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        Messaging.SingleEmailMessage Emailmessage = new Messaging.SingleEmailMessage();
        Emailmessage.toaddresses = new String[] { UserInfo.getUserEmail() };
        Emailmessage.subject='Batch Job is Completed.';
        String Message = 'Batch Job is Completed. <br/>';        
        Message += 'Thank you';
        Emailmessage.setHtmlBody(Message);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { Emailmessage });
        system.debug('Email is sent Successfully.');
        
    }
}