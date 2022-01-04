trigger DistrictTrigger on District__c (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        List<District__c> districtList = new List<District__c>();
        
        if (Trigger.isDelete) {
            districtList = Trigger.old;
        } else {
            districtList = Trigger.new;
        }
        Set<Id> stateSet = new Set<Id>();
        for (District__c district : districtList) {
            stateSet.add(district.State__c);    
            if (Trigger.isUpdate) {
                District__c oldDistrict = Trigger.oldMap.get(district.Id);
                if (oldDistrict.State__c != district.State__c) {
                    stateSet.add(oldDistrict.Id);
                }
            }
        }
        
        Map<Id, StatusCount> statusMap = new Map<Id, StatusCount>();
        List<District__c> distList = [Select Id, State__c, Status__c from District__c where state__c IN :stateSet];
        
        for (District__c d: distList) {
            if (statusMap.containsKey(d.State__c)) {
                StatusCount sCount = statusMap.get(d.State__c);
                if (d.Status__c == 'dangerous') {
                    sCount.danger += 1;
                } else if(d.Status__c == 'warning') {
                    sCount.warning += 1;
                } else {
                    sCount.safe += 1;
                }
                sCount.total += 1;
            } else {
                StatusCount sCount = new StatusCount();
                if (d.Status__c == 'dangerous') {
                    sCount.danger = 1;
                } else if(d.Status__c == 'warning') {
                    sCount.warning = 1;
                } else {
                    sCount.safe = 1;
                }
                sCount.total = 1;
                statusMap.put(d.State__c, sCount);
            }
        }
        
        List<State__c> stateList = new List<State__c>();
        for (Id sId: statusMap.keySet()) {
            StatusCount sCount = statusMap.get(sId);
            State__c state = new State__c();
            state.Id = sId;
            if ((sCount.total / 2) <= sCount.danger) {
				System.debug('Danger');  
                state.Status__c = 'dangerous';
            } else if ((sCount.total / 3) <= sCount.warning) {
                System.debug('Warning');
                state.Status__c = 'warning';
            } else {
                System.debug('Safe');
                state.Status__c = 'safe	';
            }
            stateList.add(state);
        }
        
        update stateList;
    }
}