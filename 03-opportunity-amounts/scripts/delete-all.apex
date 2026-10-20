// Video 3: deletes every remaining opportunity on Sharma Traders so 0 deals remain.
delete [SELECT Id FROM Opportunity WHERE Account.Name = 'Sharma Traders'];
Account sharma = [SELECT Total_Opportunity_Amount__c, (SELECT Id FROM Opportunities) FROM Account WHERE Name = 'Sharma Traders'];
System.debug('Deals left: ' + sharma.Opportunities.size() + ', Total Opportunity Amount: ' + sharma.Total_Opportunity_Amount__c);
