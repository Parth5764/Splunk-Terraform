const request = require('request');
var assert = require('assert');

var customerId = "{{CustomerId}}";
var baseUrl = "{{SiteBaseUrl}}";
var targetUrl = baseUrl + customerId + "/tokens/clients";
var clientId = {{ClientId}};
var clientSecret = {{ClientSecret}};

{{UtilityScript}}

var options = {
    url: targetUrl,
    hearders: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
    },
    form: { client_id: clientId, client_secret: clientSecret, grant_type: "client_credentials" }
}

function callback(err, response, body) {
    log(1, 'Make POST to:' + targetUrl);
    assert.ok(response.statusCode == 200, 'Expected 200 OK response');
    var info = JSON.parse(body)
    assert.ok(info.access_token != null && info.access_token != '', 'Expected token in the response, result was ' + info.access_token);
    log(2, 'End reached');
}

request.post(options, callback)