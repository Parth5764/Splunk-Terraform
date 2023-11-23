/*
Synthetics script that calls Releases HealthCheck API for multiple customers 
*/
var assert = require('assert');

var siteBaseUrl = "{{SiteBaseUrl}}";
var customers = {{Customers}};
var apiKey = {{ApiKey}};

/** BEGINNING OF SCRIPT **/

for(var i = 0; i < customers.length; i++) {
    var options = {
        url: siteBaseUrl+customers[i]+"/health",
        headers: {
          'X-Cws-Authentication-Key': apiKey
        }
    };

    $http.get(options, function (err, response, body){
        assert.equal(response.statusCode, 200, `Expected a 200 response`);
    });
}

/** END OF SCRIPT **/