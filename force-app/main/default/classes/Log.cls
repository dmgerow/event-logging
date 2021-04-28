global with sharing class Log {

    // Set by user
    global Datetime startDate {get;set;}
    global Datetime endDate {get;set;}
    global String errorId {get;set;}
    global Id runningUserId {get;set;}

    // Trigger info
    global String triggerContext {get;set;}
    global Integer triggerSize {get;set;}
    global Boolean isTrigger {get;set;}

    // System info
    global Boolean isScheduled {get;set;}
    global Boolean isQueueable {get;set;}
    global Boolean isFuture {get;set;}
    global Boolean isBatch {get;set;}

    // Exception data
    global Integer exceptionLineNumber {get;set;}
    global String exceptionMessage {get;set;}
    global String exceptionStackTrace {get;set;}
    global String exceptionType {get;set;}

    // Specify additional data dynamically. Assumes that the API names match on the event and the
    // log recording object
    global Map<String,Object> additionalParamsByApiName {get;set;}


    global Log() {
        this.additionalParamsByApiName = new Map<String,Object>();
        this.errorId = LogService.createErrorId();
        setContextVariables();
    }

    global String getErrorId() {
        return this.errorId;
    }

    global void setContextVariables() {
        this.runningUserId = UserInfo.getUserId();
        this.isTrigger = Trigger.isExecuting;
        if(this.isTrigger) {
            this.triggerContext = String.valueOf(Trigger.operationType);
            this.triggerSize = Trigger.size;
        }
        this.isScheduled = System.isScheduled();
        this.isQueueable = System.isQueueable();
        this.isFuture = System.isFuture();
        this.isBatch = System.isBatch();
    }

    global void setExceptionInfo(Exception e) {
        this.exceptionLineNumber = e.getLineNumber();
        this.exceptionMessage = e.getMessage().abbreviate(255);
        this.exceptionStackTrace = e.getStackTraceString();
        this.exceptionType = e.getTypeName();
    }

    global Decimal getDuration() {
        if(startDate == null || endDate == null) {
            return null;
        }
        return endDate.getTime() - startDate.getTime();
    }

    global void emit() {
        Database.SaveResult result = Eventbus.publish(createLogEvent());
        System.debug(result);
    }

    global Log__e createLogEvent() {
        Log__e log = new Log__e();
        log.ErrorId__c = this.errorId;
        log.Duration__c = getDuration();
        log.StartDate__c = this.startDate;
        log.EndDate__c = this.endDate;
        log.ExceptionLineNumber__c = this.exceptionLineNumber;
        log.ExceptionMessage__c = this.exceptionMessage != null ? this.exceptionMessage.abbreviate(255) : null;
        log.ExceptionStackTrace__c = this.exceptionStackTrace != null ? this.exceptionStackTrace.abbreviate(255) : null;
        log.ExceptionType__c = this.exceptionType;
        log.IsBatch__c = this.isBatch;
        log.IsFuture__c = this.isFuture;
        log.IsQueueable__c = this.isQueueable;
        log.IsScheduled__c = this.isScheduled;
        log.IsTrigger__c = this.isTrigger;
        log.TriggerContext__c = this.triggerContext;
        log.TriggerSize__c = this.triggerSize;
        log.RunningUserId__c = this.runningUserId;
        for(String apiName : additionalParamsByApiName.keySet()) {
            log.put(apiName,additionalParamsByApiName.get(apiName));
        }
        return log;
    }

}