/**
 * レコードタイプに関する処理を定義します。<br />
 * レコードタイプの取得、判定を行います。<br />
 *
 * 使用時には必ずインスタンス生成を行ってください。
 */
public without sharing class COM_RecordTypeManager {

    // レコードタイプMap（キー：レコードタイプID, 値：レコードタイプ）
    private Map<Id, RecordType>    recordTypes;
    // レコードタイプMap（キー：SObjectType, （キー：DeveloperName, 値：レコードタイプID））
    private Map<String, Map<String, Id>>    recordTypeIds;

    /**
     * インスタンスを生成します。
     */
    public COM_RecordTypeManager() {
        System.debug( '■[COM_RecordTypeManager]インスタンス生成' );
        recordTypes = null;
        recordTypeIds = null;

        // 全レコードタイプ取得
        getRecordType( null );
    }

    /**
     * 指定のDeveloperNameを持つレコードタイプIdを返します。
     *
     * @param recordTypeName レコードタイプのDeveloperName
     * @return 指定のDeveloperNameを持つレコードタイプId
     */
    public Id getRecordTypeId( String sobjectType, String recordTypeName ) {

        if ( COM_Utility.isEmpty( recordTypeName ) ) {
            return null;
        }

        // 未キャッシュの場合、レコードタイプを取得する
        if ( recordTypeIds == null ) {
            getRecordType( null );
        }
        if ( recordTypeIds != null ) {
            Id resultId = recordTypeIds.get( sobjectType ).get( recordTypeName );
            System.debug( '■[COM_RecordTypeManager]getRecordTypeId【レコードタイプ】' + recordTypeName + ',【レコードタイプID】' + resultId );
            return resultId;
        }

        return null;
    }

    /**
     * 指定のレコードタイプIDが、指定のDeveloperNameかどうかを返します。<br />
     * いずれかの引数がnullの場合はfalseを返却します。
     *
     * @param recordTypeId レコードタイプId
     * @param recordTypeName レコードタイプのDeveloperName
     * @return 指定のDeveloperNameのレコードタイプの場合はtrue、それ以外はfalse
     */
    public Boolean checkRecordType( Id recordTypeId, String sobjectType, String recordTypeName ) {
        Boolean result = false;

        if ( !COM_Utility.isEmpty( recordTypeId ) && !COM_Utility.isEmpty( recordTypeName ) ) {
            // 指定のDeveloperNameのレコードタイプIDを取得し、引数と比較する
            if ( recordTypeId == getRecordTypeId( sobjectType, recordTypeName ) ) {
                result = true;
            }
        }

        System.debug( '■[COM_RecordTypeManager]checkRecordType【レコードタイプID】' + recordTypeId + ',【レコードタイプ】' + recordTypeName + ',【チェック結果】' + result );
        return result;
    }

    /**
     * 指定のレコードタイプIDを持つレコードタイプオブジェクトを返します。<br />
     * 指定のレコードタイプIDがnullの場合でも、<br />
     * すべてのレコードタイプを取得しキャッシュに保持する処理を行います。
     *
     * @param recordTypeId レコードタイプId
     * @return 指定のレコードタイプIdを持つレコードタイプオブジェクト（引数がnullの場合はnullを返却）
     */
    public RecordType getRecordType( Id recordTypeId ) {

        // キャッシュ済みの場合
        if ( recordTypes != null ) {
            if ( recordTypeId != null ) {
                System.debug( '■[COM_RecordTypeManager]getRecordType【レコードタイプ取得済み】レコードタイプID：' + recordTypeId );
                return recordTypes.get( recordTypeId );
            }
        // 未キャッシュの場合
        } else {
            List<RecordType> recordTypeList = [SELECT Id, Name, DeveloperName, SobjectType From RecordType];

            // レコードタイプMap生成（SOQL実行結果が空リスト＝該当のユーザがいない場合も空Map生成）
            recordTypes = new Map<Id, RecordType>();
            recordTypeIds = new Map<String, Map<String, Id>>();
            if ( recordTypeList != null && recordTypeList.size() > 0 ) {
                for ( RecordType recordTypeData : recordTypeList ) {
                    recordTypes.put( recordTypeData.Id, recordTypeData );

                    if ( recordTypeIds.containsKey( recordTypeData.SobjectType ) ) {
                        recordTypeIds.get( recordTypeData.SobjectType ).put( recordTypeData.DeveloperName, recordTypeData.Id );
                    } else {
                        Map<String, Id> tempMap = new Map<String, Id>();
                        tempMap.put( recordTypeData.DeveloperName, recordTypeData.Id );
                        recordTypeIds.put( recordTypeData.SobjectType, tempMap );
                    }
                }
            }

            // 指定のレコードタイプを返す（該当のレコードタイプがなければnull）
            if ( recordTypeId != null ) {
                RecordType result = recordTypes.get( recordTypeId );

                String debugLog;
                if ( result == null ) {
                    debugLog = null;
                } else {
                    debugLog = result.Id;
                }
                System.debug( '■[COM_RecordTypeManager]getRecordType【レコードタイプ取得】レコードタイプID：' + debugLog );

                return result;
            }
        }

        return null;
    }

    /**
     * 保持している情報をクリアします。
     */
    public void clear() {
        recordTypes.clear();
        recordTypeIds.clear();
    }
}