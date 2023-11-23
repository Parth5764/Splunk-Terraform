//Reusable functions


//Setting necessary variables for following functions
var scriptTimeout = 0,
    startTime = Date.now(),
    stepStartTime = Date.now(),
    prevMsg = '',
    prevStep = 0,
    lastStep = 9999;

//Log the starting and finishing time of specific step.
function log(thisStep, thisMsg) {
    if (thisStep > 1 || thisStep == lastStep) {
        var totalTimeElapsed = Date.now() - startTime;
        var prevStepTimeElapsed = totalTimeElapsed - stepStartTime;
        console.log('Step ' + prevStep + ': ' + prevMsg + ' FINISHED. It took ' + prevStepTimeElapsed + 'ms to complete.');
        $util.insights.set('Step ' + prevStep + ': ' + prevMsg, prevStepTimeElapsed);
        if (scriptTimeout > 0 && totalTimeElapsed > scriptTimeout) {
            throw new Error('Script timed out. ' + totalTimeElapsed + 'ms is longer than script timeout threshold of ' + scriptTimeout + 'ms.');
        }
    }
    if (thisStep > 0 && thisStep != lastStep) {
        stepStartTime = Date.now() - startTime;
        console.log('Step ' + thisStep + ': ' + thisMsg + ' STARTED at ' + stepStartTime + 'ms.');
        prevMsg = thisMsg;
        prevStep = thisStep;
    }
};

//Stop the watch for specific miliseconds
function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds) {
            break;
        }
    }
}
