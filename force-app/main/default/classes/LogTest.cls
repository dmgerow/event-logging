@IsTest
private class LogTest {

    @IsTest
    public static void logTestDuration() {
        Test.startTest();
        Log durationLog = new Log();
        durationLog.startDate = System.now();
        durationLog.endDate = durationLog.startDate.addMinutes(1);
        durationLog.emit();
        Test.stopTest();
        System.assertEquals(1,[SELECT count() FROM LogRecording__c]);
    }


    @IsTest
    public static void logExceptionTest() {
        Test.startTest();
        try {
            Integer i;
            i++;
        } catch(Exception e) {
            Log exceptionLog = new Log();
            exceptionLog.setExceptionInfo(e);
            exceptionLog.emit();
        }
        Test.stopTest();
        System.assertEquals(1,[SELECT count() FROM LogRecording__c]);
    }

}