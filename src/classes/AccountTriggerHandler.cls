public with sharing class AccountTriggerHandler {
	
	public static void createJunctionObjects( List<Account> accounts ) {
		List<Partner_Strength__c> partnerStrengths = new List<Partner_Strength__c>();
		List<Partner_Country__c> partnerCountries = new List<Partner_Country__c>();
		
		Map<String, List<Id>> strengthIdToPartners = new Map<String, List<Id>>();
		Map<String, List<Id>> countryIsoToPartners = new Map<String, List<Id>>();
		
		for(Account a : accounts){
			
			if(a.PartnerStrength_Ids__c != null){
				for(String s : a.PartnerStrength_Ids__c.split(';')){
					if( strengthIdToPartners.containsKey( s )) strengthIdToPartners.get(s).add(a.Id);
					else strengthIdToPartners.put( s, new List<Id>{a.Id});
				}
			}
			
			if( a.Country_Codes__c != null ){
				for( String s : a.Country_Codes__c.split(';')) {
					if( countryIsoToPartners.containsKey( s ) ) countryIsoToPartners.get(s).add(a.Id);
					else countryIsoToPartners.put( s, new List<Id>{a.Id});
				}
			}
			
		}
		
		
		System.debug('strengthIdToPartners: ' + strengthIdToPartners);
		System.debug('countryIsoToPartners: ' + countryIsoToPartners);
		
		for( Social_Performance_Strength__c s : [SELECT Id, Id__c, Name FROM Social_Performance_Strength__c WHERE Id__c IN :strengthIdToPartners.keyset()]){
			for( Id aId : strengthIdToPartners.get(s.Id__c) ){
				partnerStrengths.add( new Partner_Strength__c(	Name= s.Name,
																Social_Performance_Strength__c = s.Id,
																Partner__c = aId ) );				
			}
		}
		
		for( Country__c c : [SELECT Id, Name, Iso_Code__c FROM Country__c WHERE Iso_Code__c IN :countryIsoToPartners.keyset()]){
			for(Id aId : countryIsoToPartners.get(c.Iso_Code__c)){
				partnerCountries.add( new Partner_Country__c( 	Name = c.Name,
																Country__c = c.Id,
																Partner__c = aId ) );
			}
		}
		
		System.debug('partnerStrengths: ' + partnerStrengths);
		System.debug('partnerCountries: ' + partnerCountries);

		try{
			insert partnerStrengths;
			insert partnerCountries;
		} catch(DmlException e){
			System.debug('AccountTriggerHandler.createJunctionObjects: ' + e);
		}
		
	}
}