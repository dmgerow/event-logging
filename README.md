# Event Logger

Salesforce Logging framework powered by Platform Events

## Installation

1. Ensure my domain is enabled (this is needed for any lightning components to render!)
2. Navigate to the latest release for a package installation link: [latest release](https://github.com/dmgerow/sfdc-event-logging/releases/latest)
3. Install for admins only
4. Assign the Event Logger Permission Set to your team

## Generating Unique Error Ids

You can get a unique error ID with the following code. Use this when sending exceptions to the end user so that they can tell you what log to look for:

```java
Log exceptionLog = new Log();
String errorId = exceptionLog.getErrorId();
```

## Example Trigger Implementation

```java
public void run() {
    Log exceptionLog = new Log();
    exceptionLog.startDate = System.now();
    try{

    } catch(Exception e) {
        System.debug(e);
        String errorId = exceptionLog.getErrorId();
        exceptionLog.setExceptionInfo(e);
        exceptionLog.endDate = System.now();
        exceptionLog.emit();
        List<SObject> records = trigger.operationType == TriggerOperation.BEFORE_DELETE
            || trigger.operationType == TriggerOperation.AFTER_DELETE ? trigger.old : trigger.new;
        for(SObject record : records) {
            record.addError(errorId + ': ' + e.getMessage());
        }
    }
}
```

## Add additional data to events and log records

1. Create a new custom field for the data you want to track on both the **Log**e event and the **LogRecording**c object with the same API name and data type
2. Add that data to the Log object during event creation
3. The application will automatically map data with the same API name on the event to the log recording for you

In the below scenario, AnInDepthDescription\_\_c would be a text (255) field on both the Log Event and the Log Recording Object:

```java
Log exceptionLog = new Log();
exceptionLog.additionalParamsByApiName.put('AnInDepthDescription__c','not sure why it broke but it did');
exceptionLog.emit();
```

## Time multiple things

```java
List<__Log__e> times = new List<__Log__e>();
String transactionId = LogService.createErrorId();
datetime startTime = datetime.now();
// do important things
Log durationLog = new Log();
durationLog.startDate = System.now();
durationLog.endDate = durationLog.startDate.addMinutes(1);
times.add(durationLog.createLogEvent());

//time more things and add them
EventBus.publish(times);

```

## Time one thing

```java
Log durationLog = new Log();
durationLog.startDate = System.now();
durationLog.endDate = durationLog.startDate.addMinutes(1);
durationLog.emit();
```

## Technical Setup Notes

To assign yourself the EventLogger Permission Set

`sfdx force:user:permset:assign -n EventLogger`
