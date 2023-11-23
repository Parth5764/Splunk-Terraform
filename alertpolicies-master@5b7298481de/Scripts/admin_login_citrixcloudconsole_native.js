/*
Synthetics script to emulate admin login through CC Console native
*/
var totpLoginUrl = "{{SiteUrl}}";
var totpUsername = {{Username}};
var totpPassword = {{Password}};
var totp = {{Totp}};
var codeGenerator = $secure.ATHENA_TOTP_FUNCTION_CODE;
var totpUrl = `https://twostepsauthenticator.azurewebsites.net/api/CodeGenerator?code=${codeGenerator}&secret=${totp}`;

var urllib = require('urllib');

/** HELPER VARIABLES AND FUNCTIONS **/

{{PrerequisitesScript}}

{{UtilityScript}}

{{AdminTotpLoginScript}}

adminTotpLogin(totpLoginUrl, totpUsername, totpPassword, totpUrl)

.then(function () {
    log(lastStep, '');
    console.log('Browser script execution SUCCEEDED.');
}, function (err) {
    console.log('Browser script execution FAILED.');
    throw (err);
});
