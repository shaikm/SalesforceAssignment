trigger AccountTrigger on Account (before insert) {
    Id userId = UserInfo.getUserId();    
    User u = [Select Id, name, Country from User where Id = :userId Limit 1];
    
    for (Account a: Trigger.new) {
        if (u.Country != null && u.Country != '') {
            a.Country__c = u.Country;
        } else {
            a.Country__c.addError('Country needs to specified for sharing to apply..');
        }
    }
}