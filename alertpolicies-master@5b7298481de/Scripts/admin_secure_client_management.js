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

var thisStep = 1;

/** HELPER VARIABLES AND FUNCTIONS **/

{{PrerequisitesScript}}

{{UtilityScript}}

{{AdminTotpLoginScript}}

/** BEGINNING OF SCRIPT **/

// Login
adminTotpLogin(totpLoginUrl, totpUsername, totpPassword, totpUrl)
.then (() => {
    //open api access tab
    $browser.wait(() => {
        log(thisStep++, 'open "dropdown"');
        return $browser.findElement(By.className("ctx-icon icon icon-menu icon-small"))
        .then(el => { el.click(); })
        .then(() => {
            log(thisStep++, 'open "identity and access management"');
            return $browser.findElement(By.xpath("//span[.='Identity and Access Management']"))
        })
        .then(el => { el.click(); })
        .then(() => {
            log(thisStep++, 'open "api access"');
            return $browser.findElement(By.xpath("//span[.='API Access']"))
        })
        .then(el => { el.click(); })
        .then(() => {
            return $browser.findElement(By.xpath("//input[contains(@class, 'ctx-secure-clients-form-client-name')]"))
        })
        .then(() => {
            return true;
        })
        .catch(err => {
            console.log("tab navigation fails, retrying...");
            return false;
        })
    })
})

//clear any clients created in error
.then(() => {
    log(thisStep++, 'checking for redudant clients: ');
    return $browser.findElements(By.xpath("//ctx-static-grid[@class = 'ctx-secure-clients-table table']/ctx-static-grid-cell/div/*/div"));
})
.then(async el => {
    for (i = 0; i < el.length; i++) {
        log(thisStep++, 'delete "extra test client"');
        el[i].click();
        el = await $browser.waitForAndFindElement(By.xpath("//ctx-button[@class= 'ctx-modal-content-buttons-button primary']"), defaultTimeout);
        el.click();
    }
})

//create secure client
.then(() => {
    log(thisStep++, 'enter "secure client name"');
    return $browser.findElement(By.xpath("//input[contains(@class, 'ctx-secure-clients-form-client-name')]")).sendKeys("Test-client");
})
.then(() => {
    log(thisStep++, 'click element "Create client"');
    return $browser.waitForAndFindElement(By.xpath("//ctx-button[contains(@class, 'ctx-secure-clients-form-submit')]"));
})
.then(el => { 
    el.click();
    return $browser.wait(() => {
        return $browser.findElement(By.xpath("//ctx-button[contains(@class, 'ctx-modal-content-buttons-button secondary')]"))
        .then(() => {
            return true;
        })
        .catch(err => {
            console.log("trying to click create client again");
            el.click();
            return false;
        })
    });
})
.then(() => {
    log(thisStep++, 'close "confirmation modal"');
    return $browser.waitForAndFindElement(By.xpath("//ctx-button[contains(@class, 'ctx-modal-content-buttons-button secondary')]"), defaultTimeout);
})
.then(el => { el.click(); })
//delete secure client
.then(() => {
    log(thisStep++, 'delete "test client"');
    return $browser.waitForAndFindElement(By.xpath("//ctx-static-grid[@class = 'ctx-secure-clients-table table']/ctx-static-grid-cell/div/*/div"), defaultTimeout);
})
.then(el => {
    el.click();
    return $browser.wait(() => {
        return $browser.findElement(By.xpath("//ctx-button[contains(@class, 'ctx-modal-content-buttons-button primary')]"))
        .then(() => {
            return true;
        })
        .catch(err => {
            console.log("trying to click delete client again");
            el.click();
            return false;
        })
    });
})
.then(() => {
    log(thisStep++, 'confirm delete "test client"');
    return $browser.waitForAndFindElement(By.xpath("//ctx-button[contains(@class, 'ctx-modal-content-buttons-button primary')]"), defaultTimeout);
})
.then(el => { el.click(); })
.then(() => {
    log(lastStep, '');
    console.log('Browser script execution SUCCEEDED.');
}, err => {
    if (err instanceof TotpLoginError) {
        console.log('Browser script execution BYPASSED due to persistent totp login errors. Error:' + err);     
    } else {
        console.log('Browser script execution FAILED.');
        throw (err);
    }
});