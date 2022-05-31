/**
* Created by waqasali on 22/03/2022.
*/

public without sharing class ERPIntegrationHelper {
    
    /*Method: projectCreation
    * Desc: ERP Project Creation API call handler
    * Param: projectIds - Set of Project Id 
    * Return: None
    */ 
    public Static void projectCreation(Set<Id> projectIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_PROJECT, 
                                                                 ERPUtilities.API_NAME_PROJECT_CREATION, 
                                                                 ERPUtilities.PROJECT_CREATION_JSON_HEAD, 
                                                                 projectIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createBuilding
    * Desc:  Create Bulding in ERP Handler
    * Param: Building - Set of Building Ids
    * Return: None
    */
    public Static void createBuilding(Set<Id> buildingIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_BUILDING, 
                                                                 ERPUtilities.API_NAME_BUILDING_CREATION,
                                                                 ERPUtilities.BUILDING_CREATION_JSON_HEAD, 
                                                                 buildingIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createFloor
    * Desc:  Create Floor in ERP Handler
    * Param: Floor - Set of Floor Ids
    * Return: None
    */
    public Static void createFloor(Set<Id> floorIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_FLOOR, 
                                                                 ERPUtilities.API_NAME_FLOOR_CREATION,
                                                                 ERPUtilities.FLOOR_CREATION_JSON_HEAD,
                                                                 floorIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createMasterCommunity
    * Desc:  Create Master Community in ERP Handler
    * Param: Master Community - Set of MasterCommunity Ids
    * Return: None
    */
    public Static void createMasterCommunity(Set<Id> masterCommIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_MASTERCOMMUNITY, 
                                                                 ERPUtilities.API_NAME_MASTERCOMMUNITY_CREATION,
                                                                 ERPUtilities.MASTCOMMUNITY_CREATION_JSON_HEAD,
                                                                 masterCommIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createUnit
    * Desc:  Create Unit in ERP Handler
    * Param: Unit - Set of Unit Ids
    * Return: None
    */
    public Static void createUnit(Set<Id> unitIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_UNIT, 
                                                                 ERPUtilities.API_NAME_UNIT_CREATION, 
                                                                 ERPUtilities.UNIT_CREATION_JSON_HEAD,
                                                                 unitIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createCustomer
    * Desc:  Create Customer in ERP Handler
    * Param: Account - Set of Acccount Ids
    * Return: None
    */
    public Static void createCustomer(Set<Id> accountId) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_ACCOUNT, 
                                                                 ERPUtilities.API_NAME_CUSTOMER_CREATION, 
                                                                 ERPUtilities.CUSTOMER_CREATION_JSON_HEAD,
                                                                 accountId);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createReceipt
    * Desc:  Create Receipt in ERP Handler
    * Param: Receipt - Set of receipt Ids
    * Return: None
    * Author: Vishal A
    */
    public Static void createReceipt(Set<Id> receiptIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_RECEIPT, 
                                                                 ERPUtilities.API_NAME_RECEIPT_CREATION, 
                                                                 ERPUtilities.RECEIPT_CREATION_JSON_HEAD,
                                                                 receiptIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createOpportunities
    * Desc:  created opportunities  in ERP
    * Param: Set of Opportunity IDs
    * Return: None
    * Author: Vishal 
    */
    public static void createOpportunities(Set<Id> opportunityIds){
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_OPPORTUNITY, 
                                                                 ERPUtilities.API_NAME_OPPORTUNITY_CREATION, 
                                                                 ERPUtilities.OPPORTUNITY_CREATION_JSON_HEAD,
                                                                 opportunityIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createInvoices
    * Desc:  Create Invoice  in ERP
    * Param: Set of Invoice IDs
    * Return: None
    * Author: Vishal 
    */
    public static void createInvoices(Set<Id> invoiceIds){
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_INVOICE, 
                                                                 ERPUtilities.API_NAME_INVOICE_CREATION, 
                                                                 ERPUtilities.CREATE_INVOICE_JSON_HEAD,
                                                                 invoiceIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: getUserDetails
    * Desc:  get user info from ERP
    * Param: employeeId - Set of User Ids
    * Return: None
    * Author: Vishal Agrawal
    */
    public Static void getUserDetails(Set<Id> employeeId) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_USER, 
                                                                 ERPUtilities.API_NAME_USER_CREATION, 
                                                                 ERPUtilities.GET_USER_INFO_JSON_HEAD,
                                                                 employeeId);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
     /*Method: createSalesSO
    * Desc:  Send Agreement as SO to ERP
    * Param: agreementIds - Set of Agreement Ids
    * Return: None
    * Author: Vishal Agrawal
    */
    public Static void createSalesSO(Set<Id> agreementIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_AGREEMENT, 
                                                                 ERPUtilities.API_NAME_SALES_SO_CREATION, 
                                                                 ERPUtilities.SALE_LEAS_SO_CREATION_JSON_HEAD,
                                                                 agreementIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    /*Method: createLeasingSO
    * Desc:  Send Agreement as SO to ERP
    * Param: leasContractIds - Set of lease contract Ids
    * Return: None
    * Author: Vishal Agrawal
    */
    public Static void createLeasingSO(Set<Id> leasContractIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_LEASE_CONTRACT, 
                                                                 ERPUtilities.API_NAME_LEASING_SO_CREATION, 
                                                                 ERPUtilities.SALE_LEAS_SO_CREATION_JSON_HEAD,
                                                                 leasContractIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createBillingLine
    * Desc:  Send Billing Line to ERP
    * Param: paymentMileStoneId - Set of Payment MileStone Ids
    * Return: None
    * Author: Vishal Agrawal
    */
    public Static void createBillingLine(Set<Id> paymentMileStoneId) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_PAYMENTMILESTONE, 
                                                                 ERPUtilities.API_NAME_BILL_LINE_CREATION, 
                                                                 ERPUtilities.BILLINGLINE_CREATE_JSON_HEAD,
                                                                 paymentMileStoneId);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: unappliedReceipt
    * Desc:  Send Unapplied Receipt to ERP
    * Param: receiptIds - Set of Payment MileStone Ids
    * Return: None
    * Author: Vishal Agrawal
    */
    public Static void unappliedReceipt(Set<Id> receiptIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_RECEIPT, 
                                                                 ERPUtilities.API_NAME_UNAPPLIED_RECEIPT, 
                                                                 ERPUtilities.UNAPPLIED_RECEIPT_JSON_HEAD,
                                                                 receiptIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createCreditMemo
    * Desc:  Create Credit Memo in ERP
    * Param: Set of Credit Memo IDs
    * Return: None
    * Author: Vishal A
    */
    public static void createCreditMemo(Set<Id> creditIds){
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_CREDITMEMO, 
                                                                 ERPUtilities.API_NAME_CREDIT_MEMO_CREATION, 
                                                                 ERPUtilities.CREDITMEMO_CREATE_JSON_HEAD,
                                                                 creditIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createRefundERP
    * Desc:  Create Refund in ERP Handler
    * Param: Receipt refund - Set of receipt refund Ids
    * Return: None
    * Author: Vishal A
    */
    public Static void createRefundERP(Set<Id> receiptIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_RECEIPTREFUND, 
                                                                 ERPUtilities.API_NAME_REFUND, 
                                                                 ERPUtilities.REFUND_CREATE_JSON_HEAD,
                                                                 receiptIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createReceiptReversal
    * Desc:  Create Receipt reversal in ERP Handler
    * Param: Receipt - Set of receipt Ids
    * Return: None
    * Author: Vishal A
    */
    public Static void createReceiptReversal(Set<Id> receiptIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_RECEIPT, 
                                                                 ERPUtilities.API_NAME_RECEIPT_REVERSAL, 
                                                                 ERPUtilities.REVERSE_RECEIPT_JSON_HEAD,
                                                                 receiptIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createFlagUnit
    * Desc:  Create Flag Unit in ERP Handler
    * Param: Flag - Set of Flag Ids
    * Return: None
    * Author: Vishal A
    */
    public Static void createFlagUnit(Set<Id> flagIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_FLAG, 
                                                                 ERPUtilities.API_NAME_FLAG_UNIT, 
                                                                 ERPUtilities.FLAG_UNIT_JSON_HEAD,
                                                                 flagIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createFlagCustomer
    * Desc:  Create Flag Customer in ERP Handler
    * Param: Flag - Set of Flag Ids
    * Return: None
    * Author: Vishal A
    */
    public Static void createFlagCustomer(Set<Id> flagIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_FLAG, 
                                                                 ERPUtilities.API_NAME_FLAG_CUSTOMER, 
                                                                 ERPUtilities.FLAG_CUSTOMER_JSON_HEAD,
                                                                 flagIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createUNFlagUnit
    * Desc:  UNFlag Unit in ERP Handler
    * Param: Flag - Set of Flag Ids
    * Return: None
    * Author: Vishal A
    */
    public Static void createUNFlagUnit(Set<Id> flagIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_FLAG, 
                                                                 ERPUtilities.API_NAME_UNFLAG_UNIT, 
                                                                 ERPUtilities.UNFLAG_UNIT_JSON_HEAD,
                                                                 flagIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: createUNFlagCustomer
    * Desc:  UNFlag Customer in ERP Handler
    * Param: Flag - Set of Flag Ids
    * Return: None
    * Author: Vishal A
    */
    public Static void createUNFlagCustomer(Set<Id> flagIds) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_FLAG, 
                                                                 ERPUtilities.API_NAME_UNFLAG_CUSTOMER, 
                                                                 ERPUtilities.UNFLAG_CUSTOMER_JSON_HEAD,
                                                                 flagIds);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: spaTermination
    * Desc:  Terminate SPA in ERP
    * Param: SPA- Set of Agreement Ids
    * Return: None
    * Author: Vishal A
    */
    public Static void spaTermination(Set<Id> agreementId) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_AGREEMENT, 
                                                                 ERPUtilities.API_NAME_SO_TERMINATION, 
                                                                 ERPUtilities.TERMINATE_CONTRACT_JSON_HEAD,
                                                                 agreementId);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
    
    /*Method: contractTermination
    * Desc:  Terminate contract in ERP
    * Param:  Set of contract Ids
    * Return: None
    * Author: Vishal A
    */
    public Static void contractTermination(Set<Id> contractId) {
        BatchCommonERPAPI batchRef = new BatchCommonERPAPI(ERPUtilities.OBJECT_NAME_LEASE_CONTRACT, 
                                                                 ERPUtilities.API_NAME_SO_TERMINATION, 
                                                                 ERPUtilities.TERMINATE_CONTRACT_JSON_HEAD,
                                                                 contractId);
        Database.executeBatch(batchRef, ERPUtilities.BATCH_SIZE_COMMON_APIS);
    }
}