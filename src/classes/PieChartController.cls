public class PieChartController {
    public List<PieWedgeData> getPieData() {
        ID calID = apexpages.currentpage(). getparameters(). get('id');
        Calling_List__c cl =[select id,deal__c,unit__c  from Calling_List__c WHERE ID=:calID ];
        List<Payment_MIlestone__c> pms =[select id,Amount__c ,Payment_Status__c   from Payment_MIlestone__c where Opportunity__c  =:cl.Deal__c];
        Decimal ttlAmt = 0;
        Decimal paidAmt= 0;
        Decimal unpiadAmt =0;
        for(Payment_MIlestone__c pm:pms){
            ttlAmt+= pm.Amount__c;
            if(pm.Payment_Status__c=='Paid'){
                paidAmt += pm.Amount__c;
            }
            else {
                unpiadAmt+= pm.Amount__c;
                
            }

            
        }
        
        system.debug('paidAmt is '+ paidAmt);
         system.debug('unpiadAmt is '+ unpiadAmt);
        
        String paidPrcnt = String.valueof((paidAmt/ttlAmt)*100) + ' %';
        String unpiadPrcnt=   String.valueof(100 - ((paidAmt/ttlAmt)*100) ) + ' %';
        
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Paid', 80));
        data.add(new PieWedgeData('Unpaid', 20));
        /*data.add(new PieWedgeData('Mar', 10));
        data.add(new PieWedgeData('Apr', 20));
        data.add(new PieWedgeData('May', 20));
        data.add(new PieWedgeData('Jun', 5));*/
        return data;
    }

    // Wrapper class
    public class PieWedgeData {

        public String name { get; set; }
        public Decimal data { get; set; }

        public PieWedgeData(String name, Decimal data) {
            this.name = name;
            this.data = data;
        }
    }
}