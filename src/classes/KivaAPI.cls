global class KivaAPI {

	/*************************
	 *		 CLASSES         *
	 *************************/
	public virtual class Response {
		
		public Paging paging { get; set; }
		
		//getAllRecords() ? to handle the pagination
		
	}
	

	public class Paging {
		
		public Integer page { get; set; }
		public Integer total { get; set; }
		public Integer page_size { get; set; }
		public Integer pages { get; set; }
		
	}
	

	/******************************
	 *		RESPONSE OBJECTS	  *
	 ******************************/
	public class PartnerResponse extends Response{
		
		public List<Partner> partners { get; set; }
		
		public PartnerResponse(){
		}
		
		public PartnerResponse(HttpResponse response){
			PartnerResponse r = (PartnerResponse)JSON.deserialize( response.getBody(), PartnerResponse.class);
			this.partners = r.partners;
			this.paging = r.paging;
		}
	}
	
	public class LenderResponse extends Response{
		
		public List<Lender> lenders { get; set; }
		
		public LenderResponse(){
		}
		
		public LenderResponse(HttpResponse response){
			LenderResponse r = (LenderResponse)JSON.deserialize( response.getBody(), LenderResponse.class );
			this.lenders = r.lenders;
			this.paging = r.paging;
		}
	}
	
	public class LoanResponse extends Response{
		public List<Loan> loans { get; set; }
		
		public LoanResponse(){
		}
		
		public LoanResponse(HttpResponse response) {
			LoanResponse r = (LoanResponse)JSON.deserialize( response.getBody(), LoanResponse.class );
			this.loans = r.loans;
			this.paging = r.paging;
		}
	}
	


	public class GeneralResponse extends Response{
		public List<Map<String,String>> partners { get; set; }
		
		public GeneralResponse(String recType){
			
			Type rType = Type.forName('KivaAPI.Partner');
			System.debug('this.recordType = ' + rType);
			this.partners = new List<Map<String,String>>();
			this.paging = new Paging();
		}
	}

		
		
		
	/********************************
	 *		LOCAL API OBJECTS		*
	 ********************************/
	 
	public class Lender {
		String lender_id { get; set; }
		String name { get; set; }
		Image image { get; set; }
		String whereabouts { get; set; }
		String country_code { get; set; }
		String uid { get; set; }
		String member_since { get; set; }
		String personal_url { get; set; }
		String occupation { get; set; }
		String loan_because { get; set; }
		String occupational_info { get; set; }
		Integer loan_count { get; set; }
		Integer invitee_count { get; set; }
	}
	
	public class Loan {
		Integer id { get; set; }
		String name { get; set; }
		Description description { get; set; }
		String status { get; set; }
		Integer funded_amount { get; set; }
		Integer basket_amount { get; set; }
		Image image { get; set; }
		String activity { get; set; }
		String sector { get; set; }
		String use { get; set; }
		Location location { get; set; }
		Integer partner_id { get; set; }
		String posted_date { get; set; }
		String planned_expiration_date { get; set; }
		Integer loan_amount { get; set; }
		Integer borrower_count { get; set; }
		Integer lender_count { get; set; }
		Integer bonus_credit_eligibility { get; set; }
	}
		
	public class Description{
		List<String> Languages { get; set; }
	}
	
	
	public class Partner {
		public Integer Id { get; set; }
		public String Name { get; set; }
		public String Status { get; set; }
		public String Rating { get; set; }
		public String Due_Diligence_Type { get; set; }
		public Image Image { get; set; }
		public DateTime Start_Date { get; set; }
		public List<Country> Countries { get; set; }		
		public String Delinquency_Rate { get; set; }
		public String Default_Rate { get; set; }
		public Double Total_Amount_Raised { get; set; }
		public Integer Loans_Posted { get; set; }
		public Double Portfolio_Yield { get; set; }
		public Double Profitability { get; set; }
		public String Delinquency_Rate_Note { get; set; }
		public String Default_Rate_Note { get; set; }
		public List<SocialPerformanceStrength> Social_Performance_Strengths { get; set; }
		public String Portfolio_Yield_Note { get; set; }
		public Boolean Charges_Fees_And_Interest { get; set; }
		public Double Loans_At_Risk_Rate { get; set; }
		public Double Currency_Exchange_Loss_Rate { get; set; }
		public String Url { get; set; }
        
        public Partner() {
            this.Social_Performance_Strengths = new List<SocialPerformanceStrength>();
            this.Countries = new List<Country>();
            this.Image = new Image();
        }
		
	}
	
	public class Image {
		public Integer id { get; set; }
		public Integer templateId { get; set; }
	}
	
	public class Country {
		public String Iso_Code { get; set; }
		public String Region { get; set; }
		public String Name { get; set; }
		public Location Location { get; set; }
        
        public Country() {
            this.Location = new Location();
        }
	}
	
	public class Geo {
		public String Level { get; set; }
		public String Pairs { get; set; }
		public String Type { get; set; }

	}
	
	public class Location {
		public Geo Geo { get; set; }
		String country_code { get; set; }
		String country { get; set; }
		String town { get; set; }
        
        public Location() {
            this.Geo = new Geo();
        }
	}
	
	
	public class SocialPerformanceStrength {
		public String Id { get; set; }
		public String Name { get; set; }
		public String Description { get; set; }
        
	}
	
}