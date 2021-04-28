trigger LogTrigger on Log__e (after insert) {
    LogService.recordErrors((List<Log__e>)trigger.new);
}