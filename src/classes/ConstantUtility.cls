/*
* Description: This class is all constant variables
* Author: Biswajeet
* Created Date: 08/Oct/2020
* Version:1.0.0 - Biswajeet - 08/Oct/2020 - Added Activity & Opportunity related constant variables
*/
public class ConstantUtility {
    //Case Status
    public static final STRING STATUS_NEW ='New';
    public static final STRING STATUS_IN_PROGRESS ='In Progress';
    public static final STRING ERRORMSG_CASE_NO_UNIT_SEL_PM_TER='Please select unit before changing the status of the case';
    public static final STRING APPROVAL_STATUS_APPROVED ='Approved';
    public static final STRING APPROVAL_STATUS_SUBMITTED ='Submitted for approval';    
    public static final STRING ERRORMSG_CASE_TYPE_CHANGE_ALLOW_ONCE='The case type can be changed only once';
    public static final STRING STATUS_IN_DOC_VERF='Documents Verification';
    
    public static final STRING EMAIL_SUPPORT ='Email Support';
    //Object Constants
    public static final STRING SOBJ_ACCOUNT= 'Account';
    public static final STRING SOBJ_CASE= 'Case';
    public static final STRING SOBJ_OPPORTUNITY= 'Opportunity';
    public static final STRING SOBJ_AgencyRegistration= 'Broker__c'; 
    
    public static final STRING SOBJ_Agent= 'Broker_Agents__c';
    public static final STRING SOBJ_BrokerProprietor= 'Broker_Proprietor__c';

    
    public static final STRING PARNTERPROFILE_Agent= 'Nakheel Broker Agent';
    public static final STRING PARNTERPROFILE_Admin= 'Nakheel Broker Admin';
    public static final STRING GUESTUSERPROFILE = 'Nakheel Broker Portal Profile';



    //Account Record Types
    public static final STRING RT_ACC_FOR_AMB= 'Person_Account_for_Ambassador';
    //Record Type Developer Name Constants
    
    public static final STRING DN_AGENT_OWNER='Agent_International_Owner_Partner';
    public static final STRING DN_AGENT_INTER_AUTHO='Agent_International_Authorized_Signatory';
    public static final STRING DN_AGENT_LOCAL_PARTNER=    'Agent_Local_Owner_Partner';
    public static final STRING DN_AGENT_LOCAL_AUTHO=    'Agent_Local_Authorized_Signatory';
    public static final STRING DN_OWNER_PARTNER= 'Owner_Partner_Shareholder';
    public static final STRING DN_AUTHO_SIGN= 'Authorized_Signatory';
    public static final STRING RT_AGENT_REP= 'Agent_Representative';

    public static final STRING DN_BROKER_ACC='Broker_Account';
    
    
    public static final STRING PLACE_OF_INCOPORATION='AE';
    public static final STRING CITY_OF_INCOPORATION='Dubai';
    //Added by Mamta
    public static final STRING REC_DocumentActionName= 'Broker Agreement';
    public static final STRING REC_DocumentExpireMetaName= 'Document_Expire_Notice';
    public static final STRING TSK_SUBJECT_DOCFOLLOWUP ='Document expiry Followup';
    public static final STRING TSK_DESC_DOCFOLLOWUP ='Please followup with replacement of new document ';
    //Document Matrix Developer Name
    public static final STRING NKHL_SHAREHOLDER_INTRNL ='NKHL_Shareholder_International';//Partner ShareHolder International
    public static final STRING NKHL_SHAREHOLDER_LOCAL_NONDUBAI ='NKHL_Shareholder_Local'; //Partner ShareHolder Local Non-Dubai
    public static final STRING NKHL_SHAREHOLDER_LOCAL_DUBAI ='NKHL_Shareholder_Local_Dubai'; //Partnet ShareHolder Local Dubai
    
    public static final STRING NKHL_AGENT_REP_INTRNL ='NKHL_Agent_International_representative'; //Agent Rep INTERNATIONAL
    public static final STRING NKHL_AGENT_REP_LOCAL_NONDUBAI ='NKHL_Agent_Local_representative'; //Agent Rep Local Non- Dubai

    public static final STRING NKHL_AGENT_REP_AGENT_LOCAL_DUBAI ='NKHL_Agent_Dubai_representative'; //Agent Rep with BROKER ACCESS AGENT-LOCAL DUBAI
    public static final STRING NKHL_AGENT_REP_ADMIN_LOCAL_DUBAI ='Admin_Dubai_representative'; //Agent Rep with BROKER ACCESS ADMIN-LOCAL DUBAI

    public static final STRING NKHL_AUTH_SIGNATORY_INTRNL ='Agent_International_Authorized_Signatory'; //Auth Signatory INTERNATIONAL
    public static final STRING NKHL_AUTH_SIGNATORY_LOCAL_NONDUBAI ='Agent_Local_Authorized_Signatory'; //Auth Signatory Local Non Dubai
    public static final STRING NKHL_AUTH_SIGNATORY_DUBAI ='Agent_Dubai_Authorized_Signatory'; //Auth Signatory Local
    
    public static final STRING LEAD_DOCACTION=  'Lead Proposal Document';  

    



    








    
    //Activity Constants    
    public static final STRING ACTIVITY_QUEUABLE_ACTION_UPDATE_STOP_EMAIL_NOTIFICATION = 'UPDATE_STOP_EMAIL_NOTIFICATION'; 
    public static final STRING ACTIVITY_TYPE_TASK = 'Task'; 
    public static final STRING ACTIVITY_TYPE_EVENT = 'Event';
    public static final STRING TASK_STATUS_OPEN = 'Open';
    public static final STRING TASK_STATUS_CLOSED = 'Closed';
    public static final STRING TASK_STATUS_COMPLETED = 'Completed';
    
    public static final STRING TASK_PRIORITY_NORMAL = 'Normal';
    
    public static final STRING CASE_STATUS_OPEN = 'Open';
    public static final STRING CASE_STATUS_CLOSED = 'Closed';
	public static final STRING CASE_STATUS_INPROGRESS = 'In Process';
	public static final STRING CASE_CHECK_IN_OUT_BY = 'QR Code';
    
    //document Types
    public static final STRING EMIRATES_ID_NATIONAL_ID = 'EMIRATES ID / National Id';
    public static final STRING PASSPORT = 'PASSPORT';
    public static final STRING EMIRATES_ID ='Emirates ID';
    public static final STRING VALID_PASSPORT = 'Customer’s Valid Passport Copy';
    public static final STRING DOC_SET_UP_RT ='Other_Document';
    public static final STRING DOC_DUPLICATION_ERROR ='Error: Selected document is already uploaded on the Account. Please upload different document';
   
        
    public static final STRING ACCOUNT_RT_PERSON_ACCOUNT = 'PersonAccount';
    public static final STRING ACCOUNT_RT_BUSINESS_ACCOUNT = 'Business_Account';
    public static final STRING ACCOUNT_RT_BROKER_ACCOUNT = 'Broker_Account';
    
    public static final STRING ACCOUNT_TYPE_OWNER = 'Owner';
    
    
    //Sharing settings
    public static final STRING SHARING_ROW_CAUSE_MANUAL = 'Manual';
    public static final STRING SHARING_ACCESS_LEVEL_READ = 'Read';
    public static final STRING SHARING_ACCESS_LEVEL_EDIT = 'Edit';
    
    // Broker Admin Status
    public static final STRING ADMIN_APPROVAL_STATUS_APPROVED = 'Approved';
    
    
    
    public static final STRING RECEIPT_APPROVAL_STATUS_APPROVED = 'Approved';
    public static final STRING RECEIPT_APPROVAL_STATUS_PENDING_FOR_APPROVAL = 'Pending For Approval';
    public static final STRING RECEIPT_APPROVAL_STATUS_REJECTED = 'Rejected';
    public static final STRING APP_SETTING_REPORT_EXPORT_PERMISSIONSET_ID = 'ReportExportPermissionSetId';

    public static final STRING AGREEMENT_IN_PROGRESS = 'Agreement in Process';
    public static final STRING SENT_FOR_SIGNATURE_TO_BROKER = 'Sent for signature to broker';
    public static final STRING AGENCY_REGISTRATION_TEMPLATE = 'Agency Registration Acknowledgement Approval Email';
    public static final STRING LEASING_TERMINATION_TEMPLATE = 'Lease Termination Email to Customers';
    
    public static final STRING LEASING_BOOKING_FORM = 'Opportunity-Booking Form';
    public static final STRING LEASING_PAYMENT_ADVICE = 'Payment Advice Email Template';
    public static final STRING LEASING_PAYMENT_RECEIPT = 'Payment Receipt Email Template';
    
    public static final STRING SIGNED_CONTRACT_EMAIL_TEMP = 'Signed Contract Email Template';
    public static final STRING CONTRACT_EMAIL_TEMP = 'Contract Document Leasing'; // Added By sajid
    
    public static final STRING MOVE_IN_FORM_EMAIL_TEMP = 'Move-In doc template'; // Added By sajid
    
    public static BOOLEAN EMAIL_TRIGGERED = false;
    
    public static final STRING LEASE_RENEWAL_EMAIL_ALERT = 'Lease_Renewal_App_Email_Alert';
    public static final STRING UNIT_CHANGE_EMAIL_ALERT = 'Unit_Change_Approval_Email_Alert';
    
    public static final Map<String, Integer> monthShortNameNumberMap = new Map<String, Integer>{
        'JAN'  => 1, 'FEB' => 2, 'MAR' => 3, 'APR' => 4, 'MAY' => 5, 'JUN' => 6,
            'JUL' => 7, 'AUG' => 8, 'SEP' => 9, 'OCT' => 10, 'NOV' => 11, 'DEC' => 12
            };
                public static String[] to_19 = new string[]{
                    'zero', 'one',  'two', 'three', 'four',  'five',  'six',  
                        'seven', 'eight', 'nine', 'ten',  'eleven', 'twelve', 'thirteen',  
                        'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'
                        };
                            public static String[] tens = new string[]{
                                'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'
                                    };
                                        public static String[] denom = new string[]{'',  
                                            'thousand', 'million', 'billion', 'trillion', 'quadrillion',  
                                            'quintillion', 's!xtillion', 'septillion',  'octillion', 'nonillion',  
                                            'decillion',  'undecillion', 'duodecillion', 'tredecillion', 'quattuordecillion',  
                                            's!xdecillion', 'septendecillion', 'octodecillion', 'novemdecillion', 'vigintillion' 
                                            };
                                                }