public class ERPAPIResponse {
    
    public OutputParameters OutputParameters {get;set;} 
    public ISGServiceFault ISGServiceFault {get; set;}
    
    public class OutputParameters {
        public String X_PROPERTY_ID {get;set;}
        public String X_LOCATION_ID {get;set;}
        public String X_ATTRIBUTE1 {get;set;}
        public String X_ADDRESS_ID {get;set;} 
        public String X_RETURN_STATUS {get;set;} 
        public String X_MSG_COUNT {get;set;} 
        public String X_MSG_DATA {get;set;}
        public X_BU_TABLE X_BU_TABLE {get;set;} 
        public String P_CASH_RECEIPT_ID {get;set;}
        public String P_RECEIPT_NUMBER {get;set;}
        public String P_DOCUMENT_SEQUENCE {get;set;}
        public X_HELPER_RESULT_TBL1 X_HELPER_RESULT_TBL1 {get;set;}
        public String LEASE_ID {get;set;}
        public String X_LEASE_NUMBER {get;set;}
        public String X_USER_ID {get;set;}
        public String P_OPPORTUNITY_ID {get;set;}
        public String X_CUSTOMER_TRX_ID {get;set;}
        public X_CUSTOMER_STATEMENT X_CUSTOMER_STATEMENT {get;set;}
        public String PX_CUST_ACCOUNT_ID {get;set;}
        public String PX_ACCOUNT_NUMBER {get;set;}
        public String X_CODE_ASSIGNMENT_ID {get;set;}
        public String P_FLAG_ID {get;set;}
        public X_UNAPPLIED_RECEIPTS X_UNAPPLIED_RECEIPTS {get;set;}


        public OutputParameters(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    //system.debug('@@text :'+text);
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'X_PROPERTY_ID') {
                            X_PROPERTY_ID = parser.getText();
                        } else if (text == 'X_LOCATION_ID') {
                            X_LOCATION_ID = parser.getText();
                        } else if (text == 'X_ADDRESS_ID') {
                            X_ADDRESS_ID = parser.getText();
                        } else if (text == 'X_RETURN_STATUS') {
                            X_RETURN_STATUS = parser.getText();
                        } else if (text == 'X_MSG_COUNT') {
                            X_MSG_COUNT = parser.getText();
                        } else if (text == 'X_MSG_DATA') {
                            X_MSG_DATA = parser.getText();
                        } else if (text == 'P_CASH_RECEIPT_ID') {
                            P_CASH_RECEIPT_ID = parser.getText();
                        } else if (text == 'P_RECEIPT_NUMBER') {
                            P_RECEIPT_NUMBER = parser.getText();
                        } else if (text == 'P_DOCUMENT_SEQUENCE') {
                            P_DOCUMENT_SEQUENCE = parser.getText();
                        } else if(text == 'LEASE_ID'){
                            LEASE_ID = parser.getText();
                        } else if(text == 'X_LEASE_NUMBER'){
                            X_LEASE_NUMBER = parser.getText();
                        } else if(text == 'X_USER_ID'){
                            X_USER_ID = parser.getText();
                        } else if(text == 'P_OPPORTUNITY_ID'){
                            P_OPPORTUNITY_ID = parser.getText();
                        } else if(text == 'X_CUSTOMER_TRX_ID'){
                            X_CUSTOMER_TRX_ID = parser.getText();
                        } else if(text == 'PX_CUST_ACCOUNT_ID'){
                            PX_CUST_ACCOUNT_ID = parser.getText();
                        } else if(text == 'PX_ACCOUNT_NUMBER'){
                            PX_ACCOUNT_NUMBER = parser.getText();
                        } else if(text == 'X_CODE_ASSIGNMENT_ID'){
                            X_CODE_ASSIGNMENT_ID = parser.getText();
                        } else if(text == 'P_FLAG_ID'){
                            P_FLAG_ID = parser.getText();
                        } else if(text == 'X_ATTRIBUTE1') {
                            X_ATTRIBUTE1 = parser.getText();
                        } else if (text == 'X_BU_TABLE') {
                            X_BU_TABLE = new X_BU_TABLE(parser);
                        } else if (text == 'X_HELPER_RESULT_TBL1') {
                            X_HELPER_RESULT_TBL1 = new X_HELPER_RESULT_TBL1(parser);
                        } else if (text == 'X_CUSTOMER_STATEMENT') {
                            X_CUSTOMER_STATEMENT = new X_CUSTOMER_STATEMENT(parser);
                        } else if (text == 'X_UNAPPLIED_RECEIPTS') {
                            X_UNAPPLIED_RECEIPTS = new X_UNAPPLIED_RECEIPTS(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'OutputParameters consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class X_BU_TABLE {
        public List<X_BU_TABLE_ITEM> X_BU_TABLE_ITEM {get;set;} 

        public X_BU_TABLE(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'X_BU_TABLE_ITEM') {
                            X_BU_TABLE_ITEM = arrayOfX_BU_TABLE_ITEM(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'X_BU_TABLE consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class X_BU_TABLE_ITEM {
        public String ORGANIZATION_ID {get;set;} 
        public String BUSINESS_GROUP_ID {get;set;} 
        public String ORGANIZATION_NAME {get;set;} 
        public String ORGANIZATION_TYPE {get;set;} 
        public String BU_CODE {get;set;} 
        public Object ATTRIBUTE1 {get;set;} 
        public Object ATTRIBUTE2 {get;set;} 
        public Object ATTRIBUTE3 {get;set;} 
        public Object ATTRIBUTE4 {get;set;} 
        public Object ATTRIBUTE5 {get;set;} 
        public Object ATTRIBUTE6 {get;set;} 
        public Object ATTRIBUTE7 {get;set;} 
        public Object ATTRIBUTE8 {get;set;} 
        public Object ATTRIBUTE9 {get;set;} 
        public Object ATTRIBUTE10 {get;set;} 
        public Object ATTRIBUTE11 {get;set;} 
        public Object ATTRIBUTE12 {get;set;} 
        public Object ATTRIBUTE13 {get;set;} 
        public Object ATTRIBUTE14 {get;set;} 
        public Object ATTRIBUTE15 {get;set;} 

        public X_BU_TABLE_ITEM(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'ORGANIZATION_ID') {
                            ORGANIZATION_ID = parser.getText();
                        } else if (text == 'BUSINESS_GROUP_ID') {
                            BUSINESS_GROUP_ID = parser.getText();
                        } else if (text == 'ORGANIZATION_NAME') {
                            ORGANIZATION_NAME = parser.getText();
                        } else if (text == 'ORGANIZATION_TYPE') {
                            ORGANIZATION_TYPE = parser.getText();
                        } else if (text == 'BU_CODE') {
                            BU_CODE = parser.getText();
                        } else if (text == 'ATTRIBUTE1') {
                            ATTRIBUTE1 = parser.getText();//parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE2') {
                            ATTRIBUTE2 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE3') {
                            ATTRIBUTE3 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE4') {
                            ATTRIBUTE4 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE5') {
                            ATTRIBUTE5 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE6') {
                            ATTRIBUTE6 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE7') {
                            ATTRIBUTE7 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE8') {
                            ATTRIBUTE8 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE9') {
                            ATTRIBUTE9 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE10') {
                            ATTRIBUTE10 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE11') {
                            ATTRIBUTE11 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE12') {
                            ATTRIBUTE12 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE13') {
                            ATTRIBUTE13 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE14') {
                            ATTRIBUTE14 = parser.getText(); //parser.readValueAs(Object.class);
                        } else if (text == 'ATTRIBUTE15') {
                            ATTRIBUTE15 = parser.getText(); //parser.readValueAs(Object.class);
                        } else {
                            System.debug(LoggingLevel.WARN, 'X_BU_TABLE_ITEM consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public ERPAPIResponse(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'OutputParameters') {
                        OutputParameters = new OutputParameters(parser);
                    }else if (text == 'ISGServiceFault') {
                        ISGServiceFault = new ISGServiceFault(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'ERPAPIResponse consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public static ERPAPIResponse parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new ERPAPIResponse(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    private static List<X_BU_TABLE_ITEM> arrayOfX_BU_TABLE_ITEM(System.JSONParser p) {
        List<X_BU_TABLE_ITEM> res = new List<X_BU_TABLE_ITEM>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new X_BU_TABLE_ITEM(p));
        }
        return res;
    }

    public class X_HELPER_RESULT_TBL1 {
        public List<X_HELPER_RESULT_TBL1_ITEM> X_HELPER_RESULT_TBL1_ITEM {get;set;} 

        public X_HELPER_RESULT_TBL1(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'X_HELPER_RESULT_TBL1_ITEM') {
                            X_HELPER_RESULT_TBL1_ITEM = arrayOfX_HELPER_RESULT_TBL1_ITEM(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'X_HELPER_RESULT_TBL1 consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    private static List<X_HELPER_RESULT_TBL1_ITEM> arrayOfX_HELPER_RESULT_TBL1_ITEM(System.JSONParser p) {
        List<X_HELPER_RESULT_TBL1_ITEM> res = new List<X_HELPER_RESULT_TBL1_ITEM>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new X_HELPER_RESULT_TBL1_ITEM(p));
        }
        return res;
    }

    public class X_HELPER_RESULT_TBL1_ITEM {
        public String X_ATTRIBUTE_CATEGORY {get;set;}
        public String X_ATTRIBUTE1 {get;set;}
        public String X_ATTRIBUTE2 {get;set;}
        public String X_ATTRIBUTE3 {get;set;}
        public String X_ATTRIBUTE4 {get;set;}
        public String X_ATTRIBUTE5 {get;set;}
        public String X_ATTRIBUTE6 {get;set;}
        public String X_ATTRIBUTE7 {get;set;}
        public String X_ATTRIBUTE8 {get;set;}
        public String X_ATTRIBUTE9 {get;set;}
        public String X_ATTRIBUTE10 {get;set;}
        public String X_ATTRIBUTE11 {get;set;}
        public String X_ATTRIBUTE12 {get;set;}
        public String X_ATTRIBUTE13 {get;set;}
        public String X_ATTRIBUTE14 {get;set;}
        public String X_ATTRIBUTE15 {get;set;}
    public X_HELPER_RESULT_TBL1_ITEM(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'X_ATTRIBUTE_CATEGORY') {
                        X_ATTRIBUTE_CATEGORY = parser.getText();
                    } else if (text == 'X_ATTRIBUTE1') {
                        X_ATTRIBUTE1 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE2') {
                        X_ATTRIBUTE2 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE3') {
                        X_ATTRIBUTE3 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE4') {
                        X_ATTRIBUTE4 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE5') {
                        X_ATTRIBUTE5 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE6') {
                        X_ATTRIBUTE6 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE7') {
                        X_ATTRIBUTE7 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE8') {
                        X_ATTRIBUTE8 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE9') {
                        X_ATTRIBUTE9 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE10') {
                        X_ATTRIBUTE10 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE11') {
                        X_ATTRIBUTE11 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE12') {
                        X_ATTRIBUTE12 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE13') {
                        X_ATTRIBUTE13 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE14') {
                        X_ATTRIBUTE14 = parser.getText();
                    } else if (text == 'X_ATTRIBUTE15') {
                        X_ATTRIBUTE15 = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'X_BU_TABLE_ITEM consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                    }
                }
            }
        }
    }

    public class X_CUSTOMER_STATEMENT {
        public List<X_CUSTOMER_STATEMENT_ITEM> X_CUSTOMER_STATEMENT_ITEM {get;set;} 

        public X_CUSTOMER_STATEMENT(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'X_CUSTOMER_STATEMENT_ITEM') {
                            X_CUSTOMER_STATEMENT_ITEM = arrayOfX_CUSTOMER_STATEMENT_ITEM(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'X_CUSTOMER_STATEMENT consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class X_UNAPPLIED_RECEIPTS {
        public List<X_UNAPPLIED_RECEIPTS_ITEM> X_UNAPPLIED_RECEIPTS_ITEM {get;set;} 

        public X_UNAPPLIED_RECEIPTS (JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'X_UNAPPLIED_RECEIPTS_ITEM') {
                            X_UNAPPLIED_RECEIPTS_ITEM = arrayOfUNAPPLIED_RECEIPTS_ITEM(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'X_UNAPPLIED_RECEIPTS consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    private static List<X_CUSTOMER_STATEMENT_ITEM> arrayOfX_CUSTOMER_STATEMENT_ITEM(System.JSONParser p) {
        List<X_CUSTOMER_STATEMENT_ITEM> res = new List<X_CUSTOMER_STATEMENT_ITEM>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new X_CUSTOMER_STATEMENT_ITEM(p));
        }
        return res;
    }

    private static List<X_UNAPPLIED_RECEIPTS_ITEM> arrayOfUNAPPLIED_RECEIPTS_ITEM(System.JSONParser p) {
        List<X_UNAPPLIED_RECEIPTS_ITEM> res = new List<X_UNAPPLIED_RECEIPTS_ITEM>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new X_UNAPPLIED_RECEIPTS_ITEM(p));
        }
        return res;
    }
    
    public class X_UNAPPLIED_RECEIPTS_ITEM {
        public String TRX_NUMBER {get;set;}
        public String TRX_DATE {get;set;}
        public String ACTUAL_AMOUNT {get;set;}
        public String RECEIPT_NUMBER {get;set;}
        public String RECEIPT_DATE {get;set;}
        public String RECEIPT_AMOUNT {get;set;}
        public String LEASE_ID {get;set;}
        public String CASH_RECEIPT_ID {get;set;}
        public String DOC_SEQUENCE_VALUE {get;set;}
        public String CURRENCY_CODE {get;set;}
        public String INV_CUR {get;set;}
        public String APPLIED_AMOUNT {get;set;}
        public String CHAR_TRX_DATE {get;set;}
        public String CHAR_RECEIPT_DATE {get;set;}
        public String DUE_DATE {get;set;}
        public String CUSTOMER_TRX_ID {get;set;}
        public String APPLICATION_TYPE {get;set;}
        public String MATCHED_CUSTOMER_TRX_ID {get;set;}
        public String MANUAL_DBT_CRT_MEMO {get;set;}
        public String COMMENTS {get;set;}
        public String PAYMENT_PURPOSE {get;set;}
        public String ATTRIBUTE_CATEGORY {get;set;}
        public String ATTRIBUTE1 {get;set;}
        public String ATTRIBUTE2 {get;set;}
        public String ATTRIBUTE3 {get;set;}
        public String ATTRIBUTE4 {get;set;}
        public String ATTRIBUTE5 {get;set;}
        public String ATTRIBUTE6 {get;set;}
        public String ATTRIBUTE7 {get;set;}
        public String ATTRIBUTE8 {get;set;}
        public String ATTRIBUTE9 {get;set;}
        public String ATTRIBUTE10 {get;set;}
        public String ATTRIBUTE11 {get;set;}
        public String ATTRIBUTE12 {get;set;}
        public String ATTRIBUTE13 {get;set;}
        public String ATTRIBUTE14 {get;set;}
        public String ATTRIBUTE15 {get;set;}
        
        public X_UNAPPLIED_RECEIPTS_ITEM(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'TRX_NUMBER') {
                            TRX_NUMBER = parser.getText();
                        } else if (text == 'TRX_DATE') {
                            TRX_DATE = parser.getText();
                        } else if (text == 'ACTUAL_AMOUNT') {
                            ACTUAL_AMOUNT = parser.getText();
                        } else if (text == 'RECEIPT_NUMBER') {
                            RECEIPT_NUMBER = parser.getText();
                        } else if (text == 'RECEIPT_DATE') {
                            RECEIPT_DATE = parser.getText();
                        } else if (text == 'RECEIPT_AMOUNT') {
                            RECEIPT_AMOUNT = parser.getText();
                        } else if (text == 'LEASE_ID') {
                            LEASE_ID = parser.getText();
                        } else if (text == 'CASH_RECEIPT_ID') {
                            CASH_RECEIPT_ID = parser.getText();
                        } else if (text == 'DOC_SEQUENCE_VALUE') {
                            DOC_SEQUENCE_VALUE = parser.getText();
                        } else if (text == 'CURRENCY_CODE') {
                            CURRENCY_CODE = parser.getText();
                        } else if (text == 'INV_CUR') {
                            INV_CUR = parser.getText();
                        } else if (text == 'APPLIED_AMOUNT') {
                            APPLIED_AMOUNT = parser.getText();
                        } else if (text == 'CHAR_TRX_DATE') {
                            CHAR_TRX_DATE = parser.getText();
                        } else if (text == 'CHAR_RECEIPT_DATE') {
                            CHAR_RECEIPT_DATE = parser.getText();
                        } else if (text == 'DUE_DATE') {
                            DUE_DATE = parser.getText();
                        } else if (text == 'CUSTOMER_TRX_ID') {
                            CUSTOMER_TRX_ID = parser.getText();
                        } else if (text == 'APPLICATION_TYPE') {
                            APPLICATION_TYPE = parser.getText();
                        } else if (text == 'MATCHED_CUSTOMER_TRX_ID') {
                            MATCHED_CUSTOMER_TRX_ID = parser.getText();
                        } else if (text == 'MANUAL_DBT_CRT_MEMO') {
                            MANUAL_DBT_CRT_MEMO = parser.getText();
                        } else if (text == 'COMMENTS') {
                            COMMENTS = parser.getText();
                        } else if (text == 'PAYMENT_PURPOSE') {
                            PAYMENT_PURPOSE = parser.getText();
                        } else if (text == 'ATTRIBUTE_CATEGORY') {
                            ATTRIBUTE_CATEGORY = parser.getText();
                        } else if (text == 'ATTRIBUTE1') {
                            ATTRIBUTE1 = parser.getText();
                        } else if (text == 'ATTRIBUTE2') {
                            ATTRIBUTE2 = parser.getText();
                        } else if (text == 'ATTRIBUTE3') {
                            ATTRIBUTE3 = parser.getText();
                        } else if (text == 'ATTRIBUTE4') {
                            ATTRIBUTE4 = parser.getText();
                        } else if (text == 'ATTRIBUTE5') {
                            ATTRIBUTE5 = parser.getText();
                        } else if (text == 'ATTRIBUTE6') {
                            ATTRIBUTE6 = parser.getText();
                        } else if (text == 'ATTRIBUTE7') {
                            ATTRIBUTE7 = parser.getText();
                        } else if (text == 'ATTRIBUTE8') {
                            ATTRIBUTE8 = parser.getText();
                        } else if (text == 'ATTRIBUTE9') {
                            ATTRIBUTE9 = parser.getText();
                        } else if (text == 'ATTRIBUTE10') {
                            ATTRIBUTE10 = parser.getText();
                        } else if (text == 'ATTRIBUTE11') {
                            ATTRIBUTE11 = parser.getText();
                        } else if (text == 'ATTRIBUTE12') {
                            ATTRIBUTE12 = parser.getText();
                        } else if (text == 'ATTRIBUTE13') {
                            ATTRIBUTE13 = parser.getText();
                        } else if (text == 'ATTRIBUTE14') {
                            ATTRIBUTE14 = parser.getText();
                        } else if (text == 'ATTRIBUTE15') {
                            ATTRIBUTE15 = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'X_UNAPPLIED_RECEIPTS_ITEM consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class X_CUSTOMER_STATEMENT_ITEM {
        public String SEQ {get;set;}
        public String PAYMENT_SCHEDULE_ID {get;set;}
        public String TRX_DATE {get;set;}
        public String ACTUAL_AMOUNT {get;set;}
        public String SCHEDULE_DATE {get;set;}
        public String PAYMENT_TYPE {get;set;}
        public String AR_INVOICE_NUMBER {get;set;}
        public String INVOICE_DATE {get;set;}
        public String INVOICE_TYPE {get;set;}
        public String AMOUNT_DUE_ORIGINAL {get;set;}
        public String AMOUNT_APPLIED {get;set;}
        public String AMOUNT_CREDITED {get;set;}
        public String NET_OUTSTANDING {get;set;}
        public String DUE_DAYS {get;set;}
        public String CUSTOMER_TRX_ID {get;set;}
        public String CURRENCY1 {get;set;}
        public String INVOICE {get;set;}
        public String TRX_NUMBER {get;set;}
        public String LEASE_ID {get;set;}
        public String LOCATION_ID {get;set;}
        public String PAYMENT_PURPOSE {get;set;}
        public String RECEIPT_AMOUNT {get;set;}
        public String RECEIPT {get;set;}
        public String RECEIPT_DATE {get;set;}
        public String DOC_SEQUENCE_VALUE {get;set;}
        public String ATTRIBUTE1 {get;set;}
        public String ATTRIBUTE2 {get;set;}
        public String ATTRIBUTE3 {get;set;}
        public String ATTRIBUTE4 {get;set;}
        public String ATTRIBUTE5 {get;set;}
        public String ATTRIBUTE6 {get;set;}
        public String ATTRIBUTE7 {get;set;}
        public String ATTRIBUTE8 {get;set;}
        public String ATTRIBUTE9 {get;set;}
        public String ATTRIBUTE10 {get;set;}
        public String ATTRIBUTE11 {get;set;}
        public String ATTRIBUTE12 {get;set;}
        public String ATTRIBUTE13 {get;set;}
        public String ATTRIBUTE14 {get;set;}
        public String ATTRIBUTE15 {get;set;}
        public X_CUSTOMER_STATEMENT_ITEM(){}
        
        public X_CUSTOMER_STATEMENT_ITEM(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'SEQ') {
                        SEQ = parser.getText();
                    } else if (text == 'PAYMENT_SCHEDULE_ID') {
                        PAYMENT_SCHEDULE_ID = parser.getText();
                    } else if (text == 'TRX_DATE') {
                        TRX_DATE = parser.getText();
                    }else if (text == 'ACTUAL_AMOUNT') {
                        ACTUAL_AMOUNT = parser.getText();
                    }else if (text == 'SCHEDULE_DATE') {
                        SCHEDULE_DATE = parser.getText();
                    }else if (text == 'PAYMENT_TYPE') {
                        PAYMENT_TYPE = parser.getText();
                    }else if (text == 'AR_INVOICE_NUMBER') {
                        AR_INVOICE_NUMBER = parser.getText();
                    }else if (text == 'INVOICE_DATE') {
                        INVOICE_DATE = parser.getText();
                    }else if (text == 'INVOICE_TYPE') {
                        INVOICE_TYPE = parser.getText();
                    }else if (text == 'AMOUNT_DUE_ORIGINAL') {
                        AMOUNT_DUE_ORIGINAL = parser.getText();
                    } else if (text == 'AMOUNT_APPLIED') {
                        AMOUNT_APPLIED = parser.getText();
                    } else if (text == 'AMOUNT_CREDITED') {
                        AMOUNT_CREDITED = parser.getText();
                    }else if (text == 'NET_OUTSTANDING') {
                        NET_OUTSTANDING = parser.getText();
                    }else if (text == 'DUE_DAYS') {
                        DUE_DAYS = parser.getText();
                    }else if (text == 'CUSTOMER_TRX_ID') {
                        CUSTOMER_TRX_ID = parser.getText();
                    } else if (text == 'INVOICE') {
                        INVOICE = parser.getText();
                    }else if (text == 'TRX_NUMBER') {
                        TRX_NUMBER = parser.getText();
                    } else if (text == 'LEASE_ID') {
                        LEASE_ID = parser.getText();
                    } else if (text == 'LOCATION_ID') {
                        LOCATION_ID = parser.getText();
                    } else if (text == 'PAYMENT_PURPOSE') {
                        PAYMENT_PURPOSE = parser.getText();
                    } else if (text == 'RECEIPT_AMOUNT') {
                        RECEIPT_AMOUNT = parser.getText();
                    } else if (text == 'RECEIPT') {
                        RECEIPT = parser.getText();
                    } else if (text == 'RECEIPT_DATE') {
                        RECEIPT_DATE = parser.getText();
                    } else if (text == 'DOC_SEQUENCE_VALUE') {
                        DOC_SEQUENCE_VALUE = parser.getText();
                    } else if (text == 'ATTRIBUTE1') {
                        ATTRIBUTE1 = parser.getText();
                    }else if (text == 'ATTRIBUTE2') {
                        ATTRIBUTE2 = parser.getText();
                    } else if (text == 'ATTRIBUTE3') {
                        ATTRIBUTE3 = parser.getText();
                    } else if (text == 'ATTRIBUTE4') {
                        ATTRIBUTE4 = parser.getText();
                    } else if (text == 'ATTRIBUTE5') {
                        ATTRIBUTE5 = parser.getText();
                    } else if (text == 'ATTRIBUTE6') {
                        ATTRIBUTE6 = parser.getText();
                    } else if (text == 'ATTRIBUTE7') {
                        ATTRIBUTE7 = parser.getText();
                    } else if (text == 'ATTRIBUTE8') {
                        ATTRIBUTE8 = parser.getText();
                    } else if (text == 'ATTRIBUTE9') {
                        ATTRIBUTE9 = parser.getText();
                    } else if (text == 'ATTRIBUTE10') {
                        ATTRIBUTE10 = parser.getText();
                    } else if (text == 'ATTRIBUTE11') {
                        ATTRIBUTE11 = parser.getText();
                    } else if (text == 'ATTRIBUTE12') {
                        ATTRIBUTE12 = parser.getText();
                    } else if (text == 'ATTRIBUTE13') {
                        ATTRIBUTE13 = parser.getText();
                    } else if (text == 'ATTRIBUTE14') {
                        ATTRIBUTE14 = parser.getText();
                    } else if (text == 'ATTRIBUTE15') {
                        ATTRIBUTE15 = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'X_CUSTOMER_STATEMENT_ITEM consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                    }
                }
            }
        }
    }
    //Added by Karishma to capture error messages
    public class ISGServiceFault{
        public String Code {get;set;}
        public String Message {get;set;}
        public String Resolution {get; set;}
        public ServiceDetails ServiceDetails {get;set;}
        public ISGServiceFault(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    //system.debug('@@text :'+text);
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Message') {
                            Message = parser.getText();
                        } else if(text == 'Code'){
                            Code = parser.getText();
                        } else if(text == 'Resolution'){
                            Resolution = parser.getText();
                        } else if (text == 'ServiceDetails') {
                            ServiceDetails = new ServiceDetails(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'ISGServiceFault consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class ServiceDetails {
        public String ServiceName {get;set;}
        public String OperationName {get;set;}
        public String InstanceId {get;set;}

        public ServiceDetails(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'ServiceName') {
                            ServiceName = parser.getText();
                        }else if (text == 'OperationName') {
                            OperationName = parser.getText();
                        }else if (text == 'InstanceId') {
                            InstanceId = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'ServiceDetails consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

}