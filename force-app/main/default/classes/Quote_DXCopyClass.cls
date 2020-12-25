/********************************************************************************
 * クラス名 ： Quote_DXCopyClass
 * 概　　要 ： 見積のコピーボタンから呼ばれるクラス
 *             見積、見積品目名、見積帳票明細オブジェクトのコピーを行う
 * 作 成 日 ： 2020/01/28 sakamoto
 * 更 新 日 ：
 ********************************************************************************/

global class Quote_DXCopyClass {
    
   /*
    *コンストラクタ
    */
    public Quote_DXCopyClass(){}
    
    /**
     * webservice String copyQuote()
     * 見積、見積品目名、見積帳票明細オブジェクトのコピーを行う。
     * isUpdatePriceがTrueの場合には価格表より価格の更新を行う。
     * @param ID targetQuoteId コピー元の見積ID
     * @param Boolean isUpdatePrice 価格更新フラグ
     * @return String
     * 正常終了 -> 作成された見積のId 異常終了 -> 'false'を返却
     */
    @AuraEnabled
    webService static String copyQuote(Id targetQuoteId,Boolean isUpdatePrice){
        // セーブポイント設定
        SavePoint sp = Database.setSavePoint();
        String result = 'false';
        
        // 項目取得のSOQL作成
        String queryStringQuote = 'SELECT\t';
        queryStringQuote += getFieldsNameStr(targetQuoteId.getSObjectType());
        queryStringQuote += '\tFROM Quote where ID = :targetQuoteId';
        
        // 見積品目名のスキーマ情報取得、クエリ文字列に追加
        String queryStringQuoteLineItem = 'SELECT\tProduct2.Name,\t';
        queryStringQuoteLineItem += getFieldsNameStr(Schema.QuoteLineItem.getSObjectType());
        queryStringQuoteLineItem += '\tFROM QuoteLineItem where QuoteId = :targetQuoteId';
        queryStringQuoteLineItem += '\tORDER BY COWO_SortNo__c';
            
        // 見積帳票明細のスキーマ情報取得、クエリ文字列に追加
        String queryStringCOWO_QuoteLineItem = 'SELECT\t';
        queryStringCOWO_QuoteLineItem += getFieldsNameStr(Schema.COWO_QuoteLineItem__c.getSObjectType());
        queryStringCOWO_QuoteLineItem += '\tFROM COWO_QuoteLineItem__c where COWO_Quote__c = :targetQuoteId';
        queryStringCOWO_QuoteLineItem += '\tORDER BY COWO_SortNo__c';

        system.debug(queryStringQuote);
        system.debug(queryStringQuoteLineItem);
        system.debug(queryStringCOWO_QuoteLineItem);

   	    try{
            Quote copyFromQuote = Database.query(queryStringQuote);
            Quote copyToQuote   = copyFromQuote.clone();
            
            List<QuoteLineItem> copyFromQuoteLineItemList = Database.query(queryStringQuoteLineItem);
            List<COWO_QuoteLineItem__c> copyFromCOWO_QuoteLineItemList = Database.query(queryStringCOWO_QuoteLineItem);
            
            //項目の初期化
            copyToQuote.Name += '_copy';
            copyToQuote.Status	= null;
            copyToQuote.COWO_QuoteNumber__c = null;
			copyToQuote.COWO_Customer_Presented_Quote__c = false;
		    copyToQuote.COWO_Customer_Adopted_Quote__c = false;
            copyToQuote.COWO_Authorizer1__c	= null;
            copyToQuote.COWO_Authorizer2__c	= null;
            copyToQuote.COWO_ApprovalDate1__c = null;
            copyToQuote.COWO_ApprovalDate2__c = null;
            copyToQuote.COWO_Imprint1__c	= null;
            copyToQuote.COWO_Imprint2__c	= null;
            copyToQuote.COWO_Imprint3__c	= null;
            copyToQuote.COWO_Approval_Status__c	= null;
            copyToQuote.COWO_ApprovalSkipFlag__c	= false;
            copyToQuote.COWO_ApprovalStartFlag__c	= false;
            copyToQuote.COWO_Quote_Create_Date__c	= date.today();
            copyToQuote.COWO_FollowApproval__c = False;
            copyToQuote.COWO_FollowApprover__c = null;
            copyToQuote.COWO_FollowApprovalDate__c = null;
            copyToQuote.COWO_Circulation__c = 1;
            copyToQuote.OwnerId = System.UserInfo.getUserId();//担当者をコピー実施者へ変更
            copyToQuote.COWO_CopyFlag__c    = True; //コピー機能で作成された見積のフラグ　Trueの場合AfterInsertトリガが起動しない
            
            //見積のインサート
            insert copyToQuote;
            
            //価格表エントリ情報取得
            Map<String,PriceBookEntry> priceBookEntryMap;
            Map<String,Product2> product2Map;
            if(isUpdatePrice){
                // 価格表から更新する場合、見積品目名の価格表エントリIDから価格表エントリを取得する。
                Set<Id> priceBookEntryIdSet = new Set<Id>();
                Set<Id> productIdSet = new Set<Id>();
                for(QuoteLineItem copyFromQuoteLineItem:copyFromQuoteLineItemList){
                    priceBookEntryIdSet.add(copyFromQuoteLineItem.PriceBookEntryId); //Todo 一旦仕様確定までは商品から取得する様にする。
                    productIdSet.add(copyFromQuoteLineItem.Product2Id);
                }
                //価格表エントリより項目を取得する。
                priceBookEntryMap = new Map<String,PriceBookEntry>
                    ([select id,UnitPrice,COWO_MC__c,COWO_TC__c,COWO_FrontPurchasePrice__c,COWO_LocalCorporationTC__c from PriceBookEntry where id in :priceBookEntryIdSet]);
                product2Map = new Map<String,Product2>//Todo 一旦仕様確定までは商品から取得する様にする。
                    ([select id,MC__c,TC__c from Product2 where id in :productIdSet]);
                System.debug(product2Map);
            }
            
            // Insertした見積と見積品目名の紐づけ
            List<QuoteLineItem> copyToQuoteLineItemList = new List<QuoteLineItem>();
            for(QuoteLineItem copyFromQuoteLineItem:copyFromQuoteLineItemList){
            	QuoteLineItem copyToQuoteLineItem = copyFromQuoteLineItem.clone();
                copyToQuoteLineItem.QuoteId = copyToQuote.Id;
                
                if(isUpdatePrice && copyToQuoteLineItem.Product2.Name != System.Label.AP00_CONST_0001 ){ // 現在の価格表の価格で見積の価格を更新する場合の処理
                	//いいえを選択された場合または自由入力商品については価格の更新を行わない
                	priceBookEntry pbe = priceBookEntryMap.get(copyToQuoteLineItem.PricebookEntryId);
                    Product2 pro = product2Map.get(copyToQuoteLineItem.Product2Id);//Todo 一旦仕様確定までは商品から取得する様にする。
                	system.debug(pbe);
                	if(pbe != null){
						//価格表エントリから値を取得する
                    	copyToQuoteLineItem.UnitPrice = pbe.UnitPrice;
						//copyToQuoteLineItem.COWO_MC__c = pbe.COWO_MC__c != null ?  pbe.COWO_MC__c : 0;
    					//copyToQuoteLineItem.COWO_TC__c = pbe.COWO_TC__c != null ?  pbe.COWO_TC__c : 0;
    					copyToQuoteLineItem.COWO_LocalCorporationTC__c = pbe.COWO_LocalCorporationTC__c != null ?  pbe.COWO_LocalCorporationTC__c : 0;
    					copyToQuoteLineItem.COWO_FrontPurchasePrice__c = pbe.COWO_FrontPurchasePrice__c != null ?  pbe.COWO_FrontPurchasePrice__c : 0;
    					copyToQuoteLineItem.COWO_MC__c = pro.MC__c != null ?  pro.MC__c : 0;//Todo 一旦仕様確定までは商品から取得する様にする。
    					copyToQuoteLineItem.COWO_TC__c = pro.TC__c != null ?  pro.TC__c : 0;

                        //合計計算
                        Decimal quantity = (Decimal)copyToQuoteLineItem.Quantity;               
                        copyToQuoteLineItem.COWO_TotalMC__c = quantity * copyToQuoteLineItem.COWO_MC__c;
                        copyToQuoteLineItem.COWO_TotalTC__c = quantity * copyToQuoteLineItem.COWO_TC__c;
                        copyToQuoteLineItem.COWO_TotalLocalCorporationTC__c = quantity * copyToQuoteLineItem.COWO_LocalCorporationTC__c;
                        copyToQuoteLineItem.COWO_TotalFrontPurchasePrice__c = quantity * copyToQuoteLineItem.COWO_FrontPurchasePrice__c;
                    }
                }
                
                //編集した内容を見積商品名リストに設定する
                copyToQuoteLineItemList.add(copyToQuoteLineItem);
                
       		}
            
            // Insertした見積と見積帳票明細の紐づけ
            List<COWO_QuoteLineItem__c> copyToCOWO_QuoteLineItemList = new List<COWO_QuoteLineItem__c>();
            for(COWO_QuoteLineItem__c copyFromCOWO_QuoteLineItem:copyFromCOWO_QuoteLineItemList){
            	COWO_QuoteLineItem__c copyToCOWO_QuoteLineItem = copyFromCOWO_QuoteLineItem.clone();
                copyToCOWO_QuoteLineItem.COWO_Quote__c = copyToQuote.Id;
                
                //編集した内容を見積帳票明細リストに設定する
                copyToCOWO_QuoteLineItemList.add(copyToCOWO_QuoteLineItem);
                
       		}
            // 見積製品、見積明細のInsert
            insert copyToQuoteLineItemList;
            insert copyToCOWO_QuoteLineItemList;

			result = copyToQuote.Id;
        } catch(Exception e){
            Database.rollback(sp);
            System.debug(e);
        }
        return result;
    }
    
    /**
     * private  getField
     * 引数に渡されたオブジェクトの項目をカンマ区切りの文字列へ変換する。
     * @param Schema.SObjectType
     * @return String　オブジェクトの項目をカンマ区切りで作成した文字列
     */
    private static String getFieldsNameStr(Schema.SObjectType objType){
        Schema.DescribeSObjectResult sobj = objType.getDescribe();
        Map<String,Schema.SObjectField> sobjFieldsMap = sobj.fields.getMap();
        return String.join(new List<String>(sobjFieldsMap.keySet()), ',');

    }

}