global without sharing class LogService {

    public static void recordErrors(List<Log__e> logEvents) {
        List<LogRecording__c> logRecordings = new List<LogRecording__c>();
        Map<String, Schema.SObjectField> logEventFieldsByName = Schema.SObjectType.Log__e.fields.getMap();
        Map<String, Schema.SObjectField> logRecordingFieldsByName = Schema.SObjectType.LogRecording__c.fields.getMap();
        for(Log__e logEvent : logEvents) {
            LogRecording__c logRecording = new LogRecording__c();
            logRecording.RunningUser__c = logEvent.RunningUserId__c;
            for(String fieldName : logEventFieldsByName.keySet()) {
                if(logRecordingFieldsByName.containsKey(fieldName)
                        && logRecordingFieldsByName.get(fieldName).getDescribe().isUpdateable()) {
                    logRecording.put(fieldName,logEvent.get(fieldName));
                }
            }
            logRecordings.add(logRecording);
        }
        insert logRecordings;
    }

    public static String createErrorId() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }

}