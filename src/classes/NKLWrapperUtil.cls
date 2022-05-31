public class NKLWrapperUtil {
    public class SendEmailWrapper{
        public string emailTemplateName {get;set;}
        public string emailTemplateId {get;set;}
        public string whatId {get;set;}
        public string whoId {get;set;}
        public List<String> additionalEmailAddresses {get;set;}
        public string replyTo {get;set;}
        public string senderDisplayName {get;set;}
        public string orgWideAddress {get;set;}
        public boolean setTargetAsRecipient {get;set;}
    }
    public class TaskWrapper{
        public string relatedTo {get;set;}
        public string currencyIsoCode {get;set;}
        public string priority {get;set;}
        public string status {get;set;}
        public string subject {get;set;}
        public string description {get;set;}
        public string fieldUpdate {get;set;}
        public String assignedTo {get;set;}
        public Date dueDate {get;set;}
    }
    public class OptionsWrapper{
        public Set<Id> allUnitIds                       {get;set;}
        public Set<Id> setUnitIdsColorOption            {get;set;}
        public Set<Id> setUnitIdsForPentHouseTrue       {get;set;}
        public Set<Id> setUnitIdsForPentHouseFalse      {get;set;}
        public Set<Id> setUnitIdsForSwimmingPoolTrue    {get;set;}
        public Set<Id> setUnitIdsForSwimmingPoolFalse   {get;set;}
        public Set<Id> setUnitIdsForMaidRoomTrue        {get;set;}
        public Set<Id> setUnitIdsForMaidRoomFalse       {get;set;}
        public Set<Id> setUnitIdsForWatchmanRoomTrue    {get;set;}
        public Set<Id> setUnitIdsForWatchmanRoomFalse   {get;set;}
    }
}