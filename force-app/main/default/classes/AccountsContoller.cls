public with sharing class AccountsContoller {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountByName(String name){
        List<Account> accList = new List<Account>();
        try {
            String likeString = name + '%';
            accList = [Select Id, Name, Phone,AnnualRevenue from Account where Name Like :likeString];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return accList;
    }


    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(){   
        try {
            return [Select Id, Name, Phone,AnnualRevenue,LastModifiedDate from Account order by LastModifiedDate DESC Limit 20];
        } catch (Exception e) {
            throw new AuraHandledException('Not able to get records' + e.getMessage());
        }  
    }

    @AuraEnabled
    public static String saveAccounts(List<Account> accList, List<Account> updatedAccList, List<Account> deleteAcc){   
        try {
            System.debug(accList);
            upsert accList;
            delete deleteAcc;
            return 'Suceess';
        } catch (Exception e) {
            throw new AuraHandledException('Not able to save records' + e.getMessage());
        }  
    }

}