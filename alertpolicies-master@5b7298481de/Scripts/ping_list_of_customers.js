/*
Synthetics script that calls ping Api 
*/
var assert = require('assert');

var siteBaseUrl = "{{SiteBaseUrl}}";
var customers = {{Customers}};

/** BEGINNING OF SCRIPT **/

for (var i = 0; i < customers.length; i++) {
    var options = {
        url: siteBaseUrl + customers[i] + "/ping"
    };

    $http.get(options, function (err, response, body) {
        assert.equal(response.statusCode, 200, `Expected a 200 response`);
    });
}

/** END OF SCRIPT **/