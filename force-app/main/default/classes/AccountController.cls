public with sharing class AccountController {
    public List<WrapperAccount> listWrappAcc {get; set;}
    public Map<Id, Account> accMap = new Map<Id, Account>();
    
    public AccountController() {
        listWrappAcc = new List<WrapperAccount>();
        List<Account> accList = [select id, name, phone from Account order by LastModifiedDate DESC Limit 50 ];
        
        for(Account a : accList) {
            listWrappAcc.add(new WrapperAccount(a));
            accMap.put(a.id, a.clone(false, true));
        }
    }
    
    public void addRow() {
        listWrappAcc.add(new WrapperAccount(new Account()));
    }
    
    public PageReference save() {
        try {
            List<Account> lstAccToUpdate = new List<Account>();
            for(WrapperAccount wa: listWrappAcc) {     
                if (wa.acc.Id == null) {
                    lstAccToUpdate.add(wa.acc); 
                } else {
                    System.debug('Account' + wa.acc + '----' + accMap.get(wa.acc.Id));
                    Account oldAcc = accMap.get(wa.acc.Id);
                    Account newAcc  = wa.acc;
                    if (oldAcc.Name != newAcc.Name || oldAcc.Phone != newAcc.Phone) {
                        lstAccToUpdate.add(wa.acc); 
                    }
                }
                
            }    
            System.debug(lstAccToUpdate.size());
            if(lstAccToUpdate.size() > 0 ) {
                upsert lstAccToUpdate;
            }
        } catch(Exception ex) {
            System.debug('Error:::' + ex.getMessage());
        }
        return null;        
    }
    
    public PageReference deleteRows() {
        List<Account> lstAccToDelete = new List<Account>();
        for(WrapperAccount wAcc: listWrappAcc) {
            if(wAcc.selected  == true && wAcc.acc.Id != null) {
                lstAccToDelete.add(wAcc.acc);
            }
        }
        
        for (Integer i = (listWrappAcc.size()-1) ; i>= 0 ; i--){
            WrapperAccount s = listWrappAcc[i];
            if(s.selected) {
                listWrappAcc.remove(i);
            }
        } 
        
        if(lstAccToDelete.size() > 0 ) {
            Delete lstAccToDelete;
        }
        
        return null;
    }
    
    
    public class WrapperAccount
    {
        public Account acc {get; set;}
        public Boolean selected {get; set;}
        
        public WrapperAccount(Account a) {
            acc = a;
            selected = false;
        }
    }
}