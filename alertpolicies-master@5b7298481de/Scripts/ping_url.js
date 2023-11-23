/*
Synthetics script that checks API for its readiness and status.
*/
var assert = require('assert');

var siteBaseUrl = "{{SiteBaseUrl}}";

/** BEGINNING OF SCRIPT **/

var options = {
    url: siteBaseUrl,
    headers: {
        'Accept': 'application/json'
    }
};
$http.get(options, function (err, response, body) {
    assert.equal(response.statusCode, 200, `Expected a 200 response`);
});


/** END OF SCRIPT **/
