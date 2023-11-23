/*
Synthetics script that emulates admin login using Azure Active Directory 
*/
var username = {{Username}};
var password = {{Password}};
var selectCustomer = "{{Customer}}";
var siteBaseUrl = "{{SiteBaseUrl}}";
var siteUrl = siteBaseUrl + selectCustomer;
var skipCustomerDropdown = ("{{SkipCustomerDropdown}}" == "True");


/** HELPER VARIABLES AND FUNCTIONS **/

{{PrerequisitesScript}}

{{UtilityScript}}

/** BEGINNING OF SCRIPT **/

// Get browser capabilities and do nothing with it, so that we start with a then-able command
$browser.getCapabilities().then(function () { })

    // Step 1
    .then(function () {
        log(1, '$browser.get("' + siteUrl + '")');
        $browser.takeScreenshot();
        return $browser.get(siteUrl);
    })

    // Step 2
    .then(function () {
        log(2, 'setElementText "username"');
        return $browser.waitForAndFindElement(By.name("loginfmt"), defaultTimeout);
    })
    .then(function (el) {
        el.clear();
        el.sendKeys(username);
    })

    // Step 3
    .then(function () {
        log(3, 'clickElement "Next"');
        return $browser.waitForAndFindElement(By.id("idSIButton9"), defaultTimeout);
    })
    .then(function (el) {
        el.click();
    })

    // Step 4
    .then(function () {
        log(4, 'setElementText "password"');
        return $browser.waitForAndFindElement(By.css("input#i0118.form-control"), defaultTimeout);
    })
    .then(function (el) {
        el.clear();
        el.sendKeys(password);
    })

    // Step 5
    .then(function () {
        log(5, 'clickElement "Sign in"');
        return $browser.waitForAndFindElement(By.id("idSIButton9"), defaultTimeout);
    })
    .then(function (el) {
        el.click();
    })

    .then(function () {
        sleep(defaultTimeout)
    })

    // Step 6
    .then(function () {
        log(6, 'clickElement "No"');
        return $browser.waitForAndFindElement(By.id("idBtn_Back"), defaultTimeout);
    })
    .then(function (el) { el.click(); })

    // Step 7
    .then(function () {
        if (!skipCustomerDropdown) {
            log(7, 'clickElement "Customer Dropdown"');
            return $browser.waitForAndFindElement(By.xpath("//span[text()=\'" + selectCustomer + "\']"), defaultTimeout);
        }
    })
    .then(function (el) {
        if (!skipCustomerDropdown) {
            log(7, 'clickElement "Customer Dropdown"');
            el.click();
        }
    })
    .then(function () {
        if (!skipCustomerDropdown) {
            sleep(defaultTimeout)
        }
    })

    // Step 8
    .then(function () {
        log(8, 'waitForAndFindElement "ctx-dashboard"');
        return $browser.waitForAndFindElement(By.className('ctx-dashboard'), defaultTimeout + 10000);
    })
    
    .then(function () {
        log(lastStep, '');
        console.log('Browser script execution SUCCEEDED.');
    }, function (err) {
        console.log('Browser script execution FAILED.');
        throw (err);
    });

/** END OF SCRIPT **/