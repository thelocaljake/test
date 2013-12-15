public class KivaImport {

	private static final String DELIMITER = ';';

	
	
	public static void importPartners(){
		List<KivaAPI.Partner> partners = new List<KivaAPI.Partner>();
		List<Account> accountsToUpsert = new List<Account>();
		Map<String, Country__c> countryMap = new Map<String, Country__c>();
		Map<Integer, Social_Performance_Strength__c> performanceStrengths = new Map<Integer, Social_Performance_Strength__c>();
		//countries
		//partner strengths
		
		String endpoint = KivaConnection__c.getValues( 'partners' ).Endpoint__c;
		KivaAPI.PartnerResponse pRes = new KivaAPI.PartnerResponse();
		Integer page = 1;
		
		System.debug('endpoint: ' + endpoint);
		
		do{
			String url = endpoint + '&page=' + String.valueOf(page);
			
			HttpRequest req = new HTTPRequest();
			req.setEndpoint( url );
			req.setMethod( 'GET' );
		
			Http http = new Http();
			HttpResponse res = http.send( req );
		
			String body = res.getBody();
			System.debug( 'res.getBody(): ' + body);
//			Map<String, Object> ppRes = (Map<String, Object>)JSON.deserializeUntyped( body );
			pRes = (KivaAPI.PartnerResponse)JSON.deserialize( body,KivaAPI.PartnerResponse.class );
		
			partners.addAll(pRes.partners);
			System.debug('partners: ' + partners);
			System.debug('partner: ' + partners[0]);
			for(KivaAPI.Partner p : partners ){
				accountWrapper a = new accountWrapper( p );
				
				for(Country__c c : a.countries){
					if(!countryMap.containsKey(c.iso_code__c)) countryMap.put(c.iso_code__c, c);				
				}
				
				for(Social_Performance_Strength__c s : a.partnerStrengths){
					if( !performanceStrengths.containsKey(Integer.valueOf(s.Id__c)) ) performanceStrengths.put(Integer.valueOf(s.Id__c), s);
				}
				
				accountsToUpsert.add(a.account);
				
			}
			
			page = pRes.paging.page + 1;
			
		} while( page <= pRes.paging.pages && pRes.paging.page < 11 );	//SF gov' limits to 10 callouts
		system.debug('accountsToUpdate.size(): ' + accountsToUpsert.size());
		system.debug('countryMap.size(): ' + countryMap.size());
		system.debug('performanceStrengths.size(): ' + performanceStrengths.size());
		system.debug('partners.size(): ' + partners.size());
		
		try{ 
			upsert performanceStrengths.values() Id__c;
			upsert countryMap.values() Iso_Code__c;
			
			upsert accountsToUpsert Partner_Id__c;
			
		} catch( DmlException e ) {
			System.debug('KivaImport.getPartners(): ' + e);
		}
	}
	
	
	
	public static List<KivaAPI.Lender> getLenders(){
		//TODO: only get those lenders added today
		
		List<KivaAPI.Lender> lenders = new List<KivaAPI.Lender>();
		
		String endpoint = KivaConnection__c.getValues('lenders').Endpoint__c;
		Integer page = 1;
		KivaAPI.LenderResponse response = new KivaAPI.LenderResponse();
		
		do{
			System.debug(' thisPage: '+ String.valueOf(page));
			String url = endpoint + '&page=' + String.valueOf(page);
			
			HttpRequest req = new HTTPRequest();
			req.setEndpoint( url );
			req.setMethod( 'GET' );
			
			HttpResponse res = (new Http()).send( req );
			
			response = new KivaAPI.LenderResponse( res );
			System.debug( 'response: ' + response );
			lenders.addAll( response.lenders );
			
			page = response.paging.page + 1;
			
			System.debug('lenders now: ' + lenders.size());
		} while( page <= response.paging.pages && response.paging.page < 10 );
		
		System.debug( 'lenders.size(): ' + lenders.size() );
		return lenders;
		
	}
	
	
	
	public static List<KivaAPI.Loan> getLoans(){
		//TODO: only get those whose posted date = today
		
		List<KivaAPI.Loan> loans = new List<KivaAPI.Loan>();

		String endpoint = KivaConnection__c.getValues('loans').Endpoint__c;
		Integer page = 1;
		KivaAPI.LoanResponse response = new KivaAPI.LoanResponse();
		
		do{
			System.debug(' thisPage: '+ String.valueOf(page));
			String url = endpoint + '&page=' + String.valueOf(page);
			
			HttpRequest req = new HTTPRequest();
			req.setEndpoint( url );
			req.setMethod( 'GET' );
			
			Http http = new Http();
			HttpResponse res = http.send( req );
			
			String body = res.getBody();
			System.debug( 'res.getBody(): ' + body );
			
			response = (KivaAPI.LoanResponse)JSON.deserialize( body, KivaAPI.LoanResponse.class );
			System.debug( 'response: ' + response );
			loans.addAll( response.loans );
			
			page = response.paging.page + 1;
			
			System.debug('loans now: ' + loans.size());
		} while( page <= response.paging.pages && response.paging.page < 10 );
		
		System.debug( 'loans.size(): ' + loans.size() );
		return loans;
		
		
		
	}




/*
	Local Representations
*/

	public class accountWrapper{
		public Account account { get; set; }
		public List<Country__c> countries { get; set; }
		public List<Social_Performance_Strength__c> partnerStrengths { get; set; }
		
		public accountWrapper( KivaAPI.Partner partner ){		
			this.countries = new List<Country__c>();
			this.partnerStrengths = new List<Social_Performance_Strength__c>();
			system.debug(partner.name);
			this.account = new Account( 	Partner_Id__c = partner.id,
											Name = partner.Name,
											Status__c = partner.status,
											Rating__c = partner.rating,
											Due_Diligence_Type__c = partner.due_diligence_type,
											Image_URL__c = generateImageUrl( partner.image ),
											Start_Date__c = partner.start_date,
											//have logic here to gather countries and country information, insert countries and partner country objects
											Country_Codes__c = generateCountryCodeList( partner.countries ),
											Delinquency_Rate__c = partner.delinquency_rate,
											Default_Rate__c = partner.default_rate,
											Total_Amount_Raised__c = partner.total_amount_raised,
											Loans_Posted__c = partner.loans_posted,
											PartnerStrength_Ids__c = generatePartnerStrengths(partner.social_performance_strengths),
											Portfolio_Yield__c = partner.portfolio_yield,
											Profitability__c = partner.profitability,
											//logic to gather social performance strengths and create partner strengths objects
											Delinquency_Rate_Note__c = partner.delinquency_rate_note,
											Default_Rate_Note__c = partner.default_rate_note,
											Portfolio_Yield_note__c = partner.portfolio_yield_note,
											Charges_Fees_And_Interest__c = partner.charges_fees_and_interest,
											Loans_At_Risk_Rate__c = partner.loans_at_risk_rate,
											Currency_Exchange_Loss_Rate__c = partner.currency_exchange_loss_rate,
											Website = partner.url
										);
										
										

			
		}
		
		private String generateImageURL( KivaAPI.Image i ) {
			if(i != null){
				String size = '200';
				
				return 'http://www.kiva.org/img/' + size + '/' + String.valueOf(i.Id) + '.jpg';
			} else {
				return null;
			}
		}
		
		private String generateCountryCodeList( List<KivaAPI.Country> partnerCountries ){
			if( partnerCountries != null ) {
				String temp = '';
				
				for( KivaAPI.Country c : partnerCountries ) {
					temp += c.iso_code + DELIMITER;
					
					this.countries.add( new Country__c(	Name = c.name,
														Iso_Code__c = c.iso_code,
														Region__c = c.region,
														Geo_Pairs__c = c.location.geo.pairs
		  							   					) );
				}
				
				return temp;
			} else {
				return null;
			}
		}
		
		private String generatePartnerStrengths( List<KivaAPI.SocialPerformanceStrength> partnerStrengths ){
			if( partnerStrengths != null ){
				String temp = '';
				
				for( KivaAPI.SocialPerformanceStrength s : partnerStrengths ){
					temp += s.Id + DELIMITER;
					
					this.partnerStrengths.add( new Social_Performance_Strength__c (	Name = s.name,
																						Id__c = s.id,
																						Description__c = s.description
																					) );
				}
				
				return temp;
			} else{
				return null;
			}
		}
	}
	
}