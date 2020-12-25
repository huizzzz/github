/********************************************************************************
 * クラス名 ： Quote_CreateByOpportunityClass
 * 概　　要 ： 新規見積(標準オブジェクト)ボタンのコントローラークラス
 * 作 成 日 ： 2020/01/07 MAMADA
 * 更 新 日 ：
 ********************************************************************************/
global class Quote_CreateByOpportunityClass {
        /*
    *コンストラクタ
    */
    public Quote_CreateByOpportunityClass(){}
       
    /*
    * 新規見積作成
    * @param String oid 案件のId
    * @return String 見積ID
    */
    @AuraEnabled
    webService static String quoteCreate(String oid){
        //データベースのセーブポイント作成
        Savepoint sp = Database.setSavepoint();
        String result;
        try{
            COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        	// 見積のレコードタイプ取得
        	Id quoteType = comTypeManager.getRecordTypeId( 'Quote', 'COWO_DX_Quote' );
            Quote quote = new Quote();
            quote.OpportunityId = oid;
            quote.Name = oid;
            quote.RecordTypeId = quoteType;
            // quote.Opportunity__c = oid;
            insert quote;
            result = String.valueOf(quote.Id);
            return result;
        }catch(Exception e){
            Database.rollback(sp);
            system.debug(e.getMessage());
            return '';
        }
    }
    
    /*
    * 「案件」から紐づく「引合/案件製品」中で製品マスタ更新フラグがtrueのものがあるか確認
    * 「案件」から紐づく「引合/案件製品」中で価格エントリが有効であるか確認
    * @param String oid 案件のId
    * @return boolean データ存在結果
    */
    @AuraEnabled
    webService static boolean getOpportunityLineItems(String oid){
        boolean result = false;
        boolean priceBookEntryErr = false;
        Id idVal = oid;
        // List<Opportunity> op = [SELECT Id, (SELECT Id, updateProductFlg__c FROM OpportunityLineItems WHERE updateProductFlg__c = true) 
        //                         FROM Opportunity WHERE Id = :idVal];
        List<Opportunity> op = [SELECT Id, (SELECT Id, PricebookEntry.isActive FROM OpportunityLineItems) 
                                FROM Opportunity 
                                WHERE Id = :idVal];
                                
        List<OpportunityLineItem> opItem = op[0].OpportunityLineItems;
        if(opItem.size() > 0){
            System.debug(' result:' + result);
            for(OpportunityLineItem oli : opItem){
                if(!priceBookEntryErr){
                    if(!oli.PricebookEntry.isActive){
                        priceBookEntryErr = true;
                    }
                }
            }
            if(priceBookEntryErr == false){
                System.debug(' result:' + result);
                result = true;
            }
        }
        System.debug(' result:' + result);
        System.debug(' priceBookEntryErr:' + priceBookEntryErr);
        return result;
    }

}