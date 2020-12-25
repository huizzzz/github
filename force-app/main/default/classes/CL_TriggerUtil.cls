/********************************************************************************
 * クラス名 ： CL_TriggerUtil
 * 概　　要 ： トリガハンドラの汎用クラス
 * 作 成 日 ： 2016/09/15 豊田
 * 更 新 日 ： 2018/11/20 kim
 ********************************************************************************/

public without sharing class CL_TriggerUtil {
    static private String userProfileName;

    //get User profile 
    public Static Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];

    /*
    * HiSASユーザかどうかの判定
    * @return Boolean true:HiSASユーザ false:その他
    */
    public Boolean isHiSASUser(){
        // 実行ユーザのプロファイルを取得
        if( String.isEmpty(userProfileName)){
            Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            userProfileName = p.Name;
        }
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + userProfileName);
        System.debug(LoggingLevel.INFO, '■HiSASプロファイル : ' + System.Label.HISAS_PROFILES);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> hisasProfs = System.Label.HISAS_PROFILES.split(',');
        Boolean bRet = false;
        for(String prof : hisasProfs){
            if( prof == userProfileName)    bRet = true;
        }
        //return System.Label.HISAS_PROFILES.contains(userProfileName);
        return bRet;
    }

    /*
    * HiSASユーザかどうかの判定
    * @return Boolean true:HiSASユーザ false:その他
    */
    public Boolean isHiSASUser(String ProfileName){
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + ProfileName);
        System.debug(LoggingLevel.INFO, '■HiSASプロファイル : ' + System.Label.HISAS_PROFILES);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> hisasProfs = System.Label.HISAS_PROFILES.split(',');
        Boolean bRet = false;
        for(String prof : hisasProfs){
            if( prof == ProfileName)    bRet = true;
        }

        return bRet;
    }

    /*
    * CASユーザかどうかの判定
    * @return Boolean true:HiSASユーザ false:その他
    */
    public Boolean isCasUser(){
        // 実行ユーザのプロファイルを取得
        if( String.isEmpty(userProfileName)){
            Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            userProfileName = p.Name;
        }
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + userProfileName);
        System.debug(LoggingLevel.INFO, '■CASプロファイル : ' + System.Label.CAS_PROFILES);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> casProfs = System.Label.CAS_PROFILES.split(',');
        Boolean bRet = false;
        for(String prof : casProfs){
            if( prof == userProfileName)    bRet = true;
        }
        //return System.Label.HISAS_PROFILES.contains(userProfileName);
        return bRet;
    }

    /*
    * CASユーザかどうかの判定
    * @return Boolean true:HiSASユーザ false:その他
    */
    public Boolean isCasUser(String ProfileName){
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + ProfileName);
        System.debug(LoggingLevel.INFO, '■CASプロファイル : ' + System.Label.CAS_PROFILES);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> casProfs = System.Label.CAS_PROFILES.split(',');
        Boolean bRet = false;
        for(String prof : casProfs){
            if( prof == ProfileName)    bRet = true;
        }

        return bRet;
    }

    //★2017/2/2 垣野追加
    /*
    * 医用・アジアユーザかどうかの判定
    * @return Boolean true:医用・アジアユーザ false:その他
    */
    public Boolean isAsiaUser(){
        // 実行ユーザのプロファイルを取得
        if( String.isEmpty(userProfileName)){
            Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            userProfileName = p.Name;
        }
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + userProfileName);
        System.debug(LoggingLevel.INFO, '■医用・アジアプロファイル : ' + System.Label.Asia_PROFILES);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> AsiaProfs = System.Label.Asia_PROFILES.split(',');
        Boolean bRet = false;
        for(String prof : AsiaProfs){
            if( prof == userProfileName)    bRet = true;
        }
        //return System.Label.Asia_PROFILE.contains(userProfileName);
        return bRet;
    }

    /*
    * 医用・アジアユーザかどうかの判定
    * @return Boolean true:医用・アジアユーザ false:その他
    */
    public Boolean isAsiaUser(String ProfileName){
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + ProfileName);
        System.debug(LoggingLevel.INFO, '■医用・アジアプロファイル : ' + System.Label.Asia_PROFILES);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> AsiaProfs = System.Label.Asia_PROFILES.split(',');
        Boolean bRet = false;
        for(String prof : AsiaProfs){
            if( prof == ProfileName)    bRet = true;
        }

        return bRet;
    }

    //★2017/2/2 垣野追加
    //20170615addKakino
    /*
    * 実績連携ユーザかどうかの判定
    * @return Boolean true:実績連携を行うプロファイル false:その他
    */
    public Boolean isBatchUser(){
        // 実行ユーザのプロファイルを取得
        if( String.isEmpty(userProfileName)){
            Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            userProfileName = p.Name;
        }
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + userProfileName);
        System.debug(LoggingLevel.INFO, '■実績連携プロファイル : ' + System.Label.BATCH_PROFILES);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> batProfs = System.Label.BATCH_PROFILES.split(',');
        Boolean bRet = false;
        for(String prof : batProfs){
            if( prof == userProfileName)    bRet = true;
        }
        //return System.Label.Asia_PROFILE.contains(userProfileName);
        return bRet;
    }

    /*
    * 実績連携ユーザかどうかの判定
    * @return Boolean true:実績連携を行うプロファイル false:その他
    */
    public Boolean isBatchUser(String ProfileName){
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + ProfileName);
        System.debug(LoggingLevel.INFO, '■実績連携プロファイル : ' + System.Label.BATCH_PROFILES);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> batProfs = System.Label.BATCH_PROFILES.split(',');
        Boolean bRet = false;
        for(String prof : batProfs){
            if( prof == ProfileName)    bRet = true;
        }

        return bRet;
    }

    /*
    * HHSユーザかどうかの判定
    * @return Boolean true:HHSユーザ false:その他
    */
    public Boolean isHHSUser(){
        // 実行ユーザのプロファイルを取得
        if( String.isEmpty(userProfileName)){
            Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            userProfileName = p.Name;
        }
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + userProfileName);
        System.debug(LoggingLevel.INFO, '■HiSASプロファイル : ' + System.Label.HISAS_PROFILES_HHS);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> hhsProfs = System.Label.HISAS_PROFILES_HHS.split(',');
        Boolean bRet = false;
        for(String prof : hhsProfs){
            if( prof == userProfileName)    bRet = true;
        }
        //return System.Label.HISAS_PROFILES.contains(userProfileName);
        return bRet;
    }

    /*
    * HHSユーザかどうかの判定
    * @return Boolean true:HHSユーザ false:その他
    */
    public Boolean isHHSUser(String ProfileName){
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + ProfileName);
        System.debug(LoggingLevel.INFO, '■HiSASプロファイル : ' + System.Label.HISAS_PROFILES_HHS);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> hhsProfs = System.Label.HISAS_PROFILES_HHS.split(',');
        Boolean bRet = false;
        for(String prof : hhsProfs){
            if( prof == ProfileName)    bRet = true;
        }

        return bRet;
    }
    
    /*
    * HSLユーザかどうかの判定
    * @return Boolean true:HSLユーザ false:その他
    */
    public Boolean isHSLUser(){
        // 実行ユーザのプロファイルを取得
        if( String.isEmpty(userProfileName)){
            Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            userProfileName = p.Name;
        }
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + userProfileName);
        System.debug(LoggingLevel.INFO, '■HSLプロファイル : ' + System.Label.HISAS_PROFILES_HSL);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> hslProfs = System.Label.HISAS_PROFILES_HSL.split(',');
        Boolean bRet = false;
        for(String prof : hslProfs){
            if( prof == userProfileName)    bRet = true;
        }
        //return System.Label.HISAS_PROFILES.contains(userProfileName);
        return bRet;
    }

    /*
    * HSLユーザかどうかの判定
    * @return Boolean true:HSLユーザ false:その他
    */
    public Boolean isHSLUser(String ProfileName){
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + ProfileName);
        System.debug(LoggingLevel.INFO, '■HSLプロファイル : ' + System.Label.HISAS_PROFILES_HSL);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> hslProfs = System.Label.HISAS_PROFILES_HSL.split(',');
        Boolean bRet = false;
        for(String prof : hslProfs){
            if( prof == ProfileName)    bRet = true;
        }

        return bRet;
    }

    /*
    * add 2018/11/20 kim
    * HSS、HHS代理店、HHTユーザかどうかの判定
    * @return Boolean true:HSS、HHS代理店、HHTユーザ false:その他
    */
    public Boolean isHSSHHTUser(){
        // 実行ユーザのプロファイルを取得
        if( String.isEmpty(userProfileName)){
            Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            userProfileName = p.Name;
        }
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + userProfileName);
        System.debug(LoggingLevel.INFO, '■HSLプロファイル : ' + System.Label.HISAS_PROFILES_HHS_HHT);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> hslProfs = System.Label.HISAS_PROFILES_HHS_HHT.split(',');
        Boolean bRet = false;
        for(String prof : hslProfs){
            if( prof == userProfileName)    bRet = true;
        }
        //return System.Label.HISAS_PROFILES.contains(userProfileName);
        return bRet;
    }

    /*
    * HSS、HHS代理店、HHTユーザかどうかの判定
    * @return Boolean true:HSS、HHS代理店、HHTユーザ false:その他
    */
    public Boolean isHSSHHTUser(String ProfileName){
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + ProfileName);
        System.debug(LoggingLevel.INFO, '■HSLプロファイル : ' + System.Label.HISAS_PROFILES_HHS_HHT);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> hslProfs = System.Label.HISAS_PROFILES_HHS_HHT.split(',');
        Boolean bRet = false;
        for(String prof : hslProfs){
            if( prof == ProfileName)    bRet = true;
        }

        return bRet;
    }
    
    /*
    * add 2019/05/23 kim
    * HSS、HHS代理店、JTLユーザかどうかの判定
    * @return Boolean true:JTLユーザ false:その他
    */
    public Boolean isJTLUser(){
        // 実行ユーザのプロファイルを取得
        if( String.isEmpty(userProfileName)){
            Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            userProfileName = p.Name;
        }
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + userProfileName);
        System.debug(LoggingLevel.INFO, '■JTLプロファイル : ' + System.Label.JTL_PROFILES);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> jtlProfs = System.Label.JTL_PROFILES.split(',');
        Boolean bRet = false;
        for(String prof : jtlProfs){
            if( prof == userProfileName)    bRet = true;
        }
        //return System.Label.HISAS_PROFILES.contains(userProfileName);
        return bRet;
    }

    /*
    * HSS、HHS代理店、JTLユーザかどうかの判定
    * @return Boolean true:JTLユーザ false:その他
    */
    public Boolean isJTLUser(String ProfileName){
        System.debug(LoggingLevel.INFO, '■ユーザプロファイル名 : ' + ProfileName);
        System.debug(LoggingLevel.INFO, '■JTLプロファイル : ' + System.Label.JTL_PROFILES);

        // カスタム表示ラベルにユーザプロファイルが含まれているか
        List<String> jtlProfs = System.Label.JTL_PROFILES.split(',');
        Boolean bRet = false;
        for(String prof : jtlProfs){
            if( prof == ProfileName)    bRet = true;
        }

        return bRet;
    }
}