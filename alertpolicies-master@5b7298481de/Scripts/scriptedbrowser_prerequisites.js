// Reusable must-have code (only for ScriptBrowser type)

//setting User Agent ahead of time since it is not then - able
var userAgent = "default";

if (userAgent && (0 !== userAgent.trim().length) && (userAgent != 'default')) {
    $browser.addHeader('User-Agent', userAgent);
    console.log('Setting User-Agent to ' + userAgent);
}

//setting necessary variables
var assert = require('assert'),
    defaultTimeout = 100000,
    By = $driver.By,
    browser = $browser.manage(),
    VARS = {};
